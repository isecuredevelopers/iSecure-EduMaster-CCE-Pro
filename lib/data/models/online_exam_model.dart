class ExamQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final int marks;

  ExamQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation = '',
    this.marks = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'explanation': explanation,
        'marks': marks,
      };

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) => ExamQuestionModel(
        id: json['id']?.toString() ?? '',
        question: json['question']?.toString() ?? '',
        options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        correctOptionIndex: int.tryParse(json['correctOptionIndex']?.toString() ?? '0') ?? 0,
        explanation: json['explanation']?.toString() ?? '',
        marks: int.tryParse(json['marks']?.toString() ?? '1') ?? 1,
      );
}

class OnlineExamModel {
  final String id;
  final int standard;
  final String subjectCode;
  final String subjectName;
  final String title;
  final String description;
  final int durationMinutes;
  final int totalMarks;
  final int passingMarks;
  final List<ExamQuestionModel> questions;

  OnlineExamModel({
    required this.id,
    required this.standard,
    required this.subjectCode,
    required this.subjectName,
    required this.title,
    required this.description,
    this.durationMinutes = 15,
    int? totalMarks,
    int? passingMarks,
    required this.questions,
  })  : totalMarks = totalMarks ?? (questions.isNotEmpty ? questions.fold<int>(0, (sum, q) => sum + q.marks) : 10),
        passingMarks = passingMarks ?? ((questions.isNotEmpty ? questions.fold<int>(0, (sum, q) => sum + q.marks) : 10) * 0.35).ceil();

  Map<String, dynamic> toJson() => {
        'id': id,
        'standard': standard,
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'title': title,
        'description': description,
        'durationMinutes': durationMinutes,
        'totalMarks': totalMarks,
        'passingMarks': passingMarks,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  factory OnlineExamModel.fromJson(Map<String, dynamic> json) => OnlineExamModel(
        id: json['id']?.toString() ?? '',
        standard: int.tryParse(json['standard']?.toString() ?? '1') ?? 1,
        subjectCode: json['subjectCode']?.toString() ?? '',
        subjectName: json['subjectName']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        durationMinutes: int.tryParse(json['durationMinutes']?.toString() ?? '15') ?? 15,
        totalMarks: int.tryParse(json['totalMarks']?.toString() ?? '10'),
        passingMarks: int.tryParse(json['passingMarks']?.toString() ?? '4'),
        questions: (json['questions'] as List<dynamic>?)
                ?.map((e) => ExamQuestionModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class ExamResultModel {
  final String id;
  final String examId;
  final String examTitle;
  final String studentId;
  final String studentName;
  final int standard;
  final String division;
  final int score;
  final int totalMarks;
  final double percentage;
  final String grade;
  final bool isPassed;
  final DateTime submittedAt;
  final Map<int, int> userAnswers; // questionIndex -> selectedOptionIndex

  ExamResultModel({
    required this.id,
    required this.examId,
    required this.examTitle,
    required this.studentId,
    required this.studentName,
    required this.standard,
    required this.division,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.grade,
    required this.isPassed,
    required this.submittedAt,
    required this.userAnswers,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'examId': examId,
        'examTitle': examTitle,
        'studentId': studentId,
        'studentName': studentName,
        'standard': standard,
        'division': division,
        'score': score,
        'totalMarks': totalMarks,
        'percentage': percentage,
        'grade': grade,
        'isPassed': isPassed,
        'submittedAt': submittedAt.toIso8601String(),
        'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
      };

  factory ExamResultModel.fromJson(Map<String, dynamic> json) => ExamResultModel(
        id: json['id']?.toString() ?? '',
        examId: json['examId']?.toString() ?? '',
        examTitle: json['examTitle']?.toString() ?? '',
        studentId: json['studentId']?.toString() ?? '',
        studentName: json['studentName']?.toString() ?? '',
        standard: int.tryParse(json['standard']?.toString() ?? '1') ?? 1,
        division: json['division']?.toString() ?? '1',
        score: int.tryParse(json['score']?.toString() ?? '0') ?? 0,
        totalMarks: int.tryParse(json['totalMarks']?.toString() ?? '10') ?? 10,
        percentage: double.tryParse(json['percentage']?.toString() ?? '0.0') ?? 0.0,
        grade: json['grade']?.toString() ?? 'F',
        isPassed: json['isPassed'] == true,
        submittedAt: json['submittedAt'] != null
            ? DateTime.tryParse(json['submittedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        userAnswers: (json['userAnswers'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(int.tryParse(k) ?? 0, int.tryParse(v.toString()) ?? -1),
            ) ??
            {},
      );

  static String calculateGrade(double pct) {
    if (pct >= 90) return 'A1';
    if (pct >= 80) return 'A2';
    if (pct >= 70) return 'B1';
    if (pct >= 60) return 'B2';
    if (pct >= 50) return 'C1';
    if (pct >= 40) return 'C2';
    if (pct >= 35) return 'D';
    return 'E';
  }
}
