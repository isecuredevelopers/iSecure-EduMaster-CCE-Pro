import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/screens/students/students_list_screen.dart';
import 'package:myschool/screens/students/student_form_screen.dart';

void main() {
  testWidgets('Test StudentsListScreen and StudentFormScreen', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: StudentsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Now push StudentFormScreen
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: StudentFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}

