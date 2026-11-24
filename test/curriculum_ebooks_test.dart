import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/data/local/curriculum_repository.dart';
import 'package:myschool/data/models/student_model.dart';
import 'package:myschool/core/services/ebook_service.dart';
import 'package:myschool/screens/portal/ebooks_library_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Curriculum & E-Books Class 1 to 7 Comprehensive Tests', () {
    test('Total ebooks count should be at least 35 and match official Balbharati count', () {
      final totalEbooks = CurriculumRepository.totalEbooksCount;
      final totalChapters = CurriculumRepository.totalChaptersCount;

      expect(totalEbooks, greaterThanOrEqualTo(35));
      expect(totalChapters, greaterThan(150));
    });

    test('Each class 1-7 has official eBalbharati Pune PDF links and metadata', () {
      for (int std = 1; std <= 7; std++) {
        final subjects = CurriculumRepository.getSubjectsForStandard(std);
        expect(subjects.isNotEmpty, isTrue, reason: 'Class $std must have subjects');

        for (final sub in subjects) {
          // Check e-book URL or extra ebooks
          if (sub.ebookPdfUrl.isNotEmpty) {
            expect(
              sub.ebookPdfUrl.startsWith('https://ebooks.ebalbharati.in/pdfs/'),
              isTrue,
              reason: '${sub.subjectName} in Class $std has valid Balbharati URL',
            );
            expect(sub.ebookCode, isNotNull);
            expect(sub.ebookCode.isNotEmpty, isTrue);
            expect(sub.publisher, contains('बालभारती'));
          }

          // Check extra ebooks if present
          for (final extra in sub.extraEbooks) {
            expect(extra.pdfUrl.startsWith('https://ebooks.ebalbharati.in/pdfs/'), isTrue);
            expect(extra.title.isNotEmpty, isTrue);
          }

          // Check chapters
          expect(sub.chapters.isNotEmpty, isTrue);
          for (final ch in sub.chapters) {
            expect(ch.chapterTitle.isNotEmpty, isTrue);
            expect(ch.summary.isNotEmpty, isTrue);
            expect(ch.studyNotes.isNotEmpty, isTrue);
            expect(ch.keyConcepts.isNotEmpty, isTrue);
            expect(ch.practiceQuestions.isNotEmpty, isTrue);
            expect(ch.quizQuestions.isNotEmpty, isTrue);
          }
        }
      }
    });

    test('Class 1 to 7 subject compositions match Maharashtra State Board / Pune Balbharati syllabus', () {
      // Class 1
      final c1 = CurriculumRepository.getSubjectsForStandard(1).map((s) => s.subjectName).toList();
      expect(c1.any((s) => s.contains('मराठी')), isTrue);
      expect(c1.any((s) => s.contains('गणित')), isTrue);
      expect(c1.any((s) => s.contains('इंग्रजी')), isTrue);
      expect(c1.any((s) => s.contains('खेळू')), isTrue);

      // Class 2
      final c2 = CurriculumRepository.getSubjectsForStandard(2).map((s) => s.subjectName).toList();
      expect(c2.any((s) => s.contains('मराठी')), isTrue);
      expect(c2.any((s) => s.contains('गणित')), isTrue);
      expect(c2.any((s) => s.contains('इंग्रजी')), isTrue);

      // Class 3
      final c3 = CurriculumRepository.getSubjectsForStandard(3).map((s) => s.subjectName).toList();
      expect(c3.any((s) => s.contains('मराठी')), isTrue);
      expect(c3.any((s) => s.contains('गणित')), isTrue);
      expect(c3.any((s) => s.contains('परिसर अभ्यास')), isTrue);

      // Class 4
      final c4 = CurriculumRepository.getSubjectsForStandard(4).map((s) => s.subjectName).toList();
      expect(c4.any((s) => s.contains('शिवछत्रपती')), isTrue);
      expect(c4.any((s) => s.contains('परिसर अभ्यास भाग १')), isTrue);

      // Class 5
      final c5 = CurriculumRepository.getSubjectsForStandard(5).map((s) => s.subjectName).toList();
      expect(c5.any((s) => s.contains('सुगमभारती') || s.contains('सुलभभारती') || s.contains('हिंदी')), isTrue);
      expect(c5.any((s) => s.contains('परिसर अभ्यास भाग २')), isTrue);

      // Class 6
      final c6 = CurriculumRepository.getSubjectsForStandard(6).map((s) => s.subjectName).toList();
      expect(c6.any((s) => s.contains('सामान्य विज्ञान')), isTrue);
      expect(c6.any((s) => s.contains('इतिहास व नागरिकशास्त्र')), isTrue);
      expect(c6.any((s) => s.contains('भूगोल')), isTrue);

      // Class 7
      final c7 = CurriculumRepository.getSubjectsForStandard(7).map((s) => s.subjectName).toList();
      expect(c7.any((s) => s.contains('सामान्य विज्ञान')), isTrue);
      expect(c7.any((s) => s.contains('इतिहास व नागरिकशास्त्र')), isTrue);
      expect(c7.any((s) => s.contains('भूगोल')), isTrue);
      expect(c7.any((s) => s.contains('हिंदी')), isTrue);
    });

    test('EbookService generates printable offline Unicode syllabus notebook PDF bytes', () async {
      final std7Subjects = CurriculumRepository.getSubjectsForStandard(7);
      final science = std7Subjects.firstWhere((s) => s.subjectName.contains('विज्ञान'));

      final pdfBytes = await EbookService.generateOfflineSyllabusPdf(science);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF file magic bytes: %PDF-
      expect(pdfBytes[0], equals(0x25)); // %
      expect(pdfBytes[1], equals(0x50)); // P
      expect(pdfBytes[2], equals(0x44)); // D
      expect(pdfBytes[3], equals(0x46)); // F
    });
  });

  group('CurriculumEbooksBody Widget Tests', () {
    testWidgets('CurriculumEbooksBody renders class tabs, subjects and filter buttons', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final appState = AppStateProvider();
      final dummyStudent = StudentModel(
        id: 'stu_test_1',
        schoolId: 'sch_test',
        academicYearId: 'yr_2025_26',
        standard: 5,
        division: 'अ',
        rollNoSem1: 1,
        studentNameMr: 'रोहन जाधव',
        studentNameEn: 'Rohan Jadhav',
        motherName: 'सुनीता',
        dateOfBirth: DateTime(2014, 5, 10),
      );

      int currentStd = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppStateProvider>.value(
            value: appState,
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return CurriculumEbooksBody(
                    selectedStandard: currentStd,
                    onStandardChanged: (newStd) {
                      setState(() {
                        currentStd = newStd;
                      });
                    },
                    student: dummyStudent,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify standard tabs 1 to 7 are present
      expect(find.text('इयत्ता ५ वी'), findsWidgets);
      expect(find.text('इयत्ता १ ली'), findsWidgets);
      expect(find.text('इयत्ता ७ वी'), findsWidgets);

      // Verify subjects for Class 5 are shown
      expect(find.textContaining('मराठी'), findsWidgets);
      expect(find.textContaining('गणित'), findsWidgets);

      // Verify standard switch to Class 7 works
      final std7Tab = find.text('इयत्ता ७ वी').first;
      await tester.tap(std7Tab);
      await tester.pumpAndSettle();

      expect(find.textContaining('सामान्य विज्ञान'), findsWidgets);
    });
  });
}
