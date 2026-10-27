class DescriptiveNoteModel {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String studentId;
  final int standard;
  final String division;
  final int semester; // 1 or 2

  // Subject-wise descriptive remarks
  String s1; // मराठी
  String s2; // हिंदी
  String s3; // इंग्रजी
  String s4; // गणित
  String s5; // विज्ञान / परिसर अभ्यास
  String s6; // सामाजिक शास्त्रे
  String s7; // कला
  String s8; // कार्यानुभव
  String s9; // शारीरिक शिक्षण

  // General observations
  String s10; // विशेष प्रगती
  String s11; // आवड / छंद
  String s12; // सुधारणा आवश्यक
  String s13; // व्यक्तिमत्त्व गुणविशेष

  DescriptiveNoteModel({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.studentId,
    required this.standard,
    required this.division,
    required this.semester,
    this.s1 = '',
    this.s2 = '',
    this.s3 = '',
    this.s4 = '',
    this.s5 = '',
    this.s6 = '',
    this.s7 = '',
    this.s8 = '',
    this.s9 = '',
    this.s10 = '',
    this.s11 = '',
    this.s12 = '',
    this.s13 = '',
  });

  String getRemark(String code) {
    switch (code) {
      case 's1': return s1;
      case 's2': return s2;
      case 's3': return s3;
      case 's4': return s4;
      case 's5': return s5;
      case 's6': return s6;
      case 's7': return s7;
      case 's8': return s8;
      case 's9': return s9;
      case 's10': return s10;
      case 's11': return s11;
      case 's12': return s12;
      case 's13': return s13;
      default: return '';
    }
  }

  void setRemark(String code, String text) {
    switch (code) {
      case 's1': s1 = text; break;
      case 's2': s2 = text; break;
      case 's3': s3 = text; break;
      case 's4': s4 = text; break;
      case 's5': s5 = text; break;
      case 's6': s6 = text; break;
      case 's7': s7 = text; break;
      case 's8': s8 = text; break;
      case 's9': s9 = text; break;
      case 's10': s10 = text; break;
      case 's11': s11 = text; break;
      case 's12': s12 = text; break;
      case 's13': s13 = text; break;
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
      's1': s1,
      's2': s2,
      's3': s3,
      's4': s4,
      's5': s5,
      's6': s6,
      's7': s7,
      's8': s8,
      's9': s9,
      's10': s10,
      's11': s11,
      's12': s12,
      's13': s13,
    };
  }

  factory DescriptiveNoteModel.fromJson(Map<String, dynamic> json) {
    return DescriptiveNoteModel(
      id: json['id']?.toString() ?? json['NoteID']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '1',
      academicYearId: json['academic_year_id']?.toString() ?? json['YearID']?.toString() ?? '1',
      studentId: json['student_id']?.toString() ?? json['StudentID']?.toString() ?? '',
      standard: int.tryParse(json['standard']?.toString() ?? json['Std']?.toString() ?? '1') ?? 1,
      division: json['division']?.toString() ?? json['Div']?.toString() ?? '1',
      semester: int.tryParse(json['semester']?.toString() ?? json['Semister']?.toString() ?? '1') ?? 1,
      s1: json['s1']?.toString() ?? '',
      s2: json['s2']?.toString() ?? '',
      s3: json['s3']?.toString() ?? '',
      s4: json['s4']?.toString() ?? '',
      s5: json['s5']?.toString() ?? '',
      s6: json['s6']?.toString() ?? '',
      s7: json['s7']?.toString() ?? '',
      s8: json['s8']?.toString() ?? '',
      s9: json['s9']?.toString() ?? '',
      s10: json['s10']?.toString() ?? '',
      s11: json['s11']?.toString() ?? '',
      s12: json['s12']?.toString() ?? '',
      s13: json['s13']?.toString() ?? '',
    );
  }
}
