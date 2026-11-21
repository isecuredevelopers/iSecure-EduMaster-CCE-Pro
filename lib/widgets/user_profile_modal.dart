import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_translations.dart';
import '../core/services/app_update_service.dart';
import '../providers/app_state_provider.dart';

class UserProfileModal extends StatelessWidget {
  const UserProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const _UserProfileBottomSheet(),
      );
    } else {
      return showDialog(
        context: context,
        builder: (ctx) => const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(24),
          child: _UserProfileContent(isDialog: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _UserProfileContent(isDialog: false);
  }
}

class _UserProfileBottomSheet extends StatelessWidget {
  const _UserProfileBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Grab handle
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const _UserProfileContent(isDialog: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfileContent extends StatelessWidget {
  final bool isDialog;

  const _UserProfileContent({required this.isDialog});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final user = state.currentUser;
    final currentLang = state.currentLanguage;

    final content = Container(
      width: isDialog ? 440 : double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: isDialog
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title & Close Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('user_profile'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      user?.name ?? 'iSecure User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: Colors.grey.shade600,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: user?.isSuperAdmin == true
                    ? [const Color(0xFF7F1D1D), const Color(0xFF991B1B)]
                    : user?.isAdmin == true
                        ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)]
                        : [const Color(0xFF065F46), const Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (user?.isSuperAdmin == true
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF2563EB))
                      .withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    user?.isSuperAdmin == true
                        ? Icons.security_rounded
                        : user?.isAdmin == true
                            ? Icons.admin_panel_settings_rounded
                            : Icons.person_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user?.isSuperAdmin == true
                              ? context.tr('role_superadmin')
                              : user?.isAdmin == true
                                  ? context.tr('role_admin')
                                  : user?.isHeadmaster == true
                                      ? context.tr('role_headmaster')
                                      : user?.isTeacher == true
                                          ? context.tr('role_teacher')
                                          : context.tr('role_student'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.isAdmin == true
                            ? context.tr('all_classes_access')
                            : (user?.allocationSummary ?? ''),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // LANGUAGE SELECTION SECTION
          Row(
            children: [
              const Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                context.tr('select_language'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('choose_app_language'),
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          // 3 Language Option Tiles (Marathi, English, Hindi)
          Row(
            children: AppTranslations.supportedLanguages.map((lang) {
              final code = lang['code']!;
              final isSelected = currentLang == code;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      state.setLanguage(code);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            code == 'mr'
                                ? 'भाषा मराठीमध्ये बदलली आहे.'
                                : code == 'en'
                                    ? 'Language set to English.'
                                    : 'भाषा हिंदी में बदली गई है।',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.08)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lang['flag'] ?? '',
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lang['name'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            lang['englishName'] ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // School & Software Information
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('school_details'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Text(
                      'v${AppUpdateService.currentVersion}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.school.schoolName.isNotEmpty
                            ? state.school.schoolName
                            : 'जिल्हा परिषद शाळा',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.pin_outlined, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      '${context.tr('udise_code')}: ${state.school.udiseCode.isNotEmpty ? state.school.udiseCode : '27250000000'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Logout Action Button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmLogout(context, state);
            },
            icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFDC2626)),
            label: Text(
              context.tr('logout'),
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              backgroundColor: const Color(0xFFFEF2F2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );

    return content;
  }

  void _confirmLogout(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Color(0xFFDC2626)),
            const SizedBox(width: 10),
            Text(
              ctx.tr('logout_confirm_title'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(ctx.tr('logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ctx.tr('cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              state.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: Text(ctx.tr('logout')),
          ),
        ],
      ),
    );
  }
}
