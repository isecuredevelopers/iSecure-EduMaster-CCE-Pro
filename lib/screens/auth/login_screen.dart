import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/language_selector_sheet.dart';
import '../../widgets/school_logo_widget.dart';
import '../portal/student_parent_portal_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _studentGrCtrl = TextEditingController();
  final _studentPassCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureStudentPass = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRole = AppRole.teacher;
  bool _isStudentLoginMode = false;

  bool get _showRoleSelection =>
      _usernameCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  // 5 Staff roles in user-specified order
  static const List<Map<String, dynamic>> roleOptions = [
    {
      'role': AppRole.teacher,
      'title': 'Vargshikshak (वर्गशिक्षक)',
      'sub': 'वाटप केलेल्या वर्गाची उपस्थिती, आकारिक व संकलित नोंदी',
      'icon': Icons.person,
      'color': Color(0xFF059669),
      'bg': Color(0xFFECFDF5),
    },
    {
      'role': AppRole.headmaster,
      'title': 'Mukhyadhyapak (मुख्याध्यापक)',
      'sub': 'शाळा प्रमुख, सर्व वर्ग (इ. १ ते ८), निकाल व दाखले',
      'icon': Icons.school,
      'color': Color(0xFF2563EB),
      'bg': Color(0xFFEFF6FF),
    },
    {
      'role': AppRole.peon,
      'title': 'Shipai (शिपाई)',
      'sub': 'शालेय कार्यालयीन कामकाज, विद्यार्थी यादी व दाखले सहाय्य',
      'icon': Icons.badge_outlined,
      'color': Color(0xFFD97706),
      'bg': Color(0xFFFEF3C7),
    },
    {
      'role': AppRole.admin,
      'title': 'Admin (प्रशासक)',
      'sub': 'शाळा प्रणाली व्यवस्थापक, शिक्षक वाटप व नियंत्रण',
      'icon': Icons.admin_panel_settings,
      'color': Color(0xFF7C3AED),
      'bg': Color(0xFFF5F3FF),
    },
    {
      'role': AppRole.superadmin,
      'title': 'Superadmin (सुपर ॲडमीन)',
      'sub': 'सर्वोच्च अधिकार, संपूर्ण प्रणाली सेटिंग्ज व बॅकअप',
      'icon': Icons.security,
      'color': Color(0xFFDC2626),
      'bg': Color(0xFFFEF2F2),
    },
  ];

  @override
  void initState() {
    super.initState();
    _usernameCtrl.addListener(_onCredentialsChanged);
    _passwordCtrl.addListener(_onCredentialsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isMobile = MediaQuery.of(context).size.width < 800;
        if (isMobile) {
          setState(() {
            _isStudentLoginMode = true;
          });
        }
      }
    });
  }

  void _onCredentialsChanged() {
    final u = _usernameCtrl.text.trim().toLowerCase();
    if (u.isNotEmpty && mounted) {
      final state = context.read<AppStateProvider>();
      final matched = state.users.where((user) => user.username.toLowerCase() == u).toList();
      if (matched.isNotEmpty) {
        final uModel = matched.first;
        if (uModel.role != _selectedRole) {
          setState(() {
            _selectedRole = uModel.role;
          });
          return;
        }
      } else if (u == 'isecure' || u == 'superadmin') {
        if (_selectedRole != AppRole.superadmin) {
          setState(() {
            _selectedRole = AppRole.superadmin;
          });
          return;
        }
      } else if (u == 'admin') {
        if (_selectedRole != AppRole.admin) {
          setState(() {
            _selectedRole = AppRole.admin;
          });
          return;
        }
      } else if (u == 'hm') {
        if (_selectedRole != AppRole.headmaster) {
          setState(() {
            _selectedRole = AppRole.headmaster;
          });
          return;
        }
      } else if (u == 'peon') {
        if (_selectedRole != AppRole.peon) {
          setState(() {
            _selectedRole = AppRole.peon;
          });
          return;
        }
      } else if (u.startsWith('teacher')) {
        if (_selectedRole != AppRole.teacher) {
          setState(() {
            _selectedRole = AppRole.teacher;
          });
          return;
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _usernameCtrl.removeListener(_onCredentialsChanged);
    _passwordCtrl.removeListener(_onCredentialsChanged);
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _studentGrCtrl.dispose();
    _studentPassCtrl.dispose();
    super.dispose();
  }

  void _handleStudentLogin(AppStateProvider state) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identifier = _studentGrCtrl.text.trim();
    final password = _studentPassCtrl.text.trim();

    final result = await state.loginStudent(identifier, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (result['success'] != true) {
        setState(() {
          _errorMessage = result['message'] as String? ?? 'लॉगिन अयशस्वी झाले.';
        });
      }
    }
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    final state = context.read<AppStateProvider>();
    final success = await state.login(username, password);

    if (mounted) {
      if (!success) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'अवैध वापरकर्ता नाव किंवा पासवर्ड! कृपया पुन्हा प्रयत्न करा.';
        });
        return;
      }

      // Check role authorization
      final currentUser = state.currentUser;
      if (currentUser != null) {
        // Superadmin has absolute access: never block superadmin under any selected role!
        if (!currentUser.isSuperAdmin) {
          final isElevated = currentUser.isAdmin &&
              (_selectedRole == AppRole.admin ||
                  _selectedRole == AppRole.headmaster ||
                  _selectedRole == AppRole.teacher ||
                  _selectedRole == AppRole.peon);
          if (currentUser.role != _selectedRole && !isElevated) {
            await state.logout();
            setState(() {
              _isLoading = false;
              _errorMessage = 'या खात्याची भूमिका "${currentUser.roleTextMr}" आहे. कृपया यादीतून तीच भूमिका निवडा.';
            });
            return;
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final school = state.school;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          // Background subtle ambient gradients
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2563EB).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Layout
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: isDesktop
                    ? _buildDesktopLayout(context, state, school)
                    : _buildCompactLayout(context, state, school),
              ),
            ),
          ),

          // Top-Right Quick Language Selector
          Positioned(
            top: 14,
            right: 14,
            child: SafeArea(
              child: InkWell(
                onTap: () => LanguageSelectorSheet.show(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.currentLanguage == 'mr'
                            ? '🚩 मराठी'
                            : state.currentLanguage == 'hi'
                                ? '🇮🇳 हिंदी'
                                : '🇬🇧 English',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Two-Panel Professional Desktop Layout (Compact & Clean)
  Widget _buildDesktopLayout(BuildContext context, AppStateProvider state, dynamic school) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 860),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Hero Panel
            Expanded(
              flex: 5,
              child: _buildHeroPanel(school, state),
            ),

            // Divider
            Container(width: 1, color: const Color(0xFF1F2937)),

            // Right Login Form Card
            Expanded(
              flex: 6,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
                child: _buildLoginForm(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single-Panel Responsive Layout for Smaller Displays
  Widget _buildCompactLayout(BuildContext context, AppStateProvider state, dynamic school) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSchoolMiniHeader(school),
          const SizedBox(height: 14),
          _buildLoginForm(state),
        ],
      ),
    );
  }

  // Left Hero Side with School Crest, Features & Guarantee Badges
  Widget _buildHeroPanel(dynamic school, AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Brand & School Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SchoolLogoWidget(
                    logoUrl: (school.softwareLogoUrl != null && school.softwareLogoUrl!.isNotEmpty)
                        ? school.softwareLogoUrl
                        : 'assets/images/isecure_favicon.png',
                    size: 42,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                          ),
                          child: const Text(
                            '॥ शिक्षण हेच जीवन ॥',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF93C5FD)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          school.schoolName.isNotEmpty ? school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${school.sansthaName.isNotEmpty ? school.sansthaName : "शालेय शिक्षण व क्रीडा विभाग, महाराष्ट्र शासन"} • U-DISE: ${school.udiseCode.isNotEmpty ? school.udiseCode : "27260105501"}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),

              // Feature Highlights List
              const Text(
                'प्रणालीची मुख्य वैशिष्ट्ये (Key Capabilities):',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
              ),
              const SizedBox(height: 10),
              _buildFeatureRow(
                icon: Icons.calculate_outlined,
                color: const Color(0xFF38BDF8),
                title: 'CCE 8.1 सर्वंकष मूल्यमापन',
                subtitle: 'आकारिक व संकलित स्वयंचलित गुणनोंद व श्रेण्या',
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                icon: Icons.history_edu,
                color: const Color(0xFF34D399),
                title: 'शाळा सोडल्याचा दाखला (L.C.) व उतारा',
                subtitle: 'रजिस्टर नं. १ चा अधिकृत उतारा व दाखला ट्रॅकिंग',
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                icon: Icons.assignment_ind_outlined,
                color: const Color(0xFFFBBF24),
                title: 'सुरक्षित वर्गशिक्षक वाटप',
                subtitle: 'प्रत्येक शिक्षकाला फक्त वाटप वर्गाचा सुरक्षित प्रवेश',
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                icon: Icons.cloud_off,
                color: const Color(0xFFA78BFA),
                title: '१००% ऑफलाइन सुरक्षित डेटा',
                subtitle: 'स्थानिक सुरक्षित संचयन, इंटरनेटशिवाय सुरळीत कार्य',
              ),
            ],
          ),

          // Bottom System Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Color(0xFF334155), height: 18),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'iSecure EduMaster CCE Pro',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'आवृत्ती v1.2.0 • बिल्ड 3',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF475569)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.headset_mic_outlined, size: 12, color: Color(0xFF38BDF8)),
                        SizedBox(width: 5),
                        Text(
                          'Help: 9326770568',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolMiniHeader(dynamic school) {
    return Column(
      children: [
        SchoolLogoWidget(
          logoUrl: (school.softwareLogoUrl != null && school.softwareLogoUrl!.isNotEmpty)
              ? school.softwareLogoUrl
              : 'assets/images/isecure_favicon.png',
          size: 48,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 8),
        Text(
          school.schoolName.isNotEmpty ? school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 2),
        const Text(
          '॥ शिक्षण हेच जीवन ॥ • iSecure EduMaster CCE Pro',
          style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  // Right Side Login Form Widget (Compact)
  Widget _buildLoginForm(AppStateProvider state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isStudentLoginMode
                          ? 'विद्यार्थी व पालक लॉगिन'
                          : 'प्रणालीमध्ये प्रवेश करा (Sign In)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isStudentLoginMode
                          ? 'विद्यार्थी वैयक्तिक खात्यात थेट प्रवेश करा'
                          : 'आपल्या अधिकृत खात्याचे तपशील प्रविष्ट करा',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month, size: 12, color: Color(0xFF1D4ED8)),
                    const SizedBox(width: 4),
                    Text(
                      'सन ${state.currentYear.yearName}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Portal / Staff Mode Switcher Tabs
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isStudentLoginMode = true;
                        _errorMessage = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: _isStudentLoginMode ? const Color(0xFF0284C7) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isStudentLoginMode
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 15,
                            color: _isStudentLoginMode ? Colors.white : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'विद्यार्थी व पालक',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _isStudentLoginMode ? Colors.white : const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isStudentLoginMode = false;
                        _errorMessage = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: !_isStudentLoginMode ? const Color(0xFF2563EB) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_isStudentLoginMode
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 15,
                            color: !_isStudentLoginMode ? Colors.white : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'शिक्षक व कर्मचारी',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: !_isStudentLoginMode ? Colors.white : const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Error Alert Banner
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (_isStudentLoginMode) ...[
            // Student Login Form - ZERO ROLES SHOWN
            const Text(
              'जनरल रजिस्टर नंबर (GR No.) / सरल आयडी',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _studentGrCtrl,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'उदा. 780, 101 किंवा सरल आयडी',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF0284C7)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.6),
                ),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'कृपया GR नंबर प्रविष्ट करा' : null,
            ),
            const SizedBox(height: 8),

            const Text(
              'पासवर्ड किंवा जन्मतारीख (Password / DOB)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _studentPassCtrl,
              obscureText: _obscureStudentPass,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'जन्मतारीख (उदा. 15082015) किंवा पासवर्ड',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF0284C7)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureStudentPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: const Color(0xFF64748B),
                  ),
                  tooltip: _obscureStudentPass ? 'पासवर्ड दाखवा' : 'पासवर्ड लपवा',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _obscureStudentPass = !_obscureStudentPass);
                  },
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.6),
                ),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'कृपया पासवर्ड किंवा जन्मतारीख प्रविष्ट करा' : null,
              onFieldSubmitted: (_) => _handleStudentLogin(state),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 15, color: Color(0xFF0284C7)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'प्रत्येक विद्यार्थ्याचे स्वतंत्र वैयक्तिक खाते आहे. पहिल्यांदा लॉगिन करताना जन्मतारीख (उदा. 15082015) किंवा "123" वापरा.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF0369A1), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Student Submit Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleStudentLogin(state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0xFF0284C7).withOpacity(0.35),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school, size: 17),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'विद्यार्थी पोर्टलमध्ये प्रवेश करा',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ] else ...[
            // Staff Login Form (Teachers, HM, Peon, Admin, Superadmin)
            const Text(
              'वापरकर्ता नाव (Username / Login ID)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _usernameCtrl,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'उदा. isecure, superadmin, admin, teacher1',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                prefixIcon: const Icon(Icons.person_outline, size: 18, color: Color(0xFF2563EB)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.6),
                ),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'कृपया वापरकर्ता नाव प्रविष्ट करा' : null,
            ),
            const SizedBox(height: 8),

            // Password Field
            const Text(
              'पासवर्ड (Password)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'आपला गुप्त पासवर्ड प्रविष्ट करा',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
                prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF2563EB)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: const Color(0xFF64748B),
                  ),
                  tooltip: _obscurePassword ? 'पासवर्ड दाखवा' : 'पासवर्ड लपवा',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.6),
                ),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'कृपया पासवर्ड प्रविष्ट करा' : null,
              onFieldSubmitted: (_) => _handleLogin(),
            ),

            // Dynamic 5-Role Selection List (Only for staff!)
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 4),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 2),
                child: _buildRoleSelectionList(),
              ),
              crossFadeState: _showRoleSelection
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            const SizedBox(height: 12),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0xFF0D6EFD).withOpacity(0.35),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 17),
                          SizedBox(width: 8),
                          Text(
                            'लॉगिन करा (Sign In)',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                          ),
                        ],
                      ),
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Divider with "किंवा"
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('किंवा', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
              ),
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 8),

          // Direct Student & Parent Portal Access Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E88E5),
                side: const BorderSide(color: Color(0xFF1E88E5), width: 1.2),
                backgroundColor: const Color(0xFFF0F9FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentParentPortalScreen()),
                );
              },
              icon: const Icon(Icons.school, size: 17, color: Color(0xFF1E88E5)),
              label: const Text(
                'विद्यार्थी व पालक पोर्टल (थेट पूर्वावलोकन) 📱',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Security footnote
          const Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 12, color: Color(0xFF94A3B8)),
                SizedBox(width: 5),
                Text(
                  'ऑफलाइन सुरक्षित मोड • १००% स्थानिक एन्क्रिप्शन डेटाबेस',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // The 5 Roles list widget (Compact)
  Widget _buildRoleSelectionList() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_ind, size: 14, color: Color(0xFF0D6EFD)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'भूमिका निवडा (Select Login Role):',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '५ भूमिका',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 5 Roles List
          Column(
            children: roleOptions.map((item) {
              final rVal = item['role'] as String;
              final isSelected = _selectedRole == rVal;
              final color = item['color'] as Color;
              final bg = item['bg'] as Color;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedRole = rVal;
                    _errorMessage = null;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.only(bottom: 3.5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? bg : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Radio check indicator
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 14,
                        color: isSelected ? color : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),

                      // Role Icon Badge
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: isSelected ? color : const Color(0xFFF1F5F9),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 11,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Role Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : const Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              item['sub'] as String,
                              style: TextStyle(
                                fontSize: 8.5,
                                color: isSelected ? color.withOpacity(0.85) : const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'निवडले ✓',
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
