class ClassAllocationModel {
  final int standard;
  final String division;

  ClassAllocationModel({
    required this.standard,
    required this.division,
  });

  Map<String, dynamic> toJson() => {
        'standard': standard,
        'division': division,
      };

  factory ClassAllocationModel.fromJson(Map<String, dynamic> json) =>
      ClassAllocationModel(
        standard: int.tryParse(json['standard']?.toString() ?? '1') ?? 1,
        division: json['division']?.toString() ?? '1',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassAllocationModel &&
          runtimeType == other.runtimeType &&
          standard == other.standard &&
          division == other.division;

  @override
  int get hashCode => standard.hashCode ^ division.hashCode;
}

class AppRole {
  static const String teacher = 'teacher';         // Vargshikshak
  static const String headmaster = 'headmaster';   // Mukhyadhyapak
  static const String peon = 'peon';               // Shipai
  static const String admin = 'admin';             // Admin
  static const String superadmin = 'superadmin';   // Superadmin

  static const List<Map<String, String>> list = [
    {
      'role': teacher,
      'nameMr': 'वर्गशिक्षक',
      'nameEn': 'Vargshikshak',
      'sub': 'वाटप वर्ग उपस्थिती व नोंदी',
    },
    {
      'role': headmaster,
      'nameMr': 'मुख्याध्यापक',
      'nameEn': 'Mukhyadhyapak',
      'sub': 'शाळा प्रमुख, निकाल व दाखले',
    },
    {
      'role': peon,
      'nameMr': 'शिपाई',
      'nameEn': 'Shipai',
      'sub': 'शालेय कार्यालयीन कामकाज',
    },
    {
      'role': admin,
      'nameMr': 'Admin',
      'nameEn': 'Admin',
      'sub': 'शाळा प्रणाली व्यवस्थापक',
    },
    {
      'role': superadmin,
      'nameMr': 'Superadmin',
      'nameEn': 'Superadmin',
      'sub': 'सर्वोच्च अधिकार व सेटिंग्ज',
    },
  ];

  static String getLabel(String r) {
    switch (r.toLowerCase()) {
      case teacher:
        return 'वर्गशिक्षक (Vargshikshak)';
      case headmaster:
        return 'मुख्याध्यापक (Mukhyadhyapak)';
      case peon:
        return 'शिपाई (Shipai)';
      case admin:
        return 'Admin';
      case superadmin:
        return 'Superadmin';
      default:
        return r;
    }
  }
}

class UserModel {
  final String id;
  String name;
  String username;
  String password;
  String role; // 'teacher', 'headmaster', 'peon', 'admin', 'superadmin'
  String mobile;
  String email;
  List<ClassAllocationModel> allocatedClasses;
  bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    this.role = AppRole.teacher,
    this.mobile = '',
    this.email = '',
    List<ClassAllocationModel>? allocatedClasses,
    this.isActive = true,
  }) : allocatedClasses = allocatedClasses ?? [];

  bool get isSuperAdmin => role == AppRole.superadmin;
  bool get isMasterProtected => id == 'usr_isecure' || username.toLowerCase() == 'isecure';
  bool get isAdmin => role == AppRole.admin || role == AppRole.superadmin || role == AppRole.headmaster;
  bool get isHeadmaster => role == AppRole.headmaster;
  bool get isTeacher => role == AppRole.teacher;
  bool get isPeon => role == AppRole.peon;

  String get roleTextMr => AppRole.getLabel(role);

  /// Distinct list of standards assigned to this teacher (e.g. [1, 3])
  List<int> get allocatedStandards {
    if (isAdmin || isPeon) return [1, 2, 3, 4, 5, 6, 7, 8];
    final list = allocatedClasses.map((a) => a.standard).toSet().toList()..sort();
    return list.isNotEmpty ? list : [1];
  }

  /// List of divisions assigned to this teacher for a given standard
  List<String> getAllocatedDivisionsFor(int std) {
    if (isAdmin || isPeon) return ['1', '2', '3', 'A', 'B', 'C'];
    final list = allocatedClasses
        .where((a) => a.standard == std)
        .map((a) => a.division)
        .toSet()
        .toList();
    return list.isNotEmpty ? list : ['1'];
  }

  /// Whether this user has permission to view/edit standard and division
  bool hasAccessTo(int std, String div) {
    if (isAdmin || isPeon) return true;
    return allocatedClasses.any((a) => a.standard == std && (a.division == div || a.division == 'ALL'));
  }

  /// Readable summary string of allocated classes (e.g. "इ. १ ली (१), इ. २ री (१)")
  String get allocationSummary {
    if (isSuperAdmin) return 'सुपर ॲडमीन (सर्वोच्च अधिकार)';
    if (role == AppRole.admin) return 'प्रशासक (पूर्ण अधिकार)';
    if (isHeadmaster) return 'मुख्याध्यापक (शाळा प्रमुख)';
    if (isPeon) return 'शिपाई (कार्यालयीन सहाय्य)';
    if (allocatedClasses.isEmpty) return 'कोणताही वर्ग वाटप नाही';
    final map = <int, List<String>>{};
    for (var a in allocatedClasses) {
      map.putIfAbsent(a.standard, () => []).add(a.division);
    }
    final parts = <String>[];
    for (var entry in map.entries) {
      parts.add('इ. ${entry.key} ली/री (${entry.value.join(", ")})');
    }
    return parts.join(' • ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'password': password,
        'role': role,
        'mobile': mobile,
        'email': email,
        'allocated_classes': allocatedClasses.map((a) => a.toJson()).toList(),
        'is_active': isActive,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        role: json['role']?.toString() ?? AppRole.teacher,
        mobile: json['mobile']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        allocatedClasses: (json['allocated_classes'] as List?)
                ?.map((e) => ClassAllocationModel.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
        isActive: json['is_active'] != false,
      );
}
