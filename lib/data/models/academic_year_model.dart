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

  /// मागील ६०+ शैक्षणिक वर्षे तयार करण्यासाठी उपयुक्त पद्धत (१९६५ ते २०२५)
  static List<AcademicYearModel> generate60PlusYears({
    String schoolId = 'school-01',
    int startYear = 1965,
    int endYear = 2025,
    String activeYearName = '2025-26',
  }) {
    final List<AcademicYearModel> list = [];
    for (int y = endYear; y >= startYear; y--) {
      final nextYMod = (y + 1) % 100;
      final nextYStr = nextYMod.toString().padLeft(2, '0');
      final yearName = '$y-$nextYStr';
      final id = 'year-$yearName';
      final isActive = (yearName == activeYearName);
      list.add(AcademicYearModel(
        id: id,
        schoolId: schoolId,
        yearName: yearName,
        startDate: DateTime(y, 6, 15),
        endDate: DateTime(y + 1, 5, 1),
        sem1ResultDate: DateTime(y, 10, 25),
        sem2ResultDate: DateTime(y + 1, 4, 30),
        reopeningDate: DateTime(y + 1, 6, 15),
        reopeningMessage: 'उन्हाळी सुट्टीनंतर शाळा दिनांक १५ जून रोजी सुरू होईल.',
        isActive: isActive,
      ));
    }
    return list;
  }
}
