import 'online_exam_model.dart';

class CurriculumChapterModel {
  final int chapterNumber;
  final String chapterTitle;
  final String summary;
  final List<String> keyConcepts;
  final String studyNotes;
  final List<Map<String, String>> practiceQuestions; // [{'question': '...', 'answer': '...'}]
  final List<ExamQuestionModel> quizQuestions;

  CurriculumChapterModel({
    required this.chapterNumber,
    required this.chapterTitle,
    required this.summary,
    required this.keyConcepts,
    required this.studyNotes,
    required this.practiceQuestions,
    required this.quizQuestions,
  });

  Map<String, dynamic> toJson() => {
        'chapterNumber': chapterNumber,
        'chapterTitle': chapterTitle,
        'summary': summary,
        'keyConcepts': keyConcepts,
        'studyNotes': studyNotes,
        'practiceQuestions': practiceQuestions,
        'quizQuestions': quizQuestions.map((q) => q.toJson()).toList(),
      };

  factory CurriculumChapterModel.fromJson(Map<String, dynamic> json) => CurriculumChapterModel(
        chapterNumber: int.tryParse(json['chapterNumber']?.toString() ?? '1') ?? 1,
        chapterTitle: json['chapterTitle']?.toString() ?? '',
        summary: json['summary']?.toString() ?? '',
        keyConcepts: (json['keyConcepts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        studyNotes: json['studyNotes']?.toString() ?? '',
        practiceQuestions: (json['practiceQuestions'] as List<dynamic>?)
                ?.map((e) => Map<String, String>.from(e as Map))
                .toList() ??
            [],
        quizQuestions: (json['quizQuestions'] as List<dynamic>?)
                ?.map((e) => ExamQuestionModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class CurriculumSubjectModel {
  final int standard;
  final String subjectCode;
  final String subjectName;
  final String bookTitle;
  final int colorHex;
  final List<CurriculumChapterModel> chapters;

  CurriculumSubjectModel({
    required this.standard,
    required this.subjectCode,
    required this.subjectName,
    required this.bookTitle,
    this.colorHex = 0xFF1E88E5,
    required this.chapters,
  });

  Map<String, dynamic> toJson() => {
        'standard': standard,
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'bookTitle': bookTitle,
        'colorHex': colorHex,
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };

  factory CurriculumSubjectModel.fromJson(Map<String, dynamic> json) => CurriculumSubjectModel(
        standard: int.tryParse(json['standard']?.toString() ?? '1') ?? 1,
        subjectCode: json['subjectCode']?.toString() ?? '',
        subjectName: json['subjectName']?.toString() ?? '',
        bookTitle: json['bookTitle']?.toString() ?? '',
        colorHex: int.tryParse(json['colorHex']?.toString() ?? '0xFF1E88E5') ?? 0xFF1E88E5,
        chapters: (json['chapters'] as List<dynamic>?)
                ?.map((e) => CurriculumChapterModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

