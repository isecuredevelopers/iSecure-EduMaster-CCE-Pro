import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_translations.dart';
import '../../core/services/app_update_service.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/school_logo_widget.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.students;
    final curClassStudents = state.filteredStudents;
    final boysCount = students.where((s) => s.gender == 'M').length;
    final girlsCount = students.where((s) => s.gender == 'F').length;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 14 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            if (isMobile)
              _buildMobileHeader(context, state)
            else
              _buildDesktopHeader(context, state),

            const SizedBox(height: 18),

            // Online GitHub New Version Available Banner
            if (state.availableUpdate != null && state.availableUpdate!.hasUpdate)
              _buildUpdateBanner(context, state.availableUpdate!, isMobile),

            // Metric Cards
            if (isMobile) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: context.tr('stat_total_students'),
                      value: '${students.length}',
                      subtitle: context.tr('stat_all_classes'),
                      icon: Icons.groups_rounded,
                      color: AppColors.primaryLight,
                      onTap: () => onNavigate(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'इ. ${state.selectedStd} (${state.selectedDiv})',
                      value: '${curClassStudents.length}',
                      subtitle: context.tr('stat_current_class'),
                      icon: Icons.class_outlined,
                      color: AppColors.teal,
                      onTap: () => onNavigate(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: context.tr('stat_boys'),
                      value: '$boysCount',
                      subtitle: context.tr('stat_total_count'),
                      icon: Icons.boy_rounded,
                      color: AppColors.gradeB2,
                      onTap: () => onNavigate(9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      title: context.tr('stat_girls'),
                      value: '$girlsCount',
                      subtitle: context.tr('stat_total_count'),
                      icon: Icons.girl_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () => onNavigate(9),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: context.tr('stat_total_students'),
                      value: '${students.length}',
                      subtitle: context.tr('stat_all_classes'),
                      icon: Icons.groups_rounded,
                      color: AppColors.primaryLight,
                      onTap: () => onNavigate(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'इ. ${state.selectedStd} (${state.selectedDiv})',
                      value: '${curClassStudents.length}',
                      subtitle: 'सत्र ${state.selectedSemester} चालू वर्ग',
                      icon: Icons.class_outlined,
                      color: AppColors.teal,
                      onTap: () => onNavigate(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricTile(
                      title: context.tr('stat_boys'),
                      value: '$boysCount',
                      subtitle: context.tr('stat_total_count'),
                      icon: Icons.boy_rounded,
                      color: AppColors.gradeB2,
                      onTap: () => onNavigate(9),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMetricTile(
                      title: context.tr('stat_girls'),
                      value: '$girlsCount',
                      subtitle: context.tr('stat_total_count'),
                      icon: Icons.girl_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () => onNavigate(9),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // CCE Workflow Stepper
            Text(
              context.tr('cce_workflow_title'),
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isMobile
                  ? _buildMobileWorkflow(context)
                  : _buildDesktopWorkflow(context),
            ),

            const SizedBox(height: 26),

            // Quick Modules Grid
            Text(
              context.tr('quick_actions_title'),
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionGrid(
              isMobile: isMobile,
              screenWidth: screenWidth,
              children: [
                _buildActionCard(
                  title: 'सॉफ्टवेअर सेटिंग्ज',
                  desc: 'शाळा माहिती, लोगो, स्वाक्षरी, Supabase',
                  icon: Icons.tune_rounded,
                  color: AppColors.primary,
                  onTap: () => onNavigate(1),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'आकारिक-संकलित गुणनोंद',
                  desc: 'सत्रनिहाय विषयनिहाय गुणनोंद तक्ता',
                  icon: Icons.edit_calendar_rounded,
                  color: AppColors.teal,
                  onTap: () => onNavigate(3),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'वर्णनात्मक नोंदी (Remarks)',
                  desc: 'पूर्वनिर्धारित व सानुकूल वर्णनात्मक नोंदी',
                  icon: Icons.border_color_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: () => onNavigate(4),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'माहेवार उपस्थिती (Attendance)',
                  desc: 'जून ते एप्रिल हजेरी व टक्केवारी',
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () => onNavigate(5),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'प्रगती पुस्तक (Report Card)',
                  desc: 'रंगीबेरंगी व क्लासिक प्रगती पत्रके',
                  icon: Icons.school_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => onNavigate(6),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'निकाल पत्रक (Result Gazette)',
                  desc: 'वार्षिक एकत्रित निकालपत्रक व एक्सेल',
                  icon: Icons.description_rounded,
                  color: const Color(0xFF6366F1),
                  onTap: () => onNavigate(7),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'बोनाफाईड व ओळखपत्रे',
                  desc: 'दाखला प्रमाणपत्र व विद्यार्थी आयकार्ड',
                  icon: Icons.badge_rounded,
                  color: const Color(0xFFEC4899),
                  onTap: () => onNavigate(8),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'शाळा सोडल्याचा दाखला (L.C.)',
                  desc: 'अस्सल/द्वितीय प्रत, लाल बॉर्डर व प्रिंट',
                  icon: Icons.assignment_rounded,
                  color: const Color(0xFFDC2626),
                  onTap: () => onNavigate(9),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'रजिस्टर नं. १ चा उतारा',
                  desc: 'चालू व माजी विद्यार्थ्यांचा GR उतारा',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFFB45309),
                  onTap: () => onNavigate(10),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'वर्ष व वर्गनिहाय नोंद',
                  desc: 'सर्व शैक्षणिक वर्षांची वर्गनिहाय यादी',
                  icon: Icons.history_edu_rounded,
                  color: const Color(0xFF0F766E),
                  onTap: () => onNavigate(11),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'सांख्यिकी तक्ता (Statistics)',
                  desc: 'जातीनिहाय व वयोगटनिहाय सांख्यिकी',
                  icon: Icons.analytics_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => onNavigate(12),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'वर्गोन्नती (Promotion)',
                  desc: 'पुढील वर्गात एका क्लिकवर स्थलांतर',
                  icon: Icons.drive_file_move_rounded,
                  color: const Color(0xFF14B8A6),
                  onTap: () => onNavigate(13),
                  isMobile: isMobile,
                ),
                if (state.currentUser?.isAdmin ?? true)
                  _buildActionCard(
                    title: 'शिक्षक वाटप (Allocation)',
                    desc: 'शिक्षकांना एकापेक्षा जास्त वर्ग वाटप',
                    icon: Icons.assignment_ind_rounded,
                    color: const Color(0xFF4F46E5),
                    onTap: () => onNavigate(14),
                    isMobile: isMobile,
                  ),
                _buildActionCard(
                  title: 'स्वाध्याय व ऑनलाइन परीक्षा',
                  desc: 'विद्यार्थ्यांना गृहपाठ व ऑनलाइन परीक्षा देणे',
                  icon: Icons.assignment_turned_in_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () => onNavigate(16),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'ई-पुस्तके व अभ्यासक्रम 📚',
                  desc: 'इ. १ ते ७ सर्व विषयांची बालभारती पुस्तके',
                  icon: Icons.library_books_rounded,
                  color: const Color(0xFFD97706),
                  onTap: () => onNavigate(27),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'विद्यार्थी-पालक पोर्टल 📱',
                  desc: 'Android ॲप प्रिव्ह्यू व विद्यार्थी डॅशबोर्ड',
                  icon: Icons.phone_android_rounded,
                  color: const Color(0xFF059669),
                  onTap: () => onNavigate(15),
                  isMobile: isMobile,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ZP Statutory Registers Section
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('zp_registers_title'),
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActionGrid(
              isMobile: isMobile,
              screenWidth: screenWidth,
              children: [
                _buildActionCard(
                  title: 'शालेय पोषण आहार (MDM)',
                  desc: 'दैनिक हजेरी, धान्य साठा व मासिक बिल',
                  icon: Icons.restaurant_menu_rounded,
                  color: const Color(0xFFD97706),
                  onTap: () => onNavigate(17),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'मोफत पाठ्यपुस्तके व गणवेश',
                  desc: 'समग्र शिक्षा वाटप व पावती रजिस्टर',
                  icon: Icons.auto_stories_rounded,
                  color: const Color(0xFF0284C7),
                  onTap: () => onNavigate(18),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'मासिक उपस्थिती गोषवारा',
                  desc: 'Form A/B जातनिहाय मुले-मुली हजेरी',
                  icon: Icons.assessment_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () => onNavigate(19),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'शाळा व्यवस्थापन समिती (SMC)',
                  desc: 'कार्यकारिणी व मासिक सभा ठराव वही',
                  icon: Icons.groups_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: () => onNavigate(20),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'मृतसाठा नोंदवही (Dead Stock)',
                  desc: 'नमुना १ ते ५ फर्निचर, डिजिटल साहित्य',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF78350F),
                  onTap: () => onNavigate(21),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'ग्रंथालय नोंदवही (Library)',
                  desc: 'ॲक्सेशन वही व पुस्तक देवाणघेवाण',
                  icon: Icons.local_library_rounded,
                  color: const Color(0xFF0D9488),
                  onTap: () => onNavigate(22),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'शिक्षक रजा व हालचाल वही',
                  desc: 'किरकोळ रजा खातावणी व Movement',
                  icon: Icons.event_note_rounded,
                  color: const Color(0xFF4F46E5),
                  onTap: () => onNavigate(23),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'आवक-जावक व आरोग्य (RBSK)',
                  desc: 'शासकीय पत्रव्यवहार व आरोग्य तपासणी',
                  icon: Icons.folder_shared_rounded,
                  color: const Color(0xFFE11D48),
                  onTap: () => onNavigate(24),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'डिजिटल ओळखपत्रे (ID Cards)',
                  desc: 'प्रिंट-रेडी विद्यार्थी रंगीत आयकार्ड्स',
                  icon: Icons.badge_rounded,
                  color: const Color(0xFF0891B2),
                  onTap: () => onNavigate(25),
                  isMobile: isMobile,
                ),
                _buildActionCard(
                  title: 'सरळ (SARAL) व U-DISE+ सिंक',
                  desc: 'एक्सेल बल्क इंपोर्ट/एक्सपोर्ट व DCF',
                  icon: Icons.cloud_sync_rounded,
                  color: const Color(0xFF16A34A),
                  onTap: () => onNavigate(26),
                  isMobile: isMobile,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, AppStateProvider state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              SchoolLogoWidget(
                logoUrl: state.school.logoUrl,
                size: 52,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.school.schoolName.isNotEmpty
                          ? state.school.schoolName
                          : 'iSecure EduMaster CCE Pro',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.school.sansthaName} • U-DISE: ${state.school.udiseCode} • केंद्र: ${state.school.cluster} • ता. ${state.school.blockTaluka} जि. ${state.school.district}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => onNavigate(6),
          icon: const Icon(Icons.print_rounded, size: 18),
          label: Text(context.tr('print_progress_card')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context, AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SchoolLogoWidget(
                logoUrl: state.school.logoUrl,
                size: 44,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.school.schoolName.isNotEmpty
                          ? state.school.schoolName
                          : 'iSecure EduMaster CCE Pro',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'U-DISE: ${state.school.udiseCode} • ${state.school.blockTaluka}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onNavigate(6),
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: Text(
                    context.tr('print_progress_card'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => onNavigate(27),
                icon: const Icon(Icons.menu_book_rounded, size: 16),
                label: const Text('ई-पुस्तके 📚', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD97706),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopWorkflow(BuildContext context) {
    return Row(
      children: [
        _buildWorkflowStep(
          step: '१',
          title: context.tr('step_1_title'),
          desc: context.tr('step_1_desc'),
          icon: Icons.settings_rounded,
          color: AppColors.primary,
          onTap: () => onNavigate(1),
        ),
        const Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 18),
        _buildWorkflowStep(
          step: '२',
          title: context.tr('step_2_title'),
          desc: context.tr('step_2_desc'),
          icon: Icons.person_add_alt_1_rounded,
          color: const Color(0xFFD97706),
          onTap: () => onNavigate(2),
        ),
        const Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 18),
        _buildWorkflowStep(
          step: '३',
          title: context.tr('step_3_title'),
          desc: context.tr('step_3_desc'),
          icon: Icons.fact_check_rounded,
          color: AppColors.teal,
          onTap: () => onNavigate(3),
        ),
        const Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 18),
        _buildWorkflowStep(
          step: '४',
          title: context.tr('step_4_title'),
          desc: context.tr('step_4_desc'),
          icon: Icons.print_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => onNavigate(6),
        ),
      ],
    );
  }

  Widget _buildMobileWorkflow(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMobileStepCard(
                step: '१',
                title: context.tr('step_1_title'),
                icon: Icons.settings_rounded,
                color: AppColors.primary,
                onTap: () => onNavigate(1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMobileStepCard(
                step: '२',
                title: context.tr('step_2_title'),
                icon: Icons.person_add_alt_1_rounded,
                color: const Color(0xFFD97706),
                onTap: () => onNavigate(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMobileStepCard(
                step: '३',
                title: context.tr('step_3_title'),
                icon: Icons.fact_check_rounded,
                color: AppColors.teal,
                onTap: () => onNavigate(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMobileStepCard(
                step: '४',
                title: context.tr('step_4_title'),
                icon: Icons.print_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => onNavigate(6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileStepCard({
    required String step,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color,
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowStep({
    required String step,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'पायरी $step: $title',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid({
    required bool isMobile,
    required double screenWidth,
    required List<Widget> children,
  }) {
    final crossAxisCount = isMobile ? 2 : (screenWidth < 1100 ? 3 : 4);
    final childAspectRatio = isMobile ? 1.35 : 1.8;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 10 : 14,
      mainAxisSpacing: isMobile ? 10 : 14,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }

  Widget _buildActionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 10 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 19),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildUpdateBanner(BuildContext context, AppUpdateInfo update, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rocket_launch_rounded, color: AppColors.accent, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'नवीन व्हर्जन अपडेट उपलब्ध!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gradeA1,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'v${update.latestVersion}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => AppUpdateService.showUpdateModal(context, update),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('आता अपडेट करा'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.rocket_launch, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'नवीन ऑनलाइन व्हर्जन अपडेट उपलब्ध आहे!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gradeA1,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'v${update.latestVersion}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${update.releaseTitle} • GitHub वर नवीन व्हर्जन उपलब्ध आहे.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: () => AppUpdateService.showUpdateModal(context, update),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('आता अपडेट करा'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ],
            ),
    );
  }
}
