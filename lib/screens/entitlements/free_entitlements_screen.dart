import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/free_entitlements_model.dart';
import '../../providers/app_state_provider.dart';

class FreeEntitlementsScreen extends StatefulWidget {
  const FreeEntitlementsScreen({super.key});

  @override
  State<FreeEntitlementsScreen> createState() => _FreeEntitlementsScreenState();
}

class _FreeEntitlementsScreenState extends State<FreeEntitlementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_stories, color: Colors.indigo, size: 26),
            SizedBox(width: 10),
            Text(
              'समग्र शिक्षा - मोफत पाठ्यपुस्तके व गणवेश वाटप नोंदवही',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'मोफत पाठ्यपुस्तक वाटप नोंदवही'),
            Tab(icon: Icon(Icons.checkroom), text: 'मोफत गणवेश वाटप नोंदवही'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextbooksTab(context, state),
          _buildUniformsTab(context, state),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: मोफत पाठ्यपुस्तक वाटप नोंदवही
  // ==========================================
  Widget _buildTextbooksTab(BuildContext context, AppStateProvider state) {
    final currentStudents = state.filteredStudents;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.book, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'इयत्ता ${state.selectedStd} वी (${state.selectedDiv}) - मोफत पाठ्यपुस्तक नोंदवही',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('सर्वांना वाटप नोंद'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          for (var s in currentStudents) {
                            final rec = TextbookDistributionRecord(
                              id: 'tb_${s.id}',
                              studentId: s.id,
                              studentName: s.studentNameMr,
                              standard: s.standard,
                              division: s.division,
                              grNo: s.grNo,
                              setsReceivedCount: 1,
                              distributionDate: DateTime.now(),
                              isDistributed: true,
                              hasSignature: true,
                              remark: 'सर्व विषयांचे संच मिळाले',
                            );
                            await state.saveTextbookDistribution(rec);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('इयत्तेतील सर्व विद्यार्थ्यांची वाटप नोंद अद्ययावत केली!')),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text('प्रिंट करा'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _printTextbookRegister(state),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: currentStudents.isEmpty
                    ? const Center(child: Text('या वर्गात अद्याप विद्यार्थी नाहीत.'))
                    : ListView.separated(
                        itemCount: currentStudents.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final stu = currentStudents[index];
                          final rec = state.textbookDistributions.firstWhere(
                            (t) => t.studentId == stu.id,
                            orElse: () => TextbookDistributionRecord(
                              id: 'tb_${stu.id}',
                              studentId: stu.id,
                              studentName: stu.studentNameMr,
                              standard: stu.standard,
                              division: stu.division,
                              grNo: stu.grNo,
                              setsReceivedCount: 1,
                              distributionDate: DateTime.now(),
                              isDistributed: true,
                              hasSignature: true,
                              remark: 'सर्व विषयांचे संच मिळाले',
                            ),
                          );

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: Text(
                              stu.studentNameMr,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('हजेरी क्र.: ${stu.getRollNo(state.selectedSemester)} | जी.आर. क्र.: ${stu.grNo} | संच: ${rec.setsReceivedCount} | वाटप दिनांक: ${DateFormat('dd-MM-yyyy').format(rec.distributionDate)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(
                                    rec.isDistributed ? 'वाटप पूर्ण ✓' : 'शिल्लक',
                                    style: TextStyle(
                                      color: rec.isDistributed ? Colors.green.shade900 : Colors.red.shade900,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: rec.isDistributed ? Colors.green.shade100 : Colors.red.shade100,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                                  tooltip: 'तपशील बदला',
                                  onPressed: () => _showEditTextbookDialog(context, state, stu, rec),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTextbookDialog(
      BuildContext context, AppStateProvider state, dynamic stu, TextbookDistributionRecord rec) {
    bool isDist = rec.isDistributed;
    final remarkCtrl = TextEditingController(text: rec.remark);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('${stu.studentNameMr} - पाठ्यपुस्तक नोंद'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('पाठ्यपुस्तके संच प्राप्त झाला का?'),
                value: isDist,
                onChanged: (val) => setDialogState(() => isDist = val ?? true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarkCtrl,
                decoration: const InputDecoration(labelText: 'शेरा', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
            ElevatedButton(
              onPressed: () async {
                final updated = TextbookDistributionRecord(
                  id: rec.id,
                  studentId: stu.id,
                  studentName: stu.studentNameMr,
                  standard: stu.standard,
                  division: stu.division,
                  grNo: stu.grNo,
                  setsReceivedCount: 1,
                  distributionDate: rec.distributionDate,
                  isDistributed: isDist,
                  hasSignature: isDist,
                  remark: remarkCtrl.text,
                );
                await state.saveTextbookDistribution(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('जतन करा'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: मोफत गणवेश वाटप नोंदवही
  // ==========================================
  Widget _buildUniformsTab(BuildContext context, AppStateProvider state) {
    final currentStudents = state.filteredStudents;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.checkroom, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'इयत्ता ${state.selectedStd} वी (${state.selectedDiv}) - मोफत गणवेश नोंदवही (२ जोडी)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('गणवेश रजिस्टर प्रिंट'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _printUniformRegister(state),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: currentStudents.isEmpty
                    ? const Center(child: Text('या वर्गात अद्याप विद्यार्थी नाहीत.'))
                    : ListView.separated(
                        itemCount: currentStudents.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final stu = currentStudents[index];
                          final isGirl = stu.gender == 'स्त्री' || stu.gender == 'मुली';
                          final isEligible = isGirl ||
                              stu.casteCategory == 'SC' ||
                              stu.casteCategory == 'ST' ||
                              stu.casteCategory == 'VJNT';

                          final rec = state.uniformDistributions.firstWhere(
                            (u) => u.studentId == stu.id,
                            orElse: () => UniformDistributionRecord(
                              id: 'uni_${stu.id}',
                              studentId: stu.id,
                              studentName: stu.studentNameMr,
                              standard: stu.standard,
                              division: stu.division,
                              grNo: stu.grNo,
                              gender: stu.gender,
                              category: stu.casteCategory,
                              isEligible: isEligible,
                              set1Given: true,
                              set2Given: true,
                              set1Date: DateTime(2025, 7, 5),
                              set2Date: DateTime(2025, 9, 10),
                              mode: 'थेट गणवेश वाटप',
                              remark: '२ जोडी गणवेश वाटप पूर्ण',
                            ),
                          );

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade50,
                              child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: Row(
                              children: [
                                Text(stu.studentNameMr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${stu.gender} | ${stu.casteCategory}', style: const TextStyle(fontSize: 10)),
                                ),
                              ],
                            ),
                            subtitle: Text('हजेरी क्र.: ${stu.getRollNo(state.selectedSemester)} | जी.आर.: ${stu.grNo} | जोडी १: ${rec.set1Given ? "वाटप ✓" : "शिल्लक"} | जोडी २: ${rec.set2Given ? "वाटप ✓" : "शिल्लक"} | पद्धत: ${rec.mode}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: rec.isEligible ? Colors.teal.shade50 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: rec.isEligible ? Colors.teal : Colors.grey),
                              ),
                              child: Text(
                                rec.isEligible ? 'पात्र लाभार्थी' : 'अपात्र',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: rec.isEligible ? Colors.teal.shade900 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printTextbookRegister(AppStateProvider state) async {
    final pdf = pw.Document();
    final school = state.school;
    final currentStudents = state.filteredStudents;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('महाराष्ट्र शासन - समग्र शिक्षा अभियान',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('मोफत पाठ्यपुस्तके वाटप नोंदवही (Free Textbooks Register)',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${school.schoolName} | U-DISE: ${school.udiseCode}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('इयत्ता: ${state.selectedStd} वी, तुकडी: ${state.selectedDiv} | शैक्षणिक वर्ष: ${state.currentYear.yearName}',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Divider(thickness: 1),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('अ.क्र.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('जी.आर. क्र.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('विद्यार्थ्याचे पूर्ण नाव', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('प्राप्त संच', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('वाटप दिनांक', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('विद्यार्थी स्वाक्षरी / अंगठा', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...currentStudents.asMap().entries.map((e) {
                    final idx = e.key + 1;
                    final s = e.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('$idx')),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(s.grNo)),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(s.studentNameMr)),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('१ संच')),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('१७-०६-२०२५')),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('स्वाक्षरी प्राप्त ✓')),
                      ],
                    );
                  }),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('वर्गशिक्षक स्वाक्षरी', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('मुख्याध्यापक स्वाक्षरी व शिक्का', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Textbook_Register_Std_${state.selectedStd}.pdf',
    );
  }

  Future<void> _printUniformRegister(AppStateProvider state) async {
    final pdf = pw.Document();
    final school = state.school;
    final currentStudents = state.filteredStudents;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('महाराष्ट्र शासन - समग्र शिक्षा अभियान',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('मोफत गणवेश वाटप नोंदवही (Free Uniform Register - २ जोडी)',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${school.schoolName} | U-DISE: ${school.udiseCode}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('इयत्ता: ${state.selectedStd} वी, तुकडी: ${state.selectedDiv} | शैक्षणिक वर्ष: ${state.currentYear.yearName}',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Divider(thickness: 1),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('अ.क्र.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('विद्यार्थ्याचे नाव', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('लिंग / प्रवर्ग', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('पात्रता', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('जोडी १ वाटप', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('जोडी २ वाटप', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('पालक स्वाक्षरी', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...currentStudents.asMap().entries.map((e) {
                    final idx = e.key + 1;
                    final s = e.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('$idx')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(s.studentNameMr)),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${s.gender} / ${s.casteCategory}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('पात्र')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('०५-०७-२०२५ ✓')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('१०-०९-२०२५ ✓')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('स्वाक्षरी ✓')),
                      ],
                    );
                  }),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('वर्गशिक्षक स्वाक्षरी', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('मुख्याध्यापक स्वाक्षरी व शिक्का', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Uniform_Register_Std_${state.selectedStd}.pdf',
    );
  }
}
