import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschool/main.dart';

void main() {
  testWidgets('Test Full MySchoolApp and open admission form', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(const MySchoolApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Enter credentials directly
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));
    await tester.enterText(textFields.at(0), 'admin');
    await tester.enterText(textFields.at(1), 'admin');
    await tester.pump();

    // Tap "लॉगिन करा (Sign In)" submit button
    final signInBtn = find.text('लॉगिन करा (Sign In)');
    expect(signInBtn, findsOneWidget);
    await tester.ensureVisible(signInBtn);
    await tester.tap(signInBtn);
    await tester.pumpAndSettle();

    // Tap on navigation item 2 (StudentsListScreen)
    final studentsNav = find.text('विद्यार्थी यादी (Students)');
    expect(studentsNav, findsOneWidget);
    await tester.tap(studentsNav);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap on "नवीन प्रवेश नोंदणी (New Admission)" button
    final addAdmissionBtn = find.text('नवीन प्रवेश नोंदणी (New Admission)');
    expect(addAdmissionBtn, findsOneWidget);
    await tester.tap(addAdmissionBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Allow pending update timer to fire
    await tester.pump(const Duration(seconds: 4));
  });
}
