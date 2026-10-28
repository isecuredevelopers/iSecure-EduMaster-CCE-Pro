class SchoolModel {
  final String id;
  String schoolName;
  String sansthaName;
  String udiseCode;
  String board;
  String medium;
  String cluster;
  String blockTaluka;
  String district;
  String address;
  String pincode;
  String contactPhone;
  String schoolEmail;
  String headmasterName;
  String headmasterPrefix;
  String headmasterMobile;
  String? logoUrl;
  String? stampSignatureUrl;

  // Whitelabel & Commercial Resale Settings
  String softwareTitle;
  String vendorName;
  String vendorContact;
  String vendorEmail;
  String licenseKey;
  bool isActivated;
  String licenseType;
  String licenseExpiryDate;
  int minPassingPercentage;
  String? softwareLogoUrl;

  SchoolModel({
    required this.id,
    required this.schoolName,
    this.sansthaName = '',
    this.udiseCode = '',
    this.board = 'महाराष्ट्र राज्य मंडळ (State Board)',
    this.medium = 'मराठी',
    this.cluster = '',
    this.blockTaluka = '',
    this.district = '',
    this.address = '',
    this.pincode = '',
    this.contactPhone = '',
    this.schoolEmail = '',
    this.headmasterName = '',
    this.headmasterPrefix = 'श्री.',
    this.headmasterMobile = '',
    this.logoUrl,
    this.stampSignatureUrl,
    this.softwareTitle = 'iSecure EduMaster CCE Pro - शाळा मूल्यमापन प्रणाली',
    this.vendorName = 'iSecure Systems Pvt. Ltd.',
    this.vendorContact = '9326770568',
    this.vendorEmail = 'isecuredeveloper@gmail.com',
    this.licenseKey = 'IS-CCE-2025-PRO-9326',
    this.isActivated = true,
    this.licenseType = 'शाळा व्यावसायिक परवाना (iSecure Commercial License)',
    this.licenseExpiryDate = '2026-06-30',
    this.minPassingPercentage = 35,
    this.softwareLogoUrl = 'assets/images/isecure_favicon.png',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_name': schoolName,
      'sanstha_name': sansthaName,
      'udise_code': udiseCode,
      'board': board,
      'medium': medium,
      'cluster': cluster,
      'block_taluka': blockTaluka,
      'district': district,
      'address': address,
      'pincode': pincode,
      'contact_phone': contactPhone,
      'school_email': schoolEmail,
      'headmaster_name': headmasterName,
      'headmaster_prefix': headmasterPrefix,
      'headmaster_mobile': headmasterMobile,
      'logo_url': logoUrl,
      'stamp_signature_url': stampSignatureUrl,
      'software_title': softwareTitle,
      'vendor_name': vendorName,
      'vendor_contact': vendorContact,
      'vendor_email': vendorEmail,
      'license_key': licenseKey,
      'is_activated': isActivated,
      'license_type': licenseType,
      'license_expiry_date': licenseExpiryDate,
      'min_passing_percentage': minPassingPercentage,
      'software_logo_url': softwareLogoUrl,
    };
  }

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id']?.toString() ?? '1',
      schoolName: json['school_name']?.toString() ?? json['SchoolName']?.toString() ?? '',
      sansthaName: json['sanstha_name']?.toString() ?? json['sanstha']?.toString() ?? '',
      udiseCode: json['udise_code']?.toString() ?? json['UDISE']?.toString() ?? '',
      board: json['board']?.toString() ?? 'महाराष्ट्र राज्य मंडळ (State Board)',
      medium: json['medium']?.toString() ?? json['Medium']?.toString() ?? 'मराठी',
      cluster: json['cluster']?.toString() ?? json['Cluster']?.toString() ?? '',
      blockTaluka: json['block_taluka']?.toString() ?? json['Block']?.toString() ?? '',
      district: json['district']?.toString() ?? json['District']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
      schoolEmail: json['school_email']?.toString() ?? '',
      headmasterName: json['headmaster_name']?.toString() ?? '',
      headmasterPrefix: json['headmaster_prefix']?.toString() ?? 'श्री.',
      headmasterMobile: json['headmaster_mobile']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString(),
      stampSignatureUrl: json['stamp_signature_url']?.toString(),
      softwareTitle: json['software_title']?.toString() ?? 'iSecure EduMaster CCE Pro - शाळा मूल्यमापन प्रणाली',
      vendorName: json['vendor_name']?.toString() ?? 'iSecure Systems Pvt. Ltd.',
      vendorContact: json['vendor_contact']?.toString() ?? '9326770568',
      vendorEmail: json['vendor_email']?.toString() ?? 'isecuredeveloper@gmail.com',
      licenseKey: json['license_key']?.toString() ?? 'IS-CCE-2025-PRO-9326',
      isActivated: json['is_activated'] == true || json['is_activated'] == 'true' || json['is_activated'] == null,
      licenseType: json['license_type']?.toString() ?? 'शाळा व्यावसायिक परवाना (iSecure Commercial License)',
      licenseExpiryDate: json['license_expiry_date']?.toString() ?? '2026-06-30',
      minPassingPercentage: int.tryParse(json['min_passing_percentage']?.toString() ?? '35') ?? 35,
      softwareLogoUrl: json['software_logo_url']?.toString() ?? 'assets/images/isecure_favicon.png',
    );
  }

  SchoolModel copyWith({
    String? id,
    String? schoolName,
    String? sansthaName,
    String? udiseCode,
    String? board,
    String? medium,
    String? cluster,
    String? blockTaluka,
    String? district,
    String? address,
    String? pincode,
    String? contactPhone,
    String? schoolEmail,
    String? headmasterName,
    String? headmasterPrefix,
    String? headmasterMobile,
    String? logoUrl,
    String? stampSignatureUrl,
    String? softwareTitle,
    String? vendorName,
    String? vendorContact,
    String? vendorEmail,
    String? licenseKey,
    bool? isActivated,
    String? licenseType,
    String? licenseExpiryDate,
    int? minPassingPercentage,
    String? softwareLogoUrl,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      schoolName: schoolName ?? this.schoolName,
      sansthaName: sansthaName ?? this.sansthaName,
      udiseCode: udiseCode ?? this.udiseCode,
      board: board ?? this.board,
      medium: medium ?? this.medium,
      cluster: cluster ?? this.cluster,
      blockTaluka: blockTaluka ?? this.blockTaluka,
      district: district ?? this.district,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      contactPhone: contactPhone ?? this.contactPhone,
      schoolEmail: schoolEmail ?? this.schoolEmail,
      headmasterName: headmasterName ?? this.headmasterName,
      headmasterPrefix: headmasterPrefix ?? this.headmasterPrefix,
      headmasterMobile: headmasterMobile ?? this.headmasterMobile,
      logoUrl: logoUrl ?? this.logoUrl,
      stampSignatureUrl: stampSignatureUrl ?? this.stampSignatureUrl,
      softwareTitle: softwareTitle ?? this.softwareTitle,
      vendorName: vendorName ?? this.vendorName,
      vendorContact: vendorContact ?? this.vendorContact,
      vendorEmail: vendorEmail ?? this.vendorEmail,
      licenseKey: licenseKey ?? this.licenseKey,
      isActivated: isActivated ?? this.isActivated,
      licenseType: licenseType ?? this.licenseType,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      minPassingPercentage: minPassingPercentage ?? this.minPassingPercentage,
      softwareLogoUrl: softwareLogoUrl ?? this.softwareLogoUrl,
    );
  }
}
