class LeavingCertificateModel {
  final String id;
  final String studentId;
  String lcNo;
  String generalRegNo;
  String uDiseNo;
  String studentSaralId;
  String uidNo;
  String studentName;
  String motherName;
  String nationality;
  String motherTongue;
  String religion;
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
  DateTime leavingDate;
  String currentClass;
  String reasonForLeaving;
  String remarks;
  DateTime issueDate;
  int copyCount;
  String copyType; // 'Original' or 'Duplicate'
  bool isIssued;

  LeavingCertificateModel({
    required this.id,
    required this.studentId,
    this.lcNo = '',
    this.generalRegNo = '',
    this.uDiseNo = '',
    this.studentSaralId = '',
    this.uidNo = '',
    this.studentName = '',
    this.motherName = '',
    this.nationality = 'भारतीय',
    this.motherTongue = 'मराठी',
    this.religion = '',
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
    required this.leavingDate,
    this.currentClass = '',
    this.reasonForLeaving = 'पुढील शिक्षणासाठी',
    this.remarks = '',
    required this.issueDate,
    this.copyCount = 1,
    this.copyType = 'Original',
    this.isIssued = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'lc_no': lcNo,
      'general_reg_no': generalRegNo,
      'u_dise_no': uDiseNo,
      'student_saral_id': studentSaralId,
      'uid_no': uidNo,
      'student_name': studentName,
      'mother_name': motherName,
      'nationality': nationality,
      'mother_tongue': motherTongue,
      'religion': religion,
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
      'leaving_date': leavingDate.toIso8601String(),
      'current_class': currentClass,
      'reason_for_leaving': reasonForLeaving,
      'remarks': remarks,
      'issue_date': issueDate.toIso8601String(),
      'copy_count': copyCount,
      'copy_type': copyType,
      'is_issued': isIssued,
    };
  }

  factory LeavingCertificateModel.fromJson(Map<String, dynamic> json) {
    DateTime dob = DateTime.now().subtract(const Duration(days: 365 * 10));
    if (json['dob'] != null) {
      dob = DateTime.tryParse(json['dob'].toString()) ?? dob;
    }

    DateTime leavingDate = DateTime.now();
    if (json['leaving_date'] != null) {
      leavingDate = DateTime.tryParse(json['leaving_date'].toString()) ?? leavingDate;
    }

    DateTime issueDate = DateTime.now();
    if (json['issue_date'] != null) {
      issueDate = DateTime.tryParse(json['issue_date'].toString()) ?? issueDate;
    }

    DateTime? admissionDate;
    if (json['admission_date'] != null) {
      admissionDate = DateTime.tryParse(json['admission_date'].toString());
    }

    return LeavingCertificateModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      lcNo: json['lc_no']?.toString() ?? '',
      generalRegNo: json['general_reg_no']?.toString() ?? '',
      uDiseNo: json['u_dise_no']?.toString() ?? '',
      studentSaralId: json['student_saral_id']?.toString() ?? '',
      uidNo: json['uid_no']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      nationality: json['nationality']?.toString() ?? 'भारतीय',
      motherTongue: json['mother_tongue']?.toString() ?? 'मराठी',
      religion: json['religion']?.toString() ?? '',
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
      reasonForLeaving: json['reason_for_leaving']?.toString() ?? 'पुढील शिक्षणासाठी',
      remarks: json['remarks']?.toString() ?? '',
      issueDate: issueDate,
      copyCount: int.tryParse(json['copy_count']?.toString() ?? '1') ?? 1,
      copyType: json['copy_type']?.toString() ?? 'Original',
      isIssued: json['is_issued'] == true,
    );
  }
}

