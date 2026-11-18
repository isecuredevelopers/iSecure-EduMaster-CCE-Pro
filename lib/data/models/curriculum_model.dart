import 'online_exam_model.dart';

class CurriculumEbookResource {
  final String title;
  final String bookCode;
  final String pdfUrl;
  final String coverUrl;
  final String sizeLabel;

  const CurriculumEbookResource({
    required this.title,
    required this.bookCode,
    required this.pdfUrl,
    required this.coverUrl,
    this.sizeLabel = '',
  });

  factory CurriculumEbookResource.balbharati({
    required String title,
    required String bookCode,
    String sizeLabel = '',
  }) {
    return CurriculumEbookResource(
      title: title,
      bookCode: bookCode,
      pdfUrl: 'https://ebooks.ebalbharati.in/pdfs/$bookCode.pdf',
      coverUrl: 'https://books.ebalbharati.in/BookCovers/$bookCode.jpg',
      sizeLabel: sizeLabel,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'bookCode': bookCode,
        'pdfUrl': pdfUrl,
        'coverUrl': coverUrl,
        'sizeLabel': sizeLabel,
      };

  factory CurriculumEbookResource.fromJson(Map<String, dynamic> json) =>
      CurriculumEbookResource(
        title: json['title']?.toString() ?? '',
        bookCode: json['bookCode']?.toString() ?? '',
        pdfUrl: json['pdfUrl']?.toString() ?? '',
        coverUrl: json['coverUrl']?.toString() ?? '',
        sizeLabel: json['sizeLabel']?.toString() ?? '',
      );
}

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

  factory CurriculumChapterModel.fromJson(Map<String, dynamic> json) =>
      CurriculumChapterModel(
        chapterNumber:
            int.tryParse(json['chapterNumber']?.toString() ?? '1') ?? 1,
        chapterTitle: json['chapterTitle']?.toString() ?? '',
        summary: json['summary']?.toString() ?? '',
        keyConcepts: (json['keyConcepts'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        studyNotes: json['studyNotes']?.toString() ?? '',
        practiceQuestions: (json['practiceQuestions'] as List<dynamic>?)
                ?.map((e) => Map<String, String>.from(e as Map))
                .toList() ??
            [],
        quizQuestions: (json['quizQuestions'] as List<dynamic>?)
                ?.map((e) =>
                    ExamQuestionModel.fromJson(e as Map<String, dynamic>))
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
  final String ebookCode;
  final String ebookPdfUrl;
  final String ebookCoverUrl;
  final String ebookSizeLabel;
  final String publisher;
  final String medium;
  final List<CurriculumEbookResource> extraEbooks;
  final List<CurriculumChapterModel> chapters;

  CurriculumSubjectModel({
    required this.standard,
    required this.subjectCode,
    required this.subjectName,
    required this.bookTitle,
    this.colorHex = 0xFF1E88E5,
    this.ebookCode = '',
    String? ebookPdfUrl,
    String? ebookCoverUrl,
    this.ebookSizeLabel = '',
    this.publisher = 'बालभारती, पुणे (महाराष्ट्र राज्य पाठ्यपुस्तक मंडळ)',
    this.medium = 'मराठी माध्यम',
    this.extraEbooks = const [],
    required this.chapters,
  })  : ebookPdfUrl = ebookPdfUrl ??
            (ebookCode.isNotEmpty
                ? 'https://ebooks.ebalbharati.in/pdfs/$ebookCode.pdf'
                : 'https://books.ebalbharati.in/ebook.aspx'),
        ebookCoverUrl = ebookCoverUrl ??
            (ebookCode.isNotEmpty
                ? 'https://books.ebalbharati.in/BookCovers/$ebookCode.jpg'
                : '');

  List<CurriculumEbookResource> get allEbooks {
    final list = <CurriculumEbookResource>[];
    if (ebookCode.isNotEmpty) {
      list.add(
        CurriculumEbookResource(
          title: bookTitle,
          bookCode: ebookCode,
          pdfUrl: ebookPdfUrl,
          coverUrl: ebookCoverUrl,
          sizeLabel: ebookSizeLabel,
        ),
      );
    }
    list.addAll(extraEbooks);
    return list;
  }

  Map<String, dynamic> toJson() => {
        'standard': standard,
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'bookTitle': bookTitle,
        'colorHex': colorHex,
        'ebookCode': ebookCode,
        'ebookPdfUrl': ebookPdfUrl,
        'ebookCoverUrl': ebookCoverUrl,
        'ebookSizeLabel': ebookSizeLabel,
        'publisher': publisher,
        'medium': medium,
        'extraEbooks': extraEbooks.map((e) => e.toJson()).toList(),
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };

  factory CurriculumSubjectModel.fromJson(Map<String, dynamic> json) =>
      CurriculumSubjectModel(
        standard: int.tryParse(json['standard']?.toString() ?? '1') ?? 1,
        subjectCode: json['subjectCode']?.toString() ?? '',
        subjectName: json['subjectName']?.toString() ?? '',
        bookTitle: json['bookTitle']?.toString() ?? '',
        colorHex: int.tryParse(json['colorHex']?.toString() ?? '0xFF1E88E5') ??
            0xFF1E88E5,
        ebookCode: json['ebookCode']?.toString() ?? '',
        ebookPdfUrl: json['ebookPdfUrl']?.toString(),
        ebookCoverUrl: json['ebookCoverUrl']?.toString(),
        ebookSizeLabel: json['ebookSizeLabel']?.toString() ?? '',
        publisher: json['publisher']?.toString() ??
            'बालभारती, पुणे (महाराष्ट्र राज्य पाठ्यपुस्तक मंडळ)',
        medium: json['medium']?.toString() ?? 'मराठी माध्यम',
        extraEbooks: (json['extraEbooks'] as List<dynamic>?)
                ?.map((e) => CurriculumEbookResource.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
        chapters: (json['chapters'] as List<dynamic>?)
                ?.map((e) =>
                    CurriculumChapterModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
