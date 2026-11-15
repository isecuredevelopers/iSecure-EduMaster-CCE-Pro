// शासकीय आवक-जावक नोंदवही (Inward/Outward) व विद्यार्थी आरोग्य तपासणी (RBSK)

class InwardLetterRecord {
  final String id;
  final int inwardNumber; // आवक क्रमांक
  final DateTime receivedDate; // प्राप्त दिनांक
  final String senderDetails; // प्रेषक (उदा. गटशिक्षणाधिकारी कार्यालय, केंद्रप्रमुख)
  final String letterNumber; // मूळ पत्राचा जावक क्र. व दिनांक
  final String subject; // पत्राचा विषय
  final String fileReference; // नस्ती / फाईल संदर्भ
  final String actionTaken; // केलेली कार्यवाही / शेरा

  InwardLetterRecord({
    required this.id,
    required this.inwardNumber,
    required this.receivedDate,
    required this.senderDetails,
    required this.letterNumber,
    required this.subject,
    this.fileReference = '',
    this.actionTaken = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'inwardNumber': inwardNumber,
        'receivedDate': receivedDate.toIso8601String(),
        'senderDetails': senderDetails,
        'letterNumber': letterNumber,
        'subject': subject,
        'fileReference': fileReference,
        'actionTaken': actionTaken,
      };

  factory InwardLetterRecord.fromJson(Map<String, dynamic> json) =>
      InwardLetterRecord(
        id: json['id'] ?? '',
        inwardNumber: (json['inwardNumber'] as num?)?.toInt() ?? 1,
        receivedDate: DateTime.parse(
            json['receivedDate'] ?? DateTime.now().toIso8601String()),
        senderDetails: json['senderDetails'] ?? '',
        letterNumber: json['letterNumber'] ?? '',
        subject: json['subject'] ?? '',
        fileReference: json['fileReference'] ?? '',
        actionTaken: json['actionTaken'] ?? '',
      );
}

class OutwardLetterRecord {
  final String id;
  final int outwardNumber; // जावक क्रमांक
  final DateTime dispatchDate; // पाठविल्याचा दिनांक
  final String recipientDetails; // प्रति / कोणास पाठवले (उदा. मा. गटशिक्षणाधिकारी, पं.स.)
  final String subject; // पत्राचा विषय
  final String postalOrDeliveryMode; // टपाल पद्धत: 'थेट हस्ते', 'नोंदणीकृत पोस्ट', 'ईमेल'
  final double postalCost; // टपाल तिकीट खर्च (रु.)
  final String remark; // शेरा

  OutwardLetterRecord({
    required this.id,
    required this.outwardNumber,
    required this.dispatchDate,
    required this.recipientDetails,
    required this.subject,
    this.postalOrDeliveryMode = 'थेट हस्ते',
    this.postalCost = 0.0,
    this.remark = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'outwardNumber': outwardNumber,
        'dispatchDate': dispatchDate.toIso8601String(),
        'recipientDetails': recipientDetails,
        'subject': subject,
        'postalOrDeliveryMode': postalOrDeliveryMode,
        'postalCost': postalCost,
        'remark': remark,
      };

  factory OutwardLetterRecord.fromJson(Map<String, dynamic> json) =>
      OutwardLetterRecord(
        id: json['id'] ?? '',
        outwardNumber: (json['outwardNumber'] as num?)?.toInt() ?? 1,
        dispatchDate: DateTime.parse(
            json['dispatchDate'] ?? DateTime.now().toIso8601String()),
        recipientDetails: json['recipientDetails'] ?? '',
        subject: json['subject'] ?? '',
        postalOrDeliveryMode: json['postalOrDeliveryMode'] ?? 'थेट हस्ते',
        postalCost: (json['postalCost'] as num?)?.toDouble() ?? 0.0,
        remark: json['remark'] ?? '',
      );
}

class StudentHealthRecord {
  final String id;
  final String studentId;
  final String studentName;
  final int standard;
  final String division;
  final double heightCm; // उंची (सें.मी.)
  final double weightKg; // वजन (किलो)
  final String bloodGroup; // रक्तगट (A+, B+, O+, AB+, इत्यादी)
  final double hemoglobin; // हिमोग्लोबिन (Hb g/dL)
  final String visionTest; // दृष्टीदोष (सामान्य / चष्मा आवश्यक)
  final String dentalHealth; // दात स्थिती (स्वच्छ / कीड)
  final String majorIllnessOrAllergy; // विशेष आजार किंवा ॲलर्जी
  final DateTime checkupDate;
  final String examiningDoctor; // तपासणी अधिकारी (उदा. वैद्यकीय अधिकारी, प्राथमिक आरोग्य केंद्र)

  StudentHealthRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.standard,
    required this.division,
    required this.heightCm,
    required this.weightKg,
    this.bloodGroup = 'माहित नाही',
    this.hemoglobin = 12.0,
    this.visionTest = 'सामान्य',
    this.dentalHealth = 'चांगले',
    this.majorIllnessOrAllergy = 'काहीही नाही',
    required this.checkupDate,
    this.examiningDoctor = 'वैद्यकीय पथक (RBSK)',
  });

  double get bmi {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'standard': standard,
        'division': division,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'bloodGroup': bloodGroup,
        'hemoglobin': hemoglobin,
        'visionTest': visionTest,
        'dentalHealth': dentalHealth,
        'majorIllnessOrAllergy': majorIllnessOrAllergy,
        'checkupDate': checkupDate.toIso8601String(),
        'examiningDoctor': examiningDoctor,
      };

  factory StudentHealthRecord.fromJson(Map<String, dynamic> json) =>
      StudentHealthRecord(
        id: json['id'] ?? '',
        studentId: json['studentId'] ?? '',
        studentName: json['studentName'] ?? '',
        standard: (json['standard'] as num?)?.toInt() ?? 1,
        division: json['division'] ?? '1',
        heightCm: (json['heightCm'] as num?)?.toDouble() ?? 115.0,
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 20.0,
        bloodGroup: json['bloodGroup'] ?? 'माहित नाही',
        hemoglobin: (json['hemoglobin'] as num?)?.toDouble() ?? 12.0,
        visionTest: json['visionTest'] ?? 'सामान्य',
        dentalHealth: json['dentalHealth'] ?? 'चांगले',
        majorIllnessOrAllergy: json['majorIllnessOrAllergy'] ?? 'काहीही नाही',
        checkupDate: DateTime.parse(
            json['checkupDate'] ?? DateTime.now().toIso8601String()),
        examiningDoctor: json['examiningDoctor'] ?? 'वैद्यकीय पथक (RBSK)',
      );
}
