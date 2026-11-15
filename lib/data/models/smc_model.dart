// शाळा व्यवस्थापन समिती (SMC - School Management Committee) व पालक सभा मॉडेल्स

class SmcMemberModel {
  final String id;
  final String name;
  final String designation; // अध्यक्ष, उपाध्यक्ष, सदस्य सचिव (मुख्याध्यापक), पालक सदस्य, ग्रा.पं. सदस्य, शिक्षक प्रतिनिधी, शिक्षणतज्ज्ञ
  final String gender; // पुरुष / महिला
  final String category; // SC, ST, OBC, OPEN
  final String mobileNumber;
  final String wardOrAddress;
  final bool isParentMember; // ७५% पालक सदस्य निकष
  final String studentRelation; // कोणत्या पाल्याचा पालक (उदा. राहुल पवार - इ. ४ थी)
  final DateTime appointedDate;
  final DateTime expiryDate;

  SmcMemberModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.gender,
    required this.category,
    required this.mobileNumber,
    this.wardOrAddress = '',
    this.isParentMember = true,
    this.studentRelation = '',
    required this.appointedDate,
    required this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'designation': designation,
        'gender': gender,
        'category': category,
        'mobileNumber': mobileNumber,
        'wardOrAddress': wardOrAddress,
        'isParentMember': isParentMember,
        'studentRelation': studentRelation,
        'appointedDate': appointedDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
      };

  factory SmcMemberModel.fromJson(Map<String, dynamic> json) => SmcMemberModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        designation: json['designation'] ?? 'सदस्य',
        gender: json['gender'] ?? 'महिला',
        category: json['category'] ?? 'OPEN',
        mobileNumber: json['mobileNumber'] ?? '',
        wardOrAddress: json['wardOrAddress'] ?? '',
        isParentMember: json['isParentMember'] ?? true,
        studentRelation: json['studentRelation'] ?? '',
        appointedDate: DateTime.parse(
            json['appointedDate'] ?? DateTime.now().toIso8601String()),
        expiryDate: DateTime.parse(json['expiryDate'] ??
            DateTime.now().add(const Duration(days: 1095)).toIso8601String()),
      );
}

class SmcMeetingModel {
  final String id;
  final int meetingNumber; // मासिक सभा क्र.
  final DateTime meetingDate;
  final String subjectOrAgenda; // सभेचा विषय / अजेंडा
  final int totalMembersAttended; // उपस्थित सदस्य संख्या
  final List<SmcResolutionItem> resolutions; // मंजूर ठराव यादी
  final String presidentName; // सभेचे अध्यक्ष
  final String secretaryName; // सचिव (मुख्याध्यापक)
  final String meetingStatus; // 'संपन्न', 'प्रलंबित'

  SmcMeetingModel({
    required this.id,
    required this.meetingNumber,
    required this.meetingDate,
    required this.subjectOrAgenda,
    required this.totalMembersAttended,
    required this.resolutions,
    required this.presidentName,
    required this.secretaryName,
    this.meetingStatus = 'संपन्न',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'meetingNumber': meetingNumber,
        'meetingDate': meetingDate.toIso8601String(),
        'subjectOrAgenda': subjectOrAgenda,
        'totalMembersAttended': totalMembersAttended,
        'resolutions': resolutions.map((r) => r.toJson()).toList(),
        'presidentName': presidentName,
        'secretaryName': secretaryName,
        'meetingStatus': meetingStatus,
      };

  factory SmcMeetingModel.fromJson(Map<String, dynamic> json) => SmcMeetingModel(
        id: json['id'] ?? '',
        meetingNumber: (json['meetingNumber'] as num?)?.toInt() ?? 1,
        meetingDate: DateTime.parse(
            json['meetingDate'] ?? DateTime.now().toIso8601String()),
        subjectOrAgenda: json['subjectOrAgenda'] ?? '',
        totalMembersAttended:
            (json['totalMembersAttended'] as num?)?.toInt() ?? 0,
        resolutions: (json['resolutions'] as List<dynamic>?)
                ?.map((r) => SmcResolutionItem.fromJson(r))
                .toList() ??
            [],
        presidentName: json['presidentName'] ?? '',
        secretaryName: json['secretaryName'] ?? '',
        meetingStatus: json['meetingStatus'] ?? 'संपन्न',
      );
}

class SmcResolutionItem {
  final int resolutionNumber; // ठराव क्र.
  final String proposer; // सूचक नाव
  final String seconder; // अनुमोदक नाव
  final String resolutionDetails; // ठरावाचा तपशील
  final String approvalStatus; // 'सर्वानुमते मंजूर', 'बहुमताने मंजूर'

  SmcResolutionItem({
    required this.resolutionNumber,
    required this.proposer,
    required this.seconder,
    required this.resolutionDetails,
    this.approvalStatus = 'सर्वानुमते मंजूर',
  });

  Map<String, dynamic> toJson() => {
        'resolutionNumber': resolutionNumber,
        'proposer': proposer,
        'seconder': seconder,
        'resolutionDetails': resolutionDetails,
        'approvalStatus': approvalStatus,
      };

  factory SmcResolutionItem.fromJson(Map<String, dynamic> json) =>
      SmcResolutionItem(
        resolutionNumber: (json['resolutionNumber'] as num?)?.toInt() ?? 1,
        proposer: json['proposer'] ?? '',
        seconder: json['seconder'] ?? '',
        resolutionDetails: json['resolutionDetails'] ?? '',
        approvalStatus: json['approvalStatus'] ?? 'सर्वानुमते मंजूर',
      );
}

