import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test Autocomplete in student_form_screen', (WidgetTester tester) async {
    final religionCtrl = TextEditingController(text: 'हिंदू');
    final religionOptions = ['हिंदू', 'मुस्लीम'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Autocomplete<String>(
            initialValue: TextEditingValue(text: religionCtrl.text),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return religionOptions;
              }
              return religionOptions.where((String option) {
                return option.contains(textEditingValue.text);
              });
            },
            onSelected: (String selection) {
              religionCtrl.text = selection;
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              controller.addListener(() {
                religionCtrl.text = controller.text;
              });
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'धर्म (Religion)',
                  hintText: 'उदा. हिंदू, मुस्लीम, बौद्ध',
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}

