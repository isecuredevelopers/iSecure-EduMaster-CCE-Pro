import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/school_model.dart';
import '../data/models/academic_year_model.dart';
import '../data/models/subject_model.dart';
import '../data/models/student_model.dart';
import '../data/models/evaluation_model.dart';
import '../data/models/descriptive_note_model.dart';
import '../data/models/attendance_model.dart';
import '../data/models/working_days_model.dart';
import '../data/models/leaving_certificate_model.dart';
import '../data/models/general_register_extract_model.dart';
import '../data/models/user_model.dart';
import '../data/models/homework_model.dart';
import '../data/models/online_exam_model.dart';
import '../data/models/mdm_model.dart';
import '../data/models/free_entitlements_model.dart';
import '../data/models/smc_model.dart';
import '../data/models/dead_stock_model.dart';
import '../data/models/library_model.dart';
import '../data/models/teacher_service_model.dart';
import '../data/models/admin_registers_model.dart';
import '../data/local/curriculum_repository.dart';
import '../data/local/sample_data.dart';
import '../data/supabase/supabase_service.dart';
import '../core/services/app_update_service.dart';
import '../core/services/marathi_date_formatter.dart';

class AppStateProvider extends ChangeNotifier {
  late SchoolModel _school;
  List<AcademicYearModel> _academicYears = [];
  late AcademicYearModel _currentYear;

  int _selectedStd = 1;
  String _selectedDiv = '1';
  int _selectedSemester = 1; // 1 or 2
  late SubjectModel _selectedSubject;

  List<SubjectModel> _subjects = [];
  List<StudentModel> _students = [];
  List<EvaluationModel> _evaluations = [];
  List<DescriptiveNoteModel> _descriptiveNotes = [];
  List<AttendanceModel> _attendanceList = [];
  List<LeavingCertificateModel> _leavingCertificates = [];
  List<GeneralRegisterExtractModel> _grExtracts = [];
  late WorkingDaysModel _workingDays;
  List<GradingScaleModel> _gradingScales = [];
  Map<String, List<String>> _remarksBank = {};

  // User Authentication & Class Teacher Allocation
  List<UserModel> _users = [];
  UserModel? _currentUser;
  StudentModel? _currentStudent;

  // Homework, Online Exams & Results (Student/Parent Portal)
  List<HomeworkModel> _homeworkList = [];
  List<OnlineExamModel> _onlineExams = [];
  List<ExamResultModel> _examResults = [];

  // जिल्हा परिषद शाळा वैधानिक नोंदवह्या (Statutory ZP Registers)
  // १. शालेय पोषण आहार (PM POSHAN / MDM)
  List<MdmDailyAttendanceModel> _mdmAttendanceList = [];
  List<MdmStockItemModel> _mdmStockList = [];
  List<MdmMonthlyBillModel> _mdmBillsList = [];

  // २. समग्र शिक्षा मोफत वाटप (Free Entitlements)
  List<TextbookDistributionRecord> _textbookDistributions = [];
  List<UniformDistributionRecord> _uniformDistributions = [];

  // ३. शाळा व्यवस्थापन समिती (SMC)
  List<SmcMemberModel> _smcMembers = [];
  List<SmcMeetingModel> _smcMeetings = [];

  // ४. मृतसाठा व ग्रंथालय (Dead Stock & Library)
  List<DeadStockItemModel> _deadStockList = [];
  List<LibraryBookModel> _libraryBooks = [];

  // ५. शिक्षक सेवा, रजा व हालचाल (Teacher Leaves & Movement)
  List<TeacherLeaveRecord> _teacherLeaves = [];
  List<MovementRegisterRecord> _movementRecords = [];

  // ६. शासकीय आवक-जावक व आरोग्य तपासणी (Inward/Outward & Health)
  List<InwardLetterRecord> _inwardLetters = [];
  List<OutwardLetterRecord> _outwardLetters = [];
  List<StudentHealthRecord> _studentHealthRecords = [];

  String _supabaseUrl = '';
  String _supabaseAnonKey = '';
  bool _isCloudConnected = false;
  bool _isLoading = true;

  AppUpdateInfo? _availableUpdate;
  AppUpdateInfo? _automaticUpdatePrompt;
  bool _isCheckingUpdate = false;
  Timer? _updateCheckTimer;
  bool _isDisposed = false;

  // Getters
  SchoolModel get school => _school;
  List<AcademicYearModel> get academicYears => _academicYears;
  AcademicYearModel get currentYear => _currentYear;
  int get selectedStd => _selectedStd;
  String get selectedDiv => _selectedDiv;
  int get selectedSemester => _selectedSemester;
  SubjectModel get selectedSubject => _selectedSubject;
  List<SubjectModel> get subjects => _subjects;
  List<StudentModel> get students => _students;
  List<EvaluationModel> get evaluations => _evaluations;
  List<DescriptiveNoteModel> get descriptiveNotes => _descriptiveNotes;
  List<AttendanceModel> get attendanceList => _attendanceList;
  List<LeavingCertificateModel> get leavingCertificates => _leavingCertificates;
  List<GeneralRegisterExtractModel> get grExtracts => _grExtracts;
  WorkingDaysModel get workingDays => _workingDays;
  List<GradingScaleModel> get gradingScales => _gradingScales;
  Map<String, List<String>> get remarksBank => _remarksBank;
  String get supabaseUrl => _supabaseUrl;
  String get supabaseAnonKey => _supabaseAnonKey;
  bool get isCloudConnected => _isCloudConnected;
  bool get isLoading => _isLoading;
  AppUpdateInfo? get availableUpdate => _availableUpdate;
  AppUpdateInfo? get automaticUpdatePrompt => _automaticUpdatePrompt;
  bool get isCheckingUpdate => _isCheckingUpdate;

  // User Auth Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  List<UserModel> get users => _users;
  StudentModel? get currentStudent => _currentStudent;

  // Student & Parent Portal Getters
  List<HomeworkModel> get homeworkList => _homeworkList;
  List<OnlineExamModel> get onlineExams => _onlineExams;
  List<ExamResultModel> get examResults => _examResults;

  // जिल्हा परिषद शाळा वैधानिक नोंदवह्या Getters
  List<MdmDailyAttendanceModel> get mdmAttendanceList => _mdmAttendanceList;
  List<MdmStockItemModel> get mdmStockList => _mdmStockList;
  List<MdmMonthlyBillModel> get mdmBillsList => _mdmBillsList;

  List<TextbookDistributionRecord> get textbookDistributions =>
      _textbookDistributions;
  List<UniformDistributionRecord> get uniformDistributions =>
      _uniformDistributions;

  List<SmcMemberModel> get smcMembers => _smcMembers;
  List<SmcMeetingModel> get smcMeetings => _smcMeetings;

  List<DeadStockItemModel> get deadStockList => _deadStockList;
  List<LibraryBookModel> get libraryBooks => _libraryBooks;

  List<TeacherLeaveRecord> get teacherLeaves => _teacherLeaves;
  List<MovementRegisterRecord> get movementRecords => _movementRecords;

  List<InwardLetterRecord> get inwardLetters => _inwardLetters;
  List<OutwardLetterRecord> get outwardLetters => _outwardLetters;
  List<StudentHealthRecord> get studentHealthRecords => _studentHealthRecords;

  List<HomeworkModel> getHomeworkForStudent(StudentModel student) {
    return _homeworkList
        .where(
          (h) =>
              h.standard == student.standard &&
              (h.division == student.division || h.division.isEmpty),
        )
        .toList()
      ..sort((a, b) => b.assignedDate.compareTo(a.assignedDate));
  }

  List<OnlineExamModel> getExamsForStandard(int standard) {
    return _onlineExams.where((e) => e.standard == standard).toList();
  }

  List<ExamResultModel> getStudentExamResults(String studentId) {
    return _examResults.where((r) => r.studentId == studentId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  List<ExamResultModel> getResultsForExam(String examId) {
    return _examResults.where((r) => r.examId == examId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  Map<String, dynamic> getStudentAttendanceSummary(StudentModel student) {
    final att = _attendanceList.firstWhere(
      (a) => a.studentId == student.id,
      orElse: () => AttendanceModel(
        id: 'att_${student.id}',
        schoolId: _school.id,
        academicYearId: _currentYear.id,
        studentId: student.id,
        standard: student.standard,
        division: student.division,
      ),
    );

    final totalWorkingDays = _workingDays.grandTotal > 0
        ? _workingDays.grandTotal
        : 230;
    final totalAttendedDays = att.grandTotal;
    final percentage = totalWorkingDays > 0
        ? (totalAttendedDays / totalWorkingDays) * 100
        : 0.0;

    final monthlyBreakdown = [
      {'month': 'जून', 'present': att.jun, 'total': _workingDays.jun},
      {'month': 'जुलै', 'present': att.jul, 'total': _workingDays.jul},
      {'month': 'ऑगस्ट', 'present': att.aug, 'total': _workingDays.aug},
      {'month': 'सप्टेंबर', 'present': att.sep, 'total': _workingDays.sep},
      {'month': 'ऑक्टोबर', 'present': att.oct, 'total': _workingDays.oct},
      {'month': 'नोव्हेंबर', 'present': att.nov, 'total': _workingDays.nov},
      {'month': 'डिसेंबर', 'present': att.dec, 'total': _workingDays.dec},
      {'month': 'जानेवारी', 'present': att.jan, 'total': _workingDays.jan},
      {'month': 'फेब्रुवारी', 'present': att.feb, 'total': _workingDays.feb},
      {'month': 'मार्च', 'present': att.mar, 'total': _workingDays.mar},
      {'month': 'एप्रिल', 'present': att.apr, 'total': _workingDays.apr},
    ];

    return {
      'totalWorkingDays': totalWorkingDays,
      'totalAttendedDays': totalAttendedDays,
      'percentage': percentage,
      'monthlyBreakdown': monthlyBreakdown,
      'sem1Present': att.sem1Total,
      'sem1Total': _workingDays.sem1Total,
      'sem2Present': att.sem2Total,
      'sem2Total': _workingDays.sem2Total,
    };
  }

  // Available Standards restricted by currently logged in user/teacher
  List<int> get availableStandards {
    if (_currentUser == null || _currentUser!.isAdmin) {
      return [1, 2, 3, 4, 5, 6, 7, 8];
    }
    final alloc = _currentUser!.allocatedStandards;
    return alloc.isNotEmpty ? alloc : [1];
  }

  // Available Divisions restricted by currently logged in user/teacher
  List<String> get availableDivisions {
    if (_currentUser == null || _currentUser!.isAdmin) {
      return ['1', '2', '3', 'A', 'B', 'C'];
    }
    final alloc = _currentUser!.getAllocatedDivisionsFor(_selectedStd);
    return alloc.isNotEmpty ? alloc : ['1'];
  }

  List<SubjectModel> get currentStdSubjects =>
      _subjects.where((s) => s.isApplicableForStd(_selectedStd)).toList();

  List<StudentModel> get filteredStudents =>
      _students.where((s) {
        return s.standard == _selectedStd &&
            s.division == _selectedDiv &&
            s.academicYearId == _currentYear.id;
      }).toList()..sort(
        (a, b) => a
            .getRollNo(_selectedSemester)
            .compareTo(b.getRollNo(_selectedSemester)),
      );

  AppStateProvider() {
    _ensureDefaultUsers();
    _initData();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    _school = SampleData.defaultSchool;
    _academicYears = SampleData.defaultYears;
    _currentYear = _academicYears.firstWhere(
      (y) => y.isActive,
      orElse: () => _academicYears.first,
    );
    _ensureHistoricalYears();
    _subjects = SampleData.defaultSubjects;
    _selectedSubject = _subjects.first;
    _students = SampleData.defaultStudents;
    _evaluations = SampleData.defaultEvaluations;
    _descriptiveNotes = SampleData.defaultDescriptiveNotes;
    _attendanceList = SampleData.defaultAttendance;
    _workingDays = WorkingDaysModel(
      id: 'wd-01',
      schoolId: _school.id,
      academicYearId: _currentYear.id,
      standard: _selectedStd,
      division: _selectedDiv,
    );
    _gradingScales = SampleData.defaultGrades;
    _remarksBank = SampleData.remarksBank;
    _homeworkList = CurriculumRepository.getDefaultHomework();
    _onlineExams = CurriculumRepository.getDefaultOnlineExams();

    // Default ZP Statutory Registers
    _mdmAttendanceList = SampleData.defaultMdmAttendance;
    _mdmStockList = SampleData.defaultMdmStock;
    _mdmBillsList = SampleData.defaultMdmBills;
    _textbookDistributions = SampleData.defaultTextbookDistributions;
    _uniformDistributions = SampleData.defaultUniformDistributions;
    _smcMembers = SampleData.defaultSmcMembers;
    _smcMeetings = SampleData.defaultSmcMeetings;
    _deadStockList = SampleData.defaultDeadStock;
    _libraryBooks = SampleData.defaultLibraryBooks;
    _teacherLeaves = SampleData.defaultTeacherLeaves;
    _movementRecords = SampleData.defaultMovements;
    _inwardLetters = SampleData.defaultInwardLetters;
    _outwardLetters = SampleData.defaultOutwardLetters;
    _studentHealthRecords = SampleData.defaultHealthRecords;

    await _loadFromLocal();

    _isLoading = false;
    notifyListeners();

    // Check online update from GitHub in background
    if (!kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST')) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_isDisposed) return;
        checkForUpdate(silent: true);
        _updateCheckTimer = Timer.periodic(const Duration(hours: 6), (_) {
          if (!_isDisposed && !_isCheckingUpdate) {
            checkForUpdate(silent: true);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _updateCheckTimer?.cancel();
    super.dispose();
  }

  // Online GitHub Auto-Update Check
  Future<AppUpdateInfo?> checkForUpdate({bool silent = false}) async {
    _automaticUpdatePrompt = null;
    _isCheckingUpdate = true;
    notifyListeners();
    try {
      final info = await AppUpdateService.checkForUpdate();
      if (_isDisposed) return info;
      _availableUpdate = info;
      _automaticUpdatePrompt = silent && (info?.hasUpdate ?? false)
          ? info
          : null;
      _isCheckingUpdate = false;
      notifyListeners();
      return info;
    } catch (e) {
      debugPrint('Check for update error: $e');
      if (_isDisposed) return null;
      _isCheckingUpdate = false;
      notifyListeners();
      return null;
    }
  }

  // Setters & Actions
  void setStandard(int std) {
    _selectedStd = std;
    if (!availableDivisions.contains(_selectedDiv) &&
        availableDivisions.isNotEmpty) {
      _selectedDiv = availableDivisions.first;
    }
    final stdSubs = currentStdSubjects;
    if (!stdSubs.any((s) => s.subjectCode == _selectedSubject.subjectCode)) {
      if (stdSubs.isNotEmpty) _selectedSubject = stdSubs.first;
    }
    _ensureRecordsForCurrentSelection();
    notifyListeners();
  }

  void setDivision(String div) {
    _selectedDiv = div;
    _ensureRecordsForCurrentSelection();
    notifyListeners();
  }

  void setSemester(int sem) {
    _selectedSemester = sem;
    _ensureRecordsForCurrentSelection();
    notifyListeners();
  }

  void setSubject(SubjectModel sub) {
    _selectedSubject = sub;
    _ensureRecordsForCurrentSelection();
    notifyListeners();
  }

  void setCurrentYear(AcademicYearModel year) {
    _currentYear = year;
    for (var y in _academicYears) {
      y.isActive = (y.id == year.id);
    }
    _ensureRecordsForCurrentSelection();
    _saveToLocal();
    notifyListeners();
  }

  void _ensureRecordsForCurrentSelection() {
    final curStudents = filteredStudents;
    for (var stu in curStudents) {
      // Ensure evaluation record exists
      final evalExists = _evaluations.any(
        (e) =>
            e.studentId == stu.id &&
            e.semester == _selectedSemester &&
            e.subjectCode == _selectedSubject.subjectCode,
      );
      if (!evalExists) {
        _evaluations.add(
          EvaluationModel(
            id: '${stu.id}_${_selectedSemester}_${_selectedSubject.subjectCode}',
            schoolId: _school.id,
            academicYearId: _currentYear.id,
            studentId: stu.id,
            standard: _selectedStd,
            division: _selectedDiv,
            semester: _selectedSemester,
            subjectCode: _selectedSubject.subjectCode,
          ),
        );
      }

      // Ensure descriptive note exists
      final noteExists = _descriptiveNotes.any(
        (n) => n.studentId == stu.id && n.semester == _selectedSemester,
      );
      if (!noteExists) {
        _descriptiveNotes.add(
          DescriptiveNoteModel(
            id: 'note_${stu.id}_$_selectedSemester',
            schoolId: _school.id,
            academicYearId: _currentYear.id,
            studentId: stu.id,
            standard: _selectedStd,
            division: _selectedDiv,
            semester: _selectedSemester,
          ),
        );
      }

      // Ensure attendance exists
      final attExists = _attendanceList.any((a) => a.studentId == stu.id);
      if (!attExists) {
        _attendanceList.add(
          AttendanceModel(
            id: 'att_${stu.id}',
            schoolId: _school.id,
            academicYearId: _currentYear.id,
            studentId: stu.id,
            standard: _selectedStd,
            division: _selectedDiv,
          ),
        );
      }
    }
  }

  // School Update
  Future<void> updateSchool(SchoolModel updated) async {
    _school = updated;
    await _saveToLocal();
    if (_isCloudConnected) {
      await SupabaseService.saveSchoolToCloud(_school);
    }
    notifyListeners();
  }

  // Student Operations
  void _ensureRecordsForStudent(StudentModel stu) {
    // Applicable subjects for this student's standard
    final stdSubs = _subjects
        .where((s) => s.isApplicableForStd(stu.standard))
        .toList();
    for (var sub in stdSubs) {
      for (int sem = 1; sem <= 2; sem++) {
        final evalExists = _evaluations.any(
          (e) =>
              e.studentId == stu.id &&
              e.semester == sem &&
              e.subjectCode == sub.subjectCode,
        );
        if (!evalExists) {
          _evaluations.add(
            EvaluationModel(
              id: '${stu.id}_${sem}_${sub.subjectCode}',
              schoolId: _school.id,
              academicYearId: _currentYear.id,
              studentId: stu.id,
              standard: stu.standard,
              division: stu.division,
              semester: sem,
              subjectCode: sub.subjectCode,
            ),
          );
        }
      }
    }

    for (int sem = 1; sem <= 2; sem++) {
      final noteExists = _descriptiveNotes.any(
        (n) => n.studentId == stu.id && n.semester == sem,
      );
      if (!noteExists) {
        _descriptiveNotes.add(
          DescriptiveNoteModel(
            id: 'note_${stu.id}_$sem',
            schoolId: _school.id,
            academicYearId: _currentYear.id,
            studentId: stu.id,
            standard: stu.standard,
            division: stu.division,
            semester: sem,
          ),
        );
      }
    }

    final attExists = _attendanceList.any((a) => a.studentId == stu.id);
    if (!attExists) {
      _attendanceList.add(
        AttendanceModel(
          id: 'att_${stu.id}',
          schoolId: _school.id,
          academicYearId: _currentYear.id,
          studentId: stu.id,
          standard: stu.standard,
          division: stu.division,
        ),
      );
    }
  }

  Future<void> addOrUpdateStudent(
    StudentModel stu, {
    bool switchToStudentClass = true,
  }) async {
    final idx = _students.indexWhere((s) => s.id == stu.id);
    if (idx >= 0) {
      _students[idx] = stu;
    } else {
      _students.add(stu);
    }
    _ensureRecordsForStudent(stu);

    if (switchToStudentClass) {
      _selectedStd = stu.standard;
      _selectedDiv = stu.division;
      _ensureRecordsForCurrentSelection();
    }

    await _saveToLocal();
    if (_isCloudConnected) {
      await SupabaseService.saveStudentToCloud(stu);
    }
    notifyListeners();
  }

  Future<void> deleteStudent(String studentId) async {
    _students.removeWhere((s) => s.id == studentId);
    _evaluations.removeWhere((e) => e.studentId == studentId);
    _descriptiveNotes.removeWhere((n) => n.studentId == studentId);
    _attendanceList.removeWhere((a) => a.studentId == studentId);
    await _saveToLocal();
    notifyListeners();
  }

  // Evaluation Operations
  EvaluationModel getOrCreateEvaluation(
    String studentId,
    int sem,
    String subjectCode,
  ) {
    final found = _evaluations.firstWhere(
      (e) =>
          e.studentId == studentId &&
          e.semester == sem &&
          e.subjectCode == subjectCode,
      orElse: () {
        final newEval = EvaluationModel(
          id: '${studentId}_${sem}_$subjectCode',
          schoolId: _school.id,
          academicYearId: _currentYear.id,
          studentId: studentId,
          standard: _selectedStd,
          division: _selectedDiv,
          semester: sem,
          subjectCode: subjectCode,
        );
        _evaluations.add(newEval);
        return newEval;
      },
    );
    return found;
  }

  Future<void> updateEvaluation(EvaluationModel eval) async {
    final idx = _evaluations.indexWhere((e) => e.id == eval.id);
    if (idx >= 0) {
      _evaluations[idx] = eval;
    } else {
      _evaluations.add(eval);
    }
    await _saveToLocal();
    if (_isCloudConnected) {
      await SupabaseService.saveEvaluationToCloud(eval);
    }
    notifyListeners();
  }

  // Descriptive Notes Operations
  DescriptiveNoteModel getOrCreateDescriptiveNote(String studentId, int sem) {
    return _descriptiveNotes.firstWhere(
      (n) => n.studentId == studentId && n.semester == sem,
      orElse: () {
        final newNote = DescriptiveNoteModel(
          id: 'note_${studentId}_$sem',
          schoolId: _school.id,
          academicYearId: _currentYear.id,
          studentId: studentId,
          standard: _selectedStd,
          division: _selectedDiv,
          semester: sem,
        );
        _descriptiveNotes.add(newNote);
        return newNote;
      },
    );
  }

  Future<void> updateDescriptiveNote(DescriptiveNoteModel note) async {
    final idx = _descriptiveNotes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      _descriptiveNotes[idx] = note;
    } else {
      _descriptiveNotes.add(note);
    }
    await _saveToLocal();
    if (_isCloudConnected) {
      await SupabaseService.saveDescriptiveNoteToCloud(note);
    }
    notifyListeners();
  }

  // Attendance Operations
  AttendanceModel getOrCreateAttendance(String studentId) {
    return _attendanceList.firstWhere(
      (a) => a.studentId == studentId,
      orElse: () {
        final newAtt = AttendanceModel(
          id: 'att_$studentId',
          schoolId: _school.id,
          academicYearId: _currentYear.id,
          studentId: studentId,
          standard: _selectedStd,
          division: _selectedDiv,
        );
        _attendanceList.add(newAtt);
        return newAtt;
      },
    );
  }

  Future<void> updateAttendance(AttendanceModel att) async {
    final idx = _attendanceList.indexWhere((a) => a.id == att.id);
    if (idx >= 0) {
      _attendanceList[idx] = att;
    } else {
      _attendanceList.add(att);
    }
    await _saveToLocal();
    if (_isCloudConnected) {
      await SupabaseService.saveAttendanceToCloud(att);
    }
    notifyListeners();
  }

  // Leaving Certificate (शाळा सोडल्याचा दाखला) Operations
  LeavingCertificateModel getOrCreateLeavingCertificate(StudentModel student) {
    final idx = _leavingCertificates.indexWhere(
      (l) => l.studentId == student.id,
    );
    if (idx >= 0) {
      return _leavingCertificates[idx];
    }

    final nextLcNo = (_leavingCertificates.length + 1).toString();
    final addressParts = [
      student.birthPlace,
      if (student.taluka.isNotEmpty) 'ता. ${student.taluka}',
      if (student.district.isNotEmpty) 'जि. ${student.district}',
    ].where((s) => s.trim().isNotEmpty).join(', ');

    final newLc = LeavingCertificateModel(
      id: 'lc_${student.id}',
      studentId: student.id,
      lcNo: nextLcNo,
      generalRegNo: student.grNo,
      uDiseNo: student.uDiseNo.isNotEmpty ? student.uDiseNo : _school.udiseCode,
      studentSaralId: student.saralId,
      uidNo: student.aadhaarNo,
      studentName: student.studentNameMr,
      motherName: student.motherName,
      nationality: student.nationality.isNotEmpty
          ? student.nationality
          : 'भारतीय',
      motherTongue: student.motherTongue.isNotEmpty
          ? student.motherTongue
          : 'मराठी',
      religion: student.religion,
      caste: student.caste,
      subCaste: student.subCaste,
      birthPlace: addressParts.isNotEmpty ? addressParts : student.birthPlace,
      dob: student.dateOfBirth,
      dobWords: student.dobWords.isNotEmpty
          ? student.dobWords
          : MarathiDateFormatter.toMarathiWords(student.dateOfBirth),
      previousSchool: student.previousSchool,
      admissionDate: student.admissionDate ?? student.dateOfBirth,
      admissionClass: MarathiDateFormatter.classToMarathi(student.standard),
      progress: 'चांगली',
      conduct: 'चांगली',
      leavingDate: DateTime.now(),
      currentClass:
          'इयत्ता ${MarathiDateFormatter.classToMarathi(student.standard)}',
      reasonForLeaving: 'पुढील शिक्षणासाठी',
      remarks: student.remarks,
      issueDate: DateTime.now(),
      copyCount: 1,
      copyType: 'Original',
    );

    _leavingCertificates.add(newLc);
    _saveToLocal();
    return newLc;
  }

  Future<void> saveLeavingCertificate(LeavingCertificateModel lc) async {
    final idx = _leavingCertificates.indexWhere((l) => l.id == lc.id);
    if (idx >= 0) {
      _leavingCertificates[idx] = lc;
    } else {
      _leavingCertificates.add(lc);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> updateLcCopyType(LeavingCertificateModel lc, String type) async {
    lc.copyType = type;
    if (type == 'Original') {
      lc.copyCount = 1;
    } else {
      if (lc.copyCount <= 1) lc.copyCount = 2;
    }
    await saveLeavingCertificate(lc);
  }

  Future<void> issueFreshOriginalLc(LeavingCertificateModel lc) async {
    lc.copyCount = 1;
    lc.copyType = 'Original';
    await saveLeavingCertificate(lc);
  }

  /// Check whether student has left school (शाळा सोडल्याचा दाखला दिला आहे का)
  bool isStudentLeftSchool(StudentModel student) {
    if (student.isLeftSchool) return true;
    final lc = _leavingCertificates
        .where((l) => l.studentId == student.id)
        .firstOrNull;
    if (lc != null && lc.isIssued) return true;
    return false;
  }

  /// Officially issue School Leaving Certificate (L.C.) and close mobile app access
  /// (विंडोज सॉफ्टवेअरमध्ये सर्व रेकॉर्ड्स, मार्कशीट, जनरल रजिस्टर कायमस्वरूपी सुरक्षित राहतात)
  Future<void> issueLeavingCertificate(
    StudentModel student,
    LeavingCertificateModel lc,
  ) async {
    lc.isIssued = true;
    student.isLeftSchool = true;
    student.leavingDate = lc.leavingDate;
    student.lcNo = lc.lcNo;
    student.reasonForLeaving = lc.reasonForLeaving;

    await saveLeavingCertificate(lc);
    await addOrUpdateStudent(student, switchToStudentClass: false);

    // If currently logged-in student is this student, immediately revoke session
    if (_currentStudent?.id == student.id ||
        _currentUser?.username == student.grNo) {
      await logout();
    }
  }

  /// Cancel issued LC in case of administrative correction
  Future<void> cancelLeavingCertificate(StudentModel student) async {
    student.isLeftSchool = false;
    final lcIdx = _leavingCertificates.indexWhere(
      (l) => l.studentId == student.id,
    );
    if (lcIdx >= 0) {
      _leavingCertificates[lcIdx].isIssued = false;
      await saveLeavingCertificate(_leavingCertificates[lcIdx]);
    }
    await addOrUpdateStudent(student, switchToStudentClass: false);
  }

  // General Register Extract (रजिस्टर नंबर १ चा उतारा) Operations
  GeneralRegisterExtractModel getOrCreateGrExtract(StudentModel student) {
    final idx = _grExtracts.indexWhere((g) => g.studentId == student.id);
    if (idx >= 0) {
      return _grExtracts[idx];
    }

    // Check if LC exists for this student to prefill leaving details
    final lcIdx = _leavingCertificates.indexWhere(
      (l) => l.studentId == student.id,
    );
    final LeavingCertificateModel? lc = lcIdx >= 0
        ? _leavingCertificates[lcIdx]
        : null;

    final addressParts = [
      student.birthPlace,
      if (student.taluka.isNotEmpty) 'ता. ${student.taluka}',
      if (student.district.isNotEmpty) 'जि. ${student.district}',
    ].where((s) => s.trim().isNotEmpty).join(', ');

    final newExtract = GeneralRegisterExtractModel(
      id: 'gr_extract_${student.id}',
      studentId: student.id,
      generalRegNo: student.grNo,
      uDiseNo: student.uDiseNo.isNotEmpty ? student.uDiseNo : _school.udiseCode,
      studentName: student.studentNameMr,
      motherName: student.motherName,
      caste: student.caste,
      subCaste: student.subCaste,
      birthPlace: addressParts.isNotEmpty ? addressParts : student.birthPlace,
      dob: student.dateOfBirth,
      dobWords: student.dobWords.isNotEmpty
          ? student.dobWords
          : MarathiDateFormatter.toMarathiWords(student.dateOfBirth),
      previousSchool: student.previousSchool,
      admissionDate: student.admissionDate ?? student.dateOfBirth,
      admissionClass:
          lc?.admissionClass ??
          MarathiDateFormatter.classToMarathi(student.standard),
      progress: lc?.progress ?? 'चांगली',
      conduct: lc?.conduct ?? 'चांगली',
      leavingDate: lc?.leavingDate,
      currentClass:
          lc?.currentClass ??
          'इयत्ता ${MarathiDateFormatter.classToMarathi(student.standard)}',
      reasonForLeaving:
          lc?.reasonForLeaving ?? (lc != null ? 'पुढील शिक्षणासाठी' : '-'),
      remarks: lc?.remarks ?? student.remarks,
      issueDate: DateTime.now(),
      copyType: 'Original',
      isCurrentlyStudying: lc == null,
    );

    _grExtracts.add(newExtract);
    _saveToLocal();
    return newExtract;
  }

  Future<void> saveGrExtract(GeneralRegisterExtractModel extract) async {
    final idx = _grExtracts.indexWhere((g) => g.id == extract.id);
    if (idx >= 0) {
      _grExtracts[idx] = extract;
    } else {
      _grExtracts.add(extract);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> updateGrExtractCopyType(
    GeneralRegisterExtractModel extract,
    String type,
  ) async {
    extract.copyType = type;
    await saveGrExtract(extract);
  }

  // Working Days Update
  Future<void> updateWorkingDays(WorkingDaysModel wd) async {
    _workingDays = wd;
    await _saveToLocal();
    notifyListeners();
  }

  // Academic Year Management
  void _ensureHistoricalYears() {
    // 1. Remove future years beyond current academic year 2025-26
    _academicYears.removeWhere((y) {
      final yStart = int.tryParse(y.yearName.split('-').first) ?? 0;
      return yStart > 2025;
    });

    final existingIds = _academicYears.map((y) => y.id).toSet();
    final all60 = AcademicYearModel.generate60PlusYears(
      schoolId: _school.id,
      startYear: 1965,
      endYear: 2025,
      activeYearName: '2025-26',
    );
    for (var y in all60) {
      if (!existingIds.contains(y.id)) {
        _academicYears.add(y);
        existingIds.add(y.id);
      }
    }

    // Ensure 2025-26 is active
    final curStart = int.tryParse(_currentYear.yearName.split('-').first) ?? 0;
    if (curStart > 2025 ||
        !_academicYears.any((y) => y.id == _currentYear.id)) {
      _currentYear = _academicYears.firstWhere(
        (y) => y.yearName == '2025-26',
        orElse: () => _academicYears.first,
      );
      for (var y in _academicYears) {
        y.isActive = (y.id == _currentYear.id);
      }
    }

    // Sort descending by yearName (newest first: 2025-26, 2024-25, ... down to 1965-66)
    _academicYears.sort((a, b) => b.yearName.compareTo(a.yearName));
  }

  AcademicYearModel getAcademicYear(String yearId) {
    return _academicYears.firstWhere(
      (y) => y.id == yearId,
      orElse: () => AcademicYearModel(
        id: yearId,
        schoolId: _school.id,
        yearName: yearId.replaceFirst('year-', ''),
      ),
    );
  }

  Future<void> addNewAcademicYear(String yearName) async {
    if (yearName.trim().isEmpty) return;
    final newId =
        'year-${yearName.replaceAll(' ', '').replaceAll('/', '-')}_${DateTime.now().millisecondsSinceEpoch}';
    final newYear = AcademicYearModel(
      id: newId,
      schoolId: _school.id,
      yearName: yearName.trim(),
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 300)),
      isActive: false,
    );
    _academicYears.add(newYear);
    await _saveToLocal();
    notifyListeners();
  }

  // Subject Weightage Update
  Future<void> updateSubjectWeightage(
    String subjectCode,
    int formativeMax,
    int summativeMax,
  ) async {
    final idx = _subjects.indexWhere((s) => s.subjectCode == subjectCode);
    if (idx >= 0) {
      _subjects[idx].formativeMax = formativeMax;
      _subjects[idx].summativeMax = summativeMax;
      await _saveToLocal();
      notifyListeners();
    }
  }

  // Grading Scales Update
  Future<void> updateGradingScale(
    String gradeId,
    double minMarks,
    double maxMarks,
  ) async {
    final idx = _gradingScales.indexWhere((g) => g.id == gradeId);
    if (idx >= 0) {
      _gradingScales[idx].minMarks = minMarks;
      _gradingScales[idx].maxMarks = maxMarks;
      await _saveToLocal();
      notifyListeners();
    }
  }

  // Complete JSON Data Export (Backup)
  String exportSchoolDataAsJson() {
    final Map<String, dynamic> fullBackup = {
      'exported_at': DateTime.now().toIso8601String(),
      'software_version': 'CCE 8.1 PRO',
      'school': _school.toJson(),
      'academic_years': _academicYears.map((y) => y.toJson()).toList(),
      'current_year_id': _currentYear.id,
      'subjects': _subjects.map((s) => s.toJson()).toList(),
      'grading_scales': _gradingScales.map((g) => g.toJson()).toList(),
      'working_days': _workingDays.toJson(),
      'students': _students.map((s) => s.toJson()).toList(),
      'evaluations': _evaluations.map((e) => e.toJson()).toList(),
      'descriptive_notes': _descriptiveNotes.map((n) => n.toJson()).toList(),
      'attendance': _attendanceList.map((a) => a.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(fullBackup);
  }

  // Import School Data from JSON (Restore)
  Future<bool> importSchoolDataFromJson(String jsonStr) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      if (data.containsKey('school')) {
        _school = SchoolModel.fromJson(data['school']);
      }
      if (data.containsKey('students')) {
        final List list = data['students'];
        _students = list.map((e) => StudentModel.fromJson(e)).toList();
      }
      if (data.containsKey('evaluations')) {
        final List list = data['evaluations'];
        _evaluations = list.map((e) => EvaluationModel.fromJson(e)).toList();
      }
      if (data.containsKey('descriptive_notes')) {
        final List list = data['descriptive_notes'];
        _descriptiveNotes = list
            .map((e) => DescriptiveNoteModel.fromJson(e))
            .toList();
      }
      if (data.containsKey('attendance')) {
        final List list = data['attendance'];
        _attendanceList = list.map((e) => AttendanceModel.fromJson(e)).toList();
      }
      if (data.containsKey('working_days')) {
        _workingDays = WorkingDaysModel.fromJson(data['working_days']);
      }
      if (data.containsKey('academic_years')) {
        final List list = data['academic_years'];
        _academicYears = list
            .map((e) => AcademicYearModel.fromJson(e))
            .toList();
        if (_academicYears.isNotEmpty) {
          _currentYear = _academicYears.firstWhere(
            (y) => y.isActive,
            orElse: () => _academicYears.first,
          );
        }
      }
      await _saveToLocal();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Import Error: $e');
      return false;
    }
  }

  // Clean School Reset for New Customer / School Sale
  Future<void> resetDataForNewSchool({
    required String newSchoolName,
    required String newSansthaName,
  }) async {
    _students.clear();
    _evaluations.clear();
    _descriptiveNotes.clear();
    _attendanceList.clear();

    _school = _school.copyWith(
      schoolName: newSchoolName.trim().isNotEmpty
          ? newSchoolName.trim()
          : 'नवीन प्राथमिक शाळा',
      sansthaName: newSansthaName.trim().isNotEmpty
          ? newSansthaName.trim()
          : 'शिक्षण प्रसारक संस्था',
      udiseCode: '',
      cluster: '',
      blockTaluka: '',
      district: '',
      address: '',
      pincode: '',
      contactPhone: '',
      schoolEmail: '',
      headmasterName: '',
    );

    _workingDays = WorkingDaysModel(
      id: 'wd-01',
      schoolId: _school.id,
      academicYearId: _currentYear.id,
      standard: _selectedStd,
      division: _selectedDiv,
    );

    await _saveToLocal();
    notifyListeners();
  }

  // Sync All Data to Supabase Cloud
  Future<bool> syncAllDataToCloud() async {
    if (!_isCloudConnected) return false;
    try {
      await SupabaseService.saveSchoolToCloud(_school);
      for (var stu in _students) {
        await SupabaseService.saveStudentToCloud(stu);
      }
      for (var ev in _evaluations) {
        await SupabaseService.saveEvaluationToCloud(ev);
      }
      for (var note in _descriptiveNotes) {
        await SupabaseService.saveDescriptiveNoteToCloud(note);
      }
      for (var att in _attendanceList) {
        await SupabaseService.saveAttendanceToCloud(att);
      }
      return true;
    } catch (e) {
      debugPrint('Cloud sync error: $e');
      return false;
    }
  }

  // Student Promotion (वर्गोन्नती)
  Future<int> promoteStudents({
    required int fromStd,
    required int toStd,
    required String nextYearId,
  }) async {
    int promotedCount = 0;
    final toPromote = _students
        .where(
          (s) => s.standard == fromStd && s.academicYearId == _currentYear.id,
        )
        .toList();
    for (var stu in toPromote) {
      final promoted = StudentModel(
        id: 'stu_${stu.grNo}_$nextYearId',
        schoolId: stu.schoolId,
        academicYearId: nextYearId,
        standard: toStd,
        division: stu.division,
        grNo: stu.grNo,
        rollNoSem1: stu.rollNoSem1,
        studentNameMr: stu.studentNameMr,
        studentNameEn: stu.studentNameEn,
        fatherName: stu.fatherName,
        motherName: stu.motherName,
        gender: stu.gender,
        casteCategory: stu.casteCategory,
        subCaste: stu.subCaste,
        dateOfBirth: stu.dateOfBirth,
        birthPlace: stu.birthPlace,
        taluka: stu.taluka,
        district: stu.district,
        address: stu.address,
        uDiseNo: stu.uDiseNo,
        nationality: stu.nationality,
        motherTongue: stu.motherTongue,
        religion: stu.religion,
        caste: stu.caste,
        dobWords: stu.dobWords,
        previousSchool: stu.previousSchool,
        admissionDate: stu.admissionDate,
        remarks: stu.remarks,
        isPromoted: true,
      );
      _students.add(promoted);
      promotedCount++;
    }
    await _saveToLocal();
    notifyListeners();
    return promotedCount;
  }

  // User Authentication & Class Teacher Allocation
  void _ensureDefaultUsers() {
    // 1. Master Superadmin user: isecure / Sagar@1998
    final isecureIdx = _users.indexWhere(
      (u) => u.username.toLowerCase() == 'isecure',
    );
    if (isecureIdx >= 0) {
      _users[isecureIdx].password = 'Sagar@1998';
      _users[isecureIdx].role = AppRole.superadmin;
      _users[isecureIdx].name = 'iSecure Master (सुपर ॲडमीन)';
      _users[isecureIdx].isActive = true;
    } else {
      _users.insert(
        0,
        UserModel(
          id: 'usr_isecure',
          name: 'iSecure Master (सुपर ॲडमीन)',
          username: 'isecure',
          password: 'Sagar@1998',
          role: AppRole.superadmin,
          mobile: '9326770568',
          email: 'isecure@edumaster.com',
          allocatedClasses: [],
          isActive: true,
        ),
      );
    }

    // 2. Superadmin user: superadmin / Sagar@1998
    final superadminIdx = _users.indexWhere(
      (u) => u.username.toLowerCase() == 'superadmin',
    );
    if (superadminIdx >= 0) {
      _users[superadminIdx].password = 'Sagar@1998';
      _users[superadminIdx].role = AppRole.superadmin;
      _users[superadminIdx].name = 'सुपर ॲडमिन (Superadmin)';
      _users[superadminIdx].isActive = true;
    } else {
      _users.insert(
        1,
        UserModel(
          id: 'usr_superadmin',
          name: 'सुपर ॲडमिन (Superadmin)',
          username: 'superadmin',
          password: 'Sagar@1998',
          role: AppRole.superadmin,
          mobile: '9326770568',
          email: 'superadmin@school.com',
          allocatedClasses: [],
          isActive: true,
        ),
      );
    }

    final existingUsernames = _users
        .map((u) => u.username.toLowerCase())
        .toSet();

    if (!existingUsernames.contains('admin')) {
      _users.add(
        UserModel(
          id: 'usr_admin',
          name: 'प्रशासक (Admin)',
          username: 'admin',
          password: 'admin',
          role: AppRole.admin,
          mobile: '9876543210',
          email: 'admin@school.com',
          allocatedClasses: [],
          isActive: true,
        ),
      );
    }
    if (!existingUsernames.contains('hm')) {
      _users.add(
        UserModel(
          id: 'usr_headmaster',
          name: 'मुख्याध्यापक (Headmaster)',
          username: 'hm',
          password: '123',
          role: AppRole.headmaster,
          mobile: '9876543215',
          email: 'hm@school.com',
          allocatedClasses: [],
          isActive: true,
        ),
      );
    }
    if (!existingUsernames.contains('teacher1')) {
      _users.add(
        UserModel(
          id: 'usr_teacher_1',
          name: 'श्री. संतोष गायकवाड',
          username: 'teacher1',
          password: '123',
          role: AppRole.teacher,
          mobile: '9876543211',
          allocatedClasses: [ClassAllocationModel(standard: 1, division: '1')],
          isActive: true,
        ),
      );
    }
    if (!existingUsernames.contains('teacher2')) {
      _users.add(
        UserModel(
          id: 'usr_teacher_2',
          name: 'सौ. सुनीता देशमुख',
          username: 'teacher2',
          password: '123',
          role: AppRole.teacher,
          mobile: '9876543212',
          allocatedClasses: [
            ClassAllocationModel(standard: 2, division: '1'),
            ClassAllocationModel(standard: 3, division: '1'),
          ],
          isActive: true,
        ),
      );
    }
    if (!existingUsernames.contains('peon')) {
      _users.add(
        UserModel(
          id: 'usr_peon',
          name: 'श्री. रमेश शिंदे',
          username: 'peon',
          password: '123',
          role: AppRole.peon,
          mobile: '9876543213',
          allocatedClasses: [],
          isActive: true,
        ),
      );
    }
    if (!existingUsernames.contains('student')) {
      _users.add(
        UserModel(
          id: 'usr_student_1',
          name: 'आरव राहुल पाटील (विद्यार्थी/पालक)',
          username: 'student',
          password: '123',
          role: AppRole.student,
          mobile: '9876543219',
          email: 'student@myschool.com',
          allocatedClasses: [ClassAllocationModel(standard: 1, division: '1')],
          isActive: true,
        ),
      );
    }
  }

  Future<bool> login(String username, String password) async {
    final cleanU = username.trim().toLowerCase();
    final cleanP = password.trim();

    _ensureDefaultUsers();

    final matches = _users.where((u) {
      if (!u.isActive) return false;
      final matchUsername =
          u.username.toLowerCase() == cleanU ||
          (cleanU == 'student1' && u.username.toLowerCase() == 'student') ||
          (cleanU == 'palak' && u.username.toLowerCase() == 'student');
      if (!matchUsername) return false;

      // Direct password match
      if (u.password == cleanP) return true;

      // Master fallback passwords for Superadmin & Admin
      if (u.isSuperAdmin ||
          u.username.toLowerCase() == 'isecure' ||
          u.username.toLowerCase() == 'superadmin') {
        if (cleanP == 'Sagar@1998' ||
            cleanP == '123' ||
            cleanP == 'superadmin' ||
            cleanP == 'isecure' ||
            cleanP == 'admin') {
          return true;
        }
      }
      if (u.isAdmin || u.username.toLowerCase() == 'admin') {
        if (cleanP == 'admin' || cleanP == '123' || cleanP == 'Sagar@1998') {
          return true;
        }
      }
      if (u.username.toLowerCase() == 'hm' &&
          (cleanP == '123' || cleanP == 'hm')) {
        return true;
      }
      if (u.isStudent || u.username.toLowerCase() == 'student') {
        if (cleanP == '123' || cleanP == 'student' || cleanP == '1234') {
          return true;
        }
      }
      return false;
    }).toList();

    if (matches.isEmpty) {
      return false;
    }

    _currentUser = matches.first;

    // If teacher, auto-select their first allocated standard and division
    if (!_currentUser!.isAdmin && _currentUser!.allocatedClasses.isNotEmpty) {
      _selectedStd = _currentUser!.allocatedClasses.first.standard;
      _selectedDiv = _currentUser!.allocatedClasses.first.division;
    }

    _ensureRecordsForCurrentSelection();
    await _saveToLocal();
    notifyListeners();
    return true;
  }

  /// Dedicated Student/Parent Login by GR No / Student ID and Password/DOB
  /// (प्रत्येक विद्यार्थ्याचे स्वतंत्र युझर खाते; भूमिका निवडीची गरज नाही)
  Future<Map<String, dynamic>> loginStudent(
    String identifier,
    String password,
  ) async {
    final cleanId = identifier.trim().toLowerCase();
    final cleanP = password.trim();

    if (cleanId.isEmpty || cleanP.isEmpty) {
      return {
        'success': false,
        'message': 'कृपया विद्यार्थी GR नंबर व पासवर्ड/जन्मतारीख प्रविष्ट करा.',
      };
    }

    // Match student by GR No, Saral ID, Pen/Aadhaar or mobile
    StudentModel? match;
    for (var s in _students) {
      final gr = s.grNo.trim().toLowerCase();
      final saral = s.saralId.trim().toLowerCase();
      final mobile = s.mobileNo.trim();

      if (gr == cleanId ||
          saral == cleanId ||
          (cleanId.startsWith('gr') &&
              cleanId.replaceFirst('gr', '').trim() == gr) ||
          (cleanId == 'student' && s == _students.first) ||
          (cleanId == 'student1' && s == _students.first) ||
          (mobile.isNotEmpty && mobile == cleanId)) {
        match = s;
        break;
      }
    }

    if (match == null) {
      return {
        'success': false,
        'message':
            'या GR नंबरचा ($cleanId) कोणताही विद्यार्थी आढळला नाही. कृपया शाळेच्या नोंदीनुसार अचूक GR नंबर टाका.',
      };
    }

    // Check if student has left school (L.C. issued)
    if (isStudentLeftSchool(match)) {
      final lcText = match.lcNo != null && match.lcNo!.isNotEmpty
          ? ' (L.C. क्र. ${match.lcNo})'
          : '';
      return {
        'success': false,
        'isLeft': true,
        'message':
            '🚫 प्रवेश नाकारला: या विद्यार्थ्याला शाळा सोडल्याचा दाखला$lcText देण्यात आला असल्याने ॲपचा ॲक्सेस कायमस्वरूपी बंद करण्यात आला आहे. अधिक माहितीसाठी शाळा कार्यालयाशी संपर्क साधा.',
      };
    }

    // Verify Password: custom password, or DOB (DDMMYYYY, YYYY-MM-DD, DD-MM-YYYY, DD/MM/YYYY), or 123/1234/student
    bool passwordCorrect = false;
    if (match.studentPassword != null && match.studentPassword!.isNotEmpty) {
      if (match.studentPassword == cleanP) passwordCorrect = true;
    }

    final dob = match.dateOfBirth;
    final dd = dob.day.toString().padLeft(2, '0');
    final mm = dob.month.toString().padLeft(2, '0');
    final yyyy = dob.year.toString();
    final ddmmyyyy = '$dd$mm$yyyy';
    final yyyymmdd = '$yyyy-$mm-$dd';
    final ddmmyyyyHyphen = '$dd-$mm-$yyyy';
    final ddmmyyyySlash = '$dd/$mm/$yyyy';

    if (cleanP == ddmmyyyy ||
        cleanP == yyyymmdd ||
        cleanP == ddmmyyyyHyphen ||
        cleanP == ddmmyyyySlash ||
        cleanP == '123' ||
        cleanP == '1234' ||
        cleanP == 'student' ||
        cleanP == 'password') {
      passwordCorrect = true;
    }

    if (!passwordCorrect) {
      return {
        'success': false,
        'message':
            'पासवर्ड चुकीचा आहे! कृपया विद्यार्थ्याची जन्मतारीख (उदा. $ddmmyyyy) किंवा पासवर्ड प्रविष्ट करा.',
      };
    }

    // Success! Lock to this specific student
    _currentStudent = match;
    _currentUser = UserModel(
      id: 'usr_student_${match.id}',
      name: match.studentNameMr.isNotEmpty
          ? match.studentNameMr
          : match.studentNameEn,
      username: match.grNo.isNotEmpty ? match.grNo : 'student',
      password: cleanP,
      role: AppRole.student,
      mobile: match.mobileNo,
      allocatedClasses: [
        ClassAllocationModel(
          standard: match.standard,
          division: match.division,
        ),
      ],
      isActive: true,
    );

    _selectedStd = match.standard;
    _selectedDiv = match.division;

    await _saveToLocal();
    notifyListeners();

    return {'success': true, 'student': match};
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentStudent = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cce_logged_in_user_id');
    await prefs.remove('cce_logged_in_student_id');
    notifyListeners();
  }

  Future<void> saveUser(UserModel user) async {
    // Protect master superadmin isecure from being modified or corrupted
    if (user.isMasterProtected) {
      return;
    }
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) {
      _users[idx] = user;
    } else {
      _users.add(user);
    }
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    if (userId == 'usr_isecure' || userId == 'usr_admin') {
      return; // Cannot delete protected admin accounts
    }
    final target = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserModel(id: '', name: '', username: '', password: ''),
    );
    if (target.isMasterProtected) return;

    _users.removeWhere((u) => u.id == userId);
    await _saveToLocal();
    notifyListeners();
  }

  // Homework, Exam & Portal Management
  Future<void> addHomework(HomeworkModel hw) async {
    final idx = _homeworkList.indexWhere((h) => h.id == hw.id);
    if (idx >= 0) {
      _homeworkList[idx] = hw;
    } else {
      _homeworkList.insert(0, hw);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> deleteHomework(String id) async {
    _homeworkList.removeWhere((h) => h.id == id);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> toggleHomeworkStatus(String homeworkId, String studentId) async {
    final idx = _homeworkList.indexWhere((h) => h.id == homeworkId);
    if (idx >= 0) {
      final hw = _homeworkList[idx];
      final completed = List<String>.from(hw.completedStudentIds);
      if (completed.contains(studentId)) {
        completed.remove(studentId);
      } else {
        completed.add(studentId);
      }
      _homeworkList[idx] = HomeworkModel(
        id: hw.id,
        schoolId: hw.schoolId,
        academicYearId: hw.academicYearId,
        standard: hw.standard,
        division: hw.division,
        subjectCode: hw.subjectCode,
        subjectName: hw.subjectName,
        title: hw.title,
        description: hw.description,
        assignedDate: hw.assignedDate,
        dueDate: hw.dueDate,
        teacherName: hw.teacherName,
        completedStudentIds: completed,
      );
      await _saveToLocal();
      notifyListeners();
    }
  }

  Future<void> addOnlineExam(OnlineExamModel exam) async {
    final idx = _onlineExams.indexWhere((e) => e.id == exam.id);
    if (idx >= 0) {
      _onlineExams[idx] = exam;
    } else {
      _onlineExams.insert(0, exam);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> deleteOnlineExam(String id) async {
    _onlineExams.removeWhere((e) => e.id == id);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> submitExamResult(ExamResultModel result) async {
    final idx = _examResults.indexWhere(
      (r) =>
          r.id == result.id ||
          (r.examId == result.examId && r.studentId == result.studentId),
    );
    if (idx >= 0) {
      _examResults[idx] = result;
    } else {
      _examResults.insert(0, result);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> deleteExamResult(String resultId) async {
    _examResults.removeWhere((r) => r.id == resultId);
    await _saveToLocal();
    notifyListeners();
  }

  // ==========================================
  // ZP Statutory Registers Management Methods
  // ==========================================

  // १. शालेय पोषण आहार (PM POSHAN / MDM)
  Future<void> addMdmDailyAttendance(MdmDailyAttendanceModel model) async {
    final idx = _mdmAttendanceList.indexWhere((m) => m.id == model.id);
    if (idx >= 0) {
      _mdmAttendanceList[idx] = model;
    } else {
      _mdmAttendanceList.insert(0, model);
    }
    // Also deduct stock automatically
    final riceStock = _mdmStockList.firstWhere(
      (s) => s.itemName.contains('तांदूळ'),
      orElse: () => MdmStockItemModel(
        id: 'stk-1',
        itemName: 'तांदूळ',
        unit: 'किलो',
        openingStock: 0,
        receivedStock: 0,
        consumedStock: 0,
      ),
    );
    final updatedRice = MdmStockItemModel(
      id: riceStock.id,
      itemName: riceStock.itemName,
      unit: riceStock.unit,
      openingStock: riceStock.openingStock,
      receivedStock: riceStock.receivedStock,
      consumedStock: riceStock.consumedStock + model.riceUsedKg,
      batchOrChallanNo: riceStock.batchOrChallanNo,
    );
    final rIdx = _mdmStockList.indexWhere((s) => s.id == riceStock.id);
    if (rIdx >= 0) _mdmStockList[rIdx] = updatedRice;

    await _saveToLocal();
    notifyListeners();
  }

  Future<void> deleteMdmDailyAttendance(String id) async {
    _mdmAttendanceList.removeWhere((m) => m.id == id);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> addOrUpdateMdmStock(MdmStockItemModel item) async {
    final idx = _mdmStockList.indexWhere((s) => s.id == item.id);
    if (idx >= 0) {
      _mdmStockList[idx] = item;
    } else {
      _mdmStockList.add(item);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> saveMdmMonthlyBill(MdmMonthlyBillModel bill) async {
    final idx = _mdmBillsList.indexWhere((b) => b.id == bill.id);
    if (idx >= 0) {
      _mdmBillsList[idx] = bill;
    } else {
      _mdmBillsList.insert(0, bill);
    }
    await _saveToLocal();
    notifyListeners();
  }

  // २. समग्र शिक्षा मोफत वाटप (Free Entitlements)
  Future<void> saveTextbookDistribution(TextbookDistributionRecord rec) async {
    final idx = _textbookDistributions.indexWhere(
      (t) => t.id == rec.id || t.studentId == rec.studentId,
    );
    if (idx >= 0) {
      _textbookDistributions[idx] = rec;
    } else {
      _textbookDistributions.add(rec);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> saveUniformDistribution(UniformDistributionRecord rec) async {
    final idx = _uniformDistributions.indexWhere(
      (u) => u.id == rec.id || u.studentId == rec.studentId,
    );
    if (idx >= 0) {
      _uniformDistributions[idx] = rec;
    } else {
      _uniformDistributions.add(rec);
    }
    await _saveToLocal();
    notifyListeners();
  }

  // ३. शाळा व्यवस्थापन समिती (SMC)
  Future<void> addOrUpdateSmcMember(SmcMemberModel member) async {
    final idx = _smcMembers.indexWhere((m) => m.id == member.id);
    if (idx >= 0) {
      _smcMembers[idx] = member;
    } else {
      _smcMembers.add(member);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> deleteSmcMember(String id) async {
    _smcMembers.removeWhere((m) => m.id == id);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> addSmcMeeting(SmcMeetingModel meeting) async {
    final idx = _smcMeetings.indexWhere((m) => m.id == meeting.id);
    if (idx >= 0) {
      _smcMeetings[idx] = meeting;
    } else {
      _smcMeetings.insert(0, meeting);
    }
    await _saveToLocal();
    notifyListeners();
  }

  // ४. मृतसाठा व ग्रंथालय (Dead Stock & Library)
  Future<void> addOrUpdateDeadStockItem(DeadStockItemModel item) async {
    final idx = _deadStockList.indexWhere((d) => d.id == item.id);
    if (idx >= 0) {
      _deadStockList[idx] = item;
    } else {
      _deadStockList.add(item);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> deleteDeadStockItem(String id) async {
    _deadStockList.removeWhere((d) => d.id == id);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> addOrUpdateLibraryBook(LibraryBookModel book) async {
    final idx = _libraryBooks.indexWhere((b) => b.id == book.id);
    if (idx >= 0) {
      _libraryBooks[idx] = book;
    } else {
      _libraryBooks.add(book);
    }
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> toggleBookIssue(
    String bookId,
    String borrower,
    bool isIssued,
  ) async {
    final idx = _libraryBooks.indexWhere((b) => b.id == bookId);
    if (idx >= 0) {
      final b = _libraryBooks[idx];
      _libraryBooks[idx] = LibraryBookModel(
        id: b.id,
        accessionNumber: b.accessionNumber,
        bookTitle: b.bookTitle,
        author: b.author,
        publisher: b.publisher,
        category: b.category,
        price: b.price,
        totalPages: b.totalPages,
        isIssued: isIssued,
        currentBorrowerName: isIssued ? borrower : '',
        issueDate: isIssued ? DateTime.now() : null,
        expectedReturnDate: isIssued
            ? DateTime.now().add(const Duration(days: 7))
            : null,
      );
      await _saveToLocal();
      notifyListeners();
    }
  }

  // ५. शिक्षक सेवा, रजा व हालचाल (Teacher Leaves & Movement)
  Future<void> addTeacherLeave(TeacherLeaveRecord record) async {
    _teacherLeaves.insert(0, record);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> addMovementRecord(MovementRegisterRecord record) async {
    _movementRecords.insert(0, record);
    await _saveToLocal();
    notifyListeners();
  }

  // ६. शासकीय आवक-जावक व आरोग्य तपासणी (Inward/Outward & Health)
  Future<void> addInwardLetter(InwardLetterRecord record) async {
    _inwardLetters.insert(0, record);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> addOutwardLetter(OutwardLetterRecord record) async {
    _outwardLetters.insert(0, record);
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> saveHealthRecord(StudentHealthRecord record) async {
    final idx = _studentHealthRecords.indexWhere(
      (h) => h.id == record.id || h.studentId == record.studentId,
    );
    if (idx >= 0) {
      _studentHealthRecords[idx] = record;
    } else {
      _studentHealthRecords.add(record);
    }
    await _saveToLocal();
    notifyListeners();
  }

  // Cloud Supabase Connection
  Future<bool> connectSupabase(String url, String anonKey) async {
    _supabaseUrl = url;
    _supabaseAnonKey = anonKey;
    final success = await SupabaseService.initialize(
      url: url,
      anonKey: anonKey,
    );
    _isCloudConnected = success;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supabase_url', url);
    await prefs.setString('supabase_anon_key', anonKey);
    notifyListeners();
    return success;
  }

  // Local Persistence
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cce_school', jsonEncode(_school.toJson()));
      await prefs.setString(
        'cce_academic_years',
        jsonEncode(_academicYears.map((y) => y.toJson()).toList()),
      );
      await prefs.setString(
        'cce_students',
        jsonEncode(_students.map((s) => s.toJson()).toList()),
      );
      await prefs.setString(
        'cce_evaluations',
        jsonEncode(_evaluations.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        'cce_notes',
        jsonEncode(_descriptiveNotes.map((n) => n.toJson()).toList()),
      );
      await prefs.setString(
        'cce_attendance',
        jsonEncode(_attendanceList.map((a) => a.toJson()).toList()),
      );
      await prefs.setString(
        'cce_leaving_certificates',
        jsonEncode(_leavingCertificates.map((l) => l.toJson()).toList()),
      );
      await prefs.setString(
        'cce_gr_extracts',
        jsonEncode(_grExtracts.map((g) => g.toJson()).toList()),
      );
      await prefs.setString(
        'cce_working_days',
        jsonEncode(_workingDays.toJson()),
      );
      await prefs.setString(
        'cce_users',
        jsonEncode(_users.map((u) => u.toJson()).toList()),
      );
      await prefs.setString(
        'cce_homework',
        jsonEncode(_homeworkList.map((h) => h.toJson()).toList()),
      );
      await prefs.setString(
        'cce_online_exams',
        jsonEncode(_onlineExams.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        'cce_exam_results',
        jsonEncode(_examResults.map((r) => r.toJson()).toList()),
      );

      // ZP Statutory Registers Persistence
      await prefs.setString(
        'zp_mdm_attendance',
        jsonEncode(_mdmAttendanceList.map((m) => m.toJson()).toList()),
      );
      await prefs.setString(
        'zp_mdm_stock',
        jsonEncode(_mdmStockList.map((s) => s.toJson()).toList()),
      );
      await prefs.setString(
        'zp_mdm_bills',
        jsonEncode(_mdmBillsList.map((b) => b.toJson()).toList()),
      );
      await prefs.setString(
        'zp_textbooks',
        jsonEncode(_textbookDistributions.map((t) => t.toJson()).toList()),
      );
      await prefs.setString(
        'zp_uniforms',
        jsonEncode(_uniformDistributions.map((u) => u.toJson()).toList()),
      );
      await prefs.setString(
        'zp_smc_members',
        jsonEncode(_smcMembers.map((m) => m.toJson()).toList()),
      );
      await prefs.setString(
        'zp_smc_meetings',
        jsonEncode(_smcMeetings.map((m) => m.toJson()).toList()),
      );
      await prefs.setString(
        'zp_dead_stock',
        jsonEncode(_deadStockList.map((d) => d.toJson()).toList()),
      );
      await prefs.setString(
        'zp_library_books',
        jsonEncode(_libraryBooks.map((l) => l.toJson()).toList()),
      );
      await prefs.setString(
        'zp_teacher_leaves',
        jsonEncode(_teacherLeaves.map((t) => t.toJson()).toList()),
      );
      await prefs.setString(
        'zp_movements',
        jsonEncode(_movementRecords.map((m) => m.toJson()).toList()),
      );
      await prefs.setString(
        'zp_inward_letters',
        jsonEncode(_inwardLetters.map((i) => i.toJson()).toList()),
      );
      await prefs.setString(
        'zp_outward_letters',
        jsonEncode(_outwardLetters.map((o) => o.toJson()).toList()),
      );
      await prefs.setString(
        'zp_health_records',
        jsonEncode(_studentHealthRecords.map((h) => h.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Local save error: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schoolStr = prefs.getString('cce_school');
      if (schoolStr != null) {
        _school = SchoolModel.fromJson(jsonDecode(schoolStr));
      }

      final yearsStr = prefs.getString('cce_academic_years');
      if (yearsStr != null) {
        final List list = jsonDecode(yearsStr);
        if (list.isNotEmpty) {
          _academicYears = list
              .map((e) => AcademicYearModel.fromJson(e))
              .toList();
        }
      }
      _ensureHistoricalYears();
      if (_academicYears.isNotEmpty) {
        _currentYear = _academicYears.firstWhere(
          (y) => y.isActive,
          orElse: () => _academicYears.first,
        );
      }

      final studentsStr = prefs.getString('cce_students');
      if (studentsStr != null) {
        final List list = jsonDecode(studentsStr);
        _students = list.map((e) => StudentModel.fromJson(e)).toList();
      }

      // Ensure students are present for active year 2025-26 if empty
      final in2025 = _students
          .where((s) => s.academicYearId == 'year-2025-26')
          .toList();
      if (in2025.isEmpty) {
        final in2024 = _students
            .where((s) => s.academicYearId == 'year-2024-25')
            .toList();
        for (var s in in2024) {
          _students.add(
            StudentModel(
              id: 'stu_${s.grNo}_2025',
              schoolId: s.schoolId,
              academicYearId: 'year-2025-26',
              standard: s.standard,
              division: s.division,
              grNo: s.grNo,
              rollNoSem1: s.rollNoSem1,
              rollNoSem2: s.rollNoSem2,
              studentNameMr: s.studentNameMr,
              studentNameEn: s.studentNameEn,
              fatherName: s.fatherName,
              motherName: s.motherName,
              gender: s.gender,
              casteCategory: s.casteCategory,
              subCaste: s.subCaste,
              dateOfBirth: s.dateOfBirth,
              birthPlace: s.birthPlace,
              taluka: s.taluka,
              district: s.district,
              address: s.address,
              uDiseNo: s.uDiseNo,
              nationality: s.nationality,
              motherTongue: s.motherTongue,
              religion: s.religion,
              caste: s.caste,
              dobWords: s.dobWords,
              previousSchool: s.previousSchool,
              admissionDate: s.admissionDate,
              remarks: s.remarks,
            ),
          );
        }
      }

      final evalStr = prefs.getString('cce_evaluations');
      if (evalStr != null) {
        final List list = jsonDecode(evalStr);
        _evaluations = list.map((e) => EvaluationModel.fromJson(e)).toList();
      }

      final notesStr = prefs.getString('cce_notes');
      if (notesStr != null) {
        final List list = jsonDecode(notesStr);
        _descriptiveNotes = list
            .map((e) => DescriptiveNoteModel.fromJson(e))
            .toList();
      }

      final attStr = prefs.getString('cce_attendance');
      if (attStr != null) {
        final List list = jsonDecode(attStr);
        _attendanceList = list.map((e) => AttendanceModel.fromJson(e)).toList();
      }

      final lcStr = prefs.getString('cce_leaving_certificates');
      if (lcStr != null) {
        final List list = jsonDecode(lcStr);
        _leavingCertificates = list
            .map((e) => LeavingCertificateModel.fromJson(e))
            .toList();
      }

      final grStr = prefs.getString('cce_gr_extracts');
      if (grStr != null) {
        final List list = jsonDecode(grStr);
        _grExtracts = list
            .map((e) => GeneralRegisterExtractModel.fromJson(e))
            .toList();
      }

      final wdStr = prefs.getString('cce_working_days');
      if (wdStr != null) {
        _workingDays = WorkingDaysModel.fromJson(jsonDecode(wdStr));
      }

      // Load Homework
      final hwStr = prefs.getString('cce_homework');
      if (hwStr != null) {
        final List list = jsonDecode(hwStr);
        _homeworkList = list.map((e) => HomeworkModel.fromJson(e)).toList();
      } else {
        _homeworkList = CurriculumRepository.getDefaultHomework();
      }

      // Load Online Exams
      final examsStr = prefs.getString('cce_online_exams');
      if (examsStr != null) {
        final List list = jsonDecode(examsStr);
        _onlineExams = list.map((e) => OnlineExamModel.fromJson(e)).toList();
      } else {
        _onlineExams = CurriculumRepository.getDefaultOnlineExams();
      }

      // Load Exam Results
      final resultsStr = prefs.getString('cce_exam_results');
      if (resultsStr != null) {
        final List list = jsonDecode(resultsStr);
        _examResults = list.map((e) => ExamResultModel.fromJson(e)).toList();
      }

      // Load ZP Statutory Registers
      final mdmAttStr = prefs.getString('zp_mdm_attendance');
      if (mdmAttStr != null) {
        final List list = jsonDecode(mdmAttStr);
        _mdmAttendanceList = list
            .map((e) => MdmDailyAttendanceModel.fromJson(e))
            .toList();
      }

      final mdmStkStr = prefs.getString('zp_mdm_stock');
      if (mdmStkStr != null) {
        final List list = jsonDecode(mdmStkStr);
        _mdmStockList = list.map((e) => MdmStockItemModel.fromJson(e)).toList();
      }

      final mdmBillsStr = prefs.getString('zp_mdm_bills');
      if (mdmBillsStr != null) {
        final List list = jsonDecode(mdmBillsStr);
        _mdmBillsList = list
            .map((e) => MdmMonthlyBillModel.fromJson(e))
            .toList();
      }

      final tbStr = prefs.getString('zp_textbooks');
      if (tbStr != null) {
        final List list = jsonDecode(tbStr);
        _textbookDistributions = list
            .map((e) => TextbookDistributionRecord.fromJson(e))
            .toList();
      }

      final uniStr = prefs.getString('zp_uniforms');
      if (uniStr != null) {
        final List list = jsonDecode(uniStr);
        _uniformDistributions = list
            .map((e) => UniformDistributionRecord.fromJson(e))
            .toList();
      }

      final smcMemStr = prefs.getString('zp_smc_members');
      if (smcMemStr != null) {
        final List list = jsonDecode(smcMemStr);
        _smcMembers = list.map((e) => SmcMemberModel.fromJson(e)).toList();
      }

      final smcMeetStr = prefs.getString('zp_smc_meetings');
      if (smcMeetStr != null) {
        final List list = jsonDecode(smcMeetStr);
        _smcMeetings = list.map((e) => SmcMeetingModel.fromJson(e)).toList();
      }

      final dsStr = prefs.getString('zp_dead_stock');
      if (dsStr != null) {
        final List list = jsonDecode(dsStr);
        _deadStockList = list
            .map((e) => DeadStockItemModel.fromJson(e))
            .toList();
      }

      final libStr = prefs.getString('zp_library_books');
      if (libStr != null) {
        final List list = jsonDecode(libStr);
        _libraryBooks = list.map((e) => LibraryBookModel.fromJson(e)).toList();
      }

      final tlStr = prefs.getString('zp_teacher_leaves');
      if (tlStr != null) {
        final List list = jsonDecode(tlStr);
        _teacherLeaves = list
            .map((e) => TeacherLeaveRecord.fromJson(e))
            .toList();
      }

      final movStr = prefs.getString('zp_movements');
      if (movStr != null) {
        final List list = jsonDecode(movStr);
        _movementRecords = list
            .map((e) => MovementRegisterRecord.fromJson(e))
            .toList();
      }

      final inStr = prefs.getString('zp_inward_letters');
      if (inStr != null) {
        final List list = jsonDecode(inStr);
        _inwardLetters = list
            .map((e) => InwardLetterRecord.fromJson(e))
            .toList();
      }

      final outStr = prefs.getString('zp_outward_letters');
      if (outStr != null) {
        final List list = jsonDecode(outStr);
        _outwardLetters = list
            .map((e) => OutwardLetterRecord.fromJson(e))
            .toList();
      }

      final hlthStr = prefs.getString('zp_health_records');
      if (hlthStr != null) {
        final List list = jsonDecode(hlthStr);
        _studentHealthRecords = list
            .map((e) => StudentHealthRecord.fromJson(e))
            .toList();
      }

      // Load Users & Class Allocations
      final usersStr = prefs.getString('cce_users');
      if (usersStr != null) {
        final List list = jsonDecode(usersStr);
        _users = list.map((e) => UserModel.fromJson(e)).toList();
      }
      _ensureDefaultUsers();

      // Always start fresh on the Login Screen every time the app opens
      if (_currentUser == null) {
        _currentStudent = null;
      }
      await prefs.remove('cce_logged_in_user_id');
      await prefs.remove('cce_logged_in_student_id');

      _supabaseUrl = prefs.getString('supabase_url') ?? '';
      _supabaseAnonKey = prefs.getString('supabase_anon_key') ?? '';
      if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
        connectSupabase(_supabaseUrl, _supabaseAnonKey);
      }
    } catch (e) {
      debugPrint('Local load error: $e');
    }
  }
}
