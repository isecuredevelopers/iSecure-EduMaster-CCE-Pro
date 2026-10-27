import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/school_logo_widget.dart';

class ResultGazetteScreen extends StatelessWidget {
  const ResultGazetteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.filteredStudents;
    final subjects = state.currentStdSubjects;
    final school = state.school;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'वार्षिक निकाल पत्रक (Annual Result Gazette): इ. ${state.selectedStd} तुकडी ${state.selectedDiv}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () => _printGazette(context, state),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('निकाल पत्रक प्रिंट करा (Print Gazette)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          )
        ],
      ),
      body: students.isEmpty
          ? const Center(child: Text('या वर्गात विद्यार्थी नाहीत.'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SchoolLogoWidget(
                            logoUrl: school.logoUrl,
                            size: 46,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(school.sansthaName, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                school.schoolName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'वार्षिक सर्वकष निकाल पत्रक • शैक्षणिक वर्ष: ${state.currentYear.yearName} • इयत्ता: ${state.selectedStd} (${state.selectedDiv})',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(width: 46),
                        ],
                      ),
                      const Divider(height: 24),

                      // Result Grid
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                                columnSpacing: 14,
                                dataRowHeight: 46,
                                columns: [
                                  const DataColumn(label: Text('हजेरी क्र.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                  const DataColumn(label: Text('दाखला क्र.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                  const DataColumn(label: Text('विद्यार्थ्याचे नाव', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                  const DataColumn(label: Text('जन्मतारीख', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                  // Subject Grade Columns
                                  ...subjects.map((sub) => DataColumn(
                                        label: Text(
                                          sub.shortName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      )),
                                  const DataColumn(label: Text('एकूण गुण\n(Total)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                  const DataColumn(label: Text('टक्के\n(%)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                  const DataColumn(label: Text('एकूण श्रेणी\n(Grade)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                  const DataColumn(label: Text('वार्षिक निकाल\n(Result)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                ],
                                rows: students.map((stu) {
                                  final rollNo = stu.getRollNo(state.selectedSemester);
                                  final dobStr = DateFormat('dd/MM/yy').format(stu.dateOfBirth);

                                  double totalSum = 0;
                                  int count = 0;
                                  List<DataCell> subjectCells = [];

                                  for (var sub in subjects) {
                                    final eval = state.getOrCreateEvaluation(stu.id, state.selectedSemester, sub.subjectCode);
                                    totalSum += eval.tet;
                                    count++;
                                    subjectCells.add(DataCell(
                                      Center(
                                        child: Text(
                                          eval.grade,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppColors.getGradeColor(eval.grade),
                                          ),
                                        ),
                                      ),
                                    ));
                                  }

                                  final maxPossible = count * 100;
                                  final pct = maxPossible > 0 ? (totalSum / maxPossible) * 100 : 0.0;
                                  final overallGrade = pct >= 91 ? 'अ-1' : (pct >= 81 ? 'अ-2' : (pct >= 71 ? 'ब-1' : (pct >= 61 ? 'ब-2' : (pct >= 51 ? 'क-1' : (pct >= 41 ? 'क-2' : 'ड')))));

                                  return DataRow(
                                    cells: [
                                      DataCell(Center(child: Text('$rollNo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                                      DataCell(Text(stu.grNo, style: const TextStyle(fontSize: 11))),
                                      DataCell(
                                        SizedBox(
                                          width: 170,
                                          child: Text(stu.studentNameMr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                        ),
                                      ),
                                      DataCell(Text(dobStr, style: const TextStyle(fontSize: 11))),
                                      ...subjectCells,
                                      DataCell(Center(child: Text(totalSum.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                                      DataCell(Center(child: Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                                      DataCell(
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.getGradeColor(overallGrade).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              overallGrade,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.getGradeColor(overallGrade)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            pct >= 33 ? 'उत्तीर्ण (पात्र)' : 'प्रयत्नांची गरज',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: pct >= 33 ? AppColors.gradeA1 : AppColors.gradeD,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _printGazette(BuildContext context, AppStateProvider state) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text(state.school.schoolName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))),
              pw.Center(child: pw.Text('Consolidated Result Gazette - Academic Year: ${state.currentYear.yearName} (Class: Std ${state.selectedStd}-${state.selectedDiv})')),
              pw.SizedBox(height: 15),
              pw.Text('Total Students: ${state.filteredStudents.length}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Result_Gazette_Std_${state.selectedStd}',
    );
  }
}
