import '../models/curriculum_model.dart';
import '../models/homework_model.dart';
import '../models/online_exam_model.dart';
import 'curriculum/class_1_2_curriculum.dart';
import 'curriculum/class_3_4_curriculum.dart';
import 'curriculum/class_5_curriculum.dart';
import 'curriculum/class_6_curriculum.dart';
import 'curriculum/class_7_curriculum.dart';

class CurriculumRepository {
  static final Map<int, List<CurriculumSubjectModel>> _curriculumByStandard = {
    1: buildClass1Curriculum(),
    2: buildClass2Curriculum(),
    3: buildClass3Curriculum(),
    4: buildClass4Curriculum(),
    5: buildClass5Curriculum(),
    6: buildClass6Curriculum(),
    7: buildClass7Curriculum(),
  };

  /// Returns the list of curriculum subjects for a given standard (1-7)
  static List<CurriculumSubjectModel> getSubjectsForStandard(int standard) {
    return _curriculumByStandard[standard] ?? [];
  }

  /// Returns all subjects across standards 1-7
  static List<CurriculumSubjectModel> getAllSubjects() {
    return [
      for (int std = 1; std <= 7; std++) ...getSubjectsForStandard(std),
    ];
  }

  /// Total number of official e-books (including supplementary Balbharati editions)
  static int get totalEbooksCount {
    int count = 0;
    for (final sub in getAllSubjects()) {
      count += sub.allEbooks.length;
    }
    return count;
  }

  /// Total number of chapters across classes 1-7
  static int get totalChaptersCount {
    int count = 0;
    for (final sub in getAllSubjects()) {
      count += sub.chapters.length;
    }
    return count;
  }

  /// Get a single subject
  static CurriculumSubjectModel? getSubject(int standard, String subjectCode) {
    final list = getSubjectsForStandard(standard);
    try {
      return list.firstWhere((s) => s.subjectCode == subjectCode);
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }

  /// Default homework assignments for initial seeding
  static List<HomeworkModel> getDefaultHomework() {
    final now = DateTime.now();
    return [
      HomeworkModel(
        id: 'hw_1',
        schoolId: 'school_001',
        academicYearId: '2024-2025',
        standard: 1,
        division: '1',
        subjectCode: 'marathi_1',
        subjectName: 'मराठी',
        title: 'अ ते ज्ञ मुळाक्षरे २ वेळा सुंदर हस्ताक्षरात लिहा',
        description:
            'वहीत अ ते ज्ञ मुळाक्षरे व काना-मात्रा नसलेले ५ सोपे शब्द लिहून आणा.',
        assignedDate: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 1)),
        teacherName: 'श्री. संतोष सावंत (वर्गशिक्षक)',
        completedStudentIds: ['101'],
      ),
      HomeworkModel(
        id: 'hw_2',
        schoolId: 'school_001',
        academicYearId: '2024-2025',
        standard: 1,
        division: '1',
        subjectCode: 'maths_1',
        subjectName: 'गणित',
        title: '१ ते २० अंकांचे वाचन व लेखन',
        description:
            '१ ते २० अंक वहीत २ वेळा लिहा व बोटे मोजून बेरीज करा (पान क्र. १४).',
        assignedDate: now,
        dueDate: now.add(const Duration(days: 2)),
        teacherName: 'श्री. संतोष सावंत (वर्गशिक्षक)',
      ),
      HomeworkModel(
        id: 'hw_3',
        schoolId: 'school_001',
        academicYearId: '2024-2025',
        standard: 2,
        division: '1',
        subjectCode: 'marathi_2',
        subjectName: 'मराठी',
        title: '‘देवा तुझे किती सुंदर आकाश’ कविता पाठांतर',
        description: 'कविता तालासुरात पाठ करा व वहीत १ वेळा शुद्धलेखन करा.',
        assignedDate: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 1)),
        teacherName: 'सौ. सुनीता पाटील (वर्गशिक्षिका)',
      ),
      HomeworkModel(
        id: 'hw_4',
        schoolId: 'school_001',
        academicYearId: '2024-2025',
        standard: 4,
        division: '1',
        subjectCode: 'evs2_4',
        subjectName: 'शिवछत्रपती (परिसर अभ्यास २)',
        title: 'शिवनेरी किल्ल्याची माहिती व चित्र रेखाटन',
        description:
            'शिवनेरी किल्ल्यावर ५ ओळी माहिती लिहा व जिजामाता-शिवरायांचे चित्र चिटकवा किंवा काढा.',
        assignedDate: now,
        dueDate: now.add(const Duration(days: 3)),
        teacherName: 'श्री. रमेश शिंदे',
      ),
      HomeworkModel(
        id: 'hw_5',
        schoolId: 'school_001',
        academicYearId: '2024-2025',
        standard: 7,
        division: '1',
        subjectCode: 'science_7',
        subjectName: 'सामान्य विज्ञान',
        title: 'वनस्पतीचे अवयव व प्रकाशसंश्लेषण आकृती',
        description:
            'वनस्पतीच्या पानाची सुबक नामनिर्देशित आकृती काढा व प्रकाशसंश्लेषणाचे रासायनिक समीकरण लिहा.',
        assignedDate: now,
        dueDate: now.add(const Duration(days: 2)),
        teacherName: 'डॉ. विजय कुलकर्णी',
      ),
    ];
  }

  /// Default online exams with interactive tests
  static List<OnlineExamModel> getDefaultOnlineExams() {
    return [
      OnlineExamModel(
        id: 'exam_std1_marathi',
        standard: 1,
        subjectCode: 'marathi_1',
        subjectName: 'मराठी',
        title: 'इयत्ता १ ली - मराठी सराव चाचणी क्र. १',
        description: 'मुळाक्षरे, स्वर आणि कुटुंब संकल्पना यांवर आधारित बालचाचणी.',
        durationMinutes: 10,
        questions: [
          ExamQuestionModel(
            id: 'q1',
            question: '‘अननस’ या शब्दातील पहिले अक्षर कोणते आहे?',
            options: ['अ', 'आ', 'इ', 'क'],
            correctOptionIndex: 0,
            explanation: 'अननस हा शब्द ‘अ’ या अक्षराने सुरू होतो.',
          ),
          ExamQuestionModel(
            id: 'q2',
            question: 'आपण जेवणापूर्वी काय केले पाहिजे?',
            options: [
              'हात स्वच्छ धुतले पाहिजेत',
              'धावले पाहिजे',
              'झोपले पाहिजे',
              'ओरडले पाहिजे',
            ],
            correctOptionIndex: 0,
            explanation: 'आरोग्यासाठी जेवणापूर्वी हात स्वच्छ धुणे आवश्यक आहे.',
          ),
          ExamQuestionModel(
            id: 'q3',
            question: 'झाडे आपल्याला कोणती महत्त्वाची गोष्ट देतात?',
            options: ['सावली आणि फळे', 'मोबाईल', 'प्लास्टिक', 'वाहने'],
            correctOptionIndex: 0,
            explanation: 'झाडे आपल्याला गोड फळे, फुले आणि गार सावली देतात.',
          ),
        ],
      ),
      OnlineExamModel(
        id: 'exam_std1_maths',
        standard: 1,
        subjectCode: 'maths_1',
        subjectName: 'गणित',
        title: 'इयत्ता १ ली - गणित अंकज्ञान चाचणी',
        description: '१ ते १० मोजणी, लहान-मोठा आणि साधी बेरीज.',
        durationMinutes: 10,
        questions: [
          ExamQuestionModel(
            id: 'qm1',
            question: 'हत्ती आणि ससा यांपैकी मोठा प्राणी कोणता?',
            options: ['हत्ती', 'ससा', 'दोन्ही सारखे', 'सांगता येत नाही'],
            correctOptionIndex: 0,
            explanation: 'हत्ती आकाराने सशापेक्षा खूप मोठा असतो.',
          ),
          ExamQuestionModel(
            id: 'qm2',
            question: '३ + २ मिळून किती होतात?',
            options: ['५', '४', '६', '३'],
            correctOptionIndex: 0,
            explanation: '३ आणि २ मिळून ५ होतात.',
          ),
          ExamQuestionModel(
            id: 'qm3',
            question: 'एका हाताला किती बोटे असतात?',
            options: ['५', '४', '१०', '६'],
            correctOptionIndex: 0,
            explanation: 'आपल्या एका हाताला ५ बोटे असतात.',
          ),
        ],
      ),
      OnlineExamModel(
        id: 'exam_std4_evs2',
        standard: 4,
        subjectCode: 'evs2_4',
        subjectName: 'शिवछत्रपती इतिहास',
        title: 'इयत्ता ४ थी - शिवछत्रपती ज्ञान चाचणी',
        description:
            'शिवजन्म, स्वराज्य संकल्पना आणि संतांची कामगिरी यांवरील महत्त्वाची परीक्षा.',
        durationMinutes: 15,
        questions: [
          ExamQuestionModel(
            id: 'q_shiva_1',
            question: 'छत्रपती शिवाजी महाराजांचा जन्म कोणत्या किल्ल्यावर झाला?',
            options: [
              'शिवनेरी किल्ला',
              'रायगड किल्ला',
              'प्रतापगड किल्ला',
              'तोरणा किल्ला',
            ],
            correctOptionIndex: 0,
            explanation:
                'शिवरायांचा जन्म जुन्नर जवळील शिवनेरी किल्ल्यावर झाला.',
          ),
          ExamQuestionModel(
            id: 'q_shiva_2',
            question: 'शिवरायांच्या वडिलांचे नाव काय होते?',
            options: [
              'शहाजीराजे भोसले',
              'मालोजीराजे',
              'संभाजीराजे',
              'व्यंकोजीराजे',
            ],
            correctOptionIndex: 0,
            explanation: 'शिवरायांचे वडील शहाजीराजे हे शूर पराक्रमी सरदार होते.',
          ),
          ExamQuestionModel(
            id: 'q_shiva_3',
            question: 'शिवरायांनी पहिली कोणती शपथ घेतली?',
            options: [
              'स्वराज्य स्थापनेची प्रतिज्ञा',
              'व्यापाराची प्रतिज्ञा',
              'युद्धाची प्रतिज्ञा',
              'शांततेची प्रतिज्ञा',
            ],
            correctOptionIndex: 0,
            explanation:
                'रायरेश्वराच्या मंदिरात शिवरायांनी हिंदवी स्वराज्य स्थापनेची प्रतिज्ञा केली.',
          ),
        ],
      ),
      OnlineExamModel(
        id: 'exam_std7_science',
        standard: 7,
        subjectCode: 'science_7',
        subjectName: 'सामान्य विज्ञान',
        title: 'इयत्ता ७ वी - सामान्य विज्ञान सत्र चाचणी',
        description: 'सजीव सृष्टी, अनुकूलन आणि प्रकाशसंश्लेषण संकल्पना.',
        durationMinutes: 15,
        questions: [
          ExamQuestionModel(
            id: 'qs_7_1',
            question: 'प्रकाशसंश्लेषण प्रक्रियेत वनस्पती कोणता वायू बाहेर सोडतात?',
            options: [
              'ऑक्सिजन (Oxygen)',
              'कार्बन डायऑक्साइड',
              'नायट्रोजन',
              'हायड्रोजन',
            ],
            correctOptionIndex: 0,
            explanation:
                'वनस्पती सूर्यप्रकाशात अन्न तयार करताना ऑक्सिजन वायू बाहेर सोडतात.',
          ),
          ExamQuestionModel(
            id: 'qs_7_2',
            question: 'मासे पाण्यात श्वसन करण्यासाठी कशाचा वापर करतात?',
            options: ['कल्ले (Gills)', 'फुप्फुसे', 'त्वचा', 'पर'],
            correctOptionIndex: 0,
            explanation:
                'पाण्यातील विरघळलेला ऑक्सिजन घेण्यासाठी माशांना कल्ले असतात.',
          ),
          ExamQuestionModel(
            id: 'qs_7_3',
            question: 'त्रिकोणाच्या तिन्ही कोनांच्या मापांची बेरीज किती असते?',
            options: ['१८० अंश', '३६० अंश', '९० अंश', '१२० अंश'],
            correctOptionIndex: 0,
            explanation:
                'भूमिती नियमानुसार त्रिकोणाच्या तिन्ही कोनांची बेरीज नेहमी १८०° असते.',
          ),
        ],
      ),
    ];
  }
}
