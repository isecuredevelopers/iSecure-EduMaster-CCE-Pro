import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/teacher_service_model.dart';
import '../../providers/app_state_provider.dart';

class TeacherServiceScreen extends StatefulWidget {
  const TeacherServiceScreen({super.key});

  @override
  State<TeacherServiceScreen> createState() => _TeacherServiceScreenState();
}

class _TeacherServiceScreenState extends State<TeacherServiceScreen>
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
            Icon(Icons.badge, color: Colors.blueAccent, size: 26),
            SizedBox(width: 10),
            Text(
              'शिक्षक रजा खातावणी व हालचाल नोंदवही (Staff Service Register)',
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
            Tab(icon: Icon(Icons.event_note), text: 'किरकोळ रजा खातावणी (CL Balance)'),
            Tab(icon: Icon(Icons.departure_board), text: 'शिक्षक हालचाल नोंदवही (Movement)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeavesTab(context, state),
          _buildMovementTab(context, state),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: किरकोळ रजा खातावणी (CL Tracker)
  // ==========================================
  Widget _buildLeavesTab(BuildContext context, AppStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Action Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_history, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('शिक्षक किरकोळ व इतर रजा नोंदवही', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('रजा नोंदवा'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    onPressed: () => _showAddLeaveDialog(context, state),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('रजा खातावणी प्रिंट'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () => _printLeaveRegister(state),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Teachers Summary Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.users.where((u) => u.isActive).map((u) {
                final taken = state.teacherLeaves.where((l) => l.teacherName.contains(u.name) && l.leaveType.contains('CL')).fold(0, (sum, l) => sum + l.totalDays);
                const int totalCl = 12;
                final int balance = (totalCl - taken).clamp(0, totalCl);

                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(u.roleTextMr, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildMiniBadge('एकूण CL', '$totalCl', Colors.blue)),
                          Expanded(child: _buildMiniBadge('उपभोगली', '$taken', Colors.red)),
                          Expanded(child: _buildMiniBadge('शिल्लक CL', '$balance', Colors.green)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Leaves History List
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.teacherLeaves.isEmpty
                    ? const Center(child: Text('अद्याप कोणतीही रजा नोंदवलेली नाही.'))
                    : ListView.separated(
                        itemCount: state.teacherLeaves.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final l = state.teacherLeaves[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            title: Row(
                              children: [
                                Text(l.teacherName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                                  child: Text(l.leaveType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
                                ),
                              ],
                            ),
                            subtitle: Text('कालावधी: ${DateFormat("dd/MM/yyyy").format(l.fromDate)} ते ${DateFormat("dd/MM/yyyy").format(l.toDate)} (${l.totalDays} दिवस) | कारण: ${l.reason}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                              child: Text('मंजूर ✓', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildMiniBadge(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        Text(val, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _showAddLeaveDialog(BuildContext context, AppStateProvider state) {
    String teacherName = state.users.first.name;
    String leaveType = 'किरकोळ रजा (CL)';
    final daysCtrl = TextEditingController(text: '1');
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('नवीन रजा नोंद'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: teacherName,
                decoration: const InputDecoration(labelText: 'शिक्षक नाव', border: OutlineInputBorder()),
                items: state.users.map((u) => DropdownMenuItem(value: u.name, child: Text(u.name))).toList(),
                onChanged: (val) {
                  if (val != null) teacherName = val;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: leaveType,
                decoration: const InputDecoration(labelText: 'रजेचा प्रकार', border: OutlineInputBorder()),
                items: ['किरकोळ रजा (CL)', 'अर्जित रजा (EL)', 'वैद्यकीय रजा (ML)', 'विशेष रजा']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) leaveType = val;
                },
              ),
              const SizedBox(height: 10),
              TextField(controller: daysCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'एकूण दिवस', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'रजेचे कारण', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              final rec = TeacherLeaveRecord(
                id: 'tl_${DateTime.now().millisecondsSinceEpoch}',
                teacherId: 'usr',
                teacherName: teacherName,
                leaveType: leaveType,
                fromDate: DateTime.now(),
                toDate: DateTime.now(),
                totalDays: int.tryParse(daysCtrl.text) ?? 1,
                reason: reasonCtrl.text,
                status: 'मंजूर',
                appliedDate: DateTime.now(),
              );
              await state.addTeacherLeave(rec);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: शिक्षक हालचाल नोंदवही (Movement)
  // ==========================================
  Widget _buildMovementTab(BuildContext context, AppStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.departure_board, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('शिक्षक हालचाल नोंदवही (Movement)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text('हालचाल नोंद करा'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () => _showAddMovementDialog(context, state),
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
                child: state.movementRecords.isEmpty
                    ? const Center(child: Text('कोणतीही हालचाल नोंद उपलब्ध नाही.'))
                    : ListView.separated(
                        itemCount: state.movementRecords.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final m = state.movementRecords[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade50,
                              child: const Icon(Icons.directions_bus, color: Colors.teal),
                            ),
                            title: Row(
                              children: [
                                Text(m.teacherName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                  child: Text('${DateFormat("dd-MM-yyyy").format(m.date)} (${m.departureTime} ते ${m.returnTime})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                ),
                              ],
                            ),
                            subtitle: Text('ठिकाण: ${m.destination} | उद्देश: ${m.purpose} | मंजुरी: ${m.approvedBy}'),
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

  void _showAddMovementDialog(BuildContext context, AppStateProvider state) {
    String teacherName = state.users.first.name;
    final depCtrl = TextEditingController(text: '११:३० AM');
    final retCtrl = TextEditingController(text: '०३:३० PM');
    final destCtrl = TextEditingController(text: 'गट साधन केंद्र (BRC कार्यालय, पंचायत समिती)');
    final purposeCtrl = TextEditingController(text: 'शासकीय बैठक / U-DISE+ कामकाज');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('शासकीय कामासाठी हालचाल नोंद'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: teacherName,
                decoration: const InputDecoration(labelText: 'शिक्षक नाव', border: OutlineInputBorder()),
                items: state.users.map((u) => DropdownMenuItem(value: u.name, child: Text(u.name))).toList(),
                onChanged: (val) {
                  if (val != null) teacherName = val;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: depCtrl, decoration: const InputDecoration(labelText: 'निघण्याची वेळ', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: retCtrl, decoration: const InputDecoration(labelText: 'परत आल्याची वेळ', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: destCtrl, decoration: const InputDecoration(labelText: 'भेट दिलेले ठिकाण', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'कामाचे स्वरूप / उद्देश', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              final rec = MovementRegisterRecord(
                id: 'mov_${DateTime.now().millisecondsSinceEpoch}',
                teacherName: teacherName,
                date: DateTime.now(),
                departureTime: depCtrl.text,
                returnTime: retCtrl.text,
                destination: destCtrl.text,
                purpose: purposeCtrl.text,
                approvedBy: 'मुख्याध्यापक',
              );
              await state.addMovementRecord(rec);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('नोंद करा'),
          ),
        ],
      ),
    );
  }

  Future<void> _printLeaveRegister(AppStateProvider state) async {
    final pdf = pw.Document();
    final school = state.school;

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
                    pw.Text('महाराष्ट्र शासन - जिल्हा परिषद शिक्षण विभाग', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('शिक्षक किरकोळ रजा खातावणी नोंदवही', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${school.schoolName} | U-DISE: ${school.udiseCode}', style: const pw.TextStyle(fontSize: 10)),
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
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('शिक्षक नाव', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('रजा प्रकार', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('कालावधी', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('दिवस', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('कारण', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('मंजुरी शेरा', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...state.teacherLeaves.map((l) => pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l.teacherName)),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l.leaveType)),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(DateFormat('dd-MM-yyyy').format(l.fromDate))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${l.totalDays}')),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l.reason)),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('मंजूर ✓')),
                        ],
                      )),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('शिक्षक स्वाक्षरी', style: const pw.TextStyle(fontSize: 10)),
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
      name: 'Teacher_Leave_Register.pdf',
    );
  }
}
