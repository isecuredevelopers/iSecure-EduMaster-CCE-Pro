import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myschool/data/models/general_register_extract_model.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/screens/reports/general_register_extract_screen.dart';

void main() {
  test('GeneralRegisterExtractModel JSON roundtrip test', () {
    final extract = GeneralRegisterExtractModel(
      id: 'gr_extract_test',
      studentId: 'stu-01',
      generalRegNo: '780',
      uDiseNo: '27260105501',
      studentName: 'वायळ रचना विठ्ठल',
      motherName: 'उज्वला विठ्ठल वायळ',
      caste: 'मराठा',
      subCaste: 'कुणबी',
      birthPlace: 'अकोले',
      dob: DateTime(2018, 8, 13),
      dobWords: 'तेरा ऑगस्ट दोन हजार अठरा',
      previousSchool: 'जि. प. शाळा',
      admissionDate: DateTime(2024, 6, 15),
      admissionClass: '1 ली',
      progress: 'चांगली',
      conduct: 'चांगली',
      leavingDate: null,
      currentClass: 'इयत्ता 1 ली',
      reasonForLeaving: '-',
      remarks: 'हुशार विद्यार्थी',
      issueDate: DateTime.now(),
      copyType: 'Original',
      isCurrentlyStudying: true,
    );

    final json = extract.toJson();
    final restored = GeneralRegisterExtractModel.fromJson(json);

    expect(restored.studentName, equals('वायळ रचना विठ्ठल'));
    expect(restored.generalRegNo, equals('780'));
    expect(restored.copyTypeTextMr, equals('मूळ प्रत'));
    expect(restored.isCurrentlyStudying, isTrue);
  });

  testWidgets('GeneralRegisterExtractScreen widget smoke test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    final provider = AppStateProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppStateProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: GeneralRegisterExtractScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify Title and Table Labels
    expect(find.textContaining('रजिस्टर नंबर १ चा उतारा'), findsWidgets);
    expect(find.textContaining('विद्यार्थ्याचे पूर्ण नाव'), findsWidgets);
    expect(find.textContaining('आईचे नाव'), findsWidgets);
    expect(find.textContaining('जात व पोटजात'), findsWidgets);
  });
}

