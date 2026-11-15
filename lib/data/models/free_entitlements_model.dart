// समग्र शिक्षा - मोफत पाठ्यपुस्तके व मोफत गणवेश वाटप नोंदवही मॉडेल्स

class TextbookDistributionRecord {
  final String id;
  final String studentId;
  final String studentName;
  final int standard;
  final String division;
  final String grNo;
  final int setsReceivedCount; // प्राप्त संच संख्या (सामान्यतः १)
  final DateTime distributionDate;
  final bool isDistributed; // वाटप झाले का
  final bool hasSignature; // स्वाक्षरी / अंगठा नोंद
  final String remark;

  TextbookDistributionRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.standard,
    required this.division,
    required this.grNo,
    this.setsReceivedCount = 1,
    required this.distributionDate,
    this.isDistributed = true,
    this.hasSignature = true,
    this.remark = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'standard': standard,
        'division': division,
        'grNo': grNo,
        'setsReceivedCount': setsReceivedCount,
        'distributionDate': distributionDate.toIso8601String(),
        'isDistributed': isDistributed,
        'hasSignature': hasSignature,
        'remark': remark,
      };

  factory TextbookDistributionRecord.fromJson(Map<String, dynamic> json) =>
      TextbookDistributionRecord(
        id: json['id'] ?? '',
        studentId: json['studentId'] ?? '',
        studentName: json['studentName'] ?? '',
        standard: (json['standard'] as num?)?.toInt() ?? 1,
        division: json['division'] ?? '1',
        grNo: json['grNo'] ?? '',
        setsReceivedCount: (json['setsReceivedCount'] as num?)?.toInt() ?? 1,
        distributionDate: DateTime.parse(
            json['distributionDate'] ?? DateTime.now().toIso8601String()),
        isDistributed: json['isDistributed'] ?? true,
        hasSignature: json['hasSignature'] ?? true,
        remark: json['remark'] ?? '',
      );
}

class UniformDistributionRecord {
  final String id;
  final String studentId;
  final String studentName;
  final int standard;
  final String division;
  final String grNo;
  final String gender; // मुले / मुली
  final String category; // SC, ST, OBC, OPEN, BPL
  final bool isEligible; // सर्व मुली, SC मुले, ST मुले, BPL मुले
  final bool set1Given; // गणवेश जोडी १ वाटप
  final DateTime? set1Date;
  final bool set2Given; // गणवेश जोडी २ वाटप
  final DateTime? set2Date;
  final String mode; // 'थेट गणवेश वाटप' किंवा 'डीबीटी (DBT)'
  final double dbtAmount; // डीबीटी रक्कम (उदा. रु. ६००)
  final String remark;

  UniformDistributionRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.standard,
    required this.division,
    required this.grNo,
    required this.gender,
    required this.category,
    this.isEligible = true,
    this.set1Given = true,
    this.set1Date,
    this.set2Given = true,
    this.set2Date,
    this.mode = 'थेट गणवेश वाटप',
    this.dbtAmount = 600.0,
    this.remark = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'standard': standard,
        'division': division,
        'grNo': grNo,
        'gender': gender,
        'category': category,
        'isEligible': isEligible,
        'set1Given': set1Given,
        'set1Date': set1Date?.toIso8601String(),
        'set2Given': set2Given,
        'set2Date': set2Date?.toIso8601String(),
        'mode': mode,
        'dbtAmount': dbtAmount,
        'remark': remark,
      };

  factory UniformDistributionRecord.fromJson(Map<String, dynamic> json) =>
      UniformDistributionRecord(
        id: json['id'] ?? '',
        studentId: json['studentId'] ?? '',
        studentName: json['studentName'] ?? '',
        standard: (json['standard'] as num?)?.toInt() ?? 1,
        division: json['division'] ?? '1',
        grNo: json['grNo'] ?? '',
        gender: json['gender'] ?? 'मुले',
        category: json['category'] ?? 'OPEN',
        isEligible: json['isEligible'] ?? true,
        set1Given: json['set1Given'] ?? true,
        set1Date: json['set1Date'] != null ? DateTime.parse(json['set1Date']) : null,
        set2Given: json['set2Given'] ?? true,
        set2Date: json['set2Date'] != null ? DateTime.parse(json['set2Date']) : null,
        mode: json['mode'] ?? 'थेट गणवेश वाटप',
        dbtAmount: (json['dbtAmount'] as num?)?.toDouble() ?? 600.0,
        remark: json['remark'] ?? '',
      );
}

