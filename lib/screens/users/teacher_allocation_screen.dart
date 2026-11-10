import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/marathi_date_formatter.dart';
import '../../providers/app_state_provider.dart';
import '../../data/models/user_model.dart';

class TeacherAllocationScreen extends StatefulWidget {
  const TeacherAllocationScreen({super.key});

  @override
  State<TeacherAllocationScreen> createState() => _TeacherAllocationScreenState();
}

class _TeacherAllocationScreenState extends State<TeacherAllocationScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final currentUser = state.currentUser;
    final allUsers = state.users;

    final filteredUsers = allUsers.where((u) {
      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return u.name.toLowerCase().contains(q) ||
          u.username.toLowerCase().contains(q) ||
          u.mobile.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'शिक्षक नोंदणी व वर्ग वाटप (Teacher & Class Allocation)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              'वर्गशिक्षकांना एकापेक्षा जास्त इयत्ता व तुकड्यांचे वाटप करा',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _openTeacherDialog(context, state, null),
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('नवीन शिक्षक नोंदवा', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Stats Cards
            _buildStatsHeader(allUsers),
            const SizedBox(height: 16),

            // Search and Controls
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'शिक्षकाचे नाव, वापरकर्ता नाव (Username) किंवा मोबाईल शोधा...',
                        hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      'एकूण शिक्षक: ${filteredUsers.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1D4ED8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Teachers List Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: const [
                        Text(
                          'नोंदणीकृत शिक्षक व वाटप केलेले वर्ग',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'टीप: शिक्षक फक्त त्यांना वाटप केलेल्या वर्गाचीच माहिती पाहू व भरू शकतात.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),

                    if (filteredUsers.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text('कोणतेही शिक्षक आढळले नाहीत.'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, idx) {
                          final user = filteredUsers[idx];
                          final isCurrent = currentUser?.id == user.id;

                          final avatar = CircleAvatar(
                            radius: 20,
                            backgroundColor: user.isAdmin ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                            child: Icon(
                              user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                              color: user.isAdmin ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
                              size: 22,
                            ),
                          );

                          final nameAndBadges = Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                              if (user.isMasterProtected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFCA5A5)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shield, size: 10, color: Color(0xFFDC2626)),
                                      SizedBox(width: 3),
                                      Text(
                                        'मास्टर संरक्षित',
                                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                      ),
                                    ],
                                  ),
                                )
                              else if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('सध्या लॉगिन', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                                ),
                            ],
                          );

                          final credentials = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'युझरनेम: ${user.username} • पासवर्ड: ${user.password}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              if (user.mobile.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text('मोबाईल: ${user.mobile}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              ],
                            ],
                          );

                          final roleBadge = Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.isTeacher
                                  ? const Color(0xFFECFDF5)
                                  : (user.isHeadmaster
                                      ? const Color(0xFFEFF6FF)
                                      : (user.isPeon
                                          ? const Color(0xFFFEF3C7)
                                          : (user.isSuperAdmin
                                              ? const Color(0xFFFEF2F2)
                                              : const Color(0xFFF5F3FF)))),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: user.isTeacher
                                    ? const Color(0xFFA7F3D0)
                                    : (user.isHeadmaster
                                        ? const Color(0xFFBFDBFE)
                                        : (user.isPeon
                                            ? const Color(0xFFFDE68A)
                                            : (user.isSuperAdmin
                                                ? const Color(0xFFFECACA)
                                                : const Color(0xFFDDD6FE)))),
                              ),
                            ),
                            child: Text(
                              user.roleTextMr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: user.isTeacher
                                    ? const Color(0xFF059669)
                                    : (user.isHeadmaster
                                        ? const Color(0xFF2563EB)
                                        : (user.isPeon
                                            ? const Color(0xFFD97706)
                                            : (user.isSuperAdmin
                                                ? const Color(0xFFDC2626)
                                                : const Color(0xFF7C3AED)))),
                              ),
                            ),
                          );

                          final allocatedClassesWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'वाटप केलेले वर्ग (Allocated Classes):',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                              ),
                              const SizedBox(height: 6),
                              if (user.isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'सर्व वर्ग व तुकड्या (इ. १ ली ते ८ वी सर्व)',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                  ),
                                )
                              else if (user.allocatedClasses.isEmpty)
                                const Text(
                                  'कोणताही वर्ग वाटप नाही (कृपया वाटप करा)',
                                  style: TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w500),
                                )
                              else
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: user.allocatedClasses.map((alloc) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFC7D2FE)),
                                      ),
                                      child: Text(
                                        '${MarathiDateFormatter.classToMarathi(alloc.standard)} (तुकडी ${alloc.division})',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3730A3)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          );

                          final actionButtons = user.isMasterProtected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock_outline, size: 14, color: Color(0xFF64748B)),
                                      SizedBox(width: 5),
                                      Text(
                                        'संरक्षित (अपरिवर्तनीय)',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0D6EFD)),
                                      tooltip: 'वर्ग वाटप व माहिती संपादन (Edit)',
                                      onPressed: () => _openTeacherDialog(context, state, user),
                                    ),
                                    if (user.id != 'usr_admin')
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                        tooltip: 'शिक्षक हटवा (Delete)',
                                        onPressed: () => _confirmDeleteUser(context, state, user),
                                      ),
                                  ],
                                );

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isNarrow = constraints.maxWidth < 680;
                                if (isNarrow) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          avatar,
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                nameAndBadges,
                                                const SizedBox(height: 3),
                                                credentials,
                                              ],
                                            ),
                                          ),
                                          actionButtons,
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 8,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          roleBadge,
                                          allocatedClassesWidget,
                                        ],
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    avatar,
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          nameAndBadges,
                                          const SizedBox(height: 3),
                                          credentials,
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    roleBadge,
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 4,
                                      child: allocatedClassesWidget,
                                    ),
                                    const SizedBox(width: 12),
                                    actionButtons,
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(List<UserModel> allUsers) {
    final teachers = allUsers.where((u) => u.isTeacher).toList();
    final admins = allUsers.where((u) => u.isAdmin).toList();
    final totalAllocated = teachers.fold<int>(0, (sum, u) => sum + u.allocatedClasses.length);

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            label: 'एकूण शिक्षक संख्या',
            value: '${teachers.length}',
            sub: 'नोंदणीकृत वर्गशिक्षक',
            icon: Icons.people_outline,
            iconColor: const Color(0xFF0D6EFD),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            label: 'वर्ग वाटप संख्या',
            value: '$totalAllocated',
            sub: 'विविध वर्ग व तुकड्या',
            icon: Icons.class_outlined,
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFF0FDF4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            label: 'मुख्याध्यापक (प्रशासक)',
            value: '${admins.length}',
            sub: 'पूर्ण अधिकार असलेले युझर',
            icon: Icons.admin_panel_settings_outlined,
            iconColor: const Color(0xFF9333EA),
            bgColor: const Color(0xFFFAF5FF),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                Text(
                  sub,
                  style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Teacher Creation & Multi-Class Allocation Dialog
  void _openTeacherDialog(BuildContext context, AppStateProvider state, UserModel? userToEdit) {
    if (userToEdit != null && userToEdit.isMasterProtected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('iSecure Master (सुपर ॲडमीन) खाते पूर्णतः सुरक्षित आहे. हे खाते संपादित किंवा डिलीट करता येत नाही.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    final isEditing = userToEdit != null;
    final nameCtrl = TextEditingController(text: userToEdit?.name ?? '');
    final usernameCtrl = TextEditingController(text: userToEdit?.username ?? '');
    final passwordCtrl = TextEditingController(text: userToEdit?.password ?? '123');
    final mobileCtrl = TextEditingController(text: userToEdit?.mobile ?? '');
    String role = userToEdit?.role ?? 'teacher';

    // Temporary allocation state: standard -> list of divisions
    final selectedAllocations = <int, Set<String>>{};
    if (userToEdit != null) {
      for (var a in userToEdit.allocatedClasses) {
        selectedAllocations.putIfAbsent(a.standard, () => {}).add(a.division);
      }
    }

    final availableStandards = [1, 2, 3, 4, 5, 6, 7, 8];
    final availableDivisions = ['1', '2', '3', 'A', 'B'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            title: Row(
              children: [
                Icon(
                  isEditing ? Icons.edit : Icons.person_add_alt_1,
                  color: const Color(0xFF0D6EFD),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEditing ? 'शिक्षक माहिती व वर्ग वाटप संपादन' : 'नवीन शिक्षक नोंदणी व वर्ग वाटप',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Container(
              width: 680,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.70,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Teacher Basic Details
                    const Text('१. शिक्षकाचे प्राथमिक तपशील:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 480;
                        final nameField = TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'शिक्षकाचे पूर्ण नाव (उदा. श्री. संतोष गायकवाड)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        );
                        final roleField = DropdownButtonFormField<String>(
                          value: ['teacher', 'headmaster', 'peon', 'admin', 'superadmin'].contains(role) ? role : 'teacher',
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'पद / भूमिका (Role)',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            border: OutlineInputBorder(),
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return const [
                              Align(alignment: Alignment.centerLeft, child: Text('वर्गशिक्षक (Teacher)', overflow: TextOverflow.ellipsis, maxLines: 1)),
                              Align(alignment: Alignment.centerLeft, child: Text('मुख्याध्यापक (Headmaster)', overflow: TextOverflow.ellipsis, maxLines: 1)),
                              Align(alignment: Alignment.centerLeft, child: Text('शिपाई (Shipai)', overflow: TextOverflow.ellipsis, maxLines: 1)),
                              Align(alignment: Alignment.centerLeft, child: Text('Admin (प्रशासक)', overflow: TextOverflow.ellipsis, maxLines: 1)),
                              Align(alignment: Alignment.centerLeft, child: Text('Superadmin (सुपर ॲडमीन)', overflow: TextOverflow.ellipsis, maxLines: 1)),
                            ];
                          },
                          items: const [
                            DropdownMenuItem(value: 'teacher', child: Text('वर्गशिक्षक (Vargshikshak)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'headmaster', child: Text('मुख्याध्यापक (Mukhyadhyapak)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'peon', child: Text('शिपाई (Shipai)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'admin', child: Text('Admin (प्रशासक)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'superadmin', child: Text('Superadmin (सुपर ॲडमीन)', overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => role = val);
                          },
                        );

                        if (isNarrow) {
                          return Column(
                            children: [
                              nameField,
                              const SizedBox(height: 12),
                              roleField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(flex: 1, child: nameField),
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: roleField),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 540;
                        final usernameField = TextField(
                          controller: usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'लॉगिन युझरनेम (उदा. teacher1)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        );
                        final passwordField = TextField(
                          controller: passwordCtrl,
                          decoration: const InputDecoration(
                            labelText: 'लॉगिन पासवर्ड',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        );
                        final mobileField = TextField(
                          controller: mobileCtrl,
                          decoration: const InputDecoration(
                            labelText: 'मोबाईल क्रमांक',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        );

                        if (isNarrow) {
                          return Column(
                            children: [
                              usernameField,
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: passwordField),
                                  const SizedBox(width: 12),
                                  Expanded(child: mobileField),
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: usernameField),
                            const SizedBox(width: 12),
                            Expanded(child: passwordField),
                            const SizedBox(width: 12),
                            Expanded(child: mobileField),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Multi-Class & Division Allocation Matrix
                    if (role == 'teacher') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '२. वर्ग व तुकडी वाटप (Class & Division Allocation):',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'या शिक्षकाला जे वर्ग व तुकड्या द्यायच्या आहेत त्यावर टिक करा (एकापेक्षा जास्त वर्ग देता येतात)',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setDialogState(() {
                                    for (var std in availableStandards) {
                                      selectedAllocations.putIfAbsent(std, () => {}).add('1');
                                    }
                                  });
                                },
                                child: const Text('सर्व वर्ग (तुकडी १) द्या', style: TextStyle(fontSize: 11)),
                              ),
                              TextButton(
                                onPressed: () {
                                  setDialogState(() {
                                    selectedAllocations.clear();
                                  });
                                },
                                child: const Text('सर्व काढा', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: availableStandards.map((std) {
                            final isStdAllocated = selectedAllocations.containsKey(std) && selectedAllocations[std]!.isNotEmpty;
                            final allocatedDivs = selectedAllocations[std] ?? {};

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isStdAllocated ? Colors.white : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isStdAllocated ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  // Standard Checkbox
                                  Checkbox(
                                    value: isStdAllocated,
                                    activeColor: const Color(0xFF0D6EFD),
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          selectedAllocations.putIfAbsent(std, () => {}).add('1');
                                        } else {
                                          selectedAllocations.remove(std);
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      MarathiDateFormatter.classToMarathi(std),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isStdAllocated ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Division Chips
                                  if (isStdAllocated) ...[
                                    const Text('तुकड्या:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: availableDivisions.map((div) {
                                          final isDivChecked = allocatedDivs.contains(div);
                                          return FilterChip(
                                            label: Text('तुकडी $div'),
                                            selected: isDivChecked,
                                            selectedColor: const Color(0xFF0D6EFD),
                                            labelStyle: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isDivChecked ? FontWeight.bold : FontWeight.normal,
                                              color: isDivChecked ? Colors.white : const Color(0xFF0F172A),
                                            ),
                                            onSelected: (checked) {
                                              setDialogState(() {
                                                if (checked) {
                                                  selectedAllocations.putIfAbsent(std, () => {}).add(div);
                                                } else {
                                                  selectedAllocations[std]?.remove(div);
                                                  if (selectedAllocations[std]?.isEmpty == true) {
                                                    selectedAllocations.remove(std);
                                                  }
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ] else
                                    const Text(
                                      'हा वर्ग वाटप केलेला नाही',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Allocation count banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFF0D6EFD)),
                            const SizedBox(width: 8),
                            Text(
                              'एकूण निवडलेले वर्ग: ${selectedAllocations.values.fold<int>(0, (sum, set) => sum + set.length)} तुकड्या',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1D4ED8)),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF9333EA), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                role == 'superadmin'
                                    ? 'सुपर ॲडमिन (Superadmin) खात्यास शाळेतील सर्व इयत्ता, तुकड्या, सेटिंग्ज व मास्टर कॉन्फिगरेशनचे सर्वोच्च अधिकार मिळतात.'
                                    : (role == 'admin' || role == 'headmaster'
                                        ? 'प्रशासक / मुख्याध्यापक खात्यास शाळेतील सर्व इयत्ता (१ ते ८) व सर्व तुकड्यांचे पूर्ण अधिकार आपोआप मिळतात.'
                                        : 'शिपाई खात्यास शालेय कार्यालयीन कामकाज, विद्यार्थी यादी व दाखले प्रिंटिंगचे अधिकार मिळतील.'),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF7E22CE), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('रद्द करा'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final username = usernameCtrl.text.trim();
                  final password = passwordCtrl.text.trim();
                  final mobile = mobileCtrl.text.trim();

                  if (name.isEmpty || username.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('नाव, युझरनेम व पासवर्ड आवश्यक आहेत!'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  if (!isEditing && username.toLowerCase() == 'isecure') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('\'isecure\' हे मास्टर सुपरॲडमीनचे संरक्षित युझरनेम आहे!'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // Compile allocated classes
                  final List<ClassAllocationModel> allocations = [];
                  if (role == 'teacher') {
                    for (var entry in selectedAllocations.entries) {
                      for (var div in entry.value) {
                        allocations.add(ClassAllocationModel(standard: entry.key, division: div));
                      }
                    }
                  }

                  final user = UserModel(
                    id: userToEdit?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    username: username,
                    password: password,
                    role: role,
                    mobile: mobile,
                    allocatedClasses: allocations,
                    isActive: true,
                  );

                  await state.saveUser(user);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${user.name} ची माहिती व वर्ग वाटप जतन झाले!'),
                        backgroundColor: const Color(0xFF166534),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('जतन करा (Save)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, AppStateProvider state, UserModel user) {
    if (user.isMasterProtected || user.id == 'usr_admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('हे मुख्य खाते संरक्षित आहे. हे खाते डिलीट करता येत नाही.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('शिक्षक खाते हटवा'),
          ],
        ),
        content: Text('तुम्हाला खात्री आहे का? "${user.name}" (${user.username}) हे शिक्षक खाते हटवले जाईल.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              await state.deleteUser(user.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.name} चे खाते हटवले.'), backgroundColor: const Color(0xFFDC2626)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('हटवा'),
          ),
        ],
      ),
    );
  }
}
