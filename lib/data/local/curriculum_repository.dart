import '../models/curriculum_model.dart';
import '../models/homework_model.dart';
import '../models/online_exam_model.dart';

class CurriculumRepository {
  static final Map<int, List<CurriculumSubjectModel>> _curriculumByStandard = {
    // ==========================================
    // CLASS 1 (इयत्ता १ ली)
    // ==========================================
    1: [
      CurriculumSubjectModel(
        standard: 1,
        subjectCode: 'marathi_1',
        subjectName: 'मराठी (बालभारती)',
        bookTitle: 'बालभारती इयत्ता पहिली',
        colorHex: 0xFFE53935,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. माझे घर व माझे कुटुंब',
            summary: 'विद्यार्थ्यांना आपल्या घराची, घरातील सदस्यांची (आई, बाबा, आजी, आजोबा, बहीण, भाऊ) आणि घराभोवतालच्या वातावरणाची गोड ओळख करून देणे.',
            keyConcepts: ['घर', 'कुटुंब', 'नातेसंबंध', 'आजी-आजोबा', 'प्रेम व आदर'],
            studyNotes: '• कुटुंबातील सर्वांचा आदर करावा.\n• एकत्र राहिल्याने प्रेम वाढते.\n• घरातील कामात आई-बाबांना छोटी मदत करावी.',
            practiceQuestions: [
              {'question': 'तुमच्या कुटुंबात कोण कोण राहतात?', 'answer': 'माझ्या कुटुंबात आई, बाबा, आजी, आजोबा आणि माझी बहीण/भाऊ राहतात.'},
              {'question': 'आपण घराची काळजी कशी घेतली पाहिजे?', 'answer': 'घर नेहमी स्वच्छ आणि सुंदर ठेवले पाहिजे.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_1_m_1',
                question: 'कुटुंबात मोठ्या व्यक्तींशी कसे बोलावे?',
                options: ['आदराने व नम्रतेने', 'रागाने', 'दुर्लक्ष करून', 'मोठ्याने ओरडून'],
                correctOptionIndex: 0,
                explanation: 'मोठ्या व्यक्तींचा नेहमी आदर करावा.',
              ),
              ExamQuestionModel(
                id: 'q_1_m_2',
                question: 'घरातील कामात कोणाला मदत करावी?',
                options: ['आई-वडिलांना', 'कोणालाच नाही', 'फक्त खेळावे', 'शांत झोपावे'],
                correctOptionIndex: 0,
                explanation: 'आई-वडिलांना घरकामात छोटी छोटी मदत करावी.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. मुळाक्षरे व स्वर ओळख (अ ते ज्ञ)',
            summary: 'मराठी भाषेतील स्वर (अ, आ, इ, ई, उ, ऊ, ए, ऐ, ओ, औ, अं, अः) आणि व्यंजने (क ते ज्ञ) यांची चित्रे व उच्चारांसह ओळख.',
            keyConcepts: ['स्वर', 'व्यंजने', 'मुळाक्षरे', 'शब्द निर्मिती'],
            studyNotes: '• स्वर: अ, आ, इ, ई, उ, ऊ, ऋ, ए, ऐ, ओ, औ, अं, अः\n• क, ख, ग, घ, ङ, च, छ, ज, झ, ञ...\n• अक्षरांपासून शब्द आणि शब्दांपासून वाक्ये तयार होतात.',
            practiceQuestions: [
              {'question': '‘अ’ वरून सुरू होणारे दोन शब्द सांगा.', 'answer': 'अननस, अमरूद.'},
              {'question': '‘क’ वरून सुरू होणारा शब्द कोणता?', 'answer': 'कमळ.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_1_m_3',
                question: '‘अननस’ या शब्दाचे पहिले अक्षर कोणते?',
                options: ['अ', 'आ', 'इ', 'ई'],
                correctOptionIndex: 0,
                explanation: 'अननस ‘अ’ ने सुरू होतो.',
              ),
              ExamQuestionModel(
                id: 'q_1_m_4',
                question: '‘कमळ’ या शब्दातील शेवटचे अक्षर कोणते?',
                options: ['ळ', 'क', 'म', 'न'],
                correctOptionIndex: 0,
                explanation: 'क-म-ळ मधील शेवटचे अक्षर ‘ळ’ आहे.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 3,
            chapterTitle: '३. सुंदर झाड (कविता)',
            summary: 'झाडे आपल्याला सावली, फळे, फुले आणि शुद्ध हवा देतात. झाडांची निगा राखणे आपला धर्म आहे.',
            keyConcepts: ['झाड', 'सावली', 'पाने-फुले', 'वृक्षारोपण'],
            studyNotes: '• झाडे ही आपली मित्र आहेत.\n• दररोज झाडांना पाणी द्यावे.\n• झाडे तोडू नयेत, नवीन झाडे लावावीत.',
            practiceQuestions: [
              {'question': 'झाडे आपल्याला काय काय देतात?', 'answer': 'झाडे आपल्याला सावली, गोड फळे, सुंदर फुले आणि ऑक्सिजन देतात.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_1_m_5',
                question: 'झाडे आपल्याला कोणती महत्त्वाची गोष्ट देतात?',
                options: ['शुद्ध हवा व सावली', 'प्लास्टिक', 'मोबाईल', 'कचरा'],
                correctOptionIndex: 0,
                explanation: 'झाडे आपल्याला शुद्ध प्राणवायू आणि सावली देतात.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 1,
        subjectCode: 'maths_1',
        subjectName: 'गणित (Mathematics)',
        bookTitle: 'गणित इयत्ता पहिली',
        colorHex: 0xFF1976D2,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. लहान - मोठा (संकल्पना ओळख)',
            summary: 'वस्तूंच्या आकारावरून लहान आणि मोठी वस्तू ओळखणे व तुलना करणे.',
            keyConcepts: ['लहान', 'मोठा', 'तुलना', 'आकार'],
            studyNotes: '• हत्ती मोठा आहे, उंदीर लहान आहे.\n• झाड मोठे आहे, रोपटे लहान आहे.',
            practiceQuestions: [
              {'question': 'हत्ती आणि ससा यात मोठा कोण?', 'answer': 'हत्ती मोठा आहे.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_1_mat_1',
                question: 'खालीलपैकी मोठी वस्तू कोणती?',
                options: ['बस', 'सायकल', 'खेळण्यातील गाडी', 'चेंडू'],
                correctOptionIndex: 0,
                explanation: 'सायकलपेक्षा बस खूप मोठी असते.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. १ ते १० संख्यांची ओळख व लेखन',
            summary: 'अंकांचे वाचन, लेखन आणि मोजणी (एक, दोन, तीन, चार, पाच, सहा, सात, आठ, नऊ, दहा).',
            keyConcepts: ['१ ते १० अंक', 'मोजणी', 'अंकज्ञान'],
            studyNotes: '• १, २, ३, ४, ५, ६, ७, ८, ९, १०\n• एका हाताला ५ बोटे असतात.\n• दोन्ही हातांना मिळून १० बोटे असतात.',
            practiceQuestions: [
              {'question': 'पाच नंतर येणारा अंक कोणता?', 'answer': 'सहा (६).'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_1_mat_2',
                question: '३ च्या पुढे कोणता अंक येतो?',
                options: ['४', '२', '५', '१'],
                correctOptionIndex: 0,
                explanation: '३ च्या लगेच नंतर ४ येतो.',
              ),
              ExamQuestionModel(
                id: 'q_1_mat_3',
                question: '२ + २ किती होतात?',
                options: ['४', '३', '५', '६'],
                correctOptionIndex: 0,
                explanation: '२ आणि २ मिळून ४ होतात.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 1,
        subjectCode: 'english_1',
        subjectName: 'इंग्रजी (My English Book One)',
        bookTitle: 'My English Book One',
        colorHex: 0xFF388E3C,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: 'Unit 1: Welcome to School & Greetings',
            summary: 'Basic greetings in English: Good Morning, Thank You, Please, Hello, and Teacher.',
            keyConcepts: ['Greetings', 'Polite Words', 'Classroom Objects'],
            studyNotes: '• Say "Good Morning" when you meet in the morning.\n• Say "Thank You" when someone helps you.\n• Say "Please" while requesting.',
            practiceQuestions: [
              {'question': 'What should you say when you receive a gift?', 'answer': 'Thank you!'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_1_eng_1',
                question: 'What do we say when meeting someone in the morning?',
                options: ['Good morning', 'Good night', 'Bye bye', 'Sleep well'],
                correctOptionIndex: 0,
                explanation: 'We greet by saying "Good morning".',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: 'Unit 2: English Alphabet (A to Z)',
            summary: 'Letter sounds and identification from Apple to Zebra.',
            keyConcepts: ['Capital Letters', 'Small Letters', 'Phonics'],
            studyNotes: '• A for Apple, B for Ball, C for Cat, D for Dog.\n• 26 letters in English alphabet.',
            practiceQuestions: [
              {'question': 'Which letter comes after C?', 'answer': 'Letter D.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_1_eng_2',
                question: 'What is the first letter of "Apple"?',
                options: ['A', 'B', 'P', 'L'],
                correctOptionIndex: 0,
                explanation: 'Apple begins with the letter A.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 1,
        subjectCode: 'art_1',
        subjectName: 'खेळू, करू, शिकू (इ. १ ली)',
        bookTitle: 'खेळू, करू, शिकू इयत्ता पहिली',
        colorHex: 0xFFF57C00,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. आरोग्य व स्वच्छता',
            summary: 'वैयक्तिक स्वच्छता, दात घासणे, हात धुणे, नखे कापणे आणि नियमित आंघोळ.',
            keyConcepts: ['स्वच्छता', 'हात धुणे', 'आरोग्य सवयी'],
            studyNotes: '• जेवणापूर्वी आणि शौचालयानंतर साबणाने स्वच्छ हात धुवावेत.\n• रोज सकाळी व रात्री झोपण्यापूर्वी दात घासावेत.',
            practiceQuestions: [
              {'question': 'जेवणापूर्वी काय केले पाहिजे?', 'answer': 'साबणाने स्वच्छ हात धुतले पाहिजेत.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_1_art_1',
                question: 'दात कधी घासावेत?',
                options: ['सकाळी आणि रात्री झोपण्यापूर्वी', 'आठवड्यातून एकदा', 'कधीच नाही', 'फक्त रविवारी'],
                correctOptionIndex: 0,
                explanation: 'रोज दोन वेळा दात घासणे आरोग्यासाठी उत्तम असते.',
              ),
            ],
          ),
        ],
      ),
    ],

    // ==========================================
    // CLASS 2 (इयत्ता २ री)
    // ==========================================
    2: [
      CurriculumSubjectModel(
        standard: 2,
        subjectCode: 'marathi_2',
        subjectName: 'मराठी (बालभारती)',
        bookTitle: 'बालभारती इयत्ता दुसरी',
        colorHex: 0xFFE53935,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. देवा तुझे किती सुंदर आकाश (कविता)',
            summary: 'निसर्गाच्या अफाट सौंदर्याचे, चंद्र-सूर्य, तार्‍यांचे आणि फुलांचे कृतज्ञतापूर्वक वर्णन.',
            keyConcepts: ['निसर्ग सौंदर्य', 'चंद्र-सूर्य', 'पक्षी', 'प्रार्थना'],
            studyNotes: '• सृष्टीच्या सुंदर रूपाबद्दल देवाचे आभार मानणारी ही सुंदर बालकविता आहे.\n• कवी: ग. ह. पाटील.',
            practiceQuestions: [
              {'question': 'आकाशात रात्री काय चमकतात?', 'answer': 'आकाशात रात्री चमचम तारे आणि चंद्र चमकतात.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_2_m_1',
                question: '‘देवा तुझे किती सुंदर आकाश’ या कवितेत कशाचे वर्णन केले आहे?',
                options: ['निसर्गाच्या सौंदर्याचे', 'शहराचे', 'गाड्यांचे', 'मोबाईलचे'],
                correctOptionIndex: 0,
                explanation: 'कवितेत सुंदर आकाश, फुले, पाखरे आणि निसर्गाचे वर्णन आहे.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. मांजर आणि उंदीर (चित्रकथा)',
            summary: 'चातुर्य आणि हुशारीने संकटावर कशी मात करता येते हे सांगणारी मनोरंजक गोष्ट.',
            keyConcepts: ['चातुर्य', 'सावधगिरी', 'चित्रकथा'],
            studyNotes: '• संकटाच्या वेळी घाबरून न जाता युक्तीने विचार करावा.',
            practiceQuestions: [
              {'question': 'उंदराने मांजरापासून स्वतःचा बचाव कसा केला?', 'answer': 'उंदराने चपळाईने बिळात पळ काढून स्वतःचा बचाव केला.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_2_m_2',
                question: 'संकटाच्या वेळी आपण काय केले पाहिजे?',
                options: ['शांत राहून युक्तीने विचार करावा', 'घाबरून रडावे', 'पळून जावे', 'चिडचिड करावी'],
                correctOptionIndex: 0,
                explanation: 'हुशारी आणि चातुर्याने मार्ग काढावा.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 3,
            chapterTitle: '३. डिंगोरी (कविता)',
            summary: 'खेळण्यातील फिरणाऱ्या भिरभिर भौऱ्याची आणि बाहुलीची गंमत सांगणारी बालगीत रचना.',
            keyConcepts: ['खेळणी', 'भिंगरी', 'सायकल', 'बाहुली'],
            studyNotes: '• मुलांच्या खेळातील आनंद आणि लयबद्ध शब्दरचना.',
            practiceQuestions: [
              {'question': 'डिंगोरी कशी फिरते?', 'answer': 'डिंगोरी भिरभिर गरगर फिरते.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_2_m_3',
                question: 'डिंगोरी कशी फिरत होती?',
                options: ['भिरभिर गरगर', 'थबकून', 'हळूच', 'उलट'],
                correctOptionIndex: 0,
                explanation: 'कवितेत डिंगोरी भिरभिर फिरली असे म्हटले आहे.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 2,
        subjectCode: 'maths_2',
        subjectName: 'गणित (Mathematics)',
        bookTitle: 'गणित इयत्ता दुसरी',
        colorHex: 0xFF1976D2,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. दोन अंकी संख्यांचे ज्ञान (११ ते १००)',
            summary: 'दशक आणि एकक यांची संकल्पना. संख्यांचे वाचन व स्थानिक किंमत.',
            keyConcepts: ['दशक', 'एकक', 'स्थानिक किंमत', 'विस्तारित रूप'],
            studyNotes: '• १० चा एक गठ्ठा म्हणजे १ दशक.\n• २४ = २ दशक + ४ एकक = २० + ४.\n• दशक डाव्या बाजूला आणि एकक उजव्या बाजूला असतो.',
            practiceQuestions: [
              {'question': '३५ या संख्येत किती दशक व किती एकक आहेत?', 'answer': '३ दशक आणि ५ एकक.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_2_mat_1',
                question: '४ दशक आणि ७ एकक मिळून कोणती संख्या बनते?',
                options: ['४७', '७४', '४०', '११'],
                correctOptionIndex: 0,
                explanation: '४ दशक = ४० आणि ७ एकक = ७, मिळून ४७.',
              ),
              ExamQuestionModel(
                id: 'q_2_mat_2',
                question: '२५ + १५ चे उत्तर काय येईल?',
                options: ['४०', '३५', '४५', '३०'],
                correctOptionIndex: 0,
                explanation: '२५ + १५ = ४०.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. गुणाकाराची तोंडओळख (पाढे २ ते ५)',
            summary: 'गुणाकार म्हणजे एकाच संख्येची पुन्हा पुन्हा केलेली बेरीज.',
            keyConcepts: ['गुणाकार चिन्हे (×)', 'पाढे', 'पट'],
            studyNotes: '• ३ + ३ + ३ + ३ = ३ × ४ = १२.\n• कोणत्याही संख्येला शून्याने गुणल्यास उत्तर ० येते.',
            practiceQuestions: [
              {'question': '४ × ३ किती होतात?', 'answer': '४ × ३ = १२.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_2_mat_3',
                question: '५ × ४ किती होतात?',
                options: ['२०', '२५', '१५', '१०'],
                correctOptionIndex: 0,
                explanation: '५ चा पाढा ४ पर्यंत मोजल्यास २० येतात.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 2,
        subjectCode: 'english_2',
        subjectName: 'इंग्रजी (My English Book Two)',
        bookTitle: 'My English Book Two',
        colorHex: 0xFF388E3C,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: 'Unit 1: Shapes and Colours',
            summary: 'Identify basic geometric shapes: Circle, Square, Triangle, Rectangle and primary colours.',
            keyConcepts: ['Shapes', 'Colours', 'Red, Blue, Green, Yellow'],
            studyNotes: '• A ball is round like a circle.\n• A door is rectangular.\n• Grass is green, the sun is yellow.',
            practiceQuestions: [
              {'question': 'What is the colour of a ripe mango?', 'answer': 'Yellow.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_2_eng_1',
                question: 'How many sides does a triangle have?',
                options: ['3', '4', '2', '5'],
                correctOptionIndex: 0,
                explanation: 'A triangle has three sides.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 2,
        subjectCode: 'art_2',
        subjectName: 'खेळू, करू, शिकू (इ. २ री)',
        bookTitle: 'खेळू, करू, शिकू इयत्ता दुसरी',
        colorHex: 0xFFF57C00,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. मैदानी खेळ व कवायत',
            summary: 'लंगडी, खो-खो, धावणे यासारखे मैदानी खेळ आणि शरीराचा सुदृढ विकास.',
            keyConcepts: ['मैदानी खेळ', 'व्यायाम', 'तंदुरुस्ती'],
            studyNotes: '• रोज किमान १ तास मैदानी खेळ खेळावेत.\n• खेळामुळे शरीर चपळ आणि निरोगी राहते.',
            practiceQuestions: [
              {'question': 'मैदानी खेळ खेळल्याने काय फायदा होतो?', 'answer': 'शरीर मजबूत आणि मन उत्साही राहते.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_2_art_1',
                question: 'खालीलपैकी कोणता खेळ मैदानावर खेळला जातो?',
                options: ['खो-खो', 'कॅरम', 'लुडो', 'व्हिडिओ गेम'],
                correctOptionIndex: 0,
                explanation: 'खो-खो हा मैदानी खेळ आहे.',
              ),
            ],
          ),
        ],
      ),
    ],

    // ==========================================
    // CLASS 3 (इयत्ता ३ री)
    // ==========================================
    3: [
      CurriculumSubjectModel(
        standard: 3,
        subjectCode: 'marathi_3',
        subjectName: 'मराठी (बालभारती)',
        bookTitle: 'बालभारती इयत्ता तिसरी',
        colorHex: 0xFFE53935,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. झोका (कविता)',
            summary: 'सुतारी झाडाला बांधलेल्या झोक्यावर आभाळात उंच झुलणाऱ्या मुलाचा आनंद.',
            keyConcepts: ['झोका', 'झाड', 'वारा', 'आनंद'],
            studyNotes: '• कवी: दादासाहेब कोते.\n• झोका वाऱ्याच्या वेगाने आकाशाला भिडल्याचा भास होतो.',
            practiceQuestions: [
              {'question': 'झोका कुठे बांधला आहे?', 'answer': 'झोका झाडाच्या फांदीला बांधला आहे.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_3_m_1',
                question: 'झाडाच्या फांदीला काय टांगले आहे?',
                options: ['झोका', 'घड्याळ', 'दप्तर', 'कंदील'],
                correctOptionIndex: 0,
                explanation: 'झाडाच्या फांदीला झोका बांधलेला आहे.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. सिंह आणि कोल्हा (चातुर्यकथा)',
            summary: 'शक्तीपेक्षा युक्ती श्रेष्ठ असते हे दाखवून देणारी बोधप्रद लोककथा.',
            keyConcepts: ['शक्ती', 'युक्ती', 'चातुर्य', 'पंचतंत्र कथा'],
            studyNotes: '• संकटाच्या वेळी शक्तीपेक्षा बुद्धी व युक्ती कामास येते.',
            practiceQuestions: [
              {'question': 'या पाठातून काय शिकवण मिळते?', 'answer': 'शक्तीपेक्षा युक्ती श्रेष्ठ असते.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_3_m_2',
                question: 'शक्तीपेक्षा काय श्रेष्ठ असते?',
                options: ['युक्ती व बुद्धी', 'संपत्ती', 'अहंकार', 'शारीरिक ताकद'],
                correctOptionIndex: 0,
                explanation: 'बुद्धी आणि चातुर्याने मोठ्यात मोठ्या संकटावर मात करता येते.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 3,
            chapterTitle: '३. वाचनाचे महत्त्व',
            summary: 'वाचनामुळे ज्ञान, भाषा आणि विचारसमृद्धी वाढते. डॉ. बाबासाहेब आंबेडकरांचा वाचन संदेश.',
            keyConcepts: ['वाचन संस्कृती', 'ग्रंथालय', 'ज्ञान'],
            studyNotes: '• वाचाल तर वाचाल!\n• दररोज वर्तमानपत्र व पुस्तके वाचण्याची सवय लावावी.',
            practiceQuestions: [
              {'question': '‘वाचाल तर वाचाल’ हा संदेश कोणाचा?', 'answer': 'डॉ. बाबासाहेब आंबेडकर.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_3_m_3',
                question: 'पुस्तके वाचल्याने काय वाढते?',
                options: ['ज्ञान व विचारशक्ती', 'आळस', 'राग', 'वजन'],
                correctOptionIndex: 0,
                explanation: 'वाचनाने आपले ज्ञान आणि कल्पनाशक्ती समृद्ध होते.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 3,
        subjectCode: 'maths_3',
        subjectName: 'गणित (Mathematics)',
        bookTitle: 'गणित इयत्ता तिसरी',
        colorHex: 0xFF1976D2,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. तीन अंकी संख्यांचे वाचन व लेखन',
            summary: 'शतक, दशक, एकक यांची संकल्पना. १०० ते ९९९ पर्यंतच्या संख्यांची स्थानिक किंमत.',
            keyConcepts: ['शतक', 'दशक', 'एकक', 'स्थानिक किंमत'],
            studyNotes: '• १०० म्हणजे १ शतक, ० दशक, ० एकक.\n• ४५६ = ४ शतक + ५ दशक + ६ एकक = ४०० + ५० + ६.',
            practiceQuestions: [
              {'question': '७२८ या संख्येत ७ चे स्थानमूल्य काय?', 'answer': '७०० (शतक स्थानी आहे).'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_3_mat_1',
                question: 'पाचशे चव्वेचाळीस ही संख्या अंकात कशी लिहितात?',
                options: ['५४४', '४५४', '५४०', '५०४'],
                correctOptionIndex: 0,
                explanation: 'पाचशे चव्वेचाळीस = ५४४.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. गुणाकार व भागाकाराची संकल्पना',
            summary: 'गुणाकार क्रिया आणि भागाकार म्हणजे समान वाटणी किंवा समान गट करणे.',
            keyConcepts: ['गुणाकार', 'भागाकार (÷)', 'समान वाटणी'],
            studyNotes: '• भागाकार म्हणजे एकाच संख्येची पुन्हा पुन्हा केलेली वजाबाकी.\n• १२ ÷ ३ = ४.',
            practiceQuestions: [
              {'question': '१५ चॉकलेट्स ३ मुलांमध्ये समान वाटल्यास प्रत्येकाला किती मिळतील?', 'answer': '१५ ÷ ३ = ५ चॉकलेट्स.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_3_mat_2',
                question: '२४ ÷ ६ चे उत्तर काय येईल?',
                options: ['४', '५', '३', '६'],
                correctOptionIndex: 0,
                explanation: '६ × ४ = २४, म्हणून २४ ÷ ६ = ४.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 3,
        subjectCode: 'english_3',
        subjectName: 'इंग्रजी (My English Book Three)',
        bookTitle: 'My English Book Three',
        colorHex: 0xFF388E3C,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: 'Unit 1: Nouns and Describing Words',
            summary: 'Naming words (Nouns) of person, place, animal, thing and adjectives (describing words).',
            keyConcepts: ['Noun', 'Adjective', 'Vocabulary'],
            studyNotes: '• Noun is a name of anything (e.g. Pune, Dog, Apple, Rohan).\n• Adjective describes a noun (e.g. sweet apple, tall tree).',
            practiceQuestions: [
              {'question': 'Find the noun in: "The dog barks."', 'answer': 'dog.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_3_eng_1',
                question: 'Which of the following is a naming word (noun)?',
                options: ['School', 'Run', 'Quickly', 'Very'],
                correctOptionIndex: 0,
                explanation: '"School" is the name of a place, hence a noun.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 3,
        subjectCode: 'evs_3',
        subjectName: 'परिसर अभ्यास (Our Surroundings)',
        bookTitle: 'परिसर अभ्यास इयत्ता तिसरी',
        colorHex: 0xFF00897B,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. आपल्या अवतीभोवती (सजीव व निर्जीव)',
            summary: 'परिसरातील घटक, सजीव (वनस्पती व प्राणी) आणि निर्जीव (दगड, माती, पाणी) यांच्यातील फरक.',
            keyConcepts: ['सजीव', 'निर्जीव', 'वाढ व विकास', 'अन्न व श्वसन'],
            studyNotes: '• सजीवांची वाढ होते, त्यांना अन्नाची व पाण्याची गरज असते.\n• निर्जीव वस्तूंमध्ये हालचाल किंवा वाढ होत नाही.',
            practiceQuestions: [
              {'question': 'सजीव आणि निर्जीव यांच्यातील दोन फरक सांगा.', 'answer': 'सजीव श्वास घेतात व वाढतात, निर्जीव श्वास घेत नाहीत व वाढत नाहीत.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_3_evs_1',
                question: 'खालीलपैकी सजीव कोणता आहे?',
                options: ['झाड', 'दगड', 'खुर्ची', 'सायकल'],
                correctOptionIndex: 0,
                explanation: 'झाडे सजीव असतात कारण ती वाढतात आणि अन्न तयार करतात.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. पाण्याची साठवण व संवर्धन',
            summary: 'पाण्याचे स्त्रोत, जुनी व नवी जलसाठवण व्यवस्था, पाण्याचा काटकसरीने वापर.',
            keyConcepts: ['विहीर', 'तलाव', 'धरण', 'जल संवर्धन'],
            studyNotes: '• पाणी हे जीवन आहे. पाण्याचा प्रत्येक थेंब महत्त्वाचा आहे.\n• नळ उघडा सोडू नये, पावसाचे पाणी साठवले पाहिजे.',
            practiceQuestions: [
              {'question': 'पाण्याचे मुख्य स्त्रोत कोणते?', 'answer': 'पावसाचे पाणी हा पाण्याचा मुख्य स्त्रोत आहे.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_3_evs_2',
                question: 'पाण्याचा मुख्य स्त्रोत कोणता आहे?',
                options: ['पाऊस', 'समुद्र', 'नळ', 'विहीर'],
                correctOptionIndex: 0,
                explanation: 'पृथ्वीवर गोड्या पाण्याचा मुख्य स्त्रोत पाऊस आहे.',
              ),
            ],
          ),
        ],
      ),
    ],

    // ==========================================
    // CLASS 4 (इयत्ता ४ थी)
    // ==========================================
    4: [
      CurriculumSubjectModel(
        standard: 4,
        subjectCode: 'marathi_4',
        subjectName: 'मराठी (बालभारती)',
        bookTitle: 'बालभारती इयत्ता चौथी',
        colorHex: 0xFFE53935,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. धरतीची आम्ही लेकरं (कविता)',
            summary: 'शेतकऱ्यांचे श्रम, काळ्या मातीची सेवा आणि शेतात पिकणाऱ्या हिरव्या पिकांचा अभिमान.',
            keyConcepts: ['शेतकरी', 'काळी आई', 'श्रमप्रतिष्ठा', 'शेती'],
            studyNotes: '• कवी: द. ना. गव्हाणकर.\n• शेतकरी अहोरात्र कष्ट करून जगाला अन्न पुरवतो.',
            practiceQuestions: [
              {'question': 'शेतकरी कोणाची लेकरे आहेत?', 'answer': 'शेतकरी धरतीमातेची लेकरे आहेत.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_4_m_1',
                question: '‘धरतीची आम्ही लेकरं’ या कवितेत कोणाचा गौरव केला आहे?',
                options: ['शेतकऱ्यांच्या श्रमाचा', 'व्यापाऱ्यांचा', 'शहरातील वाहनांचा', 'राजांचा'],
                correctOptionIndex: 0,
                explanation: 'कवितेत बळीराजा शेतकरी आणि त्याच्या कष्टांचा गौरव केला आहे.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. बोलणारी नदी (गोष्ट)',
            summary: 'लीला नावाच्या चतुर मुलीची आणि तिच्या करामतींची हसवणारी मनोरंजक कथा.',
            keyConcepts: ['लीला', 'आई-माई', 'नदी', 'गोड खाणे'],
            studyNotes: '• लीला हुशार व खोडकर मुलगी होती.\n• नदीच्या नावाखाली ती आई व आजीला कशी बनवते याची ही विनोदी गोष्ट आहे.',
            practiceQuestions: [
              {'question': 'लीलाला काय खायची खूप इच्छा होती?', 'answer': 'लीलाला बर्फाचा गोळा खायची इच्छा होती.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_4_m_2',
                question: 'लीलाला कोणत्या गोष्टीची खूप आवड होती?',
                options: ['खोड्या काढण्याची व बर्फाच्या गोळ्याची', 'झोपण्याची', 'कपडे धुण्याची', 'शांत बसण्याची'],
                correctOptionIndex: 0,
                explanation: 'लीला खोडकर मुलगी होती आणि तिला गोळा खायला आवडायचा.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 4,
        subjectCode: 'maths_4',
        subjectName: 'गणित (Mathematics)',
        bookTitle: 'गणित इयत्ता चौथी',
        colorHex: 0xFF1976D2,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. चार व पाच अंकी संख्यांचे ज्ञान',
            summary: 'हजार व दशहजार स्थान, संख्यांचे विस्तारित रूप, लहान-मोठेपणा ठरवणे.',
            keyConcepts: ['हजार', 'दशहजार', 'स्थानिक किंमत', 'चढता व उतरता क्रम'],
            studyNotes: '• ९,९९९ + १ = १०,००० (दहा हजार).\n• ५४,३२१ = ५०,००० + ४,००० + ३०० + २० + १.',
            practiceQuestions: [
              {'question': 'सर्वात लहान ४ अंकी संख्या कोणती?', 'answer': '१,००० (एक हजार).'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_4_mat_1',
                question: 'सर्वात मोठी चार अंकी संख्या कोणती?',
                options: ['९९९९', '१०००', '९०००', '९९९०'],
                correctOptionIndex: 0,
                explanation: '९९९९ ही सर्वात मोठी चार अंकी संख्या आहे.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. अपूर्णांकांची ओळख (पाव, अर्धा, पाऊण)',
            summary: 'समभागांची संकल्पना: १/२ (अर्धा), १/४ (पाव), ३/४ (पाऊण), १ पूर्ण.',
            keyConcepts: ['अंश', 'छेद', 'अर्धा (१/२)', 'पाव (१/४)', 'पाऊण (३/४)'],
            studyNotes: '• एका वस्तूचे दोन समान भाग केले की प्रत्येक भाग अर्धा (१/२) होतो.\n• चार समान भागांपैकी एक भाग म्हणजे पाव (१/४).',
            practiceQuestions: [
              {'question': 'एक भाकरीचे चार समान भाग केले, तर तीन भाग म्हणजे काय?', 'answer': 'पाऊण (३/४) भाकरी.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_4_mat_2',
                question: '१/२ या अपूर्णांकाला मराठीत काय म्हणतात?',
                options: ['अर्धा', 'पाव', 'पाऊण', 'सव्वा'],
                correctOptionIndex: 0,
                explanation: '१/२ म्हणजे अर्धा.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 4,
        subjectCode: 'evs1_4',
        subjectName: 'परिसर अभ्यास भाग १ (विज्ञान व भूगोल)',
        bookTitle: 'परिसर अभ्यास भाग १ इयत्ता चौथी',
        colorHex: 0xFF00897B,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. प्राण्यांचा जीवनक्रम',
            summary: 'फुलपाखराचे रूपांतरण (अंडे, अळी/सुरवंट, कोष, प्रौढ फुलपाखरू) आणि पिल्लांचा जन्म.',
            keyConcepts: ['रूपांतरण', 'अंडी', 'सुरवंट', 'कोष अवस्था', 'प्रौढ'],
            studyNotes: '• बिबळ्या कडवा फुलपाखराच्या चार अवस्था: अंडे → सुरवंट → कोष → फुलपाखरू.\n• कोंबडीच्या अंड्यातून पिल्लू बाहेर पडायला २१ दिवस लागतात.',
            practiceQuestions: [
              {'question': 'फुलपाखराच्या जीवनक्रमातील चार अवस्था कोणत्या?', 'answer': 'अंडे, सुरवंट (अळी), कोष आणि प्रौढ फुलपाखरू.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_4_evs1_1',
                question: 'फुलपाखराच्या कोषावस्थेला काय म्हणतात?',
                options: ['कोश', 'अंडे', 'सुरवंट', 'पक्षी'],
                correctOptionIndex: 0,
                explanation: 'अळी आपल्याभोवती आवरण विणते, त्याला कोष म्हणतात.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 4,
        subjectCode: 'evs2_4',
        subjectName: 'परिसर अभ्यास भाग २ (शिवछत्रपती)',
        bookTitle: 'शिवछत्रपती इयत्ता चौथी',
        colorHex: 0xFFEF6C00,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. शिवजन्मापूर्वीचा महाराष्ट्र',
            summary: 'महाराष्ट्रातील संतांची कामगिरी, अन्यायी सुलतानशाही, आणि रयतेची दुर्दशा.',
            keyConcepts: ['शिवाजी महाराज', 'आदिलशहा', 'निजामशहा', 'संत ज्ञानेश्वर', 'संत तुकाराम'],
            studyNotes: '• सुमारे चारशे वर्षांपूर्वी महाराष्ट्रात सुलतानशाहीचे राज्य होते.\n• रयतेला स्वतःचे राज्य नव्हते, शेतकऱ्यांवर जुलूम होत होता.',
            practiceQuestions: [
              {'question': 'शिवजन्मापूर्वी महाराष्ट्रावर कोणाचे राज्य होते?', 'answer': 'विजापूरचा आदिलशहा आणि अहमदनगरचा निजामशहा.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_4_evs2_1',
                question: 'छत्रपती शिवाजी महाराजांचा जन्म कोणत्या किल्ल्यावर झाला?',
                options: ['शिवनेरी', 'रायगड', 'प्रतापगड', 'सिंहगड'],
                correctOptionIndex: 0,
                explanation: 'शिवाजी महाराजांचा जन्म शिवनेरी किल्ल्यावर झाला.',
              ),
              ExamQuestionModel(
                id: 'q_4_evs2_2',
                question: 'शिवरायांच्या मातोश्रींचे नाव काय होते?',
                options: ['जिजामाता', 'ताराबाई', 'सोयराबाई', 'पुतळाबाई'],
                correctOptionIndex: 0,
                explanation: 'राजमाता जिजाऊ यांनी शिवरायांना शूर व न्यायी बनवले.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 4,
        subjectCode: 'english_4',
        subjectName: 'इंग्रजी (My English Book Four)',
        bookTitle: 'My English Book Four',
        colorHex: 0xFF388E3C,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: 'Unit 1: Action Words and Sentences',
            summary: 'Verbs (action words), constructing small sentences in present continuous tense.',
            keyConcepts: ['Verbs', 'Action words', 'Present tense'],
            studyNotes: '• Running, jumping, reading, writing are verbs.\n• "I am reading a story book."',
            practiceQuestions: [
              {'question': 'Name two action words.', 'answer': 'Eat, Sleep.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_4_eng_1',
                question: 'Which word is an action word (verb)?',
                options: ['Jump', 'Table', 'Blue', 'Slow'],
                correctOptionIndex: 0,
                explanation: '"Jump" shows an action.',
              ),
            ],
          ),
        ],
      ),
    ],

    // ==========================================
    // CLASS 5 (इयत्ता ५ वी)
    // ==========================================
    5: [
      CurriculumSubjectModel(
        standard: 5,
        subjectCode: 'marathi_5',
        subjectName: 'मराठी (बालभारती)',
        bookTitle: 'बालभारती इयत्ता पाचवी',
        colorHex: 0xFFE53935,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. माय मराठी (कविता)',
            summary: 'मातृभाषेची थोरवी, गोडवा आणि तिच्या चरणी सर्वस्व अर्पण करण्याची भावना.',
            keyConcepts: ['मातृभाषा', 'अमृत', 'शब्दसंपत्ती', 'अभिमान'],
            studyNotes: '• कवयित्री: संजीवनी मराठे.\n• मराठी भाषा अमृताहूनही गोड आहे.\n• मातृभाषेचे ऋण कधीही विसरू नये.',
            practiceQuestions: [
              {'question': 'कवयित्रीने मराठी भाषेला कशाची उपमा दिली आहे?', 'answer': 'कवयित्रीने मराठी भाषेला अमृताची उपमा दिली आहे.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_5_m_1',
                question: '‘माय मराठी’ या कवितेच्या कवयित्री कोण आहेत?',
                options: ['संजीवनी मराठे', 'शांता शेळके', 'बहिणाबाई चौधरी', 'अनुराधा पोतदार'],
                correctOptionIndex: 0,
                explanation: 'संजीवनी मराठे यांनी माय मराठी कविता लिहिली आहे.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. बंडूची इजार (विनोदी कथा)',
            summary: 'बंडूची चार बोटे लांब झालेली इजार कापताना घरातील सर्वांनी एकामागोमाग चार-चार बोटे कापल्यामुळे झालेली गंमत.',
            keyConcepts: ['संवाद', 'विनोद', 'समज-गैरसमज'],
            studyNotes: '• कुटुंबातील संवाद आणि गैरसमजातून झालेला निखळ विनोद.\n• काम करताना विचारपूस करणे आवश्यक असते.',
            practiceQuestions: [
              {'question': 'बंडूची इजार शेवटी काय झाली?', 'answer': 'इजार चार वेळा कापल्याने चड्डी बनली.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_5_m_2',
                question: 'बंडूची इजार किती बोटे लांब झाली होती?',
                options: ['चार बोटे', 'दोन बोटे', 'सहा बोटे', 'एक वित'],
                correctOptionIndex: 0,
                explanation: 'इजार चार बोटे लांब झाली होती.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 5,
        subjectCode: 'maths_5',
        subjectName: 'गणित (Mathematics)',
        bookTitle: 'गणित इयत्ता पाचवी',
        colorHex: 0xFF1976D2,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. रोमन संख्याचिन्हे (Roman Numerals)',
            summary: 'I, V, X, L, C, D, M या रोमन चिन्हांची ओळख, नियम आणि लेखन पद्धत.',
            keyConcepts: ['I=1', 'V=5', 'X=10', 'L=50', 'C=100', 'D=500', 'M=1000'],
            studyNotes: '• I आणि X जास्तीत जास्त तीन वेळा लागोपाठ येऊ शकतात.\n• V कधीही लागोपाठ येत नाही.\n• मोठ्या चिन्हाच्या उजवीकडे लहान चिन्ह दिल्यास बेरीज होते: VI = ५ + १ = ६.\n• डावीकडे दिल्यास वजाबाकी होते: IV = ५ - १ = ४.',
            practiceQuestions: [
              {'question': 'रोमन पद्धतीत १५ कसे लिहितात?', 'answer': 'XV (१० + ५ = १५).'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_5_mat_1',
                question: 'रोमन संख्याचिन्हांमध्ये ‘X’ म्हणजे किती?',
                options: ['१०', '५', '५०', '१००'],
                correctOptionIndex: 0,
                explanation: 'X म्हणजे १०.',
              ),
              ExamQuestionModel(
                id: 'q_5_mat_2',
                question: '‘XIV’ ही संख्या देवनागरी किंवा आंतरराष्ट्रीय अंकात किती आहे?',
                options: ['१४', '१६', '१५', '१२'],
                correctOptionIndex: 0,
                explanation: 'X = १० आणि IV = ४, मिळून १४.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 5,
        subjectCode: 'evs1_5',
        subjectName: 'परिसर अभ्यास भाग १ (विज्ञान व भूगोल)',
        bookTitle: 'परिसर अभ्यास भाग १ इयत्ता पाचवी',
        colorHex: 0xFF00897B,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. आपली पृथ्वी आणि आपली सूर्यमाला',
            summary: 'सूर्य, आठ ग्रह, उपग्रह (चंद्र), लघुग्रह आणि सूर्यमालेची रचना.',
            keyConcepts: ['सूर्यमाला', 'ग्रह (बुध, शुक्र, पृथ्वी, मंगळ, गुरू, शनी, युरेनस, नेपच्यून)', 'उपग्रह'],
            studyNotes: '• सूर्य हा तारा आहे. ग्रह स्वतः प्रकाश देत नाहीत, ते सूर्याकडून प्रकाश घेतात.\n• पृथ्वीचा एकमेव नैसर्गिक उपग्रह चंद्र आहे.',
            practiceQuestions: [
              {'question': 'सूर्याच्या सर्वात जवळचा ग्रह कोणता?', 'answer': 'बुध ग्रह.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_5_evs1_1',
                question: 'पृथ्वीचा नैसर्गिक उपग्रह कोणता आहे?',
                options: ['चंद्र', 'सूर्य', 'मंगळ', 'शुक्र'],
                correctOptionIndex: 0,
                explanation: 'चंद्र हा पृथ्वीभोवती फिरणारा नैसर्गिक उपग्रह आहे.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 5,
        subjectCode: 'evs2_5',
        subjectName: 'परिसर अभ्यास भाग २ (इतिहास - मानवाची वाटचाल)',
        bookTitle: 'मानवाची वाटचाल इयत्ता पाचवी',
        colorHex: 0xFFEF6C00,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. इतिहास म्हणजे काय?',
            summary: 'भूतकाळातील घटनांचा सुसंगत अभ्यास म्हणजे इतिहास. इतिहासाची वैज्ञानिक पद्धत.',
            keyConcepts: ['भूतकाळ', 'वर्तमानकाळ', 'भविष्यकाळ', 'पुराव्यांची सत्यता'],
            studyNotes: '• इतिहास हा काल्पनिक नसून पुराव्यांवर आधारित असतो.\n• भौतिक, लिखित आणि मौखिक साधनांवरून इतिहास तपासला जातो.',
            practiceQuestions: [
              {'question': 'इतिहास कशाचा अभ्यास करतो?', 'answer': 'इतिहास भूतकाळातील घटनांचा शास्त्रीय अभ्यास करतो.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_5_evs2_1',
                question: 'भूतकाळात घडून गेलेल्या घटनांचा अभ्यास करणाऱ्या शास्त्राला काय म्हणतात?',
                options: ['इतिहास', 'भूगोल', 'गणित', 'नागरिकशास्त्र'],
                correctOptionIndex: 0,
                explanation: 'इतिहास हे भूतकाळातील घटनांचे शास्त्र आहे.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 5,
        subjectCode: 'hindi_5',
        subjectName: 'हिंदी (सुलभभारती)',
        bookTitle: 'सुलभभारती इयत्ता पाचवी',
        colorHex: 0xFF8E24AA,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. नंदनवन (चित्रवाचन)',
            summary: 'जंगलातील प्राणी आणि पक्षी आनंदाने एकत्र राहतात, पर्यावरण रक्षणाचा संदेश.',
            keyConcepts: ['वन्यजीव', 'पर्यावरण', 'चित्रवर्णन'],
            studyNotes: '• जंगल में सभी जानवर मिलजुल कर रहते हैं।\n• पेड़ों और जानवरों की रक्षा करना हमारा कर्तव्य है।',
            practiceQuestions: [
              {'question': 'नंदनवन में कौन-कौन से जानवर दिखाई देते हैं?', 'answer': 'हाथी, हिरण, खरगोश, शेर और पक्षी।'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_5_hin_1',
                question: 'जंगल का राजा किसे कहते हैं?',
                options: ['शेर को', 'हाथी को', 'बंदर को', 'हिरण को'],
                correctOptionIndex: 0,
                explanation: 'शेर को जंगल का राजा कहा जाता है।',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 5,
        subjectCode: 'english_5',
        subjectName: 'इंग्रजी (My English Book Five)',
        bookTitle: 'My English Book Five',
        colorHex: 0xFF388E3C,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: 'Unit 1: The Golden Touch',
            summary: 'The classic story of King Midas and greed. Contentment is real wealth.',
            keyConcepts: ['King Midas', 'Greed', 'Golden Touch', 'Moral Lesson'],
            studyNotes: '• Too much greed brings unhappiness.\n• Gold and wealth cannot buy true happiness and food.',
            practiceQuestions: [
              {'question': 'What happened to Midas\'s daughter when he touched her?', 'answer': 'She turned into a golden statue.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_5_eng_1',
                question: 'What did King Midas wish for?',
                options: ['Everything he touches turns to gold', 'A flying car', 'A palace of diamonds', 'Immortal life'],
                correctOptionIndex: 0,
                explanation: 'King Midas asked for the golden touch.',
              ),
            ],
          ),
        ],
      ),
    ],

    // ==========================================
    // CLASS 6 (इयत्ता ६ वी)
    // ==========================================
    6: [
      CurriculumSubjectModel(
        standard: 6,
        subjectCode: 'marathi_6',
        subjectName: 'मराठी (बालभारती)',
        bookTitle: 'बालभारती इयत्ता सहावी',
        colorHex: 0xFFE53935,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. बलसागर भारत होवो (गीत)',
            summary: 'राष्ट्रभक्तीने ओतप्रोत गीत, भारताला सामर्थ्यवान, विश्वगौरवास्पद बनवण्याची प्रतिज्ञा.',
            keyConcepts: ['देशभक्ती', 'साने गुरुजी', 'त्याग', 'राष्ट्रसेवा'],
            studyNotes: '• गीतकार: साने गुरुजी.\n• स्वतःचे आयुष्य देशासाठी समर्पित करण्याची प्रेरणा या गीतातून मिळते.',
            practiceQuestions: [
              {'question': '‘बलसागर भारत होवो’ हे गीत कोणी लिहिले आहे?', 'answer': 'साने गुरुजी यांनी लिहिले आहे.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_m_1',
                question: '‘बलसागर भारत होवो’ या राष्ट्रगीताचे रचनाकार कोण आहेत?',
                options: ['साने गुरुजी', 'कुसुमाग्रज', 'विंदा करंदीकर', 'ग. दि. माडगूळकर'],
                correctOptionIndex: 0,
                explanation: 'साने गुरुजींनी हे प्रेरणादायी देशभक्तीपर गीत रचले.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. सायकल म्हणते, मी आहे ना!',
            summary: 'सायकलचे आत्मकथन: पर्यावरणपूरक, व्यायाम देणारे आणि अत्यंत स्वस्त प्रवासाचे साधन.',
            keyConcepts: ['सायकलचे फायदे', 'प्रदूषणमुक्ती', 'शारीरिक व्यायाम', 'बचत'],
            studyNotes: '• सायकल चालवल्याने इंधन बचत होते आणि प्रदूषण टळते.\n• सायकलिंग हा उत्कृष्ट व्यायाम आहे.',
            practiceQuestions: [
              {'question': 'सायकल वापरण्याचे दोन फायदे सांगा.', 'answer': '१. इंधनाची बचत होते व प्रदूषण होत नाही. २. शरीराला चांगला व्यायाम मिळतो.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_m_2',
                question: 'सायकल वापरल्याने कशाची बचत होते?',
                options: ['इंधन व पैशांची', 'केवळ वेळेची', 'पुस्तकांची', 'कचऱ्याची'],
                correctOptionIndex: 0,
                explanation: 'सायकलला पेट्रोल-डिझेल लागत नाही, यामुळे पैशांची व इंधनाची बचत होते.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 6,
        subjectCode: 'maths_6',
        subjectName: 'गणित (Mathematics)',
        bookTitle: 'गणित इयत्ता सहावी',
        colorHex: 0xFF1976D2,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. भूमितीतील मूलभूत संबोध (Basic Concepts in Geometry)',
            summary: 'बिंदू, रेषा, रेषाखंड, किरण, प्रतल, एकसंपाती रेषा आणि समांतर रेषा.',
            keyConcepts: ['बिंदू (Point)', 'रेषाखंड (Line Segment)', 'रेषा (Line)', 'किरण (Ray)', 'समांतर रेषा'],
            studyNotes: '• बिंदूला लांबी, रुंदी किंवा जाडी नसते.\n• दोन्ही बाजूंना अमर्याद वाढणाऱ्या सरळ मार्गाला रेषा म्हणतात.\n• एकाच प्रतलात असणाऱ्या व एकमेकींना न छेदणाऱ्या रेषा समांतर असतात.',
            practiceQuestions: [
              {'question': 'समांतर रेषा म्हणजे काय?', 'answer': 'एकाच प्रतलात असलेल्या आणि एकमेकींना कधीही न छेदणाऱ्या रेषांना समांतर रेषा म्हणतात.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_mat_1',
                question: 'एकाच बिंदूतून किती रेषा काढता येतात?',
                options: ['अनंत', 'एकच', 'दोन', 'तीन'],
                correctOptionIndex: 0,
                explanation: 'एका बिंदूतून अनंत (असंख्य) रेषा जाऊ शकतात.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. पूर्णांक संख्या (Integers)',
            summary: 'धन संख्या, ऋण संख्या आणि शून्य मिळून पूर्णांक संख्या समूह तयार होतो. संख्यारेषेवर दर्शवणे.',
            keyConcepts: ['धन संख्या (+)', 'ऋण संख्या (-)', 'संख्यारेषा', 'पूर्णांक बेरीज-वजाबाकी'],
            studyNotes: '• संख्यारेषेवर शून्याच्या उजवीकडे धन (+) आणि डावीकडे ऋण (-) संख्या असतात.\n• (-५) + ३ = -२.\n• (-४) + (-३) = -७.',
            practiceQuestions: [
              {'question': 'संख्यारेषेवर शून्याच्या डावीकडे कोणत्या संख्या असतात?', 'answer': 'ऋण संख्या.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_mat_2',
                question: '(-७) + (+१०) चे उत्तर काय येईल?',
                options: ['+३', '-३', '+१७', '-१७'],
                correctOptionIndex: 0,
                explanation: '१० - ७ = +३.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 6,
        subjectCode: 'science_6',
        subjectName: 'सामान्य विज्ञान (General Science)',
        bookTitle: 'सामान्य विज्ञान इयत्ता सहावी',
        colorHex: 0xFF43A047,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. नैसर्गिक संसाधने - हवा, पाणी आणि जमीन',
            summary: 'पृथ्वीवरील जीवावरणाचा पाया: वातावरण, जलावरण, भूमी आणि त्यांचे संवर्धन.',
            keyConcepts: ['नायट्रोजन (७८%)', 'ऑक्सिजन (२१%)', 'ओझोन थर', 'जलचक्र', 'मृदा निर्मिती'],
            studyNotes: '• हवेमध्ये नायट्रोजन ७८%, ऑक्सिजन २१%, अरगॉन ०.९%, कार्बन डायऑक्साइड ०.०३% असतो.\n• ओझोनचा थर सूर्याची हानिकारक अतिनील किरणे शोषून घेतो.\n• २.५ सेंमी जाडीचा मृदेचा थर तयार होण्यास सुमारे हजार वर्षे लागतात.',
            practiceQuestions: [
              {'question': 'हवेमध्ये सर्वाधिक प्रमाण कोणत्या वायूचे असते?', 'answer': 'नायट्रोजन वायूचे (सुमारे ७८%).'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_sci_1',
                question: 'सूर्याची अतिनील किरणे कोणता थर शोषून घेतो?',
                options: ['ओझोन थर', 'कार्बन थर', 'ऑक्सिजन थर', 'धूलिकण थर'],
                correctOptionIndex: 0,
                explanation: 'स्थितांबराच्या खालच्या भागात असलेला ओझोन वायूचा थर अतिनील किरणांपासून सजीवांचे रक्षण करतो.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 6,
        subjectCode: 'history_6',
        subjectName: 'इतिहास व नागरिकशास्त्र',
        bookTitle: 'इतिहास व नागरिकशास्त्र इयत्ता सहावी',
        colorHex: 0xFFD81B60,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. इतिहासाची साधने व हडप्पा संस्कृती',
            summary: 'भौतिक साधने (किल्ले, नाणी, भांडी), लिखित साधने, मौखिक साधने. हडप्पा संस्कृतीची नगररचना व सांडपाणी व्यवस्था.',
            keyConcepts: ['भौतिक साधने', 'लिखित साधने', 'मौखिक साधने', 'हडप्पा नगररचना', 'महान स्नानगृह'],
            studyNotes: '• हडप्पा संस्कृती ही कांस्ययुगीन प्रगत नागरी संस्कृती होती.\n• घरे पक्क्या भाजलेल्या विटांची, काटकोनात छेदणारे रस्ते आणि झाकलेली गटारे ही तिची खास वैशिष्ट्ये होती.',
            practiceQuestions: [
              {'question': 'हडप्पा संस्कृतीतील रस्ते कसे होते?', 'answer': 'रुंद आणि एकमेकांना काटकोनात छेदणारे.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_hist_1',
                question: 'हडप्पा संस्कृतीची घरे प्रामुख्याने कशाची बांधलेली होती?',
                options: ['पक्क्या भाजलेल्या विटांची', 'कापडाची', 'लोखंडाची', 'प्लास्टिकची'],
                correctOptionIndex: 0,
                explanation: 'हडप्पा संस्कृतीतील घरे भाजलेल्या पक्क्या विटांनी मजबूत बांधलेली असत.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 6,
        subjectCode: 'geography_6',
        subjectName: 'भूगोल (Geography)',
        bookTitle: 'भूगोल इयत्ता सहावी',
        colorHex: 0xFF00ACC1,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. पृथ्वी आणि वृत्तजाळी',
            summary: 'अक्षवृत्ते, रेखावृत्ते, विषुववृत्त, कर्कवृत्त, मकरवृत्त आणि कोणत्याही ठिकाणाचे स्थाननिश्चिती ज्ञान.',
            keyConcepts: ['अक्षवृत्त', 'रेखावृत्त', 'विषुववृत्त (०°)', 'मूळ रेखावृत्त (ग्रीनिच)'],
            studyNotes: '• विषुववृत्त हे सर्वात मोठे अक्षवृत्त आहे.\n• पृथ्वीवर एकूण १८१ अक्षवृत्ते आणि ३६० रेखावृत्ते आहेत.\n• अक्षवृत्ते आणि रेखावृत्ते मिळून वृत्तजाळी तयार होते.',
            practiceQuestions: [
              {'question': 'शून्य अंश अक्षवृत्ताला काय म्हणतात?', 'answer': 'विषुववृत्त.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_geo_1',
                question: '०° (शून्य अंश) अक्षवृत्ताला काय म्हणतात?',
                options: ['विषुववृत्त', 'कर्कवृत्त', 'मकरवृत्त', 'ध्रुववृत्त'],
                correctOptionIndex: 0,
                explanation: '०° अक्षवृत्ताला विषुववृत्त म्हटले जाते, जे पृथ्वीचे दोन समान गोलार्ध करते.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 6,
        subjectCode: 'hindi_6',
        subjectName: 'हिंदी (सुलभभारती)',
        bookTitle: 'सुलभभारती इयत्ता सहावी',
        colorHex: 0xFF8E24AA,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. बसंती हवा (कविता)',
            summary: 'मस्तमौला, बेफिक्र बसंती हवा का खेत-खलिहानों, पेड़ों और आम के बौरों से गुजरने का सजीव वर्णन।',
            keyConcepts: ['बसंती हवा', 'मस्तमौला', 'प्रकृति', 'केदारनाथ अग्रवाल'],
            studyNotes: '• कवि: केदारनाथ अग्रवाल।\n• बसंत ऋतु में बहने वाली हवा निडर और आनंदमयी होती है।',
            practiceQuestions: [
              {'question': 'बसंती हवा कैसी है?', 'answer': 'बसंती हवा मस्तमौला, बेफिक्र और नटखट है।'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_hin_1',
                question: '‘बसंती हवा’ कविता के रचयिता कौन हैं?',
                options: ['केदारनाथ अग्रवाल', 'मैथिलीशरण गुप्त', 'सूर्यकांत त्रिपाठी निराला', 'हरिवंश राय बच्चन'],
                correctOptionIndex: 0,
                explanation: 'यह कविता श्री केदारनाथ अग्रवाल जी ने लिखी है।',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 6,
        subjectCode: 'english_6',
        subjectName: 'इंग्रजी (My English Book Six)',
        bookTitle: 'My English Book Six',
        colorHex: 0xFF388E3C,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: 'Unit 1: Songs of Happiness & Parts of Speech',
            summary: 'Poetry appreciation, eight parts of speech: noun, pronoun, verb, adverb, adjective, preposition, conjunction, interjection.',
            keyConcepts: ['Parts of Speech', 'Rhyme', 'Sentence Structure'],
            studyNotes: '• Noun names, Pronoun replaces noun.\n• Verb denotes action, Adverb modifies verb.\n• Adjective describes noun.',
            practiceQuestions: [
              {'question': 'How many parts of speech are there in English?', 'answer': 'There are 8 parts of speech.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_6_eng_1',
                question: 'Which part of speech describes a verb or adjective?',
                options: ['Adverb', 'Noun', 'Pronoun', 'Interjection'],
                correctOptionIndex: 0,
                explanation: 'An adverb modifies a verb, adjective, or another adverb.',
              ),
            ],
          ),
        ],
      ),
    ],

    // ==========================================
    // CLASS 7 (इयत्ता ७ वी)
    // ==========================================
    7: [
      CurriculumSubjectModel(
        standard: 7,
        subjectCode: 'marathi_7',
        subjectName: 'मराठी (बालभारती)',
        bookTitle: 'बालभारती इयत्ता सातवी',
        colorHex: 0xFFE53935,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. प्रार्थना - नमस्कार माझा या ज्ञानमंदिरा',
            summary: 'शाळेप्रती आणि विद्येप्रती कृतज्ञता व्यक्त करणारी उदात्त प्रार्थना.',
            keyConcepts: ['ज्ञानमंदिर', 'सत्य, शिव, सुंदर', 'विद्या', 'संस्कार'],
            studyNotes: '• गीतकार: जगदीश खेबूडकर.\n• शाळा हे ज्ञानाचे पवित्र मंदिर आहे. येथे संस्कार व ज्ञानाची उपासना होते.',
            practiceQuestions: [
              {'question': '‘नमस्कार माझा या ज्ञानमंदिरा’ या प्रार्थनेचे कवी कोण?', 'answer': 'जगदीश खेबूडकर.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_m_1',
                question: 'ज्ञानमंदिर कोणाला म्हटले आहे?',
                options: ['शाळेला', 'बाजाराला', 'सिनेमागृहाला', 'कारखान्याला'],
                correctOptionIndex: 0,
                explanation: 'शाळा ही ज्ञान देणारे पवित्र मंदिर आहे.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. स्वप्न विकणारा माणूस (कथा)',
            summary: 'गावोगावी फिरून लोकांना उत्तुंग स्वप्ने दाखवणारा, जगण्याची उमेद देणारा पिपऱ्यावाला माणूस.',
            keyConcepts: ['स्वप्न', 'उमेद', 'अशोक मानकर', 'जिद्द'],
            studyNotes: '• लेखक: अशोक मानकर.\n• माणसाने मोठी स्वप्ने पाहिली पाहिजेत व ती पूर्ण करण्यासाठी प्रामाणिक प्रयत्न केले पाहिजेत.',
            practiceQuestions: [
              {'question': 'स्वप्न विकणारा माणूस अंगात काय घालायचा?', 'answer': 'रेशमी विजार आणि त्यावर भरजरी सदरा.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_m_2',
                question: '‘स्वप्न विकणारा माणूस’ या पाठाचे लेखक कोण?',
                options: ['अशोक मानकर', 'व. पु. काळे', 'द. मा. मिरासदार', 'श्याम मानव'],
                correctOptionIndex: 0,
                explanation: 'अशोक मानकर यांनी हा हृदयस्पर्शी पाठ लिहिला आहे.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 7,
        subjectCode: 'maths_7',
        subjectName: 'गणित (Mathematics)',
        bookTitle: 'गणित इयत्ता सातवी',
        colorHex: 0xFF1976D2,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. भौमितिक रचना (Geometrical Constructions)',
            summary: 'कोनदुभाजक, रेषाखंडाचा लंबदुभाजक, त्रिकोणाचे कोन व बाजू यांचे गुणधर्म.',
            keyConcepts: ['कोनदुभाजक', 'लंबदुभाजक', 'त्रिकोणाच्या कोनांची बेरीज १८०°', 'परिकेंद्र व अंतर्मध्य'],
            studyNotes: '• त्रिकोणाच्या तिन्ही कोनांच्या मापांची बेरीज १८० अंश असते.\n• लंबदुभाजकावरील प्रत्येक बिंदू रेषाखंडाच्या अंत्यबिंदूंपासून समदूर असतो.',
            practiceQuestions: [
              {'question': 'त्रिकोणाच्या तिन्ही कोनांच्या मापांची बेरीज किती असते?', 'answer': '१८० अंश (180°).'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_mat_1',
                question: 'त्रिकोणाच्या तिन्ही कोनांच्या मापांची बेरीज किती असते?',
                options: ['१८०°', '३६०°', '९०°', '२७०°'],
                correctOptionIndex: 0,
                explanation: 'कोणत्याही त्रिकोणाच्या सर्व कोनांची बेरीज नेहमी १८०° असते.',
              ),
              ExamQuestionModel(
                id: 'q_7_mat_2',
                question: 'काटकोनाचे माप किती अंश असते?',
                options: ['९०°', '४५°', '६०°', '१८०°'],
                correctOptionIndex: 0,
                explanation: 'काटकोन नेमका ९० अंशाचा असतो.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. मसावि आणि लसावि (HCF and LCM)',
            summary: 'मूळ अवयव पद्धत, महत्तम सामाईक विभाजक (HCF) आणि लघुत्तम सामाईक विभाज्य (LCM).',
            keyConcepts: ['मूळ संख्या', 'सामाईक अवयव', 'मसावि', 'लसावि'],
            studyNotes: '• दोन मूळ संख्यांचा मसावि नेहमी १ असतो.\n• मसावि × लसावि = त्या दोन संख्यांचा गुणाकार.',
            practiceQuestions: [
              {'question': '१२ आणि १८ चा मसावि काढा.', 'answer': '६ (सामाईक अवयव: २ × ३ = ६).'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_mat_3',
                question: '४ आणि ६ चा लसावि (LCM) किती?',
                options: ['१२', '२४', '२', '८'],
                correctOptionIndex: 0,
                explanation: '४ आणि ६ च्या पाढ्यातील सर्वात लहान सामाईक संख्या १२ आहे.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 7,
        subjectCode: 'science_7',
        subjectName: 'सामान्य विज्ञान (General Science)',
        bookTitle: 'सामान्य विज्ञान इयत्ता सातवी',
        colorHex: 0xFF43A047,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. सजीव सृष्टी: अनुकूलन व वर्गीकरण',
            summary: 'वाळवंटी, जलीय, हिमप्रदेशातील वनस्पती आणि प्राण्यांचे अनुकूलन. द्विपद नामपद्धती.',
            keyConcepts: ['अनुकूलन', 'कॅक्टस', 'उष्णता व थंडीपासून संरक्षण', 'कार्ल लिनियस'],
            studyNotes: '• वाळवंटातील वनस्पतींची पाने काट्यांत रूपांतरित होतात जेणेकरून पाण्याचे बाष्पीभवन रोखता यावे.\n• माशांना श्वसनासाठी कल्ले आणि पोहण्यासाठी पर असतात.',
            practiceQuestions: [
              {'question': 'कॅक्टस (निवडुंग) ची पाने काट्यांत का बदललेली असतात?', 'answer': 'पाण्याचे बाष्पीभवन कमी करण्यासाठी.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_sci_1',
                question: 'मासे श्वसनासाठी कोणत्या अवयवाचा वापर करतात?',
                options: ['कल्ले', 'फुप्फुसे', 'त्वचा', 'नाक'],
                correctOptionIndex: 0,
                explanation: 'मासे पाण्यात विरघळलेला ऑक्सिजन घेण्यासाठी कल्ल्यांचा वापर करतात.',
              ),
            ],
          ),
          CurriculumChapterModel(
            chapterNumber: 2,
            chapterTitle: '२. वनस्पतींची रचना व कार्ये',
            summary: 'मूळ, खोड, पान, फूल आणि फळ यांची रचना. प्रकाशसंश्लेषण क्रिया.',
            keyConcepts: ['सोतमुळ व तंतुमय मूळ', 'प्रकाशसंश्लेषण', 'हरितद्रव्य', 'पर्णरंध्रे'],
            studyNotes: '• वनस्पती सूर्यप्रकाश, कार्बन डायऑक्साइड आणि पाणी वापरून हरितद्रव्याच्या साहाय्याने अन्न तयार करतात.\n• या क्रियेत ऑक्सिजन वायू बाहेर सोडला जातो.',
            practiceQuestions: [
              {'question': 'प्रकाशसंश्लेषण प्रक्रियेत कोणता वायू बाहेर टाकला जातो?', 'answer': 'ऑक्सिजन वायू (O2).'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_sci_2',
                question: 'प्रकाशसंश्लेषणासाठी वनस्पतींच्या पानात कोणता घटक अत्यंत आवश्यक असतो?',
                options: ['हरितद्रव्य (Chlorophyll)', 'लोह', 'सोडियम', 'कॅल्शियम'],
                correctOptionIndex: 0,
                explanation: 'हरितद्रव्यामुळे वनस्पती हिरव्या दिसतात व सूर्यप्रकाश शोषून अन्न तयार करतात.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 7,
        subjectCode: 'history_7',
        subjectName: 'इतिहास व नागरिकशास्त्र',
        bookTitle: 'इतिहास व नागरिकशास्त्र इयत्ता सातवी',
        colorHex: 0xFFD81B60,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. इतिहासाची साधने व शिवपूर्वकालीन भारत',
            summary: 'भौतिक, लिखित व मौखिक साधने. पाल, राष्ट्रकूट, चोल, यादव घराणी आणि दिल्लीची सुलतानशाही.',
            keyConcepts: ['बखर', 'शिलालेख', 'ताम्रपट', 'यादव काळ', 'अल्लाउद्दीन खिलजी'],
            studyNotes: '• ‘बखर’ हा ऐतिहासिक साहित्याचा महत्वाचा प्रकार असून त्यात तत्कालीन घडामोडींची वर्णने असतात.\n• महाराष्ट्रात देवगिरीचे यादव घराणे समृद्ध होते.',
            practiceQuestions: [
              {'question': 'इतिहास लेखनात ‘बखर’ म्हणजे काय?', 'answer': 'ऐतिहासिक घटनांचे, लढायांचे व पराक्रमाचे वर्णन करणारा लिखित दस्तऐवज.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_hist_1',
                question: 'ऐतिहासिक प्रसंगांचे वर्णन करणाऱ्या मराठीतील साधनांना काय म्हणतात?',
                options: ['बखर', 'कथा', 'कादंबरी', 'नाटक'],
                correctOptionIndex: 0,
                explanation: 'बखर हे शिवकालीन व पेशवेकालीन इतिहासाचे प्रमुख लिखित साधन आहे.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 7,
        subjectCode: 'geography_7',
        subjectName: 'भूगोल (Geography)',
        bookTitle: 'भूगोल इयत्ता सातवी',
        colorHex: 0xFF00ACC1,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. ऋतूनिर्मिती (Season Formation)',
            summary: 'पृथ्वीचा कललेला आस, परिवलन, परिभ्रमण, दिनमान व रात्रमानातील फरक.',
            keyConcepts: ['पृथ्वीचा आस (२३.५° कललेला)', 'परिवलन (२४ तास)', 'परिभ्रमण (३६५.२५ दिवस)', 'ऋतू'],
            studyNotes: '• पृथ्वी स्वतःभोवती फिरते त्याला परिवलन म्हणतात (त्यामुळे दिवस व रात्र होतात).\n• पृथ्वी सूर्याभोवती फिरते त्याला परिभ्रमण म्हणतात.\n• आस कललेला असल्यामुळे ऋतूंची निर्मिती होते.',
            practiceQuestions: [
              {'question': 'पृथ्वीचा आस किती अंशाने कललेला आहे?', 'answer': '२३.५ अंशाने.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_geo_1',
                question: 'दिवस आणि रात्र कशामुळे होतात?',
                options: ['पृथ्वीच्या स्वतःभोवतीच्या परिवलनामुळे', 'चंद्राच्या कलांमुळे', 'सूर्याच्या हालचालीमुळे', 'हवेच्या दाबाने'],
                correctOptionIndex: 0,
                explanation: 'पृथ्वी स्वतःच्या आसाभोवती फिरते (परिवलन) म्हणून दिवस-रात्र होतात.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 7,
        subjectCode: 'hindi_7',
        subjectName: 'हिंदी (सुलभभारती)',
        bookTitle: 'सुलभभारती इयत्ता सातवी',
        colorHex: 0xFF8E24AA,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: '१. फूल और काँटे (कविता)',
            summary: 'एक ही पौधे पर फूल और काँटे दोनों जन्म लेते हैं, पर स्वभाव से फूल सबको महकाता है और काँटा चुभता है। कर्म से व्यक्ति महान बनता है, कुल से नहीं।',
            keyConcepts: ['सद्गुण', 'फूल और काँटा', 'अयोध्यासिंह उपाध्याय ‘हरिऔध’'],
            studyNotes: '• कवि: अयोध्यासिंह उपाध्याय ‘हरिऔध’।\n• मनुष्य कुल से नहीं बल्कि अपने अच्छे कर्मों और स्वभाव से बड़ा बनता है।',
            practiceQuestions: [
              {'question': 'फूल और काँटे में क्या सीख मिलती है?', 'answer': 'व्यक्ति अपने कर्मों और स्वभाव से आदर पाता है, जन्म से नहीं।'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_hin_1',
                question: '‘फूल और काँटे’ कविता के अनुसार व्यक्ति की पहचान किससे होती है?',
                options: ['उसके गुणों व कर्मों से', 'उसके कपड़ों से', 'उसके रूप से', 'उसके कुल से'],
                correctOptionIndex: 0,
                explanation: 'अच्छे गुण और परोपकारी स्वभाव से ही व्यक्ति श्रेष्ठ बनता है.',
              ),
            ],
          ),
        ],
      ),
      CurriculumSubjectModel(
        standard: 7,
        subjectCode: 'english_7',
        subjectName: 'इंग्रजी (My English Book Seven)',
        bookTitle: 'My English Book Seven',
        colorHex: 0xFF388E3C,
        chapters: [
          CurriculumChapterModel(
            chapterNumber: 1,
            chapterTitle: 'Unit 1: Past, Present, Future & Tenses',
            summary: 'Understanding verb tenses: Simple Present, Simple Past, and Future Tenses with conversational application.',
            keyConcepts: ['Past Tense', 'Present Tense', 'Future Tense', 'Emily Bronte poem'],
            studyNotes: '• Present: "I read a book."\n• Past: "I read a book yesterday."\n• Future: "I will read a book tomorrow."',
            practiceQuestions: [
              {'question': 'Change to past tense: "He plays cricket."', 'answer': 'He played cricket.'},
            ],
            quizQuestions: [
              ExamQuestionModel(
                id: 'q_7_eng_1',
                question: 'What is the past tense of "write"?',
                options: ['wrote', 'written', 'writing', 'writes'],
                correctOptionIndex: 0,
                explanation: 'The past tense of write is wrote.',
              ),
            ],
          ),
        ],
      ),
    ],
  };

  /// Returns the list of curriculum subjects for a given standard (1-7)
  static List<CurriculumSubjectModel> getSubjectsForStandard(int standard) {
    return _curriculumByStandard[standard] ?? [];
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
        description: 'वहीत अ ते ज्ञ मुळाक्षरे व काना-मात्रा नसलेले ५ सोपे शब्द लिहून आणा.',
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
        description: '१ ते २० अंक वहीत २ वेळा लिहा व बोटे मोजून बेरीज करा (पान क्र. १४).',
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
        description: 'शिवनेरी किल्ल्यावर ५ ओळी माहिती लिहा व जिजामाता-शिवरायांचे चित्र चिटकवा किंवा काढा.',
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
        description: 'वनस्पतीच्या पानाची सुबक नामनिर्देशित आकृती काढा व प्रकाशसंश्लेषणाचे रासायनिक समीकरण लिहा.',
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
            options: ['हात स्वच्छ धुतले पाहिजेत', 'धावले पाहिजे', 'झोपले पाहिजे', 'ओरडले पाहिजे'],
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
        description: 'शिवजन्म, स्वराज्य संकल्पना आणि संतांची कामगिरी यांवरील महत्त्वाची परीक्षा.',
        durationMinutes: 15,
        questions: [
          ExamQuestionModel(
            id: 'q_shiva_1',
            question: 'छत्रपती शिवाजी महाराजांचा जन्म कोणत्या किल्ल्यावर झाला?',
            options: ['शिवनेरी किल्ला', 'रायगड किल्ला', 'प्रतापगड किल्ला', 'तोरणा किल्ला'],
            correctOptionIndex: 0,
            explanation: 'शिवरायांचा जन्म जुन्नर जवळील शिवनेरी किल्ल्यावर झाला.',
          ),
          ExamQuestionModel(
            id: 'q_shiva_2',
            question: 'शिवरायांच्या वडिलांचे नाव काय होते?',
            options: ['शहाजीराजे भोसले', 'मालोजीराजे', 'संभाजीराजे', 'व्यंकोजीराजे'],
            correctOptionIndex: 0,
            explanation: 'शिवरायांचे वडील शहाजीराजे हे शूर पराक्रमी सरदार होते.',
          ),
          ExamQuestionModel(
            id: 'q_shiva_3',
            question: 'शिवरायांनी पहिली कोणती शपथ घेतली?',
            options: ['स्वराज्य स्थापनेची प्रतिज्ञा', 'व्यापाराची प्रतिज्ञा', 'युद्धाची प्रतिज्ञा', 'शांततेची प्रतिज्ञा'],
            correctOptionIndex: 0,
            explanation: 'रायरेश्वराच्या मंदिरात शिवरायांनी हिंदवी स्वराज्य स्थापनेची प्रतिज्ञा केली.',
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
            options: ['ऑक्सिजन (Oxygen)', 'कार्बन डायऑक्साइड', 'नायट्रोजन', 'हायड्रोजन'],
            correctOptionIndex: 0,
            explanation: 'वनस्पती सूर्यप्रकाशात अन्न तयार करताना ऑक्सिजन वायू बाहेर सोडतात.',
          ),
          ExamQuestionModel(
            id: 'qs_7_2',
            question: 'मासे पाण्यात श्वसन करण्यासाठी कशाचा वापर करतात?',
            options: ['कल्ले (Gills)', 'फुप्फुसे', 'त्वचा', 'पर'],
            correctOptionIndex: 0,
            explanation: 'पाण्यातील विरघळलेला ऑक्सिजन घेण्यासाठी माशांना कल्ले असतात.',
          ),
          ExamQuestionModel(
            id: 'qs_7_3',
            question: 'त्रिकोणाच्या तिन्ही कोनांच्या मापांची बेरीज किती असते?',
            options: ['१८० अंश', '३६० अंश', '९० अंश', '१२० अंश'],
            correctOptionIndex: 0,
            explanation: 'भूमिती नियमानुसार त्रिकोणाच्या तिन्ही कोनांची बेरीज नेहमी १८०° असते.',
          ),
        ],
      ),
    ];
  }
}
