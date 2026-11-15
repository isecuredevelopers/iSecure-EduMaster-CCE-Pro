import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';

class StudentIdCardsScreen extends StatefulWidget {
  const StudentIdCardsScreen({super.key});

  @override
  State<StudentIdCardsScreen> createState() => _StudentIdCardsScreenState();
}

class _StudentIdCardsScreenState extends State<StudentIdCardsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.filteredStudents;
    final school = state.school;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.badge, color: Colors.blueAccent, size: 26),
            SizedBox(width: 10),
            Text(
              'विद्यार्थी डिजिटल ओळखपत्र जनरेटर (Student ID Cards)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top action bar
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.print, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          'इयत्ता ${state.selectedStd} वी (तुकडी ${state.selectedDiv}) - एकूण विद्यार्थी: ${students.length}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('ओळखपत्रे प्रिंट करा (A4 Sheet)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => _printAllIdCards(state),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ID Cards Grid Preview
            Expanded(
              child: students.isEmpty
                  ? const Center(child: Text('या वर्गात अद्याप विद्यार्थी नाहीत.'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.55,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final s = students[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Column(
                              children: [
                                // ID Card Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  color: const Color(0xFF1E3A8A),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.school, size: 14, color: Color(0xFF1E3A8A)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              school.schoolName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                            ),
                                            Text(
                                              'U-DISE: ${school.udiseCode} | ता. ${school.blockTaluka}, जि. ${school.district}',
                                              style: const TextStyle(color: Colors.white70, fontSize: 8.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ID Card Body
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        // Photo placeholder
                                        Container(
                                          width: 65,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: const Icon(Icons.person, size: 48, color: Colors.blueGrey),
                                        ),
                                        const SizedBox(width: 10),
                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                s.studentNameMr,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                                              ),
                                              Text(
                                                s.studentNameEn,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 10.5, color: Colors.black54),
                                              ),
                                              Row(
                                                children: [
                                                  Text('इयत्ता: ${s.standard} (${s.division})', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                                                  const SizedBox(width: 8),
                                                  Text('हजेरी क्र.: ${s.getRollNo(state.selectedSemester)}', style: const TextStyle(fontSize: 10.5)),
                                                ],
                                              ),
                                              Text('जी.आर. क्र.: ${s.grNo} | जन्म: ${DateFormat("dd/MM/yyyy").format(s.dateOfBirth)}', style: const TextStyle(fontSize: 10)),
                                              Text('पालक: ${s.fatherName} | मो.: ${s.mobileNo.isNotEmpty ? s.mobileNo : school.contactPhone}',
                                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ID Card Footer
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  color: Colors.amber.shade100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('शैक्षणिक वर्ष: २०२५-२६', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.brown)),
                                      Text('मुख्याध्यापक: ${school.headmasterName}', style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.brown)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printAllIdCards(AppStateProvider state) async {
    final pdf = pw.Document();
    final school = state.school;
    final students = state.filteredStudents;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return pw.Column(
            children: [
              pw.Center(
                child: pw.Text('विद्यार्थी ओळखपत्रे - ${school.schoolName} (इयत्ता ${state.selectedStd} वी)',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 12),
              pw.Wrap(
                spacing: 12,
                runSpacing: 12,
                children: students.take(8).map((s) {
                  return pw.Container(
                    width: 250,
                    height: 155,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blue900, width: 1.5),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      children: [
                        // Header
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          color: PdfColors.blue900,
                          child: pw.Center(
                            child: pw.Column(
                              children: [
                                pw.Text(school.schoolName, style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                                pw.Text('U-DISE: ${school.udiseCode} | ता. ${school.blockTaluka}', style: const pw.TextStyle(color: PdfColors.white, fontSize: 6.5)),
                              ],
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 50,
                                height: 60,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.grey),
                                  color: PdfColors.grey100,
                                ),
                                child: pw.Center(child: pw.Text('फोटो', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600))),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(s.studentNameMr, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                                    pw.Text(s.studentNameEn, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                                    pw.Text('इयत्ता: ${s.standard} (${s.division}) | हजेरी: ${s.getRollNo(state.selectedSemester)}', style: const pw.TextStyle(fontSize: 7.5)),
                                    pw.Text('जी.आर. क्र.: ${s.grNo}', style: const pw.TextStyle(fontSize: 7.5)),
                                    pw.Text('जन्मदिनांक: ${DateFormat("dd/MM/yyyy").format(s.dateOfBirth)}', style: const pw.TextStyle(fontSize: 7.5)),
                                    pw.Text('मोबाईल: ${s.mobileNo.isNotEmpty ? s.mobileNo : school.contactPhone}', style: const pw.TextStyle(fontSize: 7)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Spacer(),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: PdfColors.amber100,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('शैक्षणिक वर्ष: २०२५-२६', style: const pw.TextStyle(fontSize: 6.5)),
                              pw.Text('मुख्याध्यापक स्वाक्षरी', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Student_ID_Cards_Std_${state.selectedStd}.pdf',
    );
  }
}
