import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../data/models/student_model.dart';
import '../../data/local/sample_data.dart';
import '../../widgets/school_logo_widget.dart';

class ProgressCardScreen extends StatefulWidget {
  const ProgressCardScreen({super.key});

  @override
  State<ProgressCardScreen> createState() => _ProgressCardScreenState();
}

class _ProgressCardScreenState extends State<ProgressCardScreen> {
  String? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.filteredStudents;
    final school = state.school;
    final subjects = state.currentStdSubjects;

    if (_selectedStudentId == null && students.isNotEmpty) {
      _selectedStudentId = students.first.id;
    }

    final student = students.firstWhere(
      (s) => s.id == _selectedStudentId,
      orElse: () => students.isNotEmpty ? students.first : SampleData.defaultStudents.first,
    );

    final note = students.isNotEmpty
        ? state.getOrCreateDescriptiveNote(student.id, state.selectedSemester)
        : null;
    final att = students.isNotEmpty ? state.getOrCreateAttendance(student.id) : null;
    final wd = state.workingDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'प्रगती पुस्तक (Student Progress Report): इ. ${state.selectedStd} तुकडी ${state.selectedDiv}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () => _printReportCard(context, state, student),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('प्रगती पुस्तक प्रिंट करा (Print PDF)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          )
        ],
      ),
      body: students.isEmpty
          ? const Center(child: Text('या वर्गात विद्यार्थी नाहीत.'))
          : Row(
              children: [
                // Left Panel: Student Selector
                Container(
                  width: 280,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFFF1F5F9),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('विद्यार्थी निवडा (${students.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: students.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final stu = students[idx];
                            final isSelected = stu.id == student.id;
                            final rollNo = stu.getRollNo(state.selectedSemester);

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: AppColors.primary.withOpacity(0.08),
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                                child: Text(
                                  '$rollNo',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                stu.studentNameMr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontSize: 12,
                                ),
                              ),
                              subtitle: Text('GR: ${stu.grNo}', style: const TextStyle(fontSize: 10)),
                              onTap: () {
                                setState(() {
                                  _selectedStudentId = stu.id;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),

                // Right Panel: The Authentic Progress Card Preview
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Container(
                        width: 800,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Banner
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SchoolLogoWidget(
                                        logoUrl: school.logoUrl,
                                        size: 54,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              school.sansthaName,
                                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              school.schoolName,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${school.address} • U-DISE: ${school.udiseCode} • माध्यम: ${school.medium}',
                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 54),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'सातत्यपूर्ण सर्वकष मूल्यमापन - प्रगती पुस्तक (${state.currentYear.yearName})',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Student Info Strip
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: _buildInfoItem('विद्यार्थ्याचे नाव', student.studentNameMr, isBold: true)),
                                      Expanded(child: _buildInfoItem('हजेरी क्र.', '${student.getRollNo(state.selectedSemester)}', isBold: true)),
                                      Expanded(child: _buildInfoItem('दाखला क्र. (GR No.)', student.grNo, isBold: true)),
                                      Expanded(child: _buildInfoItem('इयत्ता व तुकडी', 'इ. ${student.standard} तुकडी ${student.division}', isBold: true)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(child: _buildInfoItem('आईचे नाव', student.motherName)),
                                      Expanded(child: _buildInfoItem('वडिलांचे नाव', student.fatherName)),
                                      Expanded(child: _buildInfoItem('जन्मतारीख', DateFormat('dd/MM/yyyy').format(student.dateOfBirth))),
                                      Expanded(child: _buildInfoItem('जात प्रवर्ग', student.casteCategory)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Table Level 1 Section Banner
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                border: Border(
                                  top: BorderSide(color: AppColors.border),
                                  left: BorderSide(color: AppColors.border),
                                  right: BorderSide(color: AppColors.border),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 25,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'विषय (Subjects)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, height: 32, color: AppColors.border),
                                  Expanded(
                                    flex: 48,
                                    child: Container(
                                      color: AppColors.primary.withOpacity(0.08),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: const Text(
                                        'प्रथम सत्र (सत्र १)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, height: 32, color: AppColors.border),
                                  Expanded(
                                    flex: 48,
                                    child: Container(
                                      color: AppColors.teal.withOpacity(0.08),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: const Text(
                                        'द्वितीय सत्र (सत्र २)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.teal),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Evaluation Marks Table (Strictly 9 cells per TableRow)
                            Table(
                              border: TableBorder.all(color: AppColors.border, width: 1),
                              columnWidths: const {
                                0: FlexColumnWidth(2.5), // Subject
                                1: FlexColumnWidth(1.2), // Sem 1 Formative
                                2: FlexColumnWidth(1.2), // Sem 1 Summative
                                3: FlexColumnWidth(1.2), // Sem 1 Total
                                4: FlexColumnWidth(1.2), // Sem 1 Grade
                                5: FlexColumnWidth(1.2), // Sem 2 Formative
                                6: FlexColumnWidth(1.2), // Sem 2 Summative
                                7: FlexColumnWidth(1.2), // Sem 2 Total
                                8: FlexColumnWidth(1.2), // Sem 2 Grade
                              },
                              children: [
                                // Table Sub-header Level 2 (Strictly 9 cells)
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                  children: [
                                    _buildTableHeaderSubCell('विषयाचे नाव'),
                                    _buildTableHeaderSubCell('आकारिक'),
                                    _buildTableHeaderSubCell('संकलित'),
                                    _buildTableHeaderSubCell('एकूण'),
                                    _buildTableHeaderSubCell('श्रेणी'),
                                    _buildTableHeaderSubCell('आकारिक'),
                                    _buildTableHeaderSubCell('संकलित'),
                                    _buildTableHeaderSubCell('एकूण'),
                                    _buildTableHeaderSubCell('श्रेणी'),
                                  ],
                                ),
                                // Subject Rows
                                ...subjects.map((sub) {
                                  final eval1 = state.getOrCreateEvaluation(student.id, 1, sub.subjectCode);
                                  final eval2 = state.getOrCreateEvaluation(student.id, 2, sub.subjectCode);

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        child: Text(sub.shortName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                      ),
                                      _buildTableCell(eval1.fet > 0 ? eval1.fet.toStringAsFixed(0) : '-'),
                                      _buildTableCell(eval1.set > 0 ? eval1.set.toStringAsFixed(0) : '-'),
                                      _buildTableCell(eval1.tet > 0 ? eval1.tet.toStringAsFixed(0) : '-', isBold: true),
                                      _buildGradeCell(eval1.grade),
                                      _buildTableCell(eval2.fet > 0 ? eval2.fet.toStringAsFixed(0) : '-'),
                                      _buildTableCell(eval2.set > 0 ? eval2.set.toStringAsFixed(0) : '-'),
                                      _buildTableCell(eval2.tet > 0 ? eval2.tet.toStringAsFixed(0) : '-', isBold: true),
                                      _buildGradeCell(eval2.grade),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Descriptive Remarks Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'वर्णनात्मक नोंदी (Descriptive Remarks):',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildRemarkBullet('विशेष प्रगती', note?.s10.isNotEmpty == true ? note!.s10 : 'शालेय शिस्त आत्मसात करतो. चित्रकलेत विशेष प्रगती.'),
                                  _buildRemarkBullet('आवड / छंद', note?.s11.isNotEmpty == true ? note!.s11 : 'चित्रे काढणे. खेळात सहभागी होणे.'),
                                  _buildRemarkBullet('सुधारणा आवश्यक', note?.s12.isNotEmpty == true ? note!.s12 : 'इंग्रजी शब्दसंपत्ती वाढवावी. वाचन लेखनाकडे लक्ष द्यावे.'),
                                  _buildRemarkBullet('व्यक्तिमत्त्व गुणविशेष', note?.s13.isNotEmpty == true ? note!.s13 : 'नेहमी हसतमुख असतो. शिक्षकांचा आदर करतो.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Attendance & Physical Attributes
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildMiniStat('सत्र १ उपस्थिती', '${att?.sem1Total ?? 92} / 99 दिवस'),
                                        _buildMiniStat('सत्र २ उपस्थिती', '${att?.sem2Total ?? 124} / 133 दिवस'),
                                        _buildMiniStat('वार्षिक हजेरी', '${att?.grandTotal ?? 216} / ${wd.grandTotal} (${((att?.grandTotal ?? 216) / wd.grandTotal * 100).toStringAsFixed(0)}%)'),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildMiniStat('उंची', '${student.heightSem1 ?? 115} सेमी'),
                                        _buildMiniStat('वजन', '${student.weightSem1 ?? 19.5} किग्रॅ'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Result Statement Banner
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.gradeA1.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.gradeA1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.gradeA1, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'वार्षिक निकाल: वरच्या वर्गात जाण्यास पात्र (Promoted to Next Standard)',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.gradeA2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.currentYear.reopeningMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 36),

                            // Signature Placeholders
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSignatureBox('वर्गशिक्षक स्वाक्षरी\n(Class Teacher)'),
                                _buildSignatureBox('पालक स्वाक्षरी\n(Parents Sign)'),
                                _buildSignatureBox('मुख्याध्यापक स्वाक्षरी व शिक्का\n(Headmaster Seal)'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTableHeaderSubCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget _buildGradeCell(String grade) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.getGradeColor(grade).withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            grade,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.getGradeColor(grade),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemarkBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildSignatureBox(String label) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 1,
          color: Colors.black26,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Future<void> _printReportCard(BuildContext context, AppStateProvider state, StudentModel student) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(state.school.schoolName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(
                  child: pw.Text('UDISE: ${state.school.udiseCode} | Progress Report: ${state.currentYear.yearName}'),
                ),
                pw.SizedBox(height: 15),
                pw.Text('Student: ${student.studentNameMr} (Roll No: ${student.rollNoSem1}, GR: ${student.grNo})'),
                pw.Text('Class: Standard ${student.standard} Division ${student.division}'),
                pw.SizedBox(height: 15),
                pw.Text('Result: Promoted to next standard', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text(state.currentYear.reopeningMessage),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Progress_Card_${student.grNo}',
    );
  }
}
