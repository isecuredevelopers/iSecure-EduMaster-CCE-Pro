import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschool/data/models/user_model.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/screens/auth/login_screen.dart';
import 'package:myschool/screens/users/teacher_allocation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  test('UserModel & ClassAllocationModel roundtrip test', () {
    final user = UserModel(
      id: 'test_user_1',
      name: 'श्री. संतोष गायकवाड',
      username: 'teacher1',
      password: '123',
      role: 'teacher',
      mobile: '9876543211',
      allocatedClasses: [
        ClassAllocationModel(standard: 1, division: '1'),
        ClassAllocationModel(standard: 3, division: '2'),
      ],
    );

    expect(user.isAdmin, isFalse);
    expect(user.isTeacher, isTrue);
    expect(user.allocatedStandards, equals([1, 3]));
    expect(user.getAllocatedDivisionsFor(1), equals(['1']));
    expect(user.getAllocatedDivisionsFor(3), equals(['2']));
    expect(user.hasAccessTo(1, '1'), isTrue);
    expect(user.hasAccessTo(2, '1'), isFalse);

    final json = user.toJson();
    final parsed = UserModel.fromJson(json);
    expect(parsed.id, equals(user.id));
    expect(parsed.username, equals(user.username));
    expect(parsed.allocatedClasses.length, equals(2));
    expect(parsed.allocatedStandards, equals([1, 3]));
  });

  test('AppStateProvider login & class restriction test', () async {
    final state = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    // Initially logged in or default admin
    final adminSuccess = await state.login('admin', 'admin');
    expect(adminSuccess, isTrue);
    expect(state.isLoggedIn, isTrue);
    expect(state.currentUser!.isAdmin, isTrue);
    expect(state.availableStandards, equals([1, 2, 3, 4, 5, 6, 7, 8]));

    // Login as teacher1 (allocated Class 1)
    final teacher1Success = await state.login('teacher1', '123');
    expect(teacher1Success, isTrue);
    expect(state.currentUser!.isTeacher, isTrue);
    expect(state.availableStandards, equals([1]));
    expect(state.availableDivisions, equals(['1']));
    expect(state.selectedStd, equals(1));

    // Login as teacher2 (allocated Class 2 & 3)
    final teacher2Success = await state.login('teacher2', '123');
    expect(teacher2Success, isTrue);
    expect(state.currentUser!.isTeacher, isTrue);
    expect(state.availableStandards, equals([2, 3]));
    expect(state.selectedStd, isIn([2, 3]));

    // Login as isecure / Sagar@1998 (Master Superadmin)
    final isecureSuccess = await state.login('isecure', 'Sagar@1998');
    expect(isecureSuccess, isTrue);
    expect(state.currentUser!.isSuperAdmin, isTrue);
    expect(state.currentUser!.isAdmin, isTrue);
    expect(state.availableStandards, equals([1, 2, 3, 4, 5, 6, 7, 8]));

    // Login as superadmin / Sagar@1998
    final superadminSuccess = await state.login('superadmin', 'Sagar@1998');
    expect(superadminSuccess, isTrue);
    expect(state.currentUser!.isSuperAdmin, isTrue);

    // Login as superadmin / 123 (fallback)
    final superadminFallback = await state.login('superadmin', '123');
    expect(superadminFallback, isTrue);
    expect(state.currentUser!.isSuperAdmin, isTrue);

    // Verify isecure cannot be deleted or modified
    final initialUsersCount = state.users.length;
    await state.deleteUser('usr_isecure');
    expect(state.users.any((u) => u.username == 'isecure'), isTrue);
    expect(state.users.length, equals(initialUsersCount));

    // Attempt to corrupt or modify isecure
    final isecureUser = state.users.firstWhere((u) => u.username == 'isecure');
    expect(isecureUser.isMasterProtected, isTrue);
    await state.saveUser(UserModel(
      id: 'usr_isecure',
      name: 'Hacked Name',
      username: 'isecure',
      password: 'wrong_password',
      role: 'peon',
    ));
    // Verify isecure remains untouched
    final rechecked = state.users.firstWhere((u) => u.username == 'isecure');
    expect(rechecked.password, equals('Sagar@1998'));
    expect(rechecked.role, equals(AppRole.superadmin));

    // Logout
    await state.logout();
    expect(state.isLoggedIn, isFalse);
    expect(state.currentUser, isNull);
  });

  testWidgets('LoginScreen and TeacherAllocationScreen widget tests', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('प्रणालीमध्ये प्रवेश करा (Sign In)'), findsOneWidget);

    // Test TeacherAllocationScreen
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: TeacherAllocationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TeacherAllocationScreen), findsOneWidget);
    expect(find.text('शिक्षक नोंदणी व वर्ग वाटप (Teacher & Class Allocation)'), findsOneWidget);
    expect(find.text('संरक्षित (अपरिवर्तनीय)'), findsWidgets);
    expect(find.text('मास्टर संरक्षित'), findsWidgets);

    // Tap first edit button to open Teacher Edit Dialog
    final editButtons = find.byIcon(Icons.edit_outlined);
    expect(editButtons, findsWidgets);
    await tester.tap(editButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('शिक्षक माहिती व वर्ग वाटप संपादन'), findsOneWidget);
    expect(find.text('१. शिक्षकाचे प्राथमिक तपशील:'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('रद्द करा'));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('LoginScreen dynamic role selection and validation test', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    // Initially role selection is hidden (CrossFadeState.showFirst)
    final crossFade = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
    expect(crossFade.crossFadeState, equals(CrossFadeState.showFirst));

    // Enter username only -> still hidden
    await tester.enterText(textFields.at(0), 'teacher1');
    await tester.pump();
    final crossFade2 = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
    expect(crossFade2.crossFadeState, equals(CrossFadeState.showFirst));

    // Enter password -> now becomes visible!
    await tester.enterText(textFields.at(1), '123');
    await tester.pumpAndSettle();
    final crossFade3 = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
    expect(crossFade3.crossFadeState, equals(CrossFadeState.showSecond));
    expect(find.text('भूमिका निवडा (Select Login Role):'), findsOneWidget);

    // Verify all 5 roles are listed
    expect(find.text('Vargshikshak (वर्गशिक्षक)'), findsOneWidget);
    expect(find.text('Mukhyadhyapak (मुख्याध्यापक)'), findsOneWidget);
    expect(find.text('Shipai (शिपाई)'), findsOneWidget);
    expect(find.text('Admin (प्रशासक)'), findsOneWidget);
    expect(find.text('Superadmin (सुपर ॲडमीन)'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
  });
}
