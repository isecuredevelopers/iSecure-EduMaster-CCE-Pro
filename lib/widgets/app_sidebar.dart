import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/app_update_service.dart';
import '../providers/app_state_provider.dart';
import 'school_logo_widget.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final school = state.school;

    return Container(
      width: 280,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          // Header / School Branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SchoolLogoWidget(
                      logoUrl:
                          (school.softwareLogoUrl != null &&
                              school.softwareLogoUrl!.isNotEmpty)
                          ? school.softwareLogoUrl
                          : 'assets/images/isecure_favicon.png',
                      size: 44,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'iSecure EduMaster',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            school.schoolName.isNotEmpty
                                ? school.schoolName
                                : 'iSecure Systems Pvt. Ltd.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Current Academic Year Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 13,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'शैक्षणिक वर्ष: ${state.currentYear.yearName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'सत्र ${state.selectedSemester}',
                          style: const TextStyle(
                            color: AppColors.tealLight,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Current Logged In User Profile & Logout
                if (state.currentUser != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: state.currentUser!.isAdmin
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF10B981),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: state.currentUser!.isSuperAdmin
                              ? const Color(0xFFDC2626)
                              : (state.currentUser!.isAdmin
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF059669)),
                          child: Icon(
                            state.currentUser!.isSuperAdmin
                                ? Icons.security
                                : (state.currentUser!.isAdmin
                                      ? Icons.admin_panel_settings
                                      : Icons.person),
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.currentUser!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                state.currentUser!.isSuperAdmin
                                    ? 'सुपर ॲडमिन (सर्वोच्च अधिकार)'
                                    : (state.currentUser!.isAdmin
                                          ? '${state.currentUser!.roleTextMr} (पूर्ण अधिकार)'
                                          : state
                                                .currentUser!
                                                .allocationSummary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: state.currentUser!.isSuperAdmin
                                      ? const Color(0xFFFCA5A5)
                                      : (state.currentUser!.isAdmin
                                            ? const Color(0xFF93C5FD)
                                            : const Color(0xFF6EE7B7)),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            size: 15,
                            color: Color(0xFFF87171),
                          ),
                          tooltip: 'लॉगआउट (Sign Out)',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _confirmLogout(context, state),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Global Selection Controls (Class, Div, Semester)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF0B1120),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdownFilter<int>(
                    label: 'इयत्ता',
                    value: state.selectedStd,
                    items: state.availableStandards,
                    display: (val) => 'इ. $val',
                    onChanged: (val) {
                      if (val != null) state.setStandard(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdownFilter<String>(
                    label: 'तुकडी',
                    value: state.selectedDiv,
                    items: state.availableDivisions,
                    display: (val) => 'तुक. $val',
                    onChanged: (val) {
                      if (val != null) state.setDivision(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdownFilter<int>(
                    label: 'सत्र',
                    value: state.selectedSemester,
                    items: const [1, 2],
                    display: (val) => 'सत्र $val',
                    onChanged: (val) {
                      if (val != null) state.setSemester(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (state.currentUser?.isStudent ?? false) ...[
                  _buildSectionHeader(
                    'विद्यार्थी व पालक कॉर्नर (Student Zone)',
                  ),
                  _buildNavItem(
                    15,
                    Icons.phone_android_outlined,
                    Icons.phone_android,
                    'अभ्यासक्रम, गृहपाठ व परीक्षा (Portal 📱)',
                  ),
                  _buildNavItem(
                    5,
                    Icons.event_available_outlined,
                    Icons.event_available,
                    'माझी उपस्थिती (Attendance)',
                  ),
                  _buildNavItem(
                    6,
                    Icons.card_membership_outlined,
                    Icons.card_membership,
                    'प्रगती पुस्तक (Report Card)',
                  ),
                  _buildNavItem(
                    25,
                    Icons.badge_outlined,
                    Icons.badge,
                    'डिजिटल ओळखपत्र (ID Card 🪪)',
                  ),
                  _buildNavItem(
                    27,
                    Icons.menu_book_outlined,
                    Icons.menu_book,
                    'ई-बुक्स व अभ्यासक्रम (E-Books 📚)',
                  ),
                ] else ...[
                  _buildNavItem(
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard,
                    'डॅशबोर्ड (Dashboard)',
                  ),
                  if (state.currentUser?.isAdmin ?? true)
                    _buildNavItem(
                      1,
                      Icons.tune_outlined,
                      Icons.tune,
                      'सॉफ्टवेअर सेटिंग्ज (School Settings)',
                    ),

                  _buildSectionHeader('शैक्षणिक व निकाल कामकाज (CCE Pro)'),
                  _buildNavItem(
                    2,
                    Icons.people_outline,
                    Icons.people,
                    'विद्यार्थी यादी (Students)',
                  ),
                  _buildNavItem(
                    3,
                    Icons.calculate_outlined,
                    Icons.calculate,
                    'आकारिक-संकलित गुणनोंद (Marks)',
                  ),
                  _buildNavItem(
                    4,
                    Icons.edit_note_outlined,
                    Icons.edit_note,
                    'वर्णनात्मक नोंदी (Remarks)',
                  ),
                  _buildNavItem(
                    5,
                    Icons.event_available_outlined,
                    Icons.event_available,
                    'माहेवार उपस्थिती (Attendance)',
                  ),
                  _buildNavItem(
                    6,
                    Icons.card_membership_outlined,
                    Icons.card_membership,
                    'प्रगती पुस्तक (Progress Card)',
                  ),
                  _buildNavItem(
                    7,
                    Icons.table_chart_outlined,
                    Icons.table_chart,
                    'निकाल पत्रक (Result Gazette)',
                  ),
                  _buildNavItem(
                    8,
                    Icons.badge_outlined,
                    Icons.badge,
                    'ओळखपत्रे / बोनाफाईड (Certificates)',
                  ),
                  _buildNavItem(
                    9,
                    Icons.description_outlined,
                    Icons.description,
                    'शाळा सोडल्याचा दाखला (L.C.)',
                  ),
                  _buildNavItem(
                    10,
                    Icons.menu_book_outlined,
                    Icons.menu_book,
                    'रजिस्टर नं. १ उतारा (GR Extract)',
                  ),
                  _buildNavItem(
                    11,
                    Icons.history_edu_outlined,
                    Icons.history_edu,
                    'वर्ष व वर्गनिहाय नोंद (Yearly Archive)',
                  ),
                  _buildNavItem(
                    12,
                    Icons.analytics_outlined,
                    Icons.analytics,
                    'सांख्यिकी तक्ता (Statistics)',
                  ),
                  if (state.currentUser?.isAdmin ?? true)
                    _buildNavItem(
                      13,
                      Icons.upgrade_outlined,
                      Icons.upgrade,
                      'वर्गोन्नती (Promotion)',
                    ),
                  if (state.currentUser?.isAdmin ?? true)
                    _buildNavItem(
                      14,
                      Icons.assignment_ind_outlined,
                      Icons.assignment_ind,
                      'शिक्षक वाटप (Teacher Allocation)',
                    ),
                  _buildNavItem(
                    15,
                    Icons.phone_android_outlined,
                    Icons.phone_android,
                    'विद्यार्थी-पालक ॲप (Portal 📱)',
                  ),
                  _buildNavItem(
                    16,
                    Icons.assignment_outlined,
                    Icons.assignment,
                    'स्वाध्याय व परीक्षा (HW & Exams)',
                  ),
                  _buildNavItem(
                    27,
                    Icons.menu_book_outlined,
                    Icons.menu_book,
                    'ई-पुस्तके व अभ्यासक्रम (E-Books 📚)',
                  ),

                  _buildSectionHeader(
                    '🏛️ जि.प. शाळा वैधानिक नोंदवह्या (ZP Statutory Registers)',
                  ),
                  _buildNavItem(
                    17,
                    Icons.restaurant_menu_outlined,
                    Icons.restaurant_menu,
                    'शालेय पोषण आहार (PM POSHAN 🍲)',
                  ),
                  _buildNavItem(
                    18,
                    Icons.auto_stories_outlined,
                    Icons.auto_stories,
                    'मोफत पाठ्यपुस्तके व गणवेश (समग्र शिक्षा 📚)',
                  ),
                  _buildNavItem(
                    19,
                    Icons.assessment_outlined,
                    Icons.assessment,
                    'मासिक उपस्थिती गोषवारा (Form A/B 📊)',
                  ),
                  _buildNavItem(
                    20,
                    Icons.groups_outlined,
                    Icons.groups,
                    'शाळा व्यवस्थापन समिती (SMC ठराव वही 👥)',
                  ),
                  _buildNavItem(
                    21,
                    Icons.inventory_outlined,
                    Icons.inventory,
                    'शालेय मृतसाठा नोंदवही (Dead Stock 🪑)',
                  ),
                  _buildNavItem(
                    22,
                    Icons.local_library_outlined,
                    Icons.local_library,
                    'ग्रंथालय नोंदवही (Library Register 📖)',
                  ),
                  _buildNavItem(
                    23,
                    Icons.event_note_outlined,
                    Icons.event_note,
                    'शिक्षक रजा व हालचाल वही (Service 📝)',
                  ),
                  _buildNavItem(
                    24,
                    Icons.folder_shared_outlined,
                    Icons.folder_shared,
                    'आवक-जावक व आरोग्य (RBSK 🏥)',
                  ),
                  _buildNavItem(
                    25,
                    Icons.badge_outlined,
                    Icons.badge,
                    'डिजिटल ओळखपत्रे (ID Cards 🪪)',
                  ),
                  _buildNavItem(
                    26,
                    Icons.cloud_sync_outlined,
                    Icons.cloud_sync,
                    'सरळ व U-DISE+ सिंक (SARAL Sync 🔄)',
                  ),
                ],
              ],
            ),
          ),

          // Footer Cloud Sync & Online Update status
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              children: [
                // If update is available, show highlighted update bar
                if (state.availableUpdate?.hasUpdate == true)
                  InkWell(
                    onTap: () => AppUpdateService.showUpdateModal(
                      context,
                      state.availableUpdate!,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF312E81),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.rocket_launch,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'नवीन अपडेट: v${state.availableUpdate!.latestVersion}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.download,
                            size: 14,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),

                Row(
                  children: [
                    Icon(
                      state.isCloudConnected
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      color: state.isCloudConnected
                          ? AppColors.gradeA1
                          : AppColors.textMuted,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.isCloudConnected
                            ? 'Supabase कनेक्टेड'
                            : 'ऑफलाइन मोड (सुरक्षित)',
                        style: TextStyle(
                          color: state.isCloudConnected
                              ? AppColors.gradeA1
                              : AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(
                      Icons.headset_mic_outlined,
                      size: 12,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'iSecure Help: 9326770568',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'v${AppUpdateService.currentVersion} (b${AppUpdateService.buildNumber})',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: state.isCheckingUpdate
                          ? null
                          : () async {
                              final update = await state.checkForUpdate();
                              if (context.mounted) {
                                if (update != null && update.hasUpdate) {
                                  AppUpdateService.showUpdateModal(
                                    context,
                                    update,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'आपले सॉफ्टवेअर अद्ययावत आहे! (v1.0.0 Latest Version)',
                                      ),
                                      backgroundColor: AppColors.gradeA1,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                      child: Text(
                        state.isCheckingUpdate
                            ? 'तपासत आहे...'
                            : 'अपडेट तपासा 🔄',
                        style: const TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) display,
    required Function(T?) onChanged,
  }) {
    final effectiveValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: effectiveValue,
          isDense: true,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textMuted,
            size: 16,
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(value: item, child: Text(display(item)));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('लॉगआउट करा'),
          ],
        ),
        content: Text(
          'तुम्हाला खाते (${state.currentUser?.name}) मधून लॉगआउट करायचे आहे का?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('रद्द करा'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await state.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('लॉगआउट'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData iconOutlined,
    IconData iconFilled,
    String title,
  ) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onDestinationSelected(index),
          hoverColor: AppColors.sidebarActive,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  isSelected ? iconFilled : iconOutlined,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFCBD5E1),
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
