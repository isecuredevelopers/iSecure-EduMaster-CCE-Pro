import '../../models/curriculum_model.dart';
import '../../models/online_exam_model.dart';

/// Compact builder for Balbharati (Pune) syllabus chapters so every chapter
/// across Classes 1 to 7 has summary, key concepts, study notes, practice Q&A,
/// and interactive MCQ quiz questions.
CurriculumChapterModel buildSyllabusChapter({
  required String idPrefix,
  required int number,
  required String title,
  required String summary,
  required List<String> concepts,
  String? notes,
  List<Map<String, String>>? qa,
  List<ExamQuestionModel>? quiz,
  bool isEnglish = false,
  bool isHindi = false,
}) {
  final defaultNotes = notes ??
      (isEnglish
          ? '• Read the unit "$title" aloud with correct pronunciation.\n'
              '• Key focus areas: ${concepts.join(', ')}.\n'
              '• Practice writing new words and sentences in your notebook.'
          : isHindi
              ? '• पाठ "$title" का शुद्ध उच्चारण के साथ वाचन करें।\n'
                  '• मुख्य बिंदु: ${concepts.join(', ')}।\n'
                  '• कठिन शब्दों के अर्थ और स्वाध्याय अपनी कॉपी में लिखें।'
              : '• "$title" हा घटक लक्षपूर्वक वाचा व समजून घ्या.\n'
                  '• मुख्य मुद्दे: ${concepts.join(', ')}.\n'
                  '• पाठातील कठीण शब्द व स्वाध्याय वहीत सुवाच्य अक्षरात लिहा.');

  final defaultQa = qa ??
      (isEnglish
          ? [
              {
                'question': 'What is the main focus of "$title"?',
                'answer': summary,
              },
              {
                'question': 'List the key concepts covered in this unit.',
                'answer': concepts.join(', '),
              },
            ]
          : isHindi
              ? [
                  {
                    'question': '"$title" पाठ का मुख्य विषय क्या है?',
                    'answer': summary,
                  },
                  {
                    'question': 'इस पाठ के प्रमुख बिंदु कौन-कौन से हैं?',
                    'answer': concepts.join(', '),
                  },
                ]
              : [
                  {
                    'question': '"$title" या पाठाचा मुख्य आशय काय आहे?',
                    'answer': summary,
                  },
                  {
                    'question': 'या पाठातील महत्त्वाच्या संकल्पना कोणत्या?',
                    'answer': concepts.join(', '),
                  },
                ]);

  final primaryConcept = concepts.isNotEmpty ? concepts.first : title;
  final defaultQuiz = quiz ??
      [
        ExamQuestionModel(
          id: '${idPrefix}_ch${number}_q1',
          question: isEnglish
              ? 'Which key concept is studied in "$title"?'
              : isHindi
                  ? '"$title" पाठ में निम्नलिखित में से किस मुख्य बिंदु का अध्ययन किया जाता है?'
                  : '"$title" या घटकामध्ये खालीलपैकी कोणत्या मुख्य संकल्पनेचा अभ्यास केला जातो?',
          options: isEnglish
              ? [
                  primaryConcept,
                  'Unrelated topic',
                  'None of these',
                  'Only drawing',
                ]
              : isHindi
                  ? [
                      primaryConcept,
                      'असंबंधित विषय',
                      'इनमें से कोई नहीं',
                      'केवल चित्रकला',
                    ]
                  : [
                      primaryConcept,
                      'या पाठाशी असंबंधित विषय',
                      'यापैकी काहीही नाही',
                      'फक्त खेळ',
                    ],
          correctOptionIndex: 0,
          explanation: isEnglish
              ? 'The unit "$title" focuses on $primaryConcept and related concepts.'
              : isHindi
                  ? '"$title" पाठ में $primaryConcept का मुख्य रूप से अध्ययन किया गया है।'
                  : '"$title" या पाठात $primaryConcept या संकल्पनेचा अभ्यास केला जातो.',
        ),
      ];

  return CurriculumChapterModel(
    chapterNumber: number,
    chapterTitle: title,
    summary: summary,
    keyConcepts: concepts,
    studyNotes: defaultNotes,
    practiceQuestions: defaultQa,
    quizQuestions: defaultQuiz,
  );
}
