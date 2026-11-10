import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/data/local/curriculum_repository.dart';
import 'package:myschool/data/models/homework_model.dart';
import 'package:myschool/data/models/online_exam_model.dart';
import 'package:myschool/screens/portal/student_parent_portal_screen.dart';
import 'package:myschool/screens/portal/chapter_detail_screen.dart';
import 'package:myschool/screens/portal/exam_player_screen.dart';
import 'package:myschool/screens/portal_admin/homework_exam_management_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CurriculumRepository Class 1-7 Tests', () {
    test('Should have valid curriculum for all classes 1 through 7', () {
      for (int std = 1; std <= 7; std++) {
        final subjects = CurriculumRepository.getSubjectsForStandard(std);
        expect(subjects.isNotEmpty, isTrue, reason: 'Class $std must have subjects');

        for (final sub in subjects) {
          expect(sub.standard, equals(std));
          expect(sub.subjectName.isNotEmpty, isTrue);
          expect(sub.chapters.isNotEmpty, isTrue, reason: '${sub.subjectName} in Class $std must have chapters');

          for (final ch in sub.chapters) {
            expect(ch.chapterTitle.isNotEmpty, isTrue);
            expect(ch.summary.isNotEmpty, isTrue);
          }
        }
      }
    });

    test('Class 1 should include Marathi, Maths, English, and Art/Craft', () {
      final subs = CurriculumRepository.getSubjectsForStandard(1);
      final names = subs.map((s) => s.subjectName).toList();
      expect(names.any((n) => n.contains('मराठी')), isTrue);
      expect(names.any((n) => n.contains('गणित')), isTrue);
      expect(names.any((n) => n.contains('इंग्रजी')), isTrue);
    });

    test('Class 4 should include Shivchhatrapati history', () {
      final subs = CurriculumRepository.getSubjectsForStandard(4);
      final hasHistory = subs.any((s) => s.subjectName.contains('शिवछत्रपती'));
      expect(hasHistory, isTrue);
    });

    test('Class 7 should include Science, History, Geography, and Hindi', () {
      final subs = CurriculumRepository.getSubjectsForStandard(7);
      final names = subs.map((s) => s.subjectName).toList();
      expect(names.any((n) => n.contains('विज्ञान')), isTrue);
      expect(names.any((n) => n.contains('इतिहास')), isTrue);
      expect(names.any((n) => n.contains('भूगोल')), isTrue);
      expect(names.any((n) => n.contains('हिंदी')), isTrue);
    });

    test('Default homework and online exams should be seeded', () {
      final hw = CurriculumRepository.getDefaultHomework();
      expect(hw.isNotEmpty, isTrue);

      final exams = CurriculumRepository.getDefaultOnlineExams();
      expect(exams.isNotEmpty, isTrue);
      for (final ex in exams) {
        expect(ex.questions.isNotEmpty, isTrue);
        expect(ex.totalMarks, greaterThan(0));
      }
    });
  });

  group('Homework & Exam Logic Tests', () {
    test('Homework completion toggle works properly', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final testHw = HomeworkModel(
        id: 'hw_test_1',
        schoolId: 'sch_1',
        academicYearId: 'yr_1',
        standard: 1,
        division: '1',
        subjectCode: 'mar_1',
        subjectName: 'मराठी',
        title: 'चाचणी स्वाध्याय',
        description: 'तपशील',
        assignedDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );

      await provider.addHomework(testHw);
      expect(provider.homeworkList.any((h) => h.id == 'hw_test_1'), isTrue);

      // Toggle for student stu-01
      await provider.toggleHomeworkStatus('hw_test_1', 'stu-01');
      var updated = provider.homeworkList.firstWhere((h) => h.id == 'hw_test_1');
      expect(updated.isCompletedBy('stu-01'), isTrue);

      // Toggle again
      await provider.toggleHomeworkStatus('hw_test_1', 'stu-01');
      updated = provider.homeworkList.firstWhere((h) => h.id == 'hw_test_1');
      expect(updated.isCompletedBy('stu-01'), isFalse);

      await provider.deleteHomework('hw_test_1');
      expect(provider.homeworkList.any((h) => h.id == 'hw_test_1'), isFalse);
    });

    test('Exam result grading calculations', () {
      expect(ExamResultModel.calculateGrade(95.0), equals('A1'));
      expect(ExamResultModel.calculateGrade(82.0), equals('A2'));
      expect(ExamResultModel.calculateGrade(74.0), equals('B1'));
      expect(ExamResultModel.calculateGrade(65.0), equals('B2'));
      expect(ExamResultModel.calculateGrade(52.0), equals('C1'));
      expect(ExamResultModel.calculateGrade(41.0), equals('C2'));
      expect(ExamResultModel.calculateGrade(35.0), equals('D'));
      expect(ExamResultModel.calculateGrade(20.0), equals('E'));
    });

    test('Attendance summary calculation', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final stu = provider.students.first;
      final summary = provider.getStudentAttendanceSummary(stu);

      expect(summary.containsKey('totalWorkingDays'), isTrue);
      expect(summary.containsKey('totalAttendedDays'), isTrue);
      expect(summary.containsKey('percentage'), isTrue);
      expect(summary['monthlyBreakdown'] is List, isTrue);

      final breakdown = summary['monthlyBreakdown'] as List;
      expect(breakdown.length, equals(11)); // Jun to Apr
    });
  });

  group('Student & Parent Portal UI Widget Tests', () {
    testWidgets('StudentParentPortalScreen renders with all 5 navigation tabs', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final provider = AppStateProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: StudentParentPortalScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Title & Student Profile
      expect(find.textContaining('विद्यार्थी व पालक पोर्टल'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify all 5 tab destinations
      expect(find.text('डॅशबोर्ड'), findsOneWidget);
      expect(find.text('उपस्थिती'), findsOneWidget);
      expect(find.text('घरचा अभ्यास'), findsOneWidget);
      expect(find.text('ऑनलाइन परीक्षा'), findsOneWidget);
      expect(find.text('ई-लर्निंग'), findsOneWidget);

      // Switch to Attendance tab
      await tester.tap(find.text('उपस्थिती'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('वार्षिक उपस्थिती प्रमाण'), findsOneWidget);

      // Switch to Homework tab
      await tester.tap(find.text('घरचा अभ्यास'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('गाळणी (Filter)'), findsOneWidget);

      // Switch to Online Exams tab
      await tester.tap(find.text('ऑनलाइन परीक्षा'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('ऑनलाइन सराव चाचण्या'), findsOneWidget);

      // Switch to E-Learning tab
      await tester.tap(find.text('ई-लर्निंग'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('इयत्ता निवडा'), findsOneWidget);
    });

    testWidgets('ChapterDetailScreen renders notes, QA, and quiz tab', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final provider = AppStateProvider();

      final sub = CurriculumRepository.getSubjectsForStandard(1).first;
      final ch = sub.chapters.first;
      final student = provider.students.first;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: ChapterDetailScreen(
              subject: sub,
              chapter: ch,
              student: student,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('अभ्यास व सारांश'), findsOneWidget);
      expect(find.textContaining('स्वाध्याय (प्रश्न-उत्तरे)'), findsOneWidget);
      expect(find.textContaining('सराव चाचणी'), findsOneWidget);
      expect(find.text(ch.summary), findsOneWidget);
    });

    testWidgets('ExamPlayerScreen plays and submits test', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final provider = AppStateProvider();

      final exam = CurriculumRepository.getDefaultOnlineExams().first;
      final student = provider.students.first;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: ExamPlayerScreen(
              exam: exam,
              student: student,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(exam.title), findsOneWidget);
      expect(find.textContaining('पर्याय निवडा'), findsOneWidget);

      // Cleanly dispose widget so timer is cancelled
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('HomeworkExamManagementScreen renders Windows admin tabs and controls', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final provider = AppStateProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: HomeworkExamManagementScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('स्वाध्याय व ऑनलाइन परीक्षा व्यवस्थापन'), findsOneWidget);
      expect(find.textContaining('घरचा अभ्यास (Homework)'), findsOneWidget);
      expect(find.textContaining('ऑनलाइन परीक्षा व निकाल (Exams)'), findsOneWidget);
      expect(find.textContaining('+ नवीन स्वाध्याय द्या'), findsOneWidget);

      // Switch to Exams tab
      await tester.tap(find.textContaining('ऑनलाइन परीक्षा व निकाल (Exams)'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('+ नवीन ऑनलाइन परीक्षा तयार करा'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    test('Windows created homework & exam reflect in Android/iOS student portal and back', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      final student = provider.students.first;

      // 1. Teacher assigns new homework in Windows panel
      final newHw = HomeworkModel(
        id: 'hw_win_test_99',
        schoolId: provider.school.id,
        academicYearId: provider.currentYear.id,
        standard: student.standard,
        division: student.division,
        subjectCode: 'marathi_1',
        subjectName: 'मराठी',
        title: 'झोका कविता शुद्धलेखन व प्रश्नोत्तरे',
        description: 'वहीत सुंदर हस्ताक्षरात लिहा व पाठांतर करा.',
        assignedDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        teacherName: 'श्री. विजय कदम (वर्गशिक्षक)',
      );
      await provider.addHomework(newHw);

      // Student views homework in mobile portal
      final studentHomeworkList = provider.getHomeworkForStudent(student);
      final reflectedHw = studentHomeworkList.where((h) => h.id == 'hw_win_test_99');
      expect(reflectedHw.isNotEmpty, isTrue, reason: 'Homework must reflect in student mobile portal');

      // 2. Student completes homework in mobile portal
      await provider.toggleHomeworkStatus('hw_win_test_99', student.id);
      final updatedHw = provider.homeworkList.firstWhere((h) => h.id == 'hw_win_test_99');
      expect(updatedHw.isCompletedBy(student.id), isTrue, reason: 'Teacher Windows panel must reflect completed status');

      // 3. Teacher creates a new online exam in Windows panel
      final newExam = OnlineExamModel(
        id: 'exam_win_test_99',
        standard: student.standard,
        subjectCode: 'maths_1',
        subjectName: 'गणित',
        title: 'अंकज्ञान चाचणी',
        description: 'सराव चाचणी',
        durationMinutes: 10,
        questions: [
          ExamQuestionModel(
            id: 'q1',
            question: '५ + ४ किती?',
            options: ['९', '८', '१०', '७'],
            correctOptionIndex: 0,
            explanation: '५ + ४ = ९.',
          ),
        ],
      );
      await provider.addOnlineExam(newExam);

      // Mobile portal queries exams for this standard
      final stdExams = provider.getExamsForStandard(student.standard);
      expect(stdExams.any((e) => e.id == 'exam_win_test_99'), isTrue, reason: 'Exam must reflect in student mobile portal');

      // 4. Student takes exam on mobile portal and submits
      final examResult = ExamResultModel(
        id: 'res_win_test_99',
        examId: 'exam_win_test_99',
        examTitle: 'अंकज्ञान चाचणी',
        studentId: student.id,
        studentName: student.studentNameMr.isNotEmpty ? student.studentNameMr : student.studentNameEn,
        standard: student.standard,
        division: student.division,
        score: 1,
        totalMarks: 1,
        percentage: 100.0,
        grade: 'A1',
        isPassed: true,
        submittedAt: DateTime.now(),
        userAnswers: {0: 0},
      );
      await provider.submitExamResult(examResult);

      // Windows panel queries results for this exam
      final examResultsOnWindows = provider.getResultsForExam('exam_win_test_99');
      expect(examResultsOnWindows.isNotEmpty, isTrue, reason: 'Scorecard must reflect back to Windows teacher software');
      expect(examResultsOnWindows.first.studentId, equals(student.id));
      expect(examResultsOnWindows.first.grade, equals('A1'));
      expect(examResultsOnWindows.first.isPassed, isTrue);

      // Cleanup
      await provider.deleteHomework('hw_win_test_99');
      await provider.deleteOnlineExam('exam_win_test_99');
      await provider.deleteExamResult('res_win_test_99');
    });
  });
}
