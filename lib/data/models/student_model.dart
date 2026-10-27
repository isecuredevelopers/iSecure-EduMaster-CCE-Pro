class StudentModel {
  final String id;
  final String schoolId;
  final String academicYearId;
  int standard;
  String division;
  String grNo;
  int rollNoSem1;
  int rollNoSem2;
  String studentNameMr;
  String studentNameEn;
  String fatherName;
  String motherName;
  String gender; // 'M' or 'F' or 'T'
  String casteCategory; // 'OPEN', 'OBC', 'SC', 'ST', 'VJNT', 'SBC'
  String subCaste;
  DateTime dateOfBirth;
  String birthPlace;
  String taluka;
  String district;
  String saralId;
  String apaarId;
  String penNo;
  String aadhaarNo;
  String bankAccNo;
  String ifscCode;
  String mobileNo;
  String address;
  String fatherOccupation;
  String motherOccupation;
  double? heightSem1;
  double? heightSem2;
  double? weightSem1;
  double? weightSem2;
  String? photoUrl;
  bool isPromoted;

  StudentModel({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.standard,
    required this.division,
    required this.grNo,
    required this.rollNoSem1,
    int? rollNoSem2,
    required this.studentNameMr,
    this.studentNameEn = '',
    this.fatherName = '',
    this.motherName = '',
    this.gender = 'M',
    this.casteCategory = 'OPEN',
    this.subCaste = '',
    required this.dateOfBirth,
    this.birthPlace = '',
    this.taluka = '',
    this.district = '',
    this.saralId = '',
    this.apaarId = '',
    this.penNo = '',
    this.aadhaarNo = '',
    this.bankAccNo = '',
    this.ifscCode = '',
    this.mobileNo = '',
    this.address = '',
    this.fatherOccupation = 'शेती',
    this.motherOccupation = 'गृहिणी',
    this.heightSem1,
    this.heightSem2,
    this.weightSem1,
    this.weightSem2,
    this.photoUrl,
    this.isPromoted = false,
  }) : rollNoSem2 = rollNoSem2 ?? rollNoSem1;

  int getRollNo(int semester) => semester == 2 ? rollNoSem2 : rollNoSem1;

  String get genderTextMr {
    if (gender == 'F') return 'मुलगी';
    if (gender == 'M') return 'मुलगा';
    return 'इतर';
  }

  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'academic_year_id': academicYearId,
      'standard': standard,
      'division': division,
      'gr_no': grNo,
      'roll_no_sem1': rollNoSem1,
      'roll_no_sem2': rollNoSem2,
      'student_name_mr': studentNameMr,
      'student_name_en': studentNameEn,
      'father_name': fatherName,
      'mother_name': motherName,
      'gender': gender,
      'caste_category': casteCategory,
      'sub_caste': subCaste,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'birth_place': birthPlace,
      'taluka': taluka,
      'district': district,
      'saral_id': saralId,
      'apaar_id': apaarId,
      'pen_no': penNo,
      'aadhaar_no': aadhaarNo,
      'bank_acc_no': bankAccNo,
      'ifsc_code': ifscCode,
      'mobile_no': mobileNo,
      'address': address,
      'father_occupation': fatherOccupation,
      'mother_occupation': motherOccupation,
      'height_sem1': heightSem1,
      'height_sem2': heightSem2,
      'weight_sem1': weightSem1,
      'weight_sem2': weightSem2,
      'photo_url': photoUrl,
      'is_promoted': isPromoted,
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    DateTime dob = DateTime.now().subtract(const Duration(days: 365 * 8));
    if (json['date_of_birth'] != null) {
      dob = DateTime.tryParse(json['date_of_birth']) ?? dob;
    } else if (json['BirthDate'] != null) {
      dob = DateTime.tryParse(json['BirthDate']) ?? dob;
    }

    return StudentModel(
      id: json['id']?.toString() ?? json['StudentID']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '1',
      academicYearId: json['academic_year_id']?.toString() ?? json['YearID']?.toString() ?? '1',
      standard: int.tryParse(json['standard']?.toString() ?? json['Std']?.toString() ?? '1') ?? 1,
      division: json['division']?.toString() ?? json['Div']?.toString() ?? '1',
      grNo: json['gr_no']?.toString() ?? json['RegNo']?.toString() ?? '',
      rollNoSem1: int.tryParse(json['roll_no_sem1']?.toString() ?? json['RollNo1']?.toString() ?? '1') ?? 1,
      rollNoSem2: int.tryParse(json['roll_no_sem2']?.toString() ?? json['RollNo2']?.toString() ?? '1'),
      studentNameMr: json['student_name_mr']?.toString() ?? json['StudentName']?.toString() ?? '',
      studentNameEn: json['student_name_en']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? json['FatherName']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? json['MotherName']?.toString() ?? '',
      gender: json['gender']?.toString() == '2' || json['gender']?.toString() == 'F' ? 'F' : 'M',
      casteCategory: json['caste_category']?.toString() ?? 'OPEN',
      subCaste: json['sub_caste']?.toString() ?? '',
      dateOfBirth: dob,
      birthPlace: json['birth_place']?.toString() ?? '',
      taluka: json['taluka']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      saralId: json['saral_id']?.toString() ?? json['StudentSaralID']?.toString() ?? '',
      apaarId: json['apaar_id']?.toString() ?? json['Apaar']?.toString() ?? '',
      penNo: json['pen_no']?.toString() ?? json['Pen']?.toString() ?? '',
      aadhaarNo: json['aadhaar_no']?.toString() ?? '',
      bankAccNo: json['bank_acc_no']?.toString() ?? '',
      ifscCode: json['ifsc_code']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      address: json['address']?.toString() ?? json['Address']?.toString() ?? '',
      fatherOccupation: json['father_occupation']?.toString() ?? json['FatherWork']?.toString() ?? 'शेती',
      motherOccupation: json['mother_occupation']?.toString() ?? json['MotherWork']?.toString() ?? 'गृहिणी',
      heightSem1: double.tryParse(json['height_sem1']?.toString() ?? json['Height']?.toString() ?? ''),
      heightSem2: double.tryParse(json['height_sem2']?.toString() ?? json['Height2']?.toString() ?? ''),
      weightSem1: double.tryParse(json['weight_sem1']?.toString() ?? json['Weight']?.toString() ?? ''),
      weightSem2: double.tryParse(json['weight_sem2']?.toString() ?? json['Weight2']?.toString() ?? ''),
      photoUrl: json['photo_url']?.toString(),
      isPromoted: json['is_promoted'] == true,
    );
  }
}
