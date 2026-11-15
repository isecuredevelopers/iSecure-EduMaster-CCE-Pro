// शिक्षक सेवा, रजा खातावणी (Teacher Leaves) व हालचाल नोंदवही (Movement Register)

class TeacherLeaveRecord {
  final String id;
  final String teacherId;
  final String teacherName;
  final String leaveType; // 'किरकोळ रजा (CL)', 'अर्जित रजा (EL)', 'वैद्यकीय रजा (ML)', 'विशेष रजा'
  final DateTime fromDate;
  final DateTime toDate;
  final int totalDays;
  final String reason;
  final String status; // 'मंजूर', 'प्रलंबित', 'नाकारले'
  final String approvedBy; // मुख्याध्यापक
  final DateTime appliedDate;

  TeacherLeaveRecord({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.reason,
    this.status = 'मंजूर',
    this.approvedBy = 'मुख्याध्यापक',
    required this.appliedDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'leaveType': leaveType,
        'fromDate': fromDate.toIso8601String(),
        'toDate': toDate.toIso8601String(),
        'totalDays': totalDays,
        'reason': reason,
        'status': status,
        'approvedBy': approvedBy,
        'appliedDate': appliedDate.toIso8601String(),
      };

  factory TeacherLeaveRecord.fromJson(Map<String, dynamic> json) =>
      TeacherLeaveRecord(
        id: json['id'] ?? '',
        teacherId: json['teacherId'] ?? '',
        teacherName: json['teacherName'] ?? '',
        leaveType: json['leaveType'] ?? 'किरकोळ रजा (CL)',
        fromDate: DateTime.parse(
            json['fromDate'] ?? DateTime.now().toIso8601String()),
        toDate:
            DateTime.parse(json['toDate'] ?? DateTime.now().toIso8601String()),
        totalDays: (json['totalDays'] as num?)?.toInt() ?? 1,
        reason: json['reason'] ?? '',
        status: json['status'] ?? 'मंजूर',
        approvedBy: json['approvedBy'] ?? 'मुख्याध्यापक',
        appliedDate: DateTime.parse(
            json['appliedDate'] ?? DateTime.now().toIso8601String()),
      );
}

class MovementRegisterRecord {
  final String id;
  final String teacherName;
  final DateTime date;
  final String departureTime; // शाळेतून निघण्याची वेळ (उदा. ११:३० AM)
  final String returnTime; // परत आल्याची वेळ (उदा. ०३:४५ PM)
  final String destination; // भेट दिलेले ठिकाण (उदा. BRC केंद्र, गट साधन केंद्र, तहसील, बँक)
  final String purpose; // कामाचे स्वरूप (उदा. U-DISE बैठक, समग्र शिक्षा साहित्य आणणे)
  final String approvedBy; // मुख्याध्यापक स्वाक्षरी

  MovementRegisterRecord({
    required this.id,
    required this.teacherName,
    required this.date,
    required this.departureTime,
    required this.returnTime,
    required this.destination,
    required this.purpose,
    this.approvedBy = 'मुख्याध्यापक',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherName': teacherName,
        'date': date.toIso8601String(),
        'departureTime': departureTime,
        'returnTime': returnTime,
        'destination': destination,
        'purpose': purpose,
        'approvedBy': approvedBy,
      };

  factory MovementRegisterRecord.fromJson(Map<String, dynamic> json) =>
      MovementRegisterRecord(
        id: json['id'] ?? '',
        teacherName: json['teacherName'] ?? '',
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        departureTime: json['departureTime'] ?? '',
        returnTime: json['returnTime'] ?? '',
        destination: json['destination'] ?? '',
        purpose: json['purpose'] ?? '',
        approvedBy: json['approvedBy'] ?? 'मुख्याध्यापक',
      );
}

