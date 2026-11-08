class GeneralRegisterExtractModel {
  final String id;
  final String studentId;
  String generalRegNo;
  String uDiseNo;
  String studentName;
  String motherName;
  String caste;
  String subCaste;
  String birthPlace;
  DateTime dob;
  String dobWords;
  String previousSchool;
  DateTime? admissionDate;
  String admissionClass;
  String progress;
  String conduct;
  DateTime? leavingDate;
  String currentClass;
  String reasonForLeaving;
  String remarks;
  DateTime issueDate;
  String copyType; // 'Original' ('मूळ प्रत') or 'Duplicate' ('द्वितीय प्रत')
  bool isCurrentlyStudying;

  GeneralRegisterExtractModel({
    required this.id,
    required this.studentId,
    this.generalRegNo = '',
    this.uDiseNo = '',
    this.studentName = '',
    this.motherName = '',
    this.caste = '',
    this.subCaste = '',
    this.birthPlace = '',
    required this.dob,
    this.dobWords = '',
    this.previousSchool = '',
    this.admissionDate,
    this.admissionClass = '',
    this.progress = 'चांगली',
    this.conduct = 'चांगली',
    this.leavingDate,
    this.currentClass = '',
    this.reasonForLeaving = '-',
    this.remarks = '',
    required this.issueDate,
    this.copyType = 'Original',
    this.isCurrentlyStudying = false,
  });

  String get copyTypeTextMr => copyType == 'Duplicate' ? 'द्वितीय प्रत' : 'मूळ प्रत';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'general_reg_no': generalRegNo,
      'u_dise_no': uDiseNo,
      'student_name': studentName,
      'mother_name': motherName,
      'caste': caste,
      'sub_caste': subCaste,
      'birth_place': birthPlace,
      'dob': dob.toIso8601String(),
      'dob_words': dobWords,
      'previous_school': previousSchool,
      'admission_date': admissionDate?.toIso8601String(),
      'admission_class': admissionClass,
      'progress': progress,
      'conduct': conduct,
      'leaving_date': leavingDate?.toIso8601String(),
      'current_class': currentClass,
      'reason_for_leaving': reasonForLeaving,
      'remarks': remarks,
      'issue_date': issueDate.toIso8601String(),
      'copy_type': copyType,
      'is_currently_studying': isCurrentlyStudying,
    };
  }

  factory GeneralRegisterExtractModel.fromJson(Map<String, dynamic> json) {
    DateTime dob = DateTime.now().subtract(const Duration(days: 365 * 10));
    if (json['dob'] != null) {
      dob = DateTime.tryParse(json['dob'].toString()) ?? dob;
    }

    DateTime issueDate = DateTime.now();
    if (json['issue_date'] != null) {
      issueDate = DateTime.tryParse(json['issue_date'].toString()) ?? issueDate;
    }

    DateTime? admissionDate;
    if (json['admission_date'] != null) {
      admissionDate = DateTime.tryParse(json['admission_date'].toString());
    }

    DateTime? leavingDate;
    if (json['leaving_date'] != null) {
      leavingDate = DateTime.tryParse(json['leaving_date'].toString());
    }

    return GeneralRegisterExtractModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      generalRegNo: json['general_reg_no']?.toString() ?? '',
      uDiseNo: json['u_dise_no']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      caste: json['caste']?.toString() ?? '',
      subCaste: json['sub_caste']?.toString() ?? '',
      birthPlace: json['birth_place']?.toString() ?? '',
      dob: dob,
      dobWords: json['dob_words']?.toString() ?? '',
      previousSchool: json['previous_school']?.toString() ?? '',
      admissionDate: admissionDate,
      admissionClass: json['admission_class']?.toString() ?? '',
      progress: json['progress']?.toString() ?? 'चांगली',
      conduct: json['conduct']?.toString() ?? 'चांगली',
      leavingDate: leavingDate,
      currentClass: json['current_class']?.toString() ?? '',
      reasonForLeaving: json['reason_for_leaving']?.toString() ?? '-',
      remarks: json['remarks']?.toString() ?? '',
      issueDate: issueDate,
      copyType: json['copy_type']?.toString() ?? 'Original',
      isCurrentlyStudying: json['is_currently_studying'] == true,
    );
  }
}

