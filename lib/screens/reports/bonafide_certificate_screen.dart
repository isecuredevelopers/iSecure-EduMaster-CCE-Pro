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

class BonafideCertificateScreen extends StatefulWidget {
  const BonafideCertificateScreen({super.key});

  @override
  State<BonafideCertificateScreen> createState() => _BonafideCertificateScreenState();
}

class _BonafideCertificateScreenState extends State<BonafideCertificateScreen> {
  String? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.filteredStudents;
    final school = state.school;

    if (_selectedStudentId == null && students.isNotEmpty) {
      _selectedStudentId = students.first.id;
    }

    final student = students.firstWhere(
      (s) => s.id == _selectedStudentId,
      orElse: () => students.isNotEmpty ? students.first : SampleData.defaultStudents.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('बोनाफाईड प्रमाणपत्र (Bonafide Certificate)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () => _printBonafide(context, state, student),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('प्रमाणपत्र प्रिंट करा (Print Certificate)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          )
        ],
      ),
      body: students.isEmpty
          ? const Center(child: Text('विद्यार्थी आढळले नाहीत.'))
          : Row(
              children: [
                // Student selector list
                Container(
                  width: 280,
                  color: Colors.white,
                  child: ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final stu = students[idx];
                      final isSelected = stu.id == student.id;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withOpacity(0.08),
                        title: Text(stu.studentNameMr, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                        subtitle: Text('GR: ${stu.grNo}', style: const TextStyle(fontSize: 11)),
                        onTap: () => setState(() => _selectedStudentId = stu.id),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1),

                // Printable Certificate Canvas
                Expanded(
                  child: Center(
                    child: Container(
                      width: 650,
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD97706), width: 3),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Seal / Logo
                          SchoolLogoWidget(
                            logoUrl: school.logoUrl,
                            size: 56,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(height: 8),
                          Text(school.sansthaName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            school.schoolName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          Text('${school.address} • U-DISE: ${school.udiseCode}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD97706)),
                            ),
                            child: const Text(
                              'बोनाफाईड प्रमाणपत्र (BONAFIDE CERTIFICATE)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Certificate Body Text
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 2),
                                children: [
                                  const TextSpan(text: 'दाखला देण्यात येतो की, कुमार / कुमारी '),
                                  TextSpan(text: student.studentNameMr, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                  const TextSpan(text: ' हा / ही आमच्या शाळेचा / शाळेची सन '),
                                  TextSpan(text: state.currentYear.yearName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: ' या शैक्षणिक वर्षात इयत्ता '),
                                  TextSpan(text: '${student.standard} तुकडी ${student.division}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: ' मध्ये नियमित शिकत असलेला / असलेली विद्यार्थी / विद्यार्थिनी आहे.\n'),
                                  const TextSpan(text: 'शाळेच्या जनरल रजिस्टर (GR No.) प्रमाणे त्याचा / तिचा दाखल क्रमांक '),
                                  TextSpan(text: student.grNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: ' असा असून जन्मदिनांक '),
                                  TextSpan(text: DateFormat('dd/MM/yyyy').format(student.dateOfBirth), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: ' आहे. तसेच जात प्रवर्ग '),
                                  TextSpan(text: student.casteCategory, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: ' आहे.\nसदर प्रमाणपत्र विद्यार्थ्याच्या विनंतीवरून शैक्षणिक कारणास्तव देण्यात येत आहे.'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Footer Dates and Headmaster Sign
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('दिनांक: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  const Text('स्थळ: अकोले', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(width: 140, height: 1, color: Colors.black45),
                                  const SizedBox(height: 6),
                                  Text(
                                    'मुख्याध्यापक स्वाक्षरी व शिक्का\n${school.schoolName}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _printBonafide(BuildContext context, AppStateProvider state, StudentModel student) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              children: [
                pw.Center(child: pw.Text(state.school.sansthaName, style: const pw.TextStyle(fontSize: 13))),
                pw.Center(child: pw.Text(state.school.schoolName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Text('BONAFIDE CERTIFICATE', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 30),
                pw.Text('This is to certify that ${student.studentNameMr} is a bonafide student of this school studying in Standard ${student.standard} Division ${student.division} during the academic year ${state.currentYear.yearName}.'),
                pw.SizedBox(height: 10),
                pw.Text('General Register No: ${student.grNo} | Date of Birth: ${DateFormat('dd/MM/yyyy').format(student.dateOfBirth)}'),
                pw.SizedBox(height: 60),
                pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Headmaster Signature & Seal')),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bonafide_${student.grNo}',
    );
  }
}
