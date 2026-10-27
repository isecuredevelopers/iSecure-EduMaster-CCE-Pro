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
import 'screens/reports/statistics_screen.dart';
import 'screens/students/student_promotion_screen.dart';

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
        currentScreen = const StatisticsScreen();
        break;
      case 10:
        currentScreen = const StudentPromotionScreen();
        break;
      default:
        currentScreen = DashboardScreen(onNavigate: _navigateTo);
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
