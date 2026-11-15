import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/smc_model.dart';
import '../../providers/app_state_provider.dart';

class SmcManagementScreen extends StatefulWidget {
  const SmcManagementScreen({super.key});

  @override
  State<SmcManagementScreen> createState() => _SmcManagementScreenState();
}

class _SmcManagementScreenState extends State<SmcManagementScreen>
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
            Icon(Icons.groups, color: Colors.deepPurple, size: 26),
            SizedBox(width: 10),
            Text(
              'शाळा व्यवस्थापन समिती (SMC) व ठराव नोंदवही',
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
            Tab(icon: Icon(Icons.badge), text: 'SMC कार्यकारिणी सदस्य यादी'),
            Tab(icon: Icon(Icons.history_edu), text: 'मासिक सभा व ठराव वही (Resolutions)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(context, state),
          _buildMeetingsTab(context, state),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: SMC कार्यकारिणी सदस्य यादी
  // ==========================================
  Widget _buildMembersTab(BuildContext context, AppStateProvider state) {
    final totalMembers = state.smcMembers.length;
    final womenCount = state.smcMembers.where((m) => m.gender == 'महिला').length;
    final parentsCount = state.smcMembers.where((m) => m.isParentMember).length;

    final double womenPct = totalMembers > 0 ? (womenCount / totalMembers * 100) : 0;
    final double parentsPct = totalMembers > 0 ? (parentsCount / totalMembers * 100) : 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stat Badges (RTE 2009 Compliance)
          Row(
            children: [
              _buildComplianceBadge('एकूण सदस्य', '$totalMembers सदस्य', Icons.people, Colors.blue),
              const SizedBox(width: 12),
              _buildComplianceBadge(
                'महिला आरक्षण (५०% अनिवार्य)',
                '$womenCount महिला (${womenPct.toStringAsFixed(0)}%)',
                Icons.female,
                womenPct >= 50 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              _buildComplianceBadge(
                'पालक सदस्य (७५% अनिवार्य)',
                '$parentsCount पालक (${parentsPct.toStringAsFixed(0)}%)',
                Icons.family_restroom,
                parentsPct >= 75 ? Colors.green : Colors.orange,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('नवीन सदस्य जोडा'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _showAddMemberDialog(context, state),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Members List Table
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.smcMembers.isEmpty
                    ? const Center(child: Text('कोणतेही सदस्य नोंदवलेले नाहीत.'))
                    : ListView.separated(
                        itemCount: state.smcMembers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final m = state.smcMembers[index];
                          final isHM = m.designation.contains('सचिव');
                          final isPresident = m.designation.contains('अध्यक्ष');

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPresident
                                  ? Colors.amber.shade100
                                  : (isHM ? Colors.blue.shade100 : Colors.purple.shade50),
                              child: Icon(
                                isPresident ? Icons.star : (isHM ? Icons.school : Icons.person),
                                color: isPresident
                                    ? Colors.amber.shade900
                                    : (isHM ? Colors.blue.shade900 : Colors.purple.shade900),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.blueGrey.shade200),
                                  ),
                                  child: Text(
                                    m.designation,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isPresident ? Colors.brown : Colors.blueGrey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text('लिंग: ${m.gender} | प्रवर्ग: ${m.category} | संपर्क: ${m.mobileNumber} | पाल्याचा संदर्भ: ${m.studentRelation.isNotEmpty ? m.studentRelation : "-"} | कार्यकाळ: ${DateFormat("dd/MM/yyyy").format(m.appointedDate)} ते ${DateFormat("dd/MM/yyyy").format(m.expiryDate)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'सदस्य काढा',
                              onPressed: () async {
                                await state.deleteSmcMember(m.id);
                              },
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

  Widget _buildComplianceBadge(String title, String val, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), radius: 18, child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(val, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, AppStateProvider state) {
    final nameCtrl = TextEditingController();
    String designation = 'पालक सदस्य (महिला)';
    String gender = 'महिला';
    String category = 'OPEN';
    final mobileCtrl = TextEditingController();
    final childCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('नवीन SMC सदस्य नोंदणी'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'सदस्याचे पूर्ण नाव', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: designation,
                    decoration: const InputDecoration(labelText: 'पद / भूमिका', border: OutlineInputBorder()),
                    items: [
                      'अध्यक्ष',
                      'उपाध्यक्ष',
                      'सदस्य सचिव (मुख्याध्यापक)',
                      'पालक सदस्य (महिला)',
                      'पालक सदस्य (पुरुष)',
                      'स्थानिक स्वराज्य संस्था प्रतिनिधी (ग्रा.पं. सदस्य)',
                      'शिक्षक प्रतिनिधी',
                      'शिक्षणतज्ज्ञ',
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          designation = val;
                          if (val.contains('महिला')) gender = 'महिला';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: gender,
                          decoration: const InputDecoration(labelText: 'लिंग', border: OutlineInputBorder()),
                          items: ['महिला', 'पुरुष'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setDialogState(() => gender = val ?? 'महिला'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(labelText: 'प्रवर्ग', border: OutlineInputBorder()),
                          items: ['SC', 'ST', 'VJNT', 'OBC', 'SBC', 'OPEN'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setDialogState(() => category = val ?? 'OPEN'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: mobileCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'मोबाईल क्रमांक', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: childCtrl, decoration: const InputDecoration(labelText: 'पाल्याचे नाव व इयत्ता (उदा. राहुल - इ. ४ थी)', border: OutlineInputBorder())),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final member = SmcMemberModel(
                  id: 'smc_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  designation: designation,
                  gender: gender,
                  category: category,
                  mobileNumber: mobileCtrl.text,
                  studentRelation: childCtrl.text,
                  isParentMember: designation.contains('पालक') || designation.contains('अध्यक्ष') || designation.contains('उपाध्यक्ष'),
                  appointedDate: DateTime.now(),
                  expiryDate: DateTime.now().add(const Duration(days: 1095)),
                );
                await state.addOrUpdateSmcMember(member);
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
  // TAB 2: मासिक सभा व मंजूर ठराव वही
  // ==========================================
  Widget _buildMeetingsTab(BuildContext context, AppStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('शाळा व्यवस्थापन समिती - मासिक सभा व ठराव वही', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_task),
                label: const Text('नवीन सभा व ठराव नोंदवा'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () => _showAddMeetingDialog(context, state),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: state.smcMeetings.length,
              itemBuilder: (context, index) {
                final meet = state.smcMeetings[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text('${meet.meetingNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('मासिक सभा क्र. ${meet.meetingNumber} | दिनांक: ${DateFormat("dd MMMM yyyy").format(meet.meetingDate)}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                Text('सभेचे अध्यक्ष: ${meet.presidentName} | सचिव: ${meet.secretaryName} | उपस्थिती: ${meet.totalMembersAttended} सदस्य',
                                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.print, size: 16),
                              label: const Text('ठराव प्रत प्रिंट'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                              onPressed: () => _printSmcMeeting(state, meet),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Text('📌 अजेंडा / सभेचा विषय: ${meet.subjectOrAgenda}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 12),
                        const Text('मंजूर झालेले ठराव:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        ...meet.resolutions.map((r) => Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(radius: 10, backgroundColor: Colors.purple.shade100, child: Text('${r.resolutionNumber}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.resolutionDetails, style: const TextStyle(fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Text('सूचक: ${r.proposer} | अनुमोदक: ${r.seconder} | स्थिती: ${r.approvalStatus}',
                                            style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMeetingDialog(BuildContext context, AppStateProvider state) {
    int meetNo = state.smcMeetings.length + 1;
    final agendaCtrl = TextEditingController();
    final attendedCtrl = TextEditingController(text: '12');
    final propCtrl = TextEditingController(text: 'सौ. सुनीता गायकवाड');
    final secCtrl = TextEditingController(text: 'सौ. मीना शिंदे');
    final resDetailsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('मासिक सभा क्र. $meetNo व ठराव नोंदवा'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: agendaCtrl, decoration: const InputDecoration(labelText: 'सभेचा विषय / अजेंडा', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: attendedCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'उपस्थित सदस्य संख्या', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                const Divider(),
                const Text('ठराव क्र. १ तपशील', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: propCtrl, decoration: const InputDecoration(labelText: 'सूचक नाव', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: secCtrl, decoration: const InputDecoration(labelText: 'अनुमोदक नाव', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: resDetailsCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'मंजूर झालेला ठराव मजकूर', border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              if (agendaCtrl.text.isEmpty) return;
              final meeting = SmcMeetingModel(
                id: 'meet_${DateTime.now().millisecondsSinceEpoch}',
                meetingNumber: meetNo,
                meetingDate: DateTime.now(),
                subjectOrAgenda: agendaCtrl.text,
                totalMembersAttended: int.tryParse(attendedCtrl.text) ?? 12,
                presidentName: state.smcMembers.firstWhere((m) => m.designation.contains('अध्यक्ष'), orElse: () => state.smcMembers.first).name,
                secretaryName: state.school.headmasterName,
                resolutions: [
                  SmcResolutionItem(
                    resolutionNumber: 1,
                    proposer: propCtrl.text,
                    seconder: secCtrl.text,
                    resolutionDetails: resDetailsCtrl.text.isNotEmpty ? resDetailsCtrl.text : agendaCtrl.text,
                    approvalStatus: 'सर्वानुमते मंजूर',
                  ),
                ],
              );
              await state.addSmcMeeting(meeting);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('जतन करा'),
          ),
        ],
      ),
    );
  }

  Future<void> _printSmcMeeting(AppStateProvider state, SmcMeetingModel meet) async {
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
                    pw.Text('महाराष्ट्र शासन - शिक्षण विभाग', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('शाळा व्यवस्थापन समिती (SMC) - मासिक सभा व ठराव इतिवृत्त', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${school.schoolName} | U-DISE: ${school.udiseCode}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('मासिक सभा क्र.: ${meet.meetingNumber} | दिनांक: ${DateFormat("dd-MM-yyyy").format(meet.meetingDate)}',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Divider(thickness: 1),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('सभेचे अध्यक्ष: ${meet.presidentName} | सदस्य सचिव: ${meet.secretaryName}', style: const pw.TextStyle(fontSize: 11)),
              pw.Text('उपस्थित सदस्य संख्या: ${meet.totalMembersAttended} सदस्य', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 8),
              pw.Text('सभेचा अजेंडा / विषय: ${meet.subjectOrAgenda}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text('सभेत मंजूर झालेले ठराव:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              ...meet.resolutions.map((r) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ठराव क्र. ${r.resolutionNumber}: ${r.resolutionDetails}', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('सूचक: ${r.proposer} | अनुमोदक: ${r.seconder} | ठराव: ${r.approvalStatus}',
                            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                      ],
                    ),
                  )),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('अध्यक्ष स्वाक्षरी', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('(${meet.presidentName})', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('सदस्य सचिव स्वाक्षरी', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('(मुख्याध्यापक)', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SMC_Meeting_${meet.meetingNumber}.pdf',
    );
  }
}
