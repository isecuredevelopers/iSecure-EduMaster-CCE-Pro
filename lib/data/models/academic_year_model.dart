class AcademicYearModel {
  final String id;
  final String schoolId;
  String yearName; // e.g. "2024-25"
  DateTime? startDate;
  DateTime? endDate;
  DateTime? sem1ResultDate;
  DateTime? sem2ResultDate;
  DateTime? reopeningDate;
  String reopeningMessage;
  bool isActive;

  AcademicYearModel({
    required this.id,
    required this.schoolId,
    required this.yearName,
    this.startDate,
    this.endDate,
    this.sem1ResultDate,
    this.sem2ResultDate,
    this.reopeningDate,
    this.reopeningMessage = 'उन्हाळी सुट्टीनंतर शाळा दिनांक १५ जून रोजी सुरु होईल.',
    this.isActive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'year_name': yearName,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'sem1_result_date': sem1ResultDate?.toIso8601String(),
      'sem2_result_date': sem2ResultDate?.toIso8601String(),
      'reopening_date': reopeningDate?.toIso8601String(),
      'reopening_message': reopeningMessage,
      'is_active': isActive,
    };
  }

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json['id']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '',
      yearName: json['year_name']?.toString() ?? '',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      sem1ResultDate: json['sem1_result_date'] != null ? DateTime.tryParse(json['sem1_result_date']) : null,
      sem2ResultDate: json['sem2_result_date'] != null ? DateTime.tryParse(json['sem2_result_date']) : null,
      reopeningDate: json['reopening_date'] != null ? DateTime.tryParse(json['reopening_date']) : null,
      reopeningMessage: json['reopening_message']?.toString() ?? 'उन्हाळी सुट्टीनंतर शाळा दिनांक १५ जून रोजी सुरु होईल.',
      isActive: json['is_active'] == true,
    );
  }
}
