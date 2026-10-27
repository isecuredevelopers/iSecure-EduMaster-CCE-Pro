class SubjectModel {
  final String id;
  final String schoolId;
  final String subjectCode; // 's1', 's2' .. 's9'
  String subjectNameMr;
  String subjectNameEn;
  String shortName;
  List<int> applicableStandards;
  int formativeMax;
  int summativeMax;
  bool isGradedOnly;
  int orderIndex;

  SubjectModel({
    required this.id,
    required this.schoolId,
    required this.subjectCode,
    required this.subjectNameMr,
    required this.subjectNameEn,
    required this.shortName,
    required this.applicableStandards,
    this.formativeMax = 70,
    this.summativeMax = 30,
    this.isGradedOnly = false,
    this.orderIndex = 1,
  });

  int get totalMax => formativeMax + summativeMax;

  bool isApplicableForStd(int std) => applicableStandards.contains(std);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'subject_code': subjectCode,
      'subject_name_mr': subjectNameMr,
      'subject_name_en': subjectNameEn,
      'short_name': shortName,
      'applicable_standards': applicableStandards,
      'formative_max': formativeMax,
      'summative_max': summativeMax,
      'is_graded_only': isGradedOnly,
      'order_index': orderIndex,
    };
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    List<int> stds = [1, 2, 3, 4, 5, 6, 7, 8];
    if (json['applicable_standards'] is List) {
      stds = (json['applicable_standards'] as List).map((e) => int.tryParse(e.toString()) ?? 1).toList();
    }
    return SubjectModel(
      id: json['id']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      subjectNameMr: json['subject_name_mr']?.toString() ?? '',
      subjectNameEn: json['subject_name_en']?.toString() ?? '',
      shortName: json['short_name']?.toString() ?? '',
      applicableStandards: stds,
      formativeMax: json['formative_max'] is int ? json['formative_max'] : 70,
      summativeMax: json['summative_max'] is int ? json['summative_max'] : 30,
      isGradedOnly: json['is_graded_only'] == true,
      orderIndex: json['order_index'] is int ? json['order_index'] : 1,
    );
  }
}
