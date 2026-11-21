import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class AppTranslations {
  static const String marathi = 'mr';
  static const String english = 'en';
  static const String hindi = 'hi';

  static const List<Map<String, String>> supportedLanguages = [
    {
      'code': marathi,
      'name': 'मराठी',
      'englishName': 'Marathi',
      'flag': '🚩',
    },
    {
      'code': english,
      'name': 'English',
      'englishName': 'English',
      'flag': '🇬🇧',
    },
    {
      'code': hindi,
      'name': 'हिंदी',
      'englishName': 'Hindi',
      'flag': '🇮🇳',
    },
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case english:
        return 'English';
      case hindi:
        return 'हिंदी';
      case marathi:
      default:
        return 'मराठी';
    }
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    // App & Branding
    'app_title': {
      'mr': 'iSecure EduMaster CCE Pro - शाळा मूल्यांकन प्रणाली',
      'en': 'iSecure EduMaster CCE Pro - School Assessment System',
      'hi': 'iSecure EduMaster CCE Pro - स्कूल मूल्यांकन प्रणाली',
    },
    'app_short_title': {
      'mr': 'iSecure EduMaster',
      'en': 'iSecure EduMaster',
      'hi': 'iSecure EduMaster',
    },
    'motto': {
      'mr': '॥ शिक्षण हेच जीवन ॥',
      'en': 'Education is Life',
      'hi': '॥ शिक्षा ही जीवन है ॥',
    },

    // Navigation & Screen Titles
    'dashboard': {
      'mr': 'डॅशबोर्ड',
      'en': 'Dashboard',
      'hi': 'डैशबोर्ड',
    },
    'school_settings': {
      'mr': 'शाळा प्रोफाईल व सेटिंग्ज',
      'en': 'School Profile & Settings',
      'hi': 'स्कूल प्रोफाइल व सेटिंग्स',
    },
    'students_list': {
      'mr': 'विद्यार्थी यादी व नोंदणी',
      'en': 'Student List & Admission',
      'hi': 'छात्र सूची व प्रवेश',
    },
    'marks_entry': {
      'mr': 'गुण नोंद (आकारिक व संकलित)',
      'en': 'Marks Entry (FA & SA)',
      'hi': 'अंक प्रविष्टि (आकारिक व संकलित)',
    },
    'descriptive_notes': {
      'mr': 'वर्णनात्मक नोंदी व विशेष प्रगती',
      'en': 'Descriptive Notes & Progress',
      'hi': 'वर्णनात्मक टिप्पणियां व प्रगति',
    },
    'attendance': {
      'mr': 'मासिक उपस्थिती नोंद',
      'en': 'Monthly Attendance',
      'hi': 'मासिक उपस्थिति पंजी',
    },
    'progress_card': {
      'mr': 'प्रगती पुस्तक (Report Card)',
      'en': 'Progress Card (Report Card)',
      'hi': 'प्रगति पत्र (Report Card)',
    },
    'result_gazette': {
      'mr': 'एकत्रित निकाल गॅझेट',
      'en': 'Result Gazette Register',
      'hi': 'समेकित परिणाम राजपत्र',
    },
    'bonafide_certificate': {
      'mr': 'बोनाफाईड प्रमाणपत्र',
      'en': 'Bonafide Certificate',
      'hi': 'बोनाफाइड प्रमाण-पत्र',
    },
    'leaving_certificate': {
      'mr': 'शाळा सोडल्याचा दाखला (LC)',
      'en': 'Leaving Certificate (LC)',
      'hi': 'शाला त्याग प्रमाण-पत्र (LC)',
    },
    'general_register': {
      'mr': 'जनरल रजिस्टर (GR) उतारा',
      'en': 'General Register (GR) Extract',
      'hi': 'सामान्य रजिस्टर (GR) उद्धरण',
    },
    'yearly_class_students': {
      'mr': 'वर्गवार विद्यार्थी यादी',
      'en': 'Class-wise Student List',
      'hi': 'कक्षावार छात्र सूची',
    },
    'statistics': {
      'mr': 'शाळा सांख्यिकी व निकाल विश्लेषण',
      'en': 'School Statistics & Analytics',
      'hi': 'स्कूल सांख्यिकी व विश्लेषण',
    },
    'student_promotion': {
      'mr': 'विद्यार्थी वर्गोन्नती (Promotion)',
      'en': 'Student Promotion',
      'hi': 'छात्र पदोन्नति (Promotion)',
    },
    'teacher_allocation': {
      'mr': 'शिक्षक वाटप (Teacher Allocation)',
      'en': 'Teacher Allocation',
      'hi': 'शिक्षक आवंटन (Teacher Allocation)',
    },
    'student_portal': {
      'mr': 'विद्यार्थी व पालक पोर्टल 📱',
      'en': 'Student & Parent Portal 📱',
      'hi': 'छात्र व अभिभावक पोर्टल 📱',
    },
    'homework_exam_mgmt': {
      'mr': 'स्वाध्याय व परीक्षा व्यवस्थापन',
      'en': 'Homework & Exam Management',
      'hi': 'गृहकार्य व परीक्षा प्रबंधन',
    },
    'mdm_management': {
      'mr': 'शालेय पोषण आहार (PM POSHAN / MDM)',
      'en': 'Mid-Day Meal (PM POSHAN / MDM)',
      'hi': 'मध्याह्न भोजन (PM POSHAN / MDM)',
    },
    'free_entitlements': {
      'mr': 'मोफत पाठ्यपुस्तके व गणवेश वाटप',
      'en': 'Free Textbooks & Uniforms',
      'hi': 'मुफ्त पाठ्यपुस्तकें व गणवेश वितरण',
    },
    'monthly_attendance_abstract': {
      'mr': 'मासिक उपस्थिती गोषवारा (Form A & B)',
      'en': 'Monthly Attendance Abstract',
      'hi': 'मासिक उपस्थिति सार (Form A & B)',
    },
    'smc_management': {
      'mr': 'शाळा व्यवस्थापन समिती (SMC)',
      'en': 'School Management Committee (SMC)',
      'hi': 'विद्यालय प्रबंधन समिति (SMC)',
    },
    'dead_stock': {
      'mr': 'मृतसाठा नोंदवही (Dead Stock)',
      'en': 'Dead Stock Register',
      'hi': 'मृत भंडार पंजी (Dead Stock)',
    },
    'library': {
      'mr': 'शालेय ग्रंथालय नोंदवही (Library)',
      'en': 'School Library Register',
      'hi': 'शाला पुस्तकालय पंजी (Library)',
    },
    'teacher_service': {
      'mr': 'शिक्षक सेवा, रजा व हालचाल नोंद',
      'en': 'Teacher Leaves & Movement Register',
      'hi': 'शिक्षक अवकाश व संचलन पंजी',
    },
    'inward_outward_health': {
      'mr': 'शासकीय आवक-जावक व आरोग्य तपासणी',
      'en': 'Inward/Outward & Health Records',
      'hi': 'शासकीय आवक-जावक व स्वास्थ्य पंजी',
    },
    'student_id_cards': {
      'mr': 'विद्यार्थी ओळखपत्र (ID Cards)',
      'en': 'Student ID Cards',
      'hi': 'छात्र पहचान पत्र (ID Cards)',
    },
    'saral_udise_sync': {
      'mr': 'सरल / U-DISE+ डेटा सिंक',
      'en': 'SARAL / U-DISE+ Data Sync',
      'hi': 'सरल / U-DISE+ डेटा सिंक',
    },
    'ebooks_library': {
      'mr': 'ई-पुस्तके व अभ्यासक्रम (E-Books 📚)',
      'en': 'E-Books & Curriculum (📚)',
      'hi': 'ई-पुस्तकें व पाठ्यक्रम (E-Books 📚)',
    },

    // Bottom Navigation Bar Labels (Mobile)
    'nav_home': {
      'mr': 'डॅशबोर्ड',
      'en': 'Dashboard',
      'hi': 'डैशबोर्ड',
    },
    'nav_students': {
      'mr': 'विद्यार्थी',
      'en': 'Students',
      'hi': 'विद्यार्थी',
    },
    'nav_marks': {
      'mr': 'गुण नोंद',
      'en': 'Marks',
      'hi': 'अंक',
    },
    'nav_ebooks': {
      'mr': 'ई-पुस्तके',
      'en': 'E-Books',
      'hi': 'ई-पुस्तकें',
    },
    'nav_portal': {
      'mr': 'पोर्टल',
      'en': 'Portal',
      'hi': 'पोर्टल',
    },
    'nav_attendance': {
      'mr': 'उपस्थिती',
      'en': 'Attendance',
      'hi': 'उपस्थिति',
    },
    'nav_homework': {
      'mr': 'घरचा अभ्यास',
      'en': 'Homework',
      'hi': 'गृहकार्य',
    },
    'nav_exam': {
      'mr': 'ऑनलाइन परीक्षा',
      'en': 'Exams',
      'hi': 'परीक्षा',
    },
    'nav_elearning': {
      'mr': 'ई-लर्निंग',
      'en': 'E-Learning',
      'hi': 'ई-लर्निंग',
    },
    'nav_profile': {
      'mr': 'प्रोफाईल',
      'en': 'Profile',
      'hi': 'प्रोफाइल',
    },
    'nav_more': {
      'mr': 'सर्व मेनू',
      'en': 'All Menu',
      'hi': 'सभी मेनू',
    },

    // User Roles
    'role_superadmin': {
      'mr': 'सुपर ॲडमिन',
      'en': 'Super Admin',
      'hi': 'सुपर एडमिन',
    },
    'role_admin': {
      'mr': 'प्रशासक (Admin)',
      'en': 'Administrator (Admin)',
      'hi': 'प्रशासक (Admin)',
    },
    'role_headmaster': {
      'mr': 'मुख्याध्यापक',
      'en': 'Headmaster',
      'hi': 'प्रधानाध्यापक',
    },
    'role_teacher': {
      'mr': 'वर्गशिक्षक',
      'en': 'Class Teacher',
      'hi': 'कक्षाध्यापक',
    },
    'role_peon': {
      'mr': 'शिपाई (Office Staff)',
      'en': 'Office Staff (Peon)',
      'hi': 'कार्यालयीन कर्मचारी (चपरासी)',
    },
    'role_student': {
      'mr': 'विद्यार्थी / पालक',
      'en': 'Student / Parent',
      'hi': 'छात्र / अभिभावक',
    },

    // Common Actions & Buttons
    'save': {
      'mr': 'जतन करा (Save)',
      'en': 'Save',
      'hi': 'सहेजें (Save)',
    },
    'cancel': {
      'mr': 'रद्द करा (Cancel)',
      'en': 'Cancel',
      'hi': 'रद्द करें (Cancel)',
    },
    'edit': {
      'mr': 'बदला (Edit)',
      'en': 'Edit',
      'hi': 'संपादित करें (Edit)',
    },
    'delete': {
      'mr': 'हटवा (Delete)',
      'en': 'Delete',
      'hi': 'हटाएं (Delete)',
    },
    'search': {
      'mr': 'शोधा...',
      'en': 'Search...',
      'hi': 'खोजें...',
    },
    'filter': {
      'mr': 'फिल्टर',
      'en': 'Filter',
      'hi': 'फ़िल्टर',
    },
    'print': {
      'mr': 'प्रिंट काढा (Print)',
      'en': 'Print PDF',
      'hi': 'प्रिंट करें (Print)',
    },
    'download': {
      'mr': 'डाउनलोड करा',
      'en': 'Download',
      'hi': 'डाउनलोड करें',
    },
    'refresh': {
      'mr': 'रीफ्रेश करा',
      'en': 'Refresh',
      'hi': 'रिफ्रेश करें',
    },
    'login': {
      'mr': 'लॉगिन करा',
      'en': 'Login',
      'hi': 'लॉगिन करें',
    },
    'logout': {
      'mr': 'लॉगआउट (Sign Out)',
      'en': 'Sign Out',
      'hi': 'लॉगआउट (Sign Out)',
    },
    'logout_confirm_title': {
      'mr': 'लॉगआउटची खात्री करा',
      'en': 'Confirm Logout',
      'hi': 'लॉगआउट की पुष्टि करें',
    },
    'logout_confirm_message': {
      'mr': 'तुम्हाला चालू सत्रातून बाहेर पडायचे आहे का?',
      'en': 'Are you sure you want to sign out?',
      'hi': 'क्या आप वर्तमान सत्र से बाहर निकलना चाहते हैं?',
    },

    // Language Selection Modal
    'select_language': {
      'mr': 'भाषा निवडा (Select Language)',
      'en': 'Select Language',
      'hi': 'भाषा चुनें (Select Language)',
    },
    'choose_app_language': {
      'mr': 'तुमची पसंतीची ॲप भाषा निवडा:',
      'en': 'Choose your preferred application language:',
      'hi': 'अपनी पसंदीदा ऐप भाषा चुनें:',
    },
    'language_changed_toast': {
      'mr': 'भाषा मराठीमध्ये यशस्वीरित्या बदलली आहे!',
      'en': 'Language successfully changed to English!',
      'hi': 'भाषा सफलतापूर्वक हिंदी में बदली गई!',
    },
    'current_language_badge': {
      'mr': 'सध्या सक्रिय',
      'en': 'Currently Active',
      'hi': 'वर्तमान में सक्रिय',
    },

    // User Profile Dialog
    'user_profile': {
      'mr': 'वापरकर्ता प्रोफाईल व प्राधान्ये',
      'en': 'User Profile & Preferences',
      'hi': 'उपयोगकर्ता प्रोफाइल व प्राथमिकताएं',
    },
    'account_info': {
      'mr': 'खाते माहिती',
      'en': 'Account Details',
      'hi': 'खाता विवरण',
    },
    'role': {
      'mr': 'भूमिका / अधिकार',
      'en': 'Role & Permissions',
      'hi': 'भूमिका व अनुमतियां',
    },
    'username': {
      'mr': 'वापरकर्ता नाव (Username)',
      'en': 'Username',
      'hi': 'उपयोगकर्ता नाम (Username)',
    },
    'allocated_classes': {
      'mr': 'वाटप केलेले वर्ग',
      'en': 'Allocated Classes',
      'hi': 'आवंटित कक्षाएं',
    },
    'all_classes_access': {
      'mr': 'सर्व वर्ग (इ. १ ते ८) पूर्ण अधिकार',
      'en': 'Full Access to All Classes (Std 1 to 8)',
      'hi': 'सभी कक्षाओं (1 से 8) का पूर्ण अधिकार',
    },
    'school_details': {
      'mr': 'शाळा तपशील',
      'en': 'School Details',
      'hi': 'विद्यालय विवरण',
    },
    'udise_code': {
      'mr': 'U-DISE कोड',
      'en': 'U-DISE Code',
      'hi': 'U-DISE कोड',
    },
    'app_version': {
      'mr': 'ॲप व्हर्जन',
      'en': 'App Version',
      'hi': 'ऐप संस्करण',
    },

    // Filters (Class, Div, Semester)
    'standard': {
      'mr': 'इयत्ता',
      'en': 'Class',
      'hi': 'कक्षा',
    },
    'division': {
      'mr': 'तुकडी',
      'en': 'Division',
      'hi': 'वर्ग/तुकड़ी',
    },
    'semester': {
      'mr': 'सत्र',
      'en': 'Semester',
      'hi': 'सत्र',
    },
    'academic_year': {
      'mr': 'शैक्षणिक वर्ष',
      'en': 'Academic Year',
      'hi': 'शैक्षणिक वर्ष',
    },

    // Portal Specific
    'welcome_student': {
      'mr': 'सुस्वागतम',
      'en': 'Welcome',
      'hi': 'सुस्वागतम्',
    },
    'roll_no': {
      'mr': 'हजेरी क्र.',
      'en': 'Roll No.',
      'hi': 'अनुक्रमांक',
    },
    'gr_no': {
      'mr': 'जनरल रजि. क्र.',
      'en': 'G.R. No.',
      'hi': 'जी.आर. क्र.',
    },
    'switch_student': {
      'mr': 'विद्यार्थी बदला',
      'en': 'Switch Student',
      'hi': 'छात्र बदलें',
    },

    // Dashboard & Stats
    'stat_total_students': {
      'mr': 'एकूण विद्यार्थी संख्या',
      'en': 'Total Students',
      'hi': 'कुल छात्र संख्या',
    },
    'stat_class_students': {
      'mr': 'चालू वर्ग विद्यार्थी',
      'en': 'Current Class Students',
      'hi': 'वर्तमान कक्षा छात्र',
    },
    'stat_boys': {
      'mr': 'मुले (Boys)',
      'en': 'Boys',
      'hi': 'छात्र (Boys)',
    },
    'stat_girls': {
      'mr': 'मुली (Girls)',
      'en': 'Girls',
      'hi': 'छात्राएं (Girls)',
    },
    'stat_all_classes': {
      'mr': 'शाळेतील सर्व वर्ग',
      'en': 'All Classes in School',
      'hi': 'विद्यालय के सभी वर्ग',
    },
    'stat_current_class': {
      'mr': 'चालू वर्ग',
      'en': 'Current Class',
      'hi': 'वर्तमान कक्षा',
    },
    'stat_total_count': {
      'mr': 'एकूण संख्या',
      'en': 'Total Count',
      'hi': 'कुल संख्या',
    },
    'cce_workflow_title': {
      'mr': 'CCE मूल्यमापन कार्यप्रवाह (Work Flow)',
      'en': 'CCE Assessment Workflow',
      'hi': 'CCE मूल्यांकन कार्यप्रवाह',
    },
    'quick_actions_title': {
      'mr': 'महत्त्वाची कार्ये (Quick Actions)',
      'en': 'Quick Actions & Modules',
      'hi': 'महत्वपूर्ण कार्य (Quick Actions)',
    },
    'zp_registers_title': {
      'mr': 'जिल्हा परिषद शाळा वैधानिक नोंदवह्या',
      'en': 'ZP School Statutory Registers',
      'hi': 'जिला परिषद शाला वैधानिक पंजी',
    },
    'step_1_title': {
      'mr': 'पायाभूत माहिती व सेटिंग्ज',
      'en': 'Basic Info & Settings',
      'hi': 'मूलभूत जानकारी व सेटिंग्स',
    },
    'step_1_desc': {
      'mr': 'शाळा माहिती, विषय, भारांश, कामाचे दिवस',
      'en': 'School info, subjects, weights, working days',
      'hi': 'शाला जानकारी, विषय, भार व कार्य दिवस',
    },
    'step_2_title': {
      'mr': 'विद्यार्थी यादी नोंदणी',
      'en': 'Student Admission List',
      'hi': 'छात्र सूची व प्रवेश पंजी',
    },
    'step_2_desc': {
      'mr': 'दाखला क्र, जन्मतारीख, जात संवर्ग, आधार',
      'en': 'GR no, DOB, category, Aadhaar',
      'hi': 'दाखिला क्र, जन्मतिथि, जाति संवर्ग, आधार',
    },
    'step_3_title': {
      'mr': 'गुणनोंद व वर्णनात्मक नोंदी',
      'en': 'Marks & Remarks Entry',
      'hi': 'अंक व वर्णनात्मक प्रविष्टि',
    },
    'step_3_desc': {
      'mr': 'आकारिक-संकलित गुण, हजेरी, नोंदी',
      'en': 'FA-SA marks, attendance, remarks',
      'hi': 'आकारिक-संकलित अंक, उपस्थिति, टिप्पणियां',
    },
    'step_4_title': {
      'mr': 'प्रिंट प्रगतीपुस्तक व निकाल',
      'en': 'Print Report Cards & Results',
      'hi': 'प्रगति पत्र व परिणाम प्रिंट',
    },
    'step_4_desc': {
      'mr': 'सत्रांत निकालपत्रक, प्रगतीपुस्तक, गॅझेट',
      'en': 'Term results, report card, gazette',
      'hi': 'सत्रांत परीक्षा परिणाम, प्रगति पत्रक, राजपत्र',
    },
    'print_progress_card': {
      'mr': 'प्रगती पुस्तक प्रिंट करा',
      'en': 'Print Report Card',
      'hi': 'प्रगति पत्र प्रिंट करें',
    },
    'app_language_settings': {
      'mr': 'अ‍ॅप भाषा सेटिंग्ज (Language Settings)',
      'en': 'App Language Settings',
      'hi': 'ऐप भाषा सेटिंग्स (Language Settings)',
    },
    'app_language_desc': {
      'mr': 'सिस्टम व मेनूसाठी पसंतीची भाषा निवडा. हा बदल त्वरित सर्व पानांवर लागू होतो.',
      'en': 'Select preferred language for app and menus. Applies immediately across all screens.',
      'hi': 'सिस्टम व मेनू के लिए पसंदीदा भाषा चुनें। यह तुरंत सभी पृष्ठों पर लागू होगा।',
    },
  };

  /// Returns translated screen title for navigation bar and app bar
  static String screenTitle(int index, String langCode, {bool isStudent = false}) {
    if (isStudent) {
      switch (index) {
        case 5:
          return tr('attendance', langCode);
        case 6:
          return tr('progress_card', langCode);
        case 25:
          return tr('student_id_cards', langCode);
        case 27:
          return tr('ebooks_library', langCode);
        case 15:
        default:
          return tr('student_portal', langCode);
      }
    }

    switch (index) {
      case 0:
        return tr('dashboard', langCode);
      case 1:
        return tr('school_settings', langCode);
      case 2:
        return tr('students_list', langCode);
      case 3:
        return tr('marks_entry', langCode);
      case 4:
        return tr('descriptive_notes', langCode);
      case 5:
        return tr('attendance', langCode);
      case 6:
        return tr('progress_card', langCode);
      case 7:
        return tr('result_gazette', langCode);
      case 8:
        return tr('bonafide_certificate', langCode);
      case 9:
        return tr('leaving_certificate', langCode);
      case 10:
        return tr('general_register', langCode);
      case 11:
        return tr('yearly_class_students', langCode);
      case 12:
        return tr('statistics', langCode);
      case 13:
        return tr('student_promotion', langCode);
      case 14:
        return tr('teacher_allocation', langCode);
      case 15:
        return tr('student_portal', langCode);
      case 16:
        return tr('homework_exam_mgmt', langCode);
      case 17:
        return tr('mdm_management', langCode);
      case 18:
        return tr('free_entitlements', langCode);
      case 19:
        return tr('monthly_attendance_abstract', langCode);
      case 20:
        return tr('smc_management', langCode);
      case 21:
        return tr('dead_stock', langCode);
      case 22:
        return tr('library', langCode);
      case 23:
        return tr('teacher_service', langCode);
      case 24:
        return tr('inward_outward_health', langCode);
      case 25:
        return tr('student_id_cards', langCode);
      case 26:
        return tr('saral_udise_sync', langCode);
      case 27:
        return tr('ebooks_library', langCode);
      default:
        return tr('dashboard', langCode);
    }
  }

  /// Translate a key for the given language code. Defaults to Marathi if not found.
  static String tr(String key, String langCode) {
    final map = _localizedValues[key];
    if (map == null) return key;
    return map[langCode] ?? map[marathi] ?? map.values.first;
  }
}

extension AppTranslationExtension on BuildContext {
  /// Convenient helper to get translated string in current app language
  String tr(String key) {
    try {
      final state = watch<AppStateProvider>();
      return AppTranslations.tr(key, state.currentLanguage);
    } catch (_) {
      return AppTranslations.tr(key, AppTranslations.marathi);
    }
  }

  /// Read translation without triggering widget rebuilds (for callbacks)
  String trRead(String key) {
    try {
      final state = read<AppStateProvider>();
      return AppTranslations.tr(key, state.currentLanguage);
    } catch (_) {
      return AppTranslations.tr(key, AppTranslations.marathi);
    }
  }
}
