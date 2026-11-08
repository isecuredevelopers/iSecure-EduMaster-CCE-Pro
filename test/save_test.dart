import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/screens/students/student_form_screen.dart';

void main() {
  testWidgets('Test save student', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: StudentFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find the save button
    final saveBtn = find.text('प्रवेश निश्चित करा (Save Admission)');
    expect(saveBtn, findsOneWidget);

    // Tap save button
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();
  });
}

