class HomeworkModel {
  final String id;
  final String schoolId;
  final String academicYearId;
  final int standard;
  final String division;
  final String subjectCode;
  final String subjectName;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String teacherName;
  final List<String> completedStudentIds;

  HomeworkModel({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.standard,
    required this.division,
    required this.subjectCode,
    required this.subjectName,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.dueDate,
    this.teacherName = 'वर्गशिक्षक',
    List<String>? completedStudentIds,
  }) : completedStudentIds = completedStudentIds ?? [];

  bool isCompletedBy(String studentId) => completedStudentIds.contains(studentId);

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  Map<String, dynamic> toJson() => {
        'id': id,
        'schoolId': schoolId,
        'academicYearId': academicYearId,
        'standard': standard,
        'division': division,
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'title': title,
        'description': description,
        'assignedDate': assignedDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'teacherName': teacherName,
        'completedStudentIds': completedStudentIds,
      };

  factory HomeworkModel.fromJson(Map<String, dynamic> json) => HomeworkModel(
        id: json['id']?.toString() ?? '',
        schoolId: json['schoolId']?.toString() ?? '',
        academicYearId: json['academicYearId']?.toString() ?? '',
        standard: int.tryParse(json['standard']?.toString() ?? '1') ?? 1,
        division: json['division']?.toString() ?? '1',
        subjectCode: json['subjectCode']?.toString() ?? '',
        subjectName: json['subjectName']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        assignedDate: json['assignedDate'] != null
            ? DateTime.tryParse(json['assignedDate'].toString()) ?? DateTime.now()
            : DateTime.now(),
        dueDate: json['dueDate'] != null
            ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now().add(const Duration(days: 2))
            : DateTime.now().add(const Duration(days: 2)),
        teacherName: json['teacherName']?.toString() ?? 'वर्गशिक्षक',
        completedStudentIds: (json['completedStudentIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
