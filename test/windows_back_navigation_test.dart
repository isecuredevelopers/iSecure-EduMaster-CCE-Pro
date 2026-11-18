import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschool/main.dart';
import 'package:myschool/screens/dashboard/dashboard_screen.dart';
import 'package:myschool/screens/evaluation/marks_entry_screen.dart';
import 'package:myschool/screens/students/students_list_screen.dart';
import 'package:myschool/widgets/windows_page_nav_bar.dart';

void main() {
  Future<void> loginAsAdmin(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MySchoolApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));
    await tester.enterText(textFields.at(0), 'admin');
    await tester.enterText(textFields.at(1), 'admin');
    await tester.pump();

    final signInBtn = find.text('लॉगिन करा (Sign In)');
    await tester.ensureVisible(signInBtn);
    await tester.tap(signInBtn);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Windows back, forward, home buttons and Alt+Left shortcut work across pages',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

    await loginAsAdmin(tester);

    // Initially on Dashboard with WindowsPageNavBar present
    expect(find.byType(WindowsPageNavBar), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byKey(const Key('windows_back_button')), findsOneWidget);

    // Navigate to Students List
    await tester.tap(find.text('विद्यार्थी यादी (Students)'));
    await tester.pumpAndSettle();
    expect(find.byType(StudentsListScreen), findsOneWidget);
    expect(find.byKey(const Key('windows_back_button')), findsOneWidget);
    expect(find.byKey(const Key('windows_home_button')), findsOneWidget);

    // Navigate to Marks Entry
    await tester.tap(find.text('आकारिक-संकलित गुणनोंद (Marks)'));
    await tester.pumpAndSettle();
    expect(find.byType(MarksEntryScreen), findsOneWidget);

    // Click Back -> returns to Students List
    await tester.tap(find.byKey(const Key('windows_back_button')));
    await tester.pumpAndSettle();
    expect(find.byType(StudentsListScreen), findsOneWidget);

    // Click Forward -> returns to Marks Entry
    await tester.tap(find.byKey(const Key('windows_forward_button')));
    await tester.pumpAndSettle();
    expect(find.byType(MarksEntryScreen), findsOneWidget);

    // Alt + Left Arrow -> returns to Students List
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.byType(StudentsListScreen), findsOneWidget);

    // Click Back again -> returns to Dashboard
    await tester.tap(find.byKey(const Key('windows_back_button')));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Navigate to Marks Entry then use Home button to jump straight to Dashboard
    await tester.tap(find.text('आकारिक-संकलित गुणनोंद (Marks)'));
    await tester.pumpAndSettle();
    expect(find.byType(MarksEntryScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('windows_home_button')));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Back from Dashboard returns to Marks Entry because we navigated from there
    await tester.tap(find.byKey(const Key('windows_back_button')));
    await tester.pumpAndSettle();
    expect(find.byType(MarksEntryScreen), findsOneWidget);

    // Allow pending update timer to fire cleanly
    await tester.pump(const Duration(seconds: 4));
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('WindowsPageNavBar renders without overflow at narrow Windows width', (
    WidgetTester tester,
  ) async {
    bool backPressed = false;
    bool forwardPressed = false;
    bool homePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: WindowsPageNavBar(
              canGoBack: true,
              canGoForward: true,
              isHome: false,
              currentTitle: 'मोफत पाठ्यपुस्तके व गणवेश (समग्र शिक्षा)',
              previousTitle: 'शालेय पोषण आहार (PM POSHAN)',
              nextTitle: 'विद्यार्थी यादी (Students)',
              homeLabel: 'डॅशबोर्ड',
              onBack: () => backPressed = true,
              onForward: () => forwardPressed = true,
              onHome: () => homePressed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('मागे जा'), findsOneWidget);
    await tester.tap(find.byKey(const Key('windows_back_button')));
    await tester.tap(find.byKey(const Key('windows_forward_button')));
    await tester.tap(find.byKey(const Key('windows_home_button')));
    await tester.pump();

    expect(backPressed, isTrue);
    expect(forwardPressed, isTrue);
    expect(homePressed, isTrue);
  });
}
