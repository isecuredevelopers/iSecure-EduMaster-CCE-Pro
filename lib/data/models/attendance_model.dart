class AttendanceModel {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String studentId;
  final int standard;
  final String division;

  int jun;
  int jul;
  int aug;
  int sep;
  int oct;
  int nov;
  int dec;
  int jan;
  int feb;
  int mar;
  int apr;

  AttendanceModel({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.studentId,
    required this.standard,
    required this.division,
    this.jun = 0,
    this.jul = 0,
    this.aug = 0,
    this.sep = 0,
    this.oct = 0,
    this.nov = 0,
    this.dec = 0,
    this.jan = 0,
    this.feb = 0,
    this.mar = 0,
    this.apr = 0,
  });

  int get sem1Total => jun + jul + aug + sep + oct;
  int get sem2Total => nov + dec + jan + feb + mar + apr;
  int get grandTotal => sem1Total + sem2Total;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'academic_year_id': academicYearId,
      'student_id': studentId,
      'standard': standard,
      'division': division,
      'jun_days': jun,
      'jul_days': jul,
      'aug_days': aug,
      'sep_days': sep,
      'oct_days': oct,
      'nov_days': nov,
      'dec_days': dec,
      'jan_days': jan,
      'feb_days': feb,
      'mar_days': mar,
      'apr_days': apr,
      'sem1_total': sem1Total,
      'sem2_total': sem2Total,
      'grand_total': grandTotal,
    };
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? json['PresentyID']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '1',
      academicYearId: json['academic_year_id']?.toString() ?? json['YearID']?.toString() ?? '1',
      studentId: json['student_id']?.toString() ?? json['StudentID']?.toString() ?? '',
      standard: int.tryParse(json['standard']?.toString() ?? json['Std']?.toString() ?? '1') ?? 1,
      division: json['division']?.toString() ?? json['Div']?.toString() ?? '1',
      jun: int.tryParse(json['jun_days']?.toString() ?? json['Jun_']?.toString() ?? '0') ?? 0,
      jul: int.tryParse(json['jul_days']?.toString() ?? json['Jul_']?.toString() ?? '0') ?? 0,
      aug: int.tryParse(json['aug_days']?.toString() ?? json['Aug_']?.toString() ?? '0') ?? 0,
      sep: int.tryParse(json['sep_days']?.toString() ?? json['Sep_']?.toString() ?? '0') ?? 0,
      oct: int.tryParse(json['oct_days']?.toString() ?? json['Oct_']?.toString() ?? '0') ?? 0,
      nov: int.tryParse(json['nov_days']?.toString() ?? json['Nov_']?.toString() ?? '0') ?? 0,
      dec: int.tryParse(json['dec_days']?.toString() ?? json['Dec_']?.toString() ?? '0') ?? 0,
      jan: int.tryParse(json['jan_days']?.toString() ?? json['Jan_']?.toString() ?? '0') ?? 0,
      feb: int.tryParse(json['feb_days']?.toString() ?? json['Feb_']?.toString() ?? '0') ?? 0,
      mar: int.tryParse(json['mar_days']?.toString() ?? json['Mar_']?.toString() ?? '0') ?? 0,
      apr: int.tryParse(json['apr_days']?.toString() ?? json['Apr_']?.toString() ?? '0') ?? 0,
    );
  }
}
