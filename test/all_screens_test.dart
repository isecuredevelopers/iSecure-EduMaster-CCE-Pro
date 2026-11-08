import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/screens/dashboard/dashboard_screen.dart';
import 'package:myschool/screens/school_settings/school_settings_screen.dart';
import 'package:myschool/screens/students/students_list_screen.dart';
import 'package:myschool/screens/students/student_form_screen.dart';
import 'package:myschool/screens/students/student_promotion_screen.dart';
import 'package:myschool/screens/evaluation/marks_entry_screen.dart';
import 'package:myschool/screens/evaluation/descriptive_notes_screen.dart';
import 'package:myschool/screens/evaluation/attendance_screen.dart';
import 'package:myschool/screens/reports/progress_card_screen.dart';
import 'package:myschool/screens/reports/result_gazette_screen.dart';
import 'package:myschool/screens/reports/bonafide_certificate_screen.dart';
import 'package:myschool/screens/reports/statistics_screen.dart';

void main() {
  testWidgets('Test All Screens', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    final provider = AppStateProvider();
    final screens = [
      DashboardScreen(onNavigate: (_) {}),
      const SchoolSettingsScreen(),
      const StudentsListScreen(),
      const StudentFormScreen(),
      const StudentPromotionScreen(),
      const MarksEntryScreen(),
      const DescriptiveNotesScreen(),
      const AttendanceScreen(),
      const ProgressCardScreen(),
      const ResultGazetteScreen(),
      const BonafideCertificateScreen(),
      const StatisticsScreen(),
    ];

    for (final s in screens) {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(body: s),
          ),
        ),
      );
      await tester.pump();
    }
  });
}

