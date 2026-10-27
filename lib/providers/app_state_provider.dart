import 'dart:convert';
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
import '../data/local/sample_data.dart';
import '../data/supabase/supabase_service.dart';
import '../core/services/app_update_service.dart';

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
  late WorkingDaysModel _workingDays;
  List<GradingScaleModel> _gradingScales = [];
  Map<String, List<String>> _remarksBank = {};

  String _supabaseUrl = '';
  String _supabaseAnonKey = '';
  bool _isCloudConnected = false;
  bool _isLoading = true;

  AppUpdateInfo? _availableUpdate;
  bool _isCheckingUpdate = false;

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
  WorkingDaysModel get workingDays => _workingDays;
  List<GradingScaleModel> get gradingScales => _gradingScales;
  Map<String, List<String>> get remarksBank => _remarksBank;
  String get supabaseUrl => _supabaseUrl;
  String get supabaseAnonKey => _supabaseAnonKey;
  bool get isCloudConnected => _isCloudConnected;
  bool get isLoading => _isLoading;
  AppUpdateInfo? get availableUpdate => _availableUpdate;
  bool get isCheckingUpdate => _isCheckingUpdate;

  List<int> get availableStandards => [1, 2, 3, 4, 5, 6, 7, 8];
  List<String> get availableDivisions => ['1', '2', '3', 'A', 'B', 'C'];

  List<SubjectModel> get currentStdSubjects =>
      _subjects.where((s) => s.isApplicableForStd(_selectedStd)).toList();

  List<StudentModel> get filteredStudents => _students.where((s) {
        return s.standard == _selectedStd &&
            s.division == _selectedDiv &&
            s.academicYearId == _currentYear.id;
      }).toList()
        ..sort((a, b) => a.getRollNo(_selectedSemester).compareTo(b.getRollNo(_selectedSemester)));

  AppStateProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    _school = SampleData.defaultSchool;
    _academicYears = SampleData.defaultYears;
    _currentYear = _academicYears.firstWhere((y) => y.isActive, orElse: () => _academicYears.first);
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

    await _loadFromLocal();

    _isLoading = false;
    notifyListeners();

    // Check online update from GitHub in background
    Future.delayed(const Duration(seconds: 3), () {
      checkForUpdate(silent: true);
    });
  }

  // Online GitHub Auto-Update Check
  Future<AppUpdateInfo?> checkForUpdate({bool silent = false}) async {
    _isCheckingUpdate = true;
    notifyListeners();
    try {
      final info = await AppUpdateService.checkForUpdate();
      _availableUpdate = info;
      _isCheckingUpdate = false;
      notifyListeners();
      return info;
    } catch (e) {
      debugPrint('Check for update error: $e');
      _isCheckingUpdate = false;
      notifyListeners();
      return null;
    }
  }

  // Setters & Actions
  void setStandard(int std) {
    _selectedStd = std;
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
      final evalExists = _evaluations.any((e) =>
          e.studentId == stu.id &&
          e.semester == _selectedSemester &&
          e.subjectCode == _selectedSubject.subjectCode);
      if (!evalExists) {
        _evaluations.add(EvaluationModel(
          id: '${stu.id}_${_selectedSemester}_${_selectedSubject.subjectCode}',
          schoolId: _school.id,
          academicYearId: _currentYear.id,
          studentId: stu.id,
          standard: _selectedStd,
          division: _selectedDiv,
          semester: _selectedSemester,
          subjectCode: _selectedSubject.subjectCode,
        ));
      }

      // Ensure descriptive note exists
      final noteExists = _descriptiveNotes.any((n) =>
          n.studentId == stu.id && n.semester == _selectedSemester);
      if (!noteExists) {
        _descriptiveNotes.add(DescriptiveNoteModel(
          id: 'note_${stu.id}_$_selectedSemester',
          schoolId: _school.id,
          academicYearId: _currentYear.id,
          studentId: stu.id,
          standard: _selectedStd,
          division: _selectedDiv,
          semester: _selectedSemester,
        ));
      }

      // Ensure attendance exists
      final attExists = _attendanceList.any((a) => a.studentId == stu.id);
      if (!attExists) {
        _attendanceList.add(AttendanceModel(
          id: 'att_${stu.id}',
          schoolId: _school.id,
          academicYearId: _currentYear.id,
          studentId: stu.id,
          standard: _selectedStd,
          division: _selectedDiv,
        ));
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
  Future<void> addOrUpdateStudent(StudentModel stu) async {
    final idx = _students.indexWhere((s) => s.id == stu.id);
    if (idx >= 0) {
      _students[idx] = stu;
    } else {
      _students.add(stu);
    }
    _ensureRecordsForCurrentSelection();
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
  EvaluationModel getOrCreateEvaluation(String studentId, int sem, String subjectCode) {
    final found = _evaluations.firstWhere(
      (e) => e.studentId == studentId && e.semester == sem && e.subjectCode == subjectCode,
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

  // Working Days Update
  Future<void> updateWorkingDays(WorkingDaysModel wd) async {
    _workingDays = wd;
    await _saveToLocal();
    notifyListeners();
  }

  // Academic Year Management
  Future<void> addNewAcademicYear(String yearName) async {
    if (yearName.trim().isEmpty) return;
    final newId = 'year-${yearName.replaceAll(' ', '').replaceAll('/', '-')}_${DateTime.now().millisecondsSinceEpoch}';
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
  Future<void> updateSubjectWeightage(String subjectCode, int formativeMax, int summativeMax) async {
    final idx = _subjects.indexWhere((s) => s.subjectCode == subjectCode);
    if (idx >= 0) {
      _subjects[idx].formativeMax = formativeMax;
      _subjects[idx].summativeMax = summativeMax;
      await _saveToLocal();
      notifyListeners();
    }
  }

  // Grading Scales Update
  Future<void> updateGradingScale(String gradeId, double minMarks, double maxMarks) async {
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
        _descriptiveNotes = list.map((e) => DescriptiveNoteModel.fromJson(e)).toList();
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
        _academicYears = list.map((e) => AcademicYearModel.fromJson(e)).toList();
        if (_academicYears.isNotEmpty) {
          _currentYear = _academicYears.firstWhere((y) => y.isActive, orElse: () => _academicYears.first);
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
  Future<void> resetDataForNewSchool({required String newSchoolName, required String newSansthaName}) async {
    _students.clear();
    _evaluations.clear();
    _descriptiveNotes.clear();
    _attendanceList.clear();

    _school = _school.copyWith(
      schoolName: newSchoolName.trim().isNotEmpty ? newSchoolName.trim() : 'नवीन प्राथमिक शाळा',
      sansthaName: newSansthaName.trim().isNotEmpty ? newSansthaName.trim() : 'शिक्षण प्रसारक संस्था',
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
  Future<int> promoteStudents({required int fromStd, required int toStd, required String nextYearId}) async {
    int promotedCount = 0;
    final toPromote = _students.where((s) => s.standard == fromStd && s.academicYearId == _currentYear.id).toList();
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
        isPromoted: true,
      );
      _students.add(promoted);
      promotedCount++;
    }
    await _saveToLocal();
    notifyListeners();
    return promotedCount;
  }

  // Cloud Supabase Connection
  Future<bool> connectSupabase(String url, String anonKey) async {
    _supabaseUrl = url;
    _supabaseAnonKey = anonKey;
    final success = await SupabaseService.initialize(url: url, anonKey: anonKey);
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
      await prefs.setString('cce_students', jsonEncode(_students.map((s) => s.toJson()).toList()));
      await prefs.setString('cce_evaluations', jsonEncode(_evaluations.map((e) => e.toJson()).toList()));
      await prefs.setString('cce_notes', jsonEncode(_descriptiveNotes.map((n) => n.toJson()).toList()));
      await prefs.setString('cce_attendance', jsonEncode(_attendanceList.map((a) => a.toJson()).toList()));
      await prefs.setString('cce_working_days', jsonEncode(_workingDays.toJson()));
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

      final studentsStr = prefs.getString('cce_students');
      if (studentsStr != null) {
        final List list = jsonDecode(studentsStr);
        _students = list.map((e) => StudentModel.fromJson(e)).toList();
      }

      final evalStr = prefs.getString('cce_evaluations');
      if (evalStr != null) {
        final List list = jsonDecode(evalStr);
        _evaluations = list.map((e) => EvaluationModel.fromJson(e)).toList();
      }

      final notesStr = prefs.getString('cce_notes');
      if (notesStr != null) {
        final List list = jsonDecode(notesStr);
        _descriptiveNotes = list.map((e) => DescriptiveNoteModel.fromJson(e)).toList();
      }

      final attStr = prefs.getString('cce_attendance');
      if (attStr != null) {
        final List list = jsonDecode(attStr);
        _attendanceList = list.map((e) => AttendanceModel.fromJson(e)).toList();
      }

      final wdStr = prefs.getString('cce_working_days');
      if (wdStr != null) {
        _workingDays = WorkingDaysModel.fromJson(jsonDecode(wdStr));
      }

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
