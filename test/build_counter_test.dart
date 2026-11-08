import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test buildCounter returning null', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextFormField(
            maxLength: 19,
            buildCounter: (ctx, {required currentLength, required isFocused, maxLength}) => null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}

