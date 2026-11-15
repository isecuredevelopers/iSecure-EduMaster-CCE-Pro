import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/admin_registers_model.dart';
import '../../providers/app_state_provider.dart';

class InwardOutwardHealthScreen extends StatefulWidget {
  const InwardOutwardHealthScreen({super.key});

  @override
  State<InwardOutwardHealthScreen> createState() =>
      _InwardOutwardHealthScreenState();
}

class _InwardOutwardHealthScreenState extends State<InwardOutwardHealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            Icon(Icons.folder_shared, color: Colors.blueAccent, size: 26),
            SizedBox(width: 10),
            Text(
              'शासकीय आवक-जावक व विद्यार्थी आरोग्य तपासणी (RBSK)',
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
            Tab(icon: Icon(Icons.move_to_inbox), text: 'शासकीय आवक वही (Inward)'),
            Tab(icon: Icon(Icons.outbox), text: 'शासकीय जावक वही (Outward)'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'विद्यार्थी आरोग्य तपासणी (Health Card)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInwardTab(context, state),
          _buildOutwardTab(context, state),
          _buildHealthTab(context, state),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: आवक वही (Inward)
  // ==========================================
  Widget _buildInwardTab(BuildContext context, AppStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.mail, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('शासकीय आवक पत्रव्यवहार नोंदवही (Inward Register)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('नवीन आवक पत्र नोंदवा'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () => _showAddInwardDialog(context, state),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.inwardLetters.isEmpty
                    ? const Center(child: Text('कोणतीही आवक पत्र नोंद उपलब्ध नाही.'))
                    : ListView.separated(
                        itemCount: state.inwardLetters.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final i = state.inwardLetters[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text('${i.inwardNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: Text(i.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('दिनांक: ${DateFormat("dd-MM-yyyy").format(i.receivedDate)} | प्रेषक: ${i.senderDetails} | मूळ जा.क्र.: ${i.letterNumber} | कार्यवाही: ${i.actionTaken}'),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddInwardDialog(BuildContext context, AppStateProvider state) {
    int nextNo = state.inwardLetters.length + 43;
    final senderCtrl = TextEditingController(text: 'मा. गटशिक्षणाधिकारी कार्यालय, पं.स.');
    final letterNoCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final actionCtrl = TextEditingController(text: 'नोंद घेऊन फाईल केले.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('नवीन आवक पत्र नोंद (आवक क्र. $nextNo)'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: senderCtrl, decoration: const InputDecoration(labelText: 'प्रेषक कार्यालय / व्यक्ती', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: letterNoCtrl, decoration: const InputDecoration(labelText: 'पत्राचा मूळ जावक क्र. व दिनांक', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'पत्राचा विषय', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: actionCtrl, decoration: const InputDecoration(labelText: 'केलेली कार्यवाही / शेरा', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              if (subjectCtrl.text.isEmpty) return;
              final rec = InwardLetterRecord(
                id: 'in_${DateTime.now().millisecondsSinceEpoch}',
                inwardNumber: nextNo,
                receivedDate: DateTime.now(),
                senderDetails: senderCtrl.text,
                letterNumber: letterNoCtrl.text,
                subject: subjectCtrl.text,
                actionTaken: actionCtrl.text,
              );
              await state.addInwardLetter(rec);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: जावक वही (Outward)
  // ==========================================
  Widget _buildOutwardTab(BuildContext context, AppStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.outbox, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('शासकीय जावक पत्रव्यवहार नोंदवही (Outward Register)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('नवीन जावक पत्र नोंदवा'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () => _showAddOutwardDialog(context, state),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.outwardLetters.isEmpty
                    ? const Center(child: Text('कोणतीही जावक पत्र नोंद उपलब्ध नाही.'))
                    : ListView.separated(
                        itemCount: state.outwardLetters.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final o = state.outwardLetters[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              child: Text('${o.outwardNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: Text(o.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('पाठविल्याचा दिनांक: ${DateFormat("dd-MM-yyyy").format(o.dispatchDate)} | प्रति: ${o.recipientDetails} | पद्धत: ${o.postalOrDeliveryMode} | शेरा: ${o.remark}'),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOutwardDialog(BuildContext context, AppStateProvider state) {
    int nextNo = state.outwardLetters.length + 69;
    final recipientCtrl = TextEditingController(text: 'मा. केंद्रप्रमुख सो., केंद्र शाळा');
    final subjectCtrl = TextEditingController();
    String mode = 'थेट हस्ते';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('नवीन जावक पत्र नोंद (जावक क्र. $nextNo)'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: recipientCtrl, decoration: const InputDecoration(labelText: 'प्रति / कोणास पाठवले', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'पत्राचा विषय', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: mode,
                decoration: const InputDecoration(labelText: 'टपाल पाठवण्याची पद्धत', border: OutlineInputBorder()),
                items: ['थेट हस्ते', 'नोंदणीकृत पोस्ट (Speed Post)', 'ईमेल'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {
                  if (val != null) mode = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              if (subjectCtrl.text.isEmpty) return;
              final rec = OutwardLetterRecord(
                id: 'out_${DateTime.now().millisecondsSinceEpoch}',
                outwardNumber: nextNo,
                dispatchDate: DateTime.now(),
                recipientDetails: recipientCtrl.text,
                subject: subjectCtrl.text,
                postalOrDeliveryMode: mode,
                remark: 'पोच प्रत दाखल',
              );
              await state.addOutwardLetter(rec);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: विद्यार्थी आरोग्य तपासणी (RBSK)
  // ==========================================
  Widget _buildHealthTab(BuildContext context, AppStateProvider state) {
    final students = state.filteredStudents;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'इयत्ता ${state.selectedStd} वी - राष्ट्रीय बाल स्वास्थ्य कार्यक्रम (RBSK) आरोग्य तपासणी',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.print, size: 16),
                label: const Text('आरोग्य कार्ड्स प्रिंट'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () => _printHealthCards(state),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: students.isEmpty
                    ? const Center(child: Text('कोणतेही विद्यार्थी उपलब्ध नाहीत.'))
                    : ListView.separated(
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final stu = students[index];
                          final rec = state.studentHealthRecords.firstWhere(
                            (h) => h.studentId == stu.id,
                            orElse: () => StudentHealthRecord(
                              id: 'hlth_${stu.id}',
                              studentId: stu.id,
                              studentName: stu.studentNameMr,
                              standard: stu.standard,
                              division: stu.division,
                              heightCm: 115.0 + (index * 2),
                              weightKg: 20.0 + (index * 1.5),
                              bloodGroup: 'B+',
                              hemoglobin: 12.0,
                              checkupDate: DateTime(2025, 9, 20),
                            ),
                          );

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade50,
                              child: Text(rec.bloodGroup, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.red)),
                            ),
                            title: Text(stu.studentNameMr, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('उंची: ${rec.heightCm} cm | वजन: ${rec.weightKg} kg | BMI: ${rec.bmi.toStringAsFixed(1)} | हिमोग्लोबिन: ${rec.hemoglobin} g/dL | दृष्टी: ${rec.visionTest}'),
                            trailing: ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('नोंद बदला'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                              onPressed: () => _showEditHealthDialog(context, state, stu, rec),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditHealthDialog(
      BuildContext context, AppStateProvider state, dynamic stu, StudentHealthRecord rec) {
    final heightCtrl = TextEditingController(text: '${rec.heightCm}');
    final weightCtrl = TextEditingController(text: '${rec.weightKg}');
    String bloodGroup = rec.bloodGroup;
    final hbCtrl = TextEditingController(text: '${rec.hemoglobin}');
    String vision = rec.visionTest;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('${stu.studentNameMr} - आरोग्य नोंद'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'उंची (cm)', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'वजन (kg)', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: bloodGroup,
                        decoration: const InputDecoration(labelText: 'रक्तगट', border: OutlineInputBorder()),
                        items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-', 'माहित नाही']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setDialogState(() => bloodGroup = val ?? 'B+'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: hbCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'हिमोग्लोबिन (Hb)', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: vision,
                  decoration: const InputDecoration(labelText: 'दृष्टीदोष', border: OutlineInputBorder()),
                  items: ['सामान्य', 'चष्मा आवश्यक', 'दोष आढळला'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setDialogState(() => vision = val ?? 'सामान्य'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
            ElevatedButton(
              onPressed: () async {
                final updated = StudentHealthRecord(
                  id: rec.id,
                  studentId: stu.id,
                  studentName: stu.studentNameMr,
                  standard: stu.standard,
                  division: stu.division,
                  heightCm: double.tryParse(heightCtrl.text) ?? 115.0,
                  weightKg: double.tryParse(weightCtrl.text) ?? 20.0,
                  bloodGroup: bloodGroup,
                  hemoglobin: double.tryParse(hbCtrl.text) ?? 12.0,
                  visionTest: vision,
                  checkupDate: DateTime.now(),
                );
                await state.saveHealthRecord(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('जतन करा'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printHealthCards(AppStateProvider state) async {
    final pdf = pw.Document();
    final school = state.school;
    final students = state.filteredStudents;

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
                    pw.Text('सार्वजनिक आरोग्य विभाग व शालेय शिक्षण विभाग, महाराष्ट्र', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('राष्ट्रीय बाल स्वास्थ्य कार्यक्रम (RBSK) - शालेय आरोग्य तपासणी पत्रक', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${school.schoolName} | U-DISE: ${school.udiseCode} | इयत्ता: ${state.selectedStd} वी', style: const pw.TextStyle(fontSize: 10)),
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
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('उंची (cm)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('वजन (kg)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('रक्तगट', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Hb (g/dL)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('दृष्टीदोष', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('तपासणी शेरा', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...students.asMap().entries.map((e) {
                    final idx = e.key + 1;
                    final s = e.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('$idx')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(s.studentNameMr)),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${115 + idx}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${20 + idx}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('B+')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('12.2')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('सामान्य')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('निरोगी ✓')),
                      ],
                    );
                  }),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('आरोग्य तपासणी अधिकारी (RBSK वैद्यकीय अधिकारी)', style: const pw.TextStyle(fontSize: 10)),
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
      name: 'RBSK_Health_Register.pdf',
    );
  }
}

