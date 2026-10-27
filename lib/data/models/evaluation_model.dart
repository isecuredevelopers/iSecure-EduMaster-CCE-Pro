class EvaluationModel {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String studentId;
  final int standard;
  final String division;
  final int semester; // 1 or 2
  final String subjectCode; // 's1' to 's9'

  // Formative evaluation tools (आकारिक मूल्यमापन)
  double fe1; // दैनंदिन निरीक्षण
  double fe2; // तोंडी काम
  double fe3; // प्रात्यक्षिके / प्रयोग
  double fe4; // उपक्रम / कृती
  double fe5; // प्रकल्प
  double fe6; // चाचणी (लेखी)
  double fe7; // स्वाध्याय / वर्गकार्य
  double fe8; // इतर
  double fet; // Formative Total

  // Summative evaluation tools (संकलित मूल्यमापन)
  double se1; // तोंडी
  double se2; // प्रात्यक्षिक
  double se3; // लेखी
  double set; // Summative Total

  // Computed Totals
  double tet; // Total Evaluation Marks (FET + SET)
  double percentage;
  String grade; // 'अ-1', 'अ-2', etc.
  double graceMarks;

  EvaluationModel({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.studentId,
    required this.standard,
    required this.division,
    required this.semester,
    required this.subjectCode,
    this.fe1 = 0,
    this.fe2 = 0,
    this.fe3 = 0,
    this.fe4 = 0,
    this.fe5 = 0,
    this.fe6 = 0,
    this.fe7 = 0,
    this.fe8 = 0,
    this.fet = 0,
    this.se1 = 0,
    this.se2 = 0,
    this.se3 = 0,
    this.set = 0,
    this.tet = 0,
    this.percentage = 0,
    this.grade = 'ब-1',
    this.graceMarks = 0,
  });

  void recalculate(int formativeMax, int summativeMax) {
    fet = fe1 + fe2 + fe3 + fe4 + fe5 + fe6 + fe7 + fe8;
    set = se1 + se2 + se3;
    tet = fet + set + graceMarks;

    final totalMax = formativeMax + summativeMax;
    percentage = totalMax > 0 ? (tet / totalMax) * 100 : 0;
    if (percentage > 100) percentage = 100;

    // Grade assignment
    if (percentage >= 91) {
      grade = 'अ-1';
    } else if (percentage >= 81) {
      grade = 'अ-2';
    } else if (percentage >= 71) {
      grade = 'ब-1';
    } else if (percentage >= 61) {
      grade = 'ब-2';
    } else if (percentage >= 51) {
      grade = 'क-1';
    } else if (percentage >= 41) {
      grade = 'क-2';
    } else if (percentage >= 33) {
      grade = 'ड';
    } else if (percentage >= 21) {
      grade = 'ई-1';
    } else {
      grade = 'ई-2';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'academic_year_id': academicYearId,
      'student_id': studentId,
      'standard': standard,
      'division': division,
      'semester': semester,
      'subject_code': subjectCode,
      'fe1': fe1,
      'fe2': fe2,
      'fe3': fe3,
      'fe4': fe4,
      'fe5': fe5,
      'fe6': fe6,
      'fe7': fe7,
      'fe8': fe8,
      'fet': fet,
      'se1': se1,
      'se2': se2,
      'se3': se3,
      'set': set,
      'tet': tet,
      'percentage': percentage,
      'grade': grade,
      'grace_marks': graceMarks,
    };
  }

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: json['id']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '1',
      academicYearId: json['academic_year_id']?.toString() ?? json['YearID']?.toString() ?? '1',
      studentId: json['student_id']?.toString() ?? json['StudentID']?.toString() ?? '',
      standard: int.tryParse(json['standard']?.toString() ?? json['Std']?.toString() ?? '1') ?? 1,
      division: json['division']?.toString() ?? json['Div']?.toString() ?? '1',
      semester: int.tryParse(json['semester']?.toString() ?? json['Semister']?.toString() ?? '1') ?? 1,
      subjectCode: json['subject_code']?.toString() ?? 's${json['SubjectID']?.toString() ?? '1'}',
      fe1: double.tryParse(json['fe1']?.toString() ?? json['FE1']?.toString() ?? '0') ?? 0,
      fe2: double.tryParse(json['fe2']?.toString() ?? json['FE2']?.toString() ?? '0') ?? 0,
      fe3: double.tryParse(json['fe3']?.toString() ?? json['FE3']?.toString() ?? '0') ?? 0,
      fe4: double.tryParse(json['fe4']?.toString() ?? json['FE4']?.toString() ?? '0') ?? 0,
      fe5: double.tryParse(json['fe5']?.toString() ?? json['FE5']?.toString() ?? '0') ?? 0,
      fe6: double.tryParse(json['fe6']?.toString() ?? json['FE6']?.toString() ?? '0') ?? 0,
      fe7: double.tryParse(json['fe7']?.toString() ?? json['FE7']?.toString() ?? '0') ?? 0,
      fe8: double.tryParse(json['fe8']?.toString() ?? json['FE8']?.toString() ?? '0') ?? 0,
      fet: double.tryParse(json['fet']?.toString() ?? json['FET']?.toString() ?? '0') ?? 0,
      se1: double.tryParse(json['se1']?.toString() ?? json['SE1']?.toString() ?? '0') ?? 0,
      se2: double.tryParse(json['se2']?.toString() ?? json['SE2']?.toString() ?? '0') ?? 0,
      se3: double.tryParse(json['se3']?.toString() ?? json['SE3']?.toString() ?? '0') ?? 0,
      set: double.tryParse(json['set']?.toString() ?? json['SET']?.toString() ?? '0') ?? 0,
      tet: double.tryParse(json['tet']?.toString() ?? json['TET']?.toString() ?? '0') ?? 0,
      percentage: double.tryParse(json['percentage']?.toString() ?? json['Cent']?.toString() ?? '0') ?? 0,
      grade: json['grade']?.toString() ?? 'ब-1',
      graceMarks: double.tryParse(json['grace_marks']?.toString() ?? json['ExMark']?.toString() ?? '0') ?? 0,
    );
  }
}
