class WorkingDaysModel {
  final String id;
  final String schoolId;
  final String academicYearId;
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

  WorkingDaysModel({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.standard,
    required this.division,
    this.jun = 12,
    this.jul = 24,
    this.aug = 23,
    this.sep = 22,
    this.oct = 18,
    this.nov = 19,
    this.dec = 24,
    this.jan = 24,
    this.feb = 22,
    this.mar = 24,
    this.apr = 20,
  });

  int get sem1Total => jun + jul + aug + sep + oct;
  int get sem2Total => nov + dec + jan + feb + mar + apr;
  int get grandTotal => sem1Total + sem2Total;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'academic_year_id': academicYearId,
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

  factory WorkingDaysModel.fromJson(Map<String, dynamic> json) {
    return WorkingDaysModel(
      id: json['id']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '1',
      academicYearId: json['academic_year_id']?.toString() ?? '1',
      standard: int.tryParse(json['standard']?.toString() ?? '1') ?? 1,
      division: json['division']?.toString() ?? '1',
      jun: int.tryParse(json['jun_days']?.toString() ?? '12') ?? 12,
      jul: int.tryParse(json['jul_days']?.toString() ?? '24') ?? 24,
      aug: int.tryParse(json['aug_days']?.toString() ?? '23') ?? 23,
      sep: int.tryParse(json['sep_days']?.toString() ?? '22') ?? 22,
      oct: int.tryParse(json['oct_days']?.toString() ?? '18') ?? 18,
      nov: int.tryParse(json['nov_days']?.toString() ?? '19') ?? 19,
      dec: int.tryParse(json['dec_days']?.toString() ?? '24') ?? 24,
      jan: int.tryParse(json['jan_days']?.toString() ?? '24') ?? 24,
      feb: int.tryParse(json['feb_days']?.toString() ?? '22') ?? 22,
      mar: int.tryParse(json['mar_days']?.toString() ?? '24') ?? 24,
      apr: int.tryParse(json['apr_days']?.toString() ?? '20') ?? 20,
    );
  }
}

class GradingScaleModel {
  final String id;
  String gradeName;
  double minMarks;
  double maxMarks;
  String description;

  GradingScaleModel({
    required this.id,
    required this.gradeName,
    required this.minMarks,
    required this.maxMarks,
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade_name': gradeName,
      'min_marks': minMarks,
      'max_marks': maxMarks,
      'description': description,
    };
  }

  factory GradingScaleModel.fromJson(Map<String, dynamic> json) {
    return GradingScaleModel(
      id: json['id']?.toString() ?? '',
      gradeName: json['grade_name']?.toString() ?? json['gradeText']?.toString() ?? '',
      minMarks: double.tryParse(json['min_marks']?.toString() ?? json['marks']?.toString() ?? '0') ?? 0,
      maxMarks: double.tryParse(json['max_marks']?.toString() ?? '100') ?? 100,
      description: json['description']?.toString() ?? '',
    );
  }
}
