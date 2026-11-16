import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myschool/data/models/leaving_certificate_model.dart';
import 'package:myschool/data/models/student_model.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/screens/auth/login_screen.dart';
import 'package:myschool/screens/portal/student_parent_portal_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Student Dedicated Account & LC Revocation Tests', () {
    test('Student individual login succeeds by GR No and DOB/password', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // There should be default students seeded
      expect(provider.students.isNotEmpty, isTrue);
      final student = provider.students.first;

      // Login using GR No and DOB
      final dd = student.dateOfBirth.day.toString().padLeft(2, '0');
      final mm = student.dateOfBirth.month.toString().padLeft(2, '0');
      final yyyy = student.dateOfBirth.year.toString();
      final dobStr = '$dd$mm$yyyy';

      final res = await provider.loginStudent(student.grNo, dobStr);
      expect(res['success'], isTrue);
      expect(provider.currentStudent?.id, equals(student.id));
      expect(provider.currentUser?.username, equals(student.grNo));
      expect(provider.currentUser?.isStudent, isTrue);

      // Logout clears session
      await provider.logout();
      expect(provider.currentStudent, isNull);
      expect(provider.currentUser, isNull);
    });

    test('Default PIN 123 also allows student login', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      final student = provider.students.first;

      final res = await provider.loginStudent(student.grNo, '123');
      expect(res['success'], isTrue);
      expect(provider.currentStudent?.id, equals(student.id));
      await provider.logout();
    });

    test('Wrong GR No or wrong password fails gracefully with Marathi message', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      final student = provider.students.first;

      final resWrongGr = await provider.loginStudent('9999999', '123');
      expect(resWrongGr['success'], isFalse);
      expect(resWrongGr['message'], contains('कोणताही विद्यार्थी आढळला नाही'));

      final resWrongPass = await provider.loginStudent(student.grNo, 'wrongPass');
      expect(resWrongPass['success'], isFalse);
      expect(resWrongPass['message'], contains('पासवर्ड चुकीचा आहे'));
    });

    test('Issuing School Leaving Certificate (L.C.) revokes app access while retaining Windows records', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      final student = provider.students.first;
      final totalBefore = provider.students.length;

      // Login student first
      await provider.loginStudent(student.grNo, '123');
      expect(provider.currentStudent?.id, equals(student.id));

      // School issues Leaving Certificate in Windows software
      final lc = provider.getOrCreateLeavingCertificate(student);
      lc.reasonForLeaving = 'दुसऱ्या शाळेत प्रवेशासाठी';
      await provider.issueLeavingCertificate(student, lc);

      // Student is flagged as left school
      expect(student.isLeftSchool, isTrue);
      expect(provider.isStudentLeftSchool(student), isTrue);

      // Active session of student must be automatically revoked (logged out)
      expect(provider.currentStudent, isNull);
      expect(provider.currentUser, isNull);

      // Subsequent login attempt by left student MUST BE BLOCKED
      final loginAttempt = await provider.loginStudent(student.grNo, '123');
      expect(loginAttempt['success'], isFalse);
      expect(loginAttempt['isLeft'], isTrue);
      expect(loginAttempt['message'], contains('शाळा सोडल्याचा दाखला'));

      // Windows software MUST retain the student's records permanently
      expect(provider.students.length, equals(totalBefore));
      final recordInDb = provider.students.firstWhere((s) => s.id == student.id);
      expect(recordInDb.isLeftSchool, isTrue);
      expect(recordInDb.lcNo, isNotNull);
      expect(recordInDb.leavingDate, isNotNull);
    });

    test('Administrative LC cancellation restores app access if needed', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      final student = provider.students.first;

      final lc = provider.getOrCreateLeavingCertificate(student);
      await provider.issueLeavingCertificate(student, lc);
      expect(provider.isStudentLeftSchool(student), isTrue);

      // Cancel LC (administrative correction)
      await provider.cancelLeavingCertificate(student);
      expect(provider.isStudentLeftSchool(student), isFalse);

      // Login now succeeds again
      final loginRes = await provider.loginStudent(student.grNo, '123');
      expect(loginRes['success'], isTrue);
      expect(provider.currentStudent?.id, equals(student.id));
      await provider.logout();
    });
  });

  group('LoginScreen & Student Portal Widget Tests', () {
    testWidgets('LoginScreen shows clean Student Tab with NO roles displayed', (tester) async {
      final provider = AppStateProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Check for Segmented Switcher
      expect(find.text('विद्यार्थी व पालक'), findsWidgets);
      expect(find.text('शिक्षक व कर्मचारी'), findsOneWidget);

      // Tap on Student tab
      await tester.tap(find.text('विद्यार्थी व पालक').first);
      await tester.pump(const Duration(milliseconds: 300));

      // In Student mode, GR No field and Password/DOB field are visible
      expect(find.text('जनरल रजिस्टर नंबर (GR No.) / सरल आयडी'), findsOneWidget);
      expect(find.text('पासवर्ड किंवा जन्मतारीख (Password / DOB)'), findsOneWidget);
      expect(find.textContaining('विद्यार्थी पोर्टलमध्ये प्रवेश करा'), findsOneWidget);

      // Zero roles displayed in student mode!
      expect(find.text('भूमिका निवडा (Select Login Role):'), findsNothing);
      expect(find.text('Vargshikshak (वर्गशिक्षक)'), findsNothing);
      expect(find.text('Mukhyadhyapak (मुख्याध्यापक)'), findsNothing);
      expect(find.text('Shipai (शिपाई)'), findsNothing);
      expect(find.text('Admin (प्रशासक)'), findsNothing);
      expect(find.text('Superadmin (सुपर ॲडमीन)'), findsNothing);
    });

    testWidgets('StudentParentPortalScreen locks student switching when student is logged in', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final provider = AppStateProvider();
      final student = provider.students.first;

      // Log in as student
      await provider.loginStudent(student.grNo, '123');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: StudentParentPortalScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // The "विद्यार्थी बदला" switcher button MUST NOT be present
      expect(find.text('विद्यार्थी बदला'), findsNothing);

      // Locked individual account badge must be shown
      expect(find.textContaining('वैयक्तिक खाते'), findsWidgets);
    });
  });
}
