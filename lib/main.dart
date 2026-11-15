import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'providers/app_state_provider.dart';
import 'widgets/app_sidebar.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'CCE 8.1 PRO लोड होत आहे...',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
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
      default:
        currentScreen = DashboardScreen(onNavigate: _navigateTo);
    }

    final isMobile = MediaQuery.of(context).size.width < 900;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.sidebarBg,
          foregroundColor: Colors.white,
          title: Text(
            _currentIndex == 15
                ? 'विद्यार्थी व पालक पोर्टल 📱'
                : 'iSecure EduMaster CCE Pro',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.school, color: AppColors.accent),
              tooltip: 'विद्यार्थी व पालक पोर्टल (Student & Parent)',
              onPressed: () => _navigateTo(15),
            ),
          ],
        ),
        drawer: Drawer(
          child: Builder(
            builder: (drawerCtx) => AppSidebar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) {
                Navigator.of(drawerCtx).pop();
                _navigateTo(idx);
              },
            ),
          ),
        ),
        body: currentScreen,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Fixed Left Navigation Rail
          AppSidebar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _navigateTo,
          ),
          // Main Content View
          Expanded(child: currentScreen),
        ],
      ),
    );
  }
}
