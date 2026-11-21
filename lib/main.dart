import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/services/app_update_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/localization/app_translations.dart';
import 'providers/app_state_provider.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/language_selector_sheet.dart';
import 'widgets/user_profile_modal.dart';
import 'widgets/windows_page_nav_bar.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/school_settings/school_settings_screen.dart';
import 'screens/students/students_list_screen.dart';
import 'screens/evaluation/marks_entry_screen.dart';
import 'screens/evaluation/descriptive_notes_screen.dart';
import 'screens/evaluation/attendance_screen.dart';
import 'screens/reports/progress_card_screen.dart';
import 'screens/reports/result_gazette_screen.dart';
import 'screens/reports/bonafide_certificate_screen.dart';
import 'screens/reports/leaving_certificate_screen.dart';
import 'screens/reports/general_register_extract_screen.dart';
import 'screens/reports/yearly_class_students_screen.dart';
import 'screens/reports/statistics_screen.dart';
import 'screens/students/student_promotion_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/users/teacher_allocation_screen.dart';
import 'screens/portal/student_parent_portal_screen.dart';
import 'screens/portal_admin/homework_exam_management_screen.dart';
import 'screens/mdm/mdm_management_screen.dart';
import 'screens/entitlements/free_entitlements_screen.dart';
import 'screens/reports/monthly_attendance_abstract_screen.dart';
import 'screens/smc/smc_management_screen.dart';
import 'screens/dead_stock/dead_stock_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/teachers/teacher_service_screen.dart';
import 'screens/admin_registers/inward_outward_health_screen.dart';
import 'screens/students/student_id_cards_screen.dart';
import 'screens/tools/saral_udise_sync_screen.dart';
import 'screens/portal/ebooks_library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: const Color(0xFFF8FAFC),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF1E88E5), size: 36),
          const SizedBox(height: 10),
          const Text(
            'घटक लोड करताना अडचण आली (कृपया रीफ्रेश करा)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            details.exceptionAsString(),
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  };
  runApp(const MySchoolApp());
}

class MySchoolApp extends StatelessWidget {
  const MySchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: MaterialApp(
        title: 'iSecure EduMaster CCE Pro - शाळा मूल्यांकन प्रणाली',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainShellScreen(),
      ),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  final List<int> _backStack = [];
  final List<int> _forwardStack = [];
  AppStateProvider? _observedState;
  String? _shownUpdateVersion;
  String? _lastSessionUserId;
  DateTime? _lastBackPressTime;

  void _handleAppExit(BuildContext context) {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('press_again_to_exit') != 'press_again_to_exit'
                ? context.tr('press_again_to_exit')
                : 'बाहेर पडण्यासाठी पुन्हा बॅक बटण दाबा',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppStateProvider>();
    if (identical(_observedState, state)) return;
    _observedState?.removeListener(_handleStateChange);
    _observedState = state;
    _lastSessionUserId = state.isLoggedIn ? state.currentUser?.id : null;
    if (state.isLoggedIn && (state.currentUser?.isStudent ?? false)) {
      _currentIndex = _normalizeIndex(_currentIndex, true);
    }
    state.addListener(_handleStateChange);
    _handleStateChange();
  }

  void _handleStateChange() {
    final state = _observedState;
    if (!mounted || state == null) return;

    final userId = state.isLoggedIn ? state.currentUser?.id : null;
    if (userId != _lastSessionUserId) {
      _lastSessionUserId = userId;
      final defaultIndex = _homeIndex(state.currentUser?.isStudent ?? false);
      if (_currentIndex != defaultIndex ||
          _backStack.isNotEmpty ||
          _forwardStack.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _currentIndex = defaultIndex;
            _backStack.clear();
            _forwardStack.clear();
          });
        });
      }
    }

    _showAvailableUpdate();
  }

  void _showAvailableUpdate() {
    final update = _observedState?.automaticUpdatePrompt;
    if (!mounted ||
        update == null ||
        !update.hasUpdate ||
        _shownUpdateVersion == update.latestVersion) {
      return;
    }
    _shownUpdateVersion = update.latestVersion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppUpdateService.showUpdateModal(context, update);
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _observedState?.removeListener(_handleStateChange);
    super.dispose();
  }

  int _homeIndex(bool isStudent) => isStudent ? 15 : 0;

  int _normalizeIndex(int index, bool isStudent) {
    if (isStudent) {
      const allowed = {5, 6, 15, 25, 27};
      return allowed.contains(index) ? index : 15;
    }
    return (index >= 0 && index <= 27) ? index : 0;
  }

  bool _canGoBack(bool isStudent) {
    final current = _normalizeIndex(_currentIndex, isStudent);
    return _backStack.isNotEmpty || current != _homeIndex(isStudent);
  }

  int? _previousPageIndex(bool isStudent) {
    if (_backStack.isNotEmpty) return _backStack.last;
    final current = _normalizeIndex(_currentIndex, isStudent);
    final home = _homeIndex(isStudent);
    return current != home ? home : null;
  }

  void _navigateTo(int index) {
    final isStudent = _observedState?.currentUser?.isStudent ?? false;
    final current = _normalizeIndex(_currentIndex, isStudent);
    final target = _normalizeIndex(index, isStudent);
    if (target == current) return;

    setState(() {
      _backStack.add(current);
      if (_backStack.length > 50) {
        _backStack.removeAt(0);
      }
      _forwardStack.clear();
      _currentIndex = target;
    });
  }

  void _goBack(bool isStudent) {
    final current = _normalizeIndex(_currentIndex, isStudent);
    final home = _homeIndex(isStudent);
    if (_backStack.isNotEmpty) {
      setState(() {
        _forwardStack.add(current);
        _currentIndex = _backStack.removeLast();
      });
    } else if (current != home) {
      setState(() {
        _forwardStack.add(current);
        _currentIndex = home;
      });
    }
  }

  void _goForward(bool isStudent) {
    if (_forwardStack.isEmpty) return;
    final current = _normalizeIndex(_currentIndex, isStudent);
    setState(() {
      _backStack.add(current);
      _currentIndex = _forwardStack.removeLast();
    });
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (!mounted) return false;
    final state = _observedState;
    if (state == null || state.isLoading || !state.isLoggedIn) return false;
    if (ModalRoute.of(context)?.isCurrent != true) return false;
    if (!HardwareKeyboard.instance.isAltPressed) return false;

    final isStudent = state.currentUser?.isStudent ?? false;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_canGoBack(isStudent)) {
        _goBack(isStudent);
        return true;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_forwardStack.isNotEmpty) {
        _goForward(isStudent);
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/isecure_favicon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0284C7),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                state.school.schoolName.isNotEmpty
                    ? state.school.schoolName
                    : 'जिल्हा परिषद प्राथमिक शाळा',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                '॥ शिक्षण हेच जीवन ॥ • iSecure EduMaster CCE Pro',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  color: Color(0xFF0284C7),
                  backgroundColor: Color(0xFFE2E8F0),
                  minHeight: 3.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.isLoggedIn) {
      return const LoginScreen();
    }

    Widget currentScreen;
    if (state.currentUser?.isStudent ?? false) {
      switch (_currentIndex) {
        case 5:
          currentScreen = const AttendanceScreen();
          break;
        case 6:
          currentScreen = const ProgressCardScreen();
          break;
        case 25:
          currentScreen = const StudentIdCardsScreen();
          break;
        case 27:
          currentScreen = const EbooksLibraryScreen();
          break;
        case 15:
        case 0:
        default:
          currentScreen = const StudentParentPortalScreen();
      }
    } else {
      switch (_currentIndex) {
        case 0:
          currentScreen = DashboardScreen(onNavigate: _navigateTo);
          break;
        case 1:
          currentScreen = const SchoolSettingsScreen();
          break;
        case 2:
          currentScreen = const StudentsListScreen();
          break;
        case 3:
          currentScreen = const MarksEntryScreen();
          break;
        case 4:
          currentScreen = const DescriptiveNotesScreen();
          break;
        case 5:
          currentScreen = const AttendanceScreen();
          break;
        case 6:
          currentScreen = const ProgressCardScreen();
          break;
        case 7:
          currentScreen = const ResultGazetteScreen();
          break;
        case 8:
          currentScreen = const BonafideCertificateScreen();
          break;
        case 9:
          currentScreen = const LeavingCertificateScreen();
          break;
        case 10:
          currentScreen = const GeneralRegisterExtractScreen();
          break;
        case 11:
          currentScreen = const YearlyClassStudentsScreen();
          break;
        case 12:
          currentScreen = const StatisticsScreen();
          break;
        case 13:
          currentScreen = const StudentPromotionScreen();
          break;
        case 14:
          currentScreen = const TeacherAllocationScreen();
          break;
        case 15:
          currentScreen = const StudentParentPortalScreen();
          break;
        case 16:
          currentScreen = const HomeworkExamManagementScreen();
          break;
        case 17:
          currentScreen = const MdmManagementScreen();
          break;
        case 18:
          currentScreen = const FreeEntitlementsScreen();
          break;
        case 19:
          currentScreen = const MonthlyAttendanceAbstractScreen();
          break;
        case 20:
          currentScreen = const SmcManagementScreen();
          break;
        case 21:
          currentScreen = const DeadStockScreen();
          break;
        case 22:
          currentScreen = const LibraryScreen();
          break;
        case 23:
          currentScreen = const TeacherServiceScreen();
          break;
        case 24:
          currentScreen = const InwardOutwardHealthScreen();
          break;
        case 25:
          currentScreen = const StudentIdCardsScreen();
          break;
        case 26:
          currentScreen = const SaralUdiseSyncScreen();
          break;
        case 27:
          currentScreen = const EbooksLibraryScreen();
          break;
        default:
          currentScreen = DashboardScreen(onNavigate: _navigateTo);
      }
    }

    final isStudent = state.currentUser?.isStudent ?? false;
    final effectiveIndex = _normalizeIndex(_currentIndex, isStudent);
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    final isMobile = MediaQuery.of(context).size.width < 900;
    final homeIndex = _homeIndex(isStudent);
    final prevIndex = _previousPageIndex(isStudent);
    final nextIndex = _forwardStack.isNotEmpty ? _forwardStack.last : null;

    Widget buildContentWithWindowsNavBar() {
      return Column(
        children: [
          WindowsPageNavBar(
            canGoBack: _canGoBack(isStudent),
            canGoForward: _forwardStack.isNotEmpty,
            isHome: effectiveIndex == homeIndex,
            currentTitle: WindowsPageNavBar.titleForIndex(
              effectiveIndex,
              isStudent: isStudent,
            ),
            previousTitle: prevIndex != null
                ? WindowsPageNavBar.titleForIndex(
                    prevIndex,
                    isStudent: isStudent,
                  )
                : null,
            nextTitle: nextIndex != null
                ? WindowsPageNavBar.titleForIndex(
                    nextIndex,
                    isStudent: isStudent,
                  )
                : null,
            homeLabel: isStudent ? 'पोर्टल' : 'डॅशबोर्ड',
            onBack: () => _goBack(isStudent),
            onForward: () => _goForward(isStudent),
            onHome: () => _navigateTo(homeIndex),
          ),
          Expanded(child: currentScreen),
        ],
      );
    }

    if (isMobile) {
      final scaffoldKey = GlobalKey<ScaffoldState>();
      final int bottomNavIndex;
      if (isStudent) {
        switch (effectiveIndex) {
          case 5:
            bottomNavIndex = 1;
            break;
          case 6:
            bottomNavIndex = 2;
            break;
          case 27:
            bottomNavIndex = 3;
            break;
          case 15:
          default:
            bottomNavIndex = 0;
            break;
        }
      } else {
        switch (effectiveIndex) {
          case 0:
            bottomNavIndex = 0;
            break;
          case 2:
            bottomNavIndex = 1;
            break;
          case 3:
            bottomNavIndex = 2;
            break;
          case 27:
            bottomNavIndex = 3;
            break;
          default:
            bottomNavIndex = 4;
            break;
        }
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_canGoBack(isStudent)) {
            _goBack(isStudent);
          } else {
            _handleAppExit(context);
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            backgroundColor: AppColors.sidebarBg,
            foregroundColor: Colors.white,
            elevation: 1,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              tooltip: 'मेनू उघडा',
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            title: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withOpacity(0.12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/isecure_favicon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppTranslations.screenTitle(
                      effectiveIndex,
                      state.currentLanguage,
                      isStudent: isStudent,
                    ),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              // Quick Language Switcher Pill
              InkWell(
                onTap: () => LanguageSelectorSheet.show(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.currentLanguage == 'mr'
                            ? '🚩 MR'
                            : state.currentLanguage == 'hi'
                                ? '🇮🇳 HI'
                                : '🇬🇧 EN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // User Profile Avatar with Role Ring
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => UserProfileModal.show(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: state.currentUser?.isSuperAdmin == true
                            ? const Color(0xFFEF4444)
                            : state.currentUser?.isAdmin == true
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF10B981),
                        width: 1.8,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: state.currentUser?.isSuperAdmin == true
                          ? const Color(0xFFDC2626)
                          : state.currentUser?.isAdmin == true
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF059669),
                      child: Icon(
                        state.currentUser?.isSuperAdmin == true
                            ? Icons.security_rounded
                            : state.currentUser?.isAdmin == true
                                ? Icons.admin_panel_settings_rounded
                                : Icons.person_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          drawer: Drawer(
            child: Builder(
              builder: (drawerCtx) => AppSidebar(
                selectedIndex: effectiveIndex,
                onDestinationSelected: (idx) {
                  Navigator.of(drawerCtx).pop();
                  _navigateTo(idx);
                },
              ),
            ),
          ),
          body: isWindows ? buildContentWithWindowsNavBar() : currentScreen,
          bottomNavigationBar: NavigationBar(
            height: 64,
            elevation: 3,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primary.withOpacity(0.14),
            selectedIndex: bottomNavIndex,
            onDestinationSelected: (idx) {
              if (isStudent) {
                switch (idx) {
                  case 0:
                    _navigateTo(15);
                    break;
                  case 1:
                    _navigateTo(5);
                    break;
                  case 2:
                    _navigateTo(6);
                    break;
                  case 3:
                    _navigateTo(27);
                    break;
                  case 4:
                    UserProfileModal.show(context);
                    break;
                }
              } else {
                switch (idx) {
                  case 0:
                    _navigateTo(0);
                    break;
                  case 1:
                    _navigateTo(2);
                    break;
                  case 2:
                    _navigateTo(3);
                    break;
                  case 3:
                    _navigateTo(27);
                    break;
                  case 4:
                    scaffoldKey.currentState?.openDrawer();
                    break;
                }
              }
            },
            destinations: isStudent
                ? [
                    NavigationDestination(
                      icon: const Icon(Icons.school_outlined, size: 22),
                      selectedIcon: const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_portal'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.event_available_outlined, size: 22),
                      selectedIcon: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_attendance'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.card_membership_outlined, size: 22),
                      selectedIcon: const Icon(Icons.card_membership_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('progress_card'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.menu_book_outlined, size: 22),
                      selectedIcon: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_ebooks'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline_rounded, size: 22),
                      selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_profile'),
                    ),
                  ]
                : [
                    NavigationDestination(
                      icon: const Icon(Icons.dashboard_outlined, size: 22),
                      selectedIcon: const Icon(Icons.dashboard_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_home'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.people_alt_outlined, size: 22),
                      selectedIcon: const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_students'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.fact_check_outlined, size: 22),
                      selectedIcon: const Icon(Icons.fact_check_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_marks'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.menu_book_outlined, size: 22),
                      selectedIcon: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_ebooks'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.grid_view_rounded, size: 22),
                      selectedIcon: const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 22),
                      label: context.tr('nav_more'),
                    ),
                  ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Fixed Left Navigation Rail
          AppSidebar(
            selectedIndex: effectiveIndex,
            onDestinationSelected: _navigateTo,
          ),
          // Main Content View with Windows Back Navigation Bar
          Expanded(child: buildContentWithWindowsNavBar()),
        ],
      ),
    );
  }
}
