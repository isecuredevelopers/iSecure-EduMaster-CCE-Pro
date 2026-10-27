import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SchoolLogoWidget(
                      logoUrl: state.school.logoUrl,
                      size: 52,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.school.schoolName.isNotEmpty
                              ? state.school.schoolName
                              : 'iSecure EduMaster CCE Pro - शाळा मूल्यांकन प्रणाली',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.school.sansthaName} • U-DISE: ${state.school.udiseCode} • केंद्र: ${state.school.cluster} • ता. ${state.school.blockTaluka} जि. ${state.school.district}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => onNavigate(6), // Progress Cards
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('प्रगती पुस्तक प्रिंट करा'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Online GitHub New Version Available Banner
            if (state.availableUpdate != null && state.availableUpdate!.hasUpdate)
              _buildUpdateBanner(context, state.availableUpdate!),

            // Metric Cards Row
            Row(
              children: [
                _buildStatCard(
                  title: 'एकूण विद्यार्थी संख्या',
                  value: '${students.length}',
                  subtitle: 'शाळेतील सर्व वर्ग',
                  icon: Icons.groups,
                  color: AppColors.primaryLight,
                  onTap: () => onNavigate(2),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'इ. ${state.selectedStd} तुकडी ${state.selectedDiv} विद्यार्थी',
                  value: '${curClassStudents.length}',
                  subtitle: 'सत्र ${state.selectedSemester} चालू वर्ग',
                  icon: Icons.class_outlined,
                  color: AppColors.teal,
                  onTap: () => onNavigate(2),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'मुले (Boys)',
                  value: '$boysCount',
                  subtitle: 'एकूण संख्या',
                  icon: Icons.boy,
                  color: AppColors.gradeB2,
                  onTap: () => onNavigate(9),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'मुली (Girls)',
                  value: '$girlsCount',
                  subtitle: 'एकूण संख्या',
                  icon: Icons.girl,
                  color: const Color(0xFFEC4899),
                  onTap: () => onNavigate(9),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // CCE Workflow Stepper (Matching Kiran Sonawane's Flow Chart)
            const Text(
              'CCE मूल्यमापन कार्यप्रवाह (Work Flow Steps)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildWorkflowStep(
                        step: '१',
                        title: 'पायाभूत माहिती व सेटिंग्ज',
                        desc: 'शाळा माहिती, विषय, भारांश, कामाचे दिवस',
                        icon: Icons.settings,
                        color: AppColors.primary,
                        onTap: () => onNavigate(1),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.textMuted),
                      _buildWorkflowStep(
                        step: '२',
                        title: 'विद्यार्थी यादी नोंदणी',
                        desc: 'दाखला क्र, जन्मतारीख, जात संवर्ग, आधार',
                        icon: Icons.person_add_alt_1,
                        color: const Color(0xFFD97706),
                        onTap: () => onNavigate(2),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.textMuted),
                      _buildWorkflowStep(
                        step: '३',
                        title: 'गुणनोंद व वर्णनात्मक नोंदी',
                        desc: 'आकारिक-संकलित गुण, हजेरी, नोंदी',
                        icon: Icons.fact_check,
                        color: AppColors.teal,
                        onTap: () => onNavigate(3),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.textMuted),
                      _buildWorkflowStep(
                        step: '४',
                        title: 'प्रिंट प्रगतीपुस्तक व निकाल',
                        desc: 'सत्रांत निकालपत्रक, प्रगतीपुस्तक, गॅझेट',
                        icon: Icons.print,
                        color: const Color(0xFF8B5CF6),
                        onTap: () => onNavigate(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Modules Grid
            const Text(
              'महत्त्वाची कार्ये (Quick Actions)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildActionCard(
                  title: 'सॉफ्टवेअर सेटिंग्ज (Whitelabel)',
                  desc: 'शाळा माहिती, लोगो, स्वाक्षरी, Supabase',
                  icon: Icons.tune,
                  color: AppColors.primary,
                  onTap: () => onNavigate(1),
                ),
                _buildActionCard(
                  title: 'आकारिक-संकलित गुणनोंद',
                  desc: 'सत्रनिहाय विषयनिहाय गुणनोंद तक्ता',
                  icon: Icons.edit_calendar,
                  color: AppColors.teal,
                  onTap: () => onNavigate(3),
                ),
                _buildActionCard(
                  title: 'वर्णनात्मक नोंदी (Remarks)',
                  desc: 'पूर्वनिर्धारित व सानुकूल वर्णनात्मक नोंदी',
                  icon: Icons.border_color,
                  color: const Color(0xFFF59E0B),
                  onTap: () => onNavigate(4),
                ),
                _buildActionCard(
                  title: 'माहेवार उपस्थिती (Attendance)',
                  desc: 'जून ते एप्रिल हजेरी व टक्केवारी',
                  icon: Icons.calendar_month,
                  color: const Color(0xFF3B82F6),
                  onTap: () => onNavigate(5),
                ),
                _buildActionCard(
                  title: 'प्रगती पुस्तक (Report Card)',
                  desc: 'रंगीबेरंगी व क्लासिक प्रगती पत्रके',
                  icon: Icons.school,
                  color: const Color(0xFF10B981),
                  onTap: () => onNavigate(6),
                ),
                _buildActionCard(
                  title: 'निकाल पत्रक (Result Gazette)',
                  desc: 'वार्षिक एकत्रित निकालपत्रक व एक्सेल',
                  icon: Icons.description,
                  color: const Color(0xFF6366F1),
                  onTap: () => onNavigate(7),
                ),
                _buildActionCard(
                  title: 'बोनाफाईड व ओळखपत्रे',
                  desc: 'दाखला प्रमाणपत्र व विद्यार्थी आयकार्ड',
                  icon: Icons.card_giftcard,
                  color: const Color(0xFFEC4899),
                  onTap: () => onNavigate(8),
                ),
                _buildActionCard(
                  title: 'वर्गोन्नती (Student Promotion)',
                  desc: 'पुढील वर्गात एका क्लिकवर स्थलांतर',
                  icon: Icons.drive_file_move_rtl,
                  color: const Color(0xFF14B8A6),
                  onTap: () => onNavigate(10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 22),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'पायरी $step: $title',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
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

  Widget _buildUpdateBanner(BuildContext context, AppUpdateInfo update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
                  '${update.releaseTitle} • GitHub वर नवीन व्हर्जन डिप्लॉय झाले आहे. त्वरित अपडेट करून नवीन सुधारणा लागू करा.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => AppUpdateService.launchUrl(update.releasePageUrl),
            icon: const Icon(Icons.open_in_browser, size: 16, color: Colors.white),
            label: const Text('GitHub पहा', style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white38),
            ),
          ),
          const SizedBox(width: 10),
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
