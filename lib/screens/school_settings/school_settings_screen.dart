import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/preset_logos.dart';
import '../../providers/app_state_provider.dart';
import '../../data/models/working_days_model.dart';
import '../../widgets/school_logo_widget.dart';
import '../../core/services/app_update_service.dart';

class SchoolSettingsScreen extends StatefulWidget {
  const SchoolSettingsScreen({super.key});

  @override
  State<SchoolSettingsScreen> createState() => _SchoolSettingsScreenState();
}

class _SchoolSettingsScreenState extends State<SchoolSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // School Profile Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _sansthaCtrl;
  late TextEditingController _udiseCtrl;
  late TextEditingController _boardCtrl;
  late TextEditingController _mediumCtrl;
  late TextEditingController _clusterCtrl;
  late TextEditingController _talukaCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _hmNameCtrl;
  late TextEditingController _hmMobileCtrl;
  late TextEditingController _logoUrlCtrl;

  // Academic Year & Reopening
  late TextEditingController _reopeningMsgCtrl;
  late TextEditingController _newYearNameCtrl;

  // Working Days Controllers
  late TextEditingController _junCtrl;
  late TextEditingController _julCtrl;
  late TextEditingController _augCtrl;
  late TextEditingController _sepCtrl;
  late TextEditingController _octCtrl;
  late TextEditingController _novCtrl;
  late TextEditingController _decCtrl;
  late TextEditingController _janCtrl;
  late TextEditingController _febCtrl;
  late TextEditingController _marCtrl;
  late TextEditingController _aprCtrl;

  // Whitelabel & Reseller License Controllers
  late TextEditingController _softwareTitleCtrl;
  late TextEditingController _softwareLogoUrlCtrl;
  late TextEditingController _vendorNameCtrl;
  late TextEditingController _vendorContactCtrl;
  late TextEditingController _vendorEmailCtrl;
  late TextEditingController _licenseKeyCtrl;
  late TextEditingController _licenseExpiryCtrl;
  late TextEditingController _minPassingCtrl;

  // Cloud Sync Controllers
  late TextEditingController _supabaseUrlCtrl;
  late TextEditingController _supabaseKeyCtrl;

  bool _isSyncingCloud = false;
  bool _isSuperAdminUnlocked = false;
  final TextEditingController _superAdminPinCtrl = TextEditingController();
  bool _pinObscure = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    final state = context.read<AppStateProvider>();
    final s = state.school;
    final wd = state.workingDays;

    _nameCtrl = TextEditingController(text: s.schoolName);
    _sansthaCtrl = TextEditingController(text: s.sansthaName);
    _udiseCtrl = TextEditingController(text: s.udiseCode);
    _boardCtrl = TextEditingController(text: s.board);
    _mediumCtrl = TextEditingController(text: s.medium);
    _clusterCtrl = TextEditingController(text: s.cluster);
    _talukaCtrl = TextEditingController(text: s.blockTaluka);
    _districtCtrl = TextEditingController(text: s.district);
    _addressCtrl = TextEditingController(text: s.address);
    _pincodeCtrl = TextEditingController(text: s.pincode);
    _phoneCtrl = TextEditingController(text: s.contactPhone);
    _emailCtrl = TextEditingController(text: s.schoolEmail);
    _hmNameCtrl = TextEditingController(text: s.headmasterName);
    _hmMobileCtrl = TextEditingController(text: s.headmasterMobile);
    _logoUrlCtrl = TextEditingController(text: s.logoUrl ?? '');

    _reopeningMsgCtrl = TextEditingController(text: state.currentYear.reopeningMessage);
    _newYearNameCtrl = TextEditingController();

    _junCtrl = TextEditingController(text: wd.jun.toString());
    _julCtrl = TextEditingController(text: wd.jul.toString());
    _augCtrl = TextEditingController(text: wd.aug.toString());
    _sepCtrl = TextEditingController(text: wd.sep.toString());
    _octCtrl = TextEditingController(text: wd.oct.toString());
    _novCtrl = TextEditingController(text: wd.nov.toString());
    _decCtrl = TextEditingController(text: wd.dec.toString());
    _janCtrl = TextEditingController(text: wd.jan.toString());
    _febCtrl = TextEditingController(text: wd.feb.toString());
    _marCtrl = TextEditingController(text: wd.mar.toString());
    _aprCtrl = TextEditingController(text: wd.apr.toString());

    _softwareTitleCtrl = TextEditingController(text: s.softwareTitle);
    _softwareLogoUrlCtrl = TextEditingController(
      text: (s.softwareLogoUrl != null && s.softwareLogoUrl!.isNotEmpty)
          ? s.softwareLogoUrl!
          : 'assets/images/isecure_favicon.png',
    );
    _vendorNameCtrl = TextEditingController(text: s.vendorName);
    _vendorContactCtrl = TextEditingController(text: s.vendorContact);
    _vendorEmailCtrl = TextEditingController(text: s.vendorEmail);
    _licenseKeyCtrl = TextEditingController(text: s.licenseKey);
    _licenseExpiryCtrl = TextEditingController(text: s.licenseExpiryDate);
    _minPassingCtrl = TextEditingController(text: s.minPassingPercentage.toString());

    _supabaseUrlCtrl = TextEditingController(text: state.supabaseUrl);
    _supabaseKeyCtrl = TextEditingController(text: state.supabaseAnonKey);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _sansthaCtrl.dispose();
    _udiseCtrl.dispose();
    _boardCtrl.dispose();
    _mediumCtrl.dispose();
    _clusterCtrl.dispose();
    _talukaCtrl.dispose();
    _districtCtrl.dispose();
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _hmNameCtrl.dispose();
    _hmMobileCtrl.dispose();
    _logoUrlCtrl.dispose();

    _reopeningMsgCtrl.dispose();
    _newYearNameCtrl.dispose();

    _junCtrl.dispose();
    _julCtrl.dispose();
    _augCtrl.dispose();
    _sepCtrl.dispose();
    _octCtrl.dispose();
    _novCtrl.dispose();
    _decCtrl.dispose();
    _janCtrl.dispose();
    _febCtrl.dispose();
    _marCtrl.dispose();
    _aprCtrl.dispose();

    _softwareTitleCtrl.dispose();
    _softwareLogoUrlCtrl.dispose();
    _vendorNameCtrl.dispose();
    _vendorContactCtrl.dispose();
    _vendorEmailCtrl.dispose();
    _licenseKeyCtrl.dispose();
    _licenseExpiryCtrl.dispose();
    _minPassingCtrl.dispose();

    _supabaseUrlCtrl.dispose();
    _supabaseKeyCtrl.dispose();
    _superAdminPinCtrl.dispose();
    super.dispose();
  }

  void _saveAllSettings() {
    final state = context.read<AppStateProvider>();
    final updatedSchool = state.school.copyWith(
      schoolName: _nameCtrl.text.trim(),
      sansthaName: _sansthaCtrl.text.trim(),
      udiseCode: _udiseCtrl.text.trim(),
      board: _boardCtrl.text.trim(),
      medium: _mediumCtrl.text.trim(),
      cluster: _clusterCtrl.text.trim(),
      blockTaluka: _talukaCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      schoolEmail: _emailCtrl.text.trim(),
      headmasterName: _hmNameCtrl.text.trim(),
      headmasterMobile: _hmMobileCtrl.text.trim(),
      logoUrl: _logoUrlCtrl.text.trim().isNotEmpty ? _logoUrlCtrl.text.trim() : null,
      softwareTitle: _softwareTitleCtrl.text.trim(),
      softwareLogoUrl: _softwareLogoUrlCtrl.text.trim().isNotEmpty
          ? _softwareLogoUrlCtrl.text.trim()
          : 'assets/images/isecure_favicon.png',
      vendorName: _vendorNameCtrl.text.trim(),
      vendorContact: _vendorContactCtrl.text.trim(),
      vendorEmail: _vendorEmailCtrl.text.trim(),
      licenseKey: _licenseKeyCtrl.text.trim(),
      licenseExpiryDate: _licenseExpiryCtrl.text.trim(),
      minPassingPercentage: int.tryParse(_minPassingCtrl.text.trim()) ?? 35,
    );

    state.updateSchool(updatedSchool);
    state.currentYear.reopeningMessage = _reopeningMsgCtrl.text.trim();

    // Save Working Days
    final updatedWd = WorkingDaysModel(
      id: state.workingDays.id,
      schoolId: state.school.id,
      academicYearId: state.currentYear.id,
      standard: state.selectedStd,
      division: state.selectedDiv,
      jun: int.tryParse(_junCtrl.text) ?? 12,
      jul: int.tryParse(_julCtrl.text) ?? 24,
      aug: int.tryParse(_augCtrl.text) ?? 23,
      sep: int.tryParse(_sepCtrl.text) ?? 22,
      oct: int.tryParse(_octCtrl.text) ?? 18,
      nov: int.tryParse(_novCtrl.text) ?? 19,
      dec: int.tryParse(_decCtrl.text) ?? 24,
      jan: int.tryParse(_janCtrl.text) ?? 24,
      feb: int.tryParse(_febCtrl.text) ?? 22,
      mar: int.tryParse(_marCtrl.text) ?? 24,
      apr: int.tryParse(_aprCtrl.text) ?? 20,
    );
    state.updateWorkingDays(updatedWd);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('सर्व सेटिंग्ज व शाळा माहिती यशस्वीरित्या जतन केली!'),
        backgroundColor: AppColors.gradeA1,
      ),
    );
  }

  Future<void> _testSupabase() async {
    final state = context.read<AppStateProvider>();
    final url = _supabaseUrlCtrl.text.trim();
    final key = _supabaseKeyCtrl.text.trim();
    if (url.isEmpty || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया Supabase URL आणि Anon Key भरा.'),
          backgroundColor: AppColors.gradeD,
        ),
      );
      return;
    }

    final success = await state.connectSupabase(url, key);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supabase Cloud जोडणी यशस्वी झाली! Online Sync Active.'),
          backgroundColor: AppColors.gradeA1,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supabase जोडणी अयशस्वी! कृपया URL किंवा Key तपासा.'),
          backgroundColor: AppColors.gradeD,
        ),
      );
    }
  }

  Future<void> _syncAllToCloud() async {
    final state = context.read<AppStateProvider>();
    if (!state.isCloudConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('प्रथम Supabase Cloud जोडणी कनेक्ट करा.'),
          backgroundColor: AppColors.gradeD,
        ),
      );
      return;
    }

    setState(() => _isSyncingCloud = true);
    final success = await state.syncAllDataToCloud();
    setState(() => _isSyncingCloud = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('शाळा, विद्यार्थी, गुण व हजेरी क्लाउडवर यशस्वीरित्या सिंक झाले!'),
          backgroundColor: AppColors.gradeA1,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('क्लाउड सिंक करताना अडचण आली. कृपया इंटरनेट तपासा.'),
          backgroundColor: AppColors.gradeD,
        ),
      );
    }
  }

  Future<void> _pickLogoFromPc() async {
    try {
      final scriptPath = 'scripts\\pick_image.ps1';
      final result = await Process.run('powershell', [
        '-ExecutionPolicy', 'Bypass',
        '-File', scriptPath,
      ]);
      final pickedPath = result.stdout.toString().trim();
      if (pickedPath.isNotEmpty) {
        final file = File(pickedPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final ext = pickedPath.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
          final base64Image = 'data:image/$ext;base64,${base64Encode(bytes)}';
          setState(() {
            _logoUrlCtrl.text = base64Image;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('शाळेचा लोगो यशस्वीरित्या निवडला! सेव्ह करण्यासाठी वरील "सर्व बदल सेव्ह करा" दाबा.'),
                backgroundColor: AppColors.gradeA1,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Logo pick error: $e');
    }
  }

  void _selectPresetLogo(String logoData) {
    setState(() {
      _logoUrlCtrl.text = logoData;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('नमुना बोधचिन्ह निवडले! सेव्ह करण्यासाठी वरील "सर्व बदल सेव्ह करा" दाबा.'),
        backgroundColor: AppColors.gradeA1,
      ),
    );
  }

  void _removeLogo() {
    setState(() {
      _logoUrlCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('शाळेचा लोगो काढण्यात आला आहे.'),
        backgroundColor: AppColors.gradeD,
      ),
    );
  }

  Future<void> _pickSoftwareLogoFromPc() async {
    try {
      final scriptPath = 'scripts\\pick_image.ps1';
      final result = await Process.run('powershell', [
        '-ExecutionPolicy', 'Bypass',
        '-File', scriptPath,
      ]);
      final pickedPath = result.stdout.toString().trim();
      if (pickedPath.isNotEmpty) {
        final file = File(pickedPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final ext = pickedPath.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
          final base64Image = 'data:image/$ext;base64,${base64Encode(bytes)}';
          setState(() {
            _softwareLogoUrlCtrl.text = base64Image;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('सॉफ्टवेअर ब्रँड लोगो व फेव्हिकॉन निवडला! सेव्ह करण्यासाठी वरील "सर्व बदल सेव्ह करा" दाबा.'),
                backgroundColor: AppColors.gradeA1,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Software logo pick error: $e');
    }
  }

  void _resetSoftwareLogoToDefault() {
    setState(() {
      _softwareLogoUrlCtrl.text = 'assets/images/isecure_favicon.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('मूळ अधिकृत iSecure ब्रँड लोगो व फेव्हिकॉन रिस्टोअर केला!'),
        backgroundColor: AppColors.gradeA1,
      ),
    );
  }

  void _exportBackupJson() {
    final state = context.read<AppStateProvider>();
    final jsonStr = state.exportSchoolDataAsJson();
    Clipboard.setData(ClipboardData(text: jsonStr));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download_done, color: AppColors.gradeA1),
            SizedBox(width: 8),
            Text('डेटा बॅकअप तयार झाला (JSON Backup)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'शाळेचा संपूर्ण डेटा (शाळा माहिती, सर्व विद्यार्थी, आकारिक/संकलित गुण, वर्णनात्मक नोंदी, हजेरी व कामाचे दिवस) यशस्वीरित्या तयार केला गेला आहे.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.content_copy, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'हा सर्व JSON डेटा क्लिपबोर्डवर (Clipboard) कॉपी करण्यात आला आहे! तुम्ही हा डेटा फाईलमध्ये सुरक्षित सेव्ह करू शकता.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ठीक आहे (OK)'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final importCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('बॅकअप डेटा इंपोर्ट करा (Restore Backup)'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'येथे आधी एक्सपोर्ट केलेला JSON डेटा पेस्ट करा:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: importCtrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: '{\n  "software_version": "CCE 8.1 PRO", ...\n}',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              final text = importCtrl.text.trim();
              if (text.isEmpty) return;
              final state = context.read<AppStateProvider>();
              final ok = await state.importSchoolDataFromJson(text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('डेटा यशस्वीरित्या रिस्टोअर झाला!'),
                      backgroundColor: AppColors.gradeA1,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('चुकीचा JSON फॉरमॅट! डेटा लोड होऊ शकला नाही.'),
                      backgroundColor: AppColors.gradeD,
                    ),
                  );
                }
              }
            },
            child: const Text('इंपोर्ट करा (Restore)'),
          ),
        ],
      ),
    );
  }

  void _showResetForNewSchoolDialog() {
    final newSchoolNameCtrl = TextEditingController();
    final newSansthaNameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.gradeD),
            SizedBox(width: 8),
            Text('नवीन शाळेसाठी डेटा रिसेट (Clean School Setup)'),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'हे फिचर जेव्हा तुम्ही सॉफ्टवेअर दुसऱ्या नवीन शाळेला विकता तेव्हा वापरले जाते.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'यामुळे जुन्या शाळेचे सर्व विद्यार्थी, त्यांचे गुण व हजेरी पूर्णपणे रिकामे केले जातील. CCE नियम, विषय, श्रेणी रचना व सॉफ्टवेअर सेटिंग्ज अबाधित राहतील.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 24),
              TextField(
                controller: newSchoolNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'नवीन शाळेचे नाव (New School Name)',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newSansthaNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'संस्थेचे नाव (Sanstha Name)',
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gradeD),
            onPressed: () async {
              final state = context.read<AppStateProvider>();
              await state.resetDataForNewSchool(
                newSchoolName: newSchoolNameCtrl.text,
                newSansthaName: newSansthaNameCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                setState(() {
                  _nameCtrl.text = state.school.schoolName;
                  _sansthaCtrl.text = state.school.sansthaName;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('नवीन शाळेसाठी सॉफ्टवेअर यशस्वीरित्या तयार केले!'),
                    backgroundColor: AppColors.gradeA1,
                  ),
                );
              }
            },
            child: const Text('होय, फ्रेश रिसेट करा (Clean Reset)'),
          ),
        ],
      ),
    );
  }

  void _unlockSuperAdmin() {
    final pin = _superAdminPinCtrl.text.trim();
    if (pin == 'Admin@1998') {
      setState(() {
        _isSuperAdminUnlocked = true;
        _superAdminPinCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('सुपर ॲडमिन मोड यशस्वीरित्या अनलॉक झाला! (SuperAdmin Access Granted)'),
          backgroundColor: AppColors.gradeA1,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('चुकीचा पासवर्ड! केवळ अधिकृत सुपर ॲडमिनला प्रवेश आहे.'),
          backgroundColor: AppColors.gradeD,
        ),
      );
    }
  }

  void _lockSuperAdmin() {
    setState(() {
      _isSuperAdminUnlocked = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('सुपर ॲडमिन मोड सुरक्षितपणे लॉक केला आहे.'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  void _generateNewLicenseKey() {
    final udise = _udiseCtrl.text.trim().isNotEmpty ? _udiseCtrl.text.trim() : '27260105501';
    final year = DateTime.now().year;
    final randPart = (DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    final udiseSuffix = udise.length >= 4 ? udise.substring(udise.length - 4) : '9326';
    final generatedKey = 'IS-EDU-$year-$udiseSuffix-$randPart-PRO';

    setState(() {
      _licenseKeyCtrl.text = generatedKey;
      _licenseExpiryCtrl.text = '${year + 1}-06-30';
    });

    Clipboard.setData(ClipboardData(text: generatedKey));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.vpn_key, color: AppColors.accent),
            SizedBox(width: 8),
            Text('नवीन परवाना की जनरेट झाली!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'iSecure Systems Pvt. Ltd. द्वारे प्रमाणित नवीन शाळा परवाना की:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: SelectableText(
                generatedKey,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• ही की क्लिपबोर्डवर आपोआप कॉपी करण्यात आली आहे.\n'
              '• परवाना कालावधी: १ वर्ष (पुढील वर्षाच्या ३० जूनपर्यंत वैध).\n'
              '• शाळा U-DISE कोडनुसार क्रिप्टोग्राफिक सिक्युरिटी लॉक लागू केला आहे.\n'
              '• तांत्रिक मदत: 9326770568 | isecuredeveloper@gmail.com',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ठीक आहे (Apply Key)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminLockGate({required String title, required String desc}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.security, size: 36, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // iSecure Systems Company Info Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('सॉफ्टवेअर मालक: iSecure Systems Pvt. Ltd.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text('हेल्पलाइन: 9326770568', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.email, size: 16, color: AppColors.teal),
                        SizedBox(width: 8),
                        Text('ईमेल: isecuredeveloper@gmail.com', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // PIN Field
              TextFormField(
                controller: _superAdminPinCtrl,
                obscureText: _pinObscure,
                decoration: InputDecoration(
                  labelText: 'सुपर ॲडमिन पासवर्ड टाका',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_pinObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _pinObscure = !_pinObscure),
                  ),
                ),
                onFieldSubmitted: (_) => _unlockSuperAdmin(),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _unlockSuperAdmin,
                  icon: const Icon(Icons.lock_open, size: 18),
                  label: const Text('प्रवेश अनलॉक करा (Unlock SuperAdmin Mode)'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'iSecure EduMaster - शाळा व सॉफ्टवेअर सेटिंग्ज',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isSuperAdminUnlocked) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gradeA1.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.gradeA1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, size: 16, color: AppColors.gradeA1),
                  SizedBox(width: 6),
                  Text('सुपर ॲडमिन मोड सक्रिय', style: TextStyle(color: AppColors.gradeA1, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _lockSuperAdmin,
              icon: const Icon(Icons.lock, size: 14, color: AppColors.gradeD),
              label: const Text('लॉक करा', style: TextStyle(color: AppColors.gradeD, fontSize: 11)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gradeD)),
            ),
            const SizedBox(width: 10),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: _saveAllSettings,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('सर्व बदल सेव्ह करा (Save All Settings)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            const Tab(icon: Icon(Icons.school, size: 18), text: 'शाळा माहिती (School Profile)'),
            const Tab(icon: Icon(Icons.calendar_month, size: 18), text: 'शैक्षणिक वर्ष व कामाचे दिवस'),
            const Tab(icon: Icon(Icons.rule, size: 18), text: 'CCE भारांश व ९-श्रेणी'),
            Tab(
              icon: Icon(_isSuperAdminUnlocked ? Icons.verified_user : Icons.lock, size: 18, color: _isSuperAdminUnlocked ? AppColors.gradeA1 : AppColors.accent),
              text: _isSuperAdminUnlocked ? 'ब्रँडिंग व परवाना' : 'ब्रँडिंग व परवाना 🔒',
            ),
            Tab(
              icon: Icon(_isSuperAdminUnlocked ? Icons.storage : Icons.lock, size: 18, color: _isSuperAdminUnlocked ? AppColors.gradeA1 : AppColors.accent),
              text: _isSuperAdminUnlocked ? 'बॅकअप व रिसेट' : 'बॅकअप व रिसेट 🔒',
            ),
            Tab(
              icon: Icon(_isSuperAdminUnlocked ? Icons.cloud_sync : Icons.lock, size: 18, color: _isSuperAdminUnlocked ? AppColors.gradeA1 : AppColors.accent),
              text: _isSuperAdminUnlocked ? 'Supabase Cloud' : 'Supabase Cloud 🔒',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSchoolProfileTab(),
          _buildAcademicYearAndWorkingDaysTab(),
          _buildCceRulesTab(),
          _isSuperAdminUnlocked
              ? _buildWhitelabelTab()
              : _buildSuperAdminLockGate(
                  title: 'सॉफ्टवेअर ब्रँडिंग व परवाना व्यवस्थापन',
                  desc: 'सॉफ्टवेअर ब्रँडिंग, कंपनी माहिती व नवीन परवाना की निर्मिती केवळ iSecure Systems Pvt. Ltd. सुपर ॲडमिनसाठी राखीव आहे.',
                ),
          _isSuperAdminUnlocked
              ? _buildBackupAndResetTab()
              : _buildSuperAdminLockGate(
                  title: 'डेटा बॅकअप, इंपोर्ट व नवीन शाळा रिसेट',
                  desc: 'डेटाबेस बॅकअप, रिस्टोअर व नवीन शाळेसाठी क्लीन डेटा रिसेट केवळ iSecure Systems सुपर ॲडमिन करू शकतात.',
                ),
          _isSuperAdminUnlocked
              ? _buildSupabaseTab()
              : _buildSuperAdminLockGate(
                  title: 'Supabase Cloud सिंक व क्रेडेंशियल्स',
                  desc: 'क्लाउड डेटाबेस जोडणी व बॅकएंड क्रेडेंशियल्स केवळ अधिकृत सुपर ॲडमिन कॉन्फिगर करू शकतात.',
                ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: SCHOOL PROFILE
  // -------------------------------------------------------------
  Widget _buildSchoolProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'शाळा व संस्थेची प्राथमिक माहिती (School & Trust Profile)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'येथे टाकलेली माहिती सर्व निकालपत्रके, प्रगती पुस्तके, बोनाफाईड प्रमाणपत्रे व ओळखपत्रांवर आपोआप छापली जाईल.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 32),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'शाळेचे पूर्ण नाव (School Name)',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sansthaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'संस्थेचे नाव (Sanstha / Trust Name)',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _udiseCtrl,
                      decoration: const InputDecoration(
                        labelText: 'U-DISE क्रमांक (UDISE Code)',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _boardCtrl,
                      decoration: const InputDecoration(
                        labelText: 'शिक्षण मंडळ (Board)',
                        prefixIcon: Icon(Icons.card_membership),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _mediumCtrl,
                      decoration: const InputDecoration(
                        labelText: 'माध्यम (Medium)',
                        prefixIcon: Icon(Icons.language),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _clusterCtrl,
                      decoration: const InputDecoration(
                        labelText: 'केंद्र (Cluster)',
                        prefixIcon: Icon(Icons.hub_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _talukaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'तालुका (Block / Taluka)',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _districtCtrl,
                      decoration: const InputDecoration(
                        labelText: 'जिल्हा (District)',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'शाळेचा पत्ता (School Address)',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pincodeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'पिनकोड (Pin Code)',
                        prefixIcon: Icon(Icons.pin_drop_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'शाळेचा फोन / संपर्क क्रमांक (Phone)',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'शाळेचा अधिकृत ईमेल (Official Email)',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'मुख्याध्यापक व स्वाक्षरी तपशील (Headmaster Information)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _hmNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'मुख्याध्यापकांचे पूर्ण नाव (Headmaster Name)',
                        prefixIcon: Icon(Icons.person_pin_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _hmMobileCtrl,
                      decoration: const InputDecoration(
                        labelText: 'मुख्याध्यापक मोबाईल (HM Mobile)',
                        prefixIcon: Icon(Icons.phone_android_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.image, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'शाळा बोधचिन्ह व लोगो व्यवस्थापन (School Logo & Seal)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'येथे सेट केलेला लोगो प्रगती पुस्तक, वार्षिक निकाल पत्रक, बोनाफाईड प्रमाणपत्र, डॅशबोर्ड व मेनूबारवर आपोआप दिसेल.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Live Logo Preview Box
                    SchoolLogoWidget(
                      logoUrl: _logoUrlCtrl.text.trim().isNotEmpty ? _logoUrlCtrl.text.trim() : null,
                      size: 72,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 20),

                    // Action Buttons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickLogoFromPc,
                                icon: const Icon(Icons.folder_open, size: 18),
                                label: const Text('संगणकावरून लोगो निवडा (Browse from PC)'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (ctx) => Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'तयार बोधचिन्ह संच निवडा (Select Preset Emblem)',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                          ),
                                          const SizedBox(height: 16),
                                          ListTile(
                                            leading: const SchoolLogoWidget(logoUrl: PresetLogos.zpLogo, size: 40),
                                            title: const Text('जिल्हा परिषद प्राथमिक शाळा बोधचिन्ह'),
                                            subtitle: const Text('महाराष्ट्र शासन अधिकृत ZP डिझाइन'),
                                            onTap: () {
                                              _selectPresetLogo(PresetLogos.zpLogo);
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                          const Divider(height: 1),
                                          ListTile(
                                            leading: const SchoolLogoWidget(logoUrl: PresetLogos.educationFlameLogo, size: 40),
                                            title: const Text('सर्व शिक्षा अभियान / ज्ञानदीप बोधचिन्ह'),
                                            subtitle: const Text('ज्ञान हेच बळ - ज्योत व पुस्तक डिझाइन'),
                                            onTap: () {
                                              _selectPresetLogo(PresetLogos.educationFlameLogo);
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                          const Divider(height: 1),
                                          ListTile(
                                            leading: const SchoolLogoWidget(logoUrl: PresetLogos.vidyaLogo, size: 40),
                                            title: const Text('सुवर्ण कलश / सरस्वती बोधचिन्ह'),
                                            subtitle: const Text('सा विद्या या विमुक्तये - सुवर्ण प्रतीक'),
                                            onTap: () {
                                              _selectPresetLogo(PresetLogos.vidyaLogo);
                                              Navigator.pop(ctx);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.collections_bookmark_outlined, size: 18),
                                label: const Text('नमुना बोधचिन्ह निवडा (Presets)'),
                              ),
                              if (_logoUrlCtrl.text.trim().isNotEmpty)
                                TextButton.icon(
                                  onPressed: _removeLogo,
                                  icon: const Icon(Icons.delete_outline, color: AppColors.gradeD, size: 18),
                                  label: const Text('लोगो काढा (Remove)', style: TextStyle(color: AppColors.gradeD)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _logoUrlCtrl,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'किंवा इमेज फाईल पाथ / वेब लिंक टाका (Path or URL)',
                              prefixIcon: Icon(Icons.link),
                              hintText: 'C:\\Users\\...\\logo.png किंवा https://...',
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: ACADEMIC YEAR & WORKING DAYS
  // -------------------------------------------------------------
  Widget _buildAcademicYearAndWorkingDaysTab() {
    final state = context.watch<AppStateProvider>();
    final years = state.academicYears;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Academic Year Selection & Creation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'सक्रिय शैक्षणिक वर्ष व संदेश (Active Academic Year & Reopening)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: state.currentYear.id,
                          decoration: const InputDecoration(
                            labelText: 'सक्रिय वर्ष निवडा (Current Active Year)',
                            prefixIcon: Icon(Icons.date_range),
                          ),
                          items: years.map((y) {
                            return DropdownMenuItem<String>(
                              value: y.id,
                              child: Text('शैक्षणिक वर्ष: ${y.yearName} ${y.isActive ? '(सक्रिय)' : ''}'),
                            );
                          }).toList(),
                          onChanged: (newId) {
                            if (newId != null) {
                              final yr = years.firstWhere((y) => y.id == newId);
                              state.setCurrentYear(yr);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('नवीन शैक्षणिक वर्ष जोडा'),
                              content: TextField(
                                controller: _newYearNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'शैक्षणिक वर्ष (उदा. 2026-27)',
                                  hintText: '2026-27',
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
                                ElevatedButton(
                                  onPressed: () {
                                    final text = _newYearNameCtrl.text.trim();
                                    if (text.isNotEmpty) {
                                      state.addNewAcademicYear(text);
                                      _newYearNameCtrl.clear();
                                      Navigator.pop(ctx);
                                    }
                                  },
                                  child: const Text('जोडा'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('नवीन वर्ष जोडा (Add Year)'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reopeningMsgCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'प्रगती पुस्तकावरील शाळा सुरू होण्याचा संदेश (Reopening Notice Message)',
                      prefixIcon: Icon(Icons.announcement_outlined),
                      hintText: 'उन्हाळी सुट्टीनंतर शाळा दिनांक १५ जून रोजी सुरू होईल.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Month-by-month working days editor
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.event_available, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'शाळेचे माहेवार कामकाजाचे दिवस (Monthly Working Days)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'इ. ${state.selectedStd} तुकडी ${state.selectedDiv} साठी कामकाजाचे दिवस (जून ते एप्रिल). यावरून उपस्थितीची टक्केवारी काढली जाते.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),

                  const Text(
                    'प्रथम सत्र (Semester 1: जून ते ऑक्टोबर)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMonthField('जून (Jun)', _junCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('जुलै (Jul)', _julCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('ऑगस्ट (Aug)', _augCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('सप्टेंबर (Sep)', _sepCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('ऑक्टोबर (Oct)', _octCtrl),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'द्वितीय सत्र (Semester 2: नोव्हेंबर ते एप्रिल)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMonthField('नोव्हेंबर (Nov)', _novCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('डिसेंबर (Dec)', _decCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('जानेवारी (Jan)', _janCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('फेब्रुवारी (Feb)', _febCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('मार्च (Mar)', _marCtrl),
                      const SizedBox(width: 12),
                      _buildMonthField('एप्रिल (Apr)', _aprCtrl),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthField(String label, TextEditingController ctrl) {
    return Expanded(
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: CCE EVALUATION & GRADING SCALE RULES
  // -------------------------------------------------------------
  Widget _buildCceRulesTab() {
    final state = context.watch<AppStateProvider>();
    final subjects = state.subjects;
    final grades = state.gradingScales;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weightage Summary Alert Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'महाराष्ट्र प्राथमिक शिक्षण परिषद CCE नियमावलीनुसार:\n'
                    '• इ. १ ली ते २ री: आकारिक ७०% + संकलित ३०% = एकूण १०० गुण\n'
                    '• इ. ३ री ते ४ थी: आकारिक ६०% + संकलित ४०% = एकूण १०० गुण\n'
                    '• इ. ५ वी ते ८ वी: आकारिक ५०% + संकलित ५०% = एकूण १०० गुण',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 9-Grade Scale Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'महाराष्ट्र शासन CCE ९-श्रेणी तक्ता (9-Point Grading Scale System)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: AppColors.border),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(3),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                        children: [
                          Padding(padding: EdgeInsets.all(8), child: Text('श्रेणी (Grade)', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('टक्केवारी मर्यादा (Percentage Range)', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('वर्णन (Remark / Description)', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      ...grades.map((g) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(g.gradeName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${g.minMarks.toInt()}% ते ${g.maxMarks.toInt()}%'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(g.description.isNotEmpty ? g.description : 'समाधानकारक प्रगती'),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Subjects Formative & Summative Weightages Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'विषयवार कमाल गुण रचना (Subject-wise Weightage Allocation)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: AppColors.border),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                        children: [
                          Padding(padding: EdgeInsets.all(8), child: Text('विषय (Subject)', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('लागू इयत्ता', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('आकारिक (FE)', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('संकलित (SE)', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('एकूण (Total)', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      ...subjects.map((sub) {
                        return TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(8), child: Text('${sub.shortName} (${sub.subjectNameMr})')),
                            Padding(padding: const EdgeInsets.all(8), child: Text('इ. ${sub.applicableStandards.join(', ')}')),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${sub.formativeMax}')),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${sub.summativeMax}')),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${sub.totalMax}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: WHITELABEL RESALE & LICENSE
  // -------------------------------------------------------------
  Widget _buildWhitelabelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Owner & Vendor Master Card
          Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.04),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.workspace_premium, color: AppColors.accent, size: 28),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'सॉफ्टवेअर ब्रँडिंग व विक्री परवाना (Whitelabel & Commercial Sale Settings)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'iSecure Systems Pvt. Ltd. अधिकृत सुपर ॲडमिन कन्सोल',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gradeA1.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gradeA1),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 16, color: AppColors.gradeA1),
                            SizedBox(width: 6),
                            Text(
                              'सक्रिय परवाना (Active Pro License)',
                              style: TextStyle(color: AppColors.gradeA1, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Company Contact & Owner Quick Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.business, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('सॉफ्टवेअर मालक (Software Owner)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  Text('iSecure Systems Pvt. Ltd.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 36, color: AppColors.border),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.phone_in_talk, size: 18, color: AppColors.accent),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('अधिकृत हेल्पलाइन (Helpline)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  Text('9326770568', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accent)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 36, color: AppColors.border),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.mail_outline, size: 18, color: AppColors.teal),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('सपोर्ट ईमेल (Official Email)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  Text('isecuredeveloper@gmail.com', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 32),

                  // Whitelabel Input Fields
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _softwareTitleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'सॉफ्टवेअर ब्रँड नाव (Software Title)',
                            prefixIcon: Icon(Icons.title),
                            hintText: 'उदा. iSecure EduMaster CCE Pro',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _vendorNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'कंपनीचे नाव (Vendor / Owner Name)',
                            prefixIcon: Icon(Icons.business),
                            hintText: 'iSecure Systems Pvt. Ltd.',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _vendorContactCtrl,
                          decoration: const InputDecoration(
                            labelText: 'हेल्पलाइन नंबर (Support Phone)',
                            prefixIcon: Icon(Icons.support_agent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _vendorEmailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'सपोर्ट ईमेल (Support Email)',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Card: SuperAdmin Only Software Brand Logo & Favicon Management
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF93C5FD), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: AppColors.primary, size: 26),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'सॉफ्टवेअर ब्रँड लोगो व फेव्हिकॉन व्यवस्थापन (Software Brand Logo & Favicon)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'हा लोगो व फेव्हिकॉन सॉफ्टवेअरची मुख्य ओळख आहे. हा बदलण्याचा अधिकार केवळ सुपर ॲडमिनला आहे.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF3B82F6)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.admin_panel_settings, size: 15, color: Color(0xFF1D4ED8)),
                            SizedBox(width: 5),
                            Text(
                              'केवळ सुपर ॲडमिन अधिकार',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Preview Box
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SchoolLogoWidget(
                              logoUrl: _softwareLogoUrlCtrl.text.trim().isNotEmpty
                                  ? _softwareLogoUrlCtrl.text.trim()
                                  : 'assets/images/isecure_favicon.png',
                              size: 76,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'सध्याचा ब्रँड फेव्हिकॉन',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),

                      // Control Buttons & Input
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickSoftwareLogoFromPc,
                                  icon: const Icon(Icons.upload_file, size: 18),
                                  label: const Text('संगणकावरून लोगो निवडा (Browse from PC)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _resetSoftwareLogoToDefault,
                                  icon: const Icon(Icons.restore, size: 18, color: AppColors.teal),
                                  label: const Text('मूळ iSecure लोगो रिस्टोअर करा (Default)'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.teal),
                                    foregroundColor: AppColors.teal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _softwareLogoUrlCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'सॉफ्टवेअर ब्रँड लोगो फाईल पाथ किंवा URL (Software Logo / Favicon Path)',
                                prefixIcon: Icon(Icons.link),
                                hintText: 'assets/images/isecure_favicon.png किंवा C:\\...\\brand_logo.png',
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '💡 टीप: शाळेचा निकालपत्रक लोगो शिक्षक टॅब १ (शाळा माहिती) मधून बदलू शकतात. परंतु संपूर्ण सॉफ्टवेअरची ब्रँडिंग व फेव्हिकॉन बदलण्याचा अधिकार केवळ iSecure Systems सुपर ॲडमिनकडेच सुरक्षित राहील.',
                              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // SuperAdmin Only: New License Key Generation Box
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFFDE68A), width: 1.5),
            ),
            color: const Color(0xFFFFFBEB),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.vpn_key_rounded, color: AppColors.accent, size: 24),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'नवीन शाळा परवाना की निर्मिती (SuperAdmin License Generator)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'नवीन शाळेला सॉफ्टवेअर देताना किंवा वार्षिक नूतनीकरणासाठी नवीन परवाना तयार करा.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _generateNewLicenseKey,
                        icon: const Icon(Icons.key, size: 18),
                        label: const Text('नवीन परवाना की जनरेट करा (Generate License Key)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'लागू शाळा: ${_nameCtrl.text.isNotEmpty ? _nameCtrl.text : "प्राथमिक शाळा"} | U-DISE कोड: ${_udiseCtrl.text.isNotEmpty ? _udiseCtrl.text : "उपलब्ध नाही"} (या कोडवर आधारित एनक्रिप्टेड की तयार केली जाईल)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Active License Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'परवाना तपशील व वैधता (Current License Details & Rules)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _licenseKeyCtrl,
                          decoration: InputDecoration(
                            labelText: 'व्यावसायिक परवाना की (Commercial License Key)',
                            prefixIcon: const Icon(Icons.vpn_key),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              tooltip: 'परवाना की कॉपी करा',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _licenseKeyCtrl.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('परवाना की क्लिपबोर्डवर कॉपी झाली!'),
                                    backgroundColor: AppColors.gradeA1,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _licenseExpiryCtrl,
                          decoration: const InputDecoration(
                            labelText: 'परवाना मुदत (Expiry Date)',
                            prefixIcon: Icon(Icons.date_range),
                            hintText: 'YYYY-MM-DD',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _minPassingCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'किमान उत्तीर्ण % (Pass %)',
                            prefixIcon: Icon(Icons.percent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Online Auto-Updates & GitHub Sync Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFC7D2FE), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.system_update_alt_rounded, color: AppColors.primary, size: 26),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ऑनलाइन सॉफ्टवेअर अपडेट्स व GitHub डिप्लॉयमेंट (Online Version Auto-Updater)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'GitHub वर नवीन व्हर्जन डिप्लॉय होताच सर्व शाळांच्या संगणकावर स्वयंचलित अपडेट उपलब्ध होते.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Consumer<AppStateProvider>(
                        builder: (context, state, _) {
                          return Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  AppUpdateService.launchUrl(AppUpdateService.repoUrl);
                                },
                                icon: const Icon(Icons.code, size: 16),
                                label: const Text('GitHub Repo'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: state.isCheckingUpdate
                                    ? null
                                    : () async {
                                        final update = await state.checkForUpdate();
                                        if (context.mounted) {
                                          if (update != null && update.hasUpdate) {
                                            AppUpdateService.showUpdateModal(context, update);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('नवीन अपडेट उपलब्ध नाही. आपले सॉफ्टवेअर अद्ययावत आहे! (v1.0.0)'),
                                                backgroundColor: AppColors.gradeA1,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                icon: state.isCheckingUpdate
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.refresh, size: 16),
                                label: Text(state.isCheckingUpdate ? 'तपासत आहे...' : 'आत्ताच अपडेट तपासा (Check Updates)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Repository & Version Status Bar
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Consumer<AppStateProvider>(
                      builder: (context, state, _) {
                        final hasUpdate = state.availableUpdate?.hasUpdate == true;
                        final latestVer = state.availableUpdate?.latestVersion ?? '1.0.0';

                        return Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.devices, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('सध्याची आवृत्ती (Installed Version)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      Text('v${AppUpdateService.currentVersion} (Build ${AppUpdateService.buildNumber})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 36, color: AppColors.border),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  const Icon(Icons.link, size: 18, color: AppColors.teal),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('GitHub अपडेट चॅनेल (Update Channel)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        SelectableText(
                                          AppUpdateService.repoUrl,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 36, color: AppColors.border),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: hasUpdate ? AppColors.accent.withOpacity(0.15) : AppColors.gradeA1.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: hasUpdate ? AppColors.accent : AppColors.gradeA1),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasUpdate ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                    size: 16,
                                    color: hasUpdate ? AppColors.accent : AppColors.gradeA1,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    hasUpdate
                                        ? 'नवीन व्हर्जन v$latestVer उपलब्ध!'
                                        : 'सॉफ्टवेअर अद्ययावत आहे (Up to date)',
                                    style: TextStyle(
                                      color: hasUpdate ? AppColors.accent : AppColors.gradeA1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Developer Guide Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'GitHub द्वारे सर्व शाळांना नवीन अपडेट्स कसे पाठवावे? (Developer Guide):',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '१. जेव्हा तुम्ही नवीन फीचर्स किंवा बग फिक्स कराल, तेव्हा GitHub वरील releases/tag मध्ये नवीन टॅग (उदा. v1.1.0) देऊन Release पब्लिश करा आणि .exe सेटअप फाईल अपलोड करा.\n'
                          '२. किंवा तुमच्या रेपॉझिटरीवरील "version.json" फाईलमध्ये आवृत्ती (उदा. "version": "1.1.0") बदलून पुश करा.\n'
                          '३. दुसऱ्या कोणत्याही संगणकावर चालू असलेले हे सॉफ्टवेअर इंटरनेट जोडलेले असताना आपोआप नवीन आवृत्ती शोधून युजर्सना एका क्लिकवर अपडेट नोटिफिकेशन आणि डाउनलोड देईल.',
                          style: TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF1E3A8A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 5: BACKUP, EXPORT & NEW SCHOOL RESET
  // -------------------------------------------------------------
  Widget _buildBackupAndResetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Export & Restore Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.backup, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'शाळा डेटा बॅकअप व रिस्टोअर (Data Backup & Restore)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'शाळेचा संपूर्ण डेटा सुरक्षित ठेवण्यासाठी नियमित बॅकअप घ्या. बॅकअप फाईल तुम्ही कधीही पुन्हा रिस्टोअर करू शकता.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _exportBackupJson,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('संपूर्ण डेटा बॅकअप एक्सपोर्ट करा (Export Backup)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _showImportDialog,
                        icon: const Icon(Icons.upload, size: 18),
                        label: const Text('बॅकअप डेटा रिस्टोअर करा (Import / Restore)'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Clean Reset for Selling to New School Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cleaning_services, color: AppColors.gradeD),
                      SizedBox(width: 8),
                      Text(
                        'नवीन शाळेसाठी डेटा रिसेट (Clean School Setup for New Sale)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gradeD),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'सॉफ्टवेअर नवीन शाळेला विकल्यावर किंवा नवीन वर्षाची नवीन शाळा नोंदणी करताना, एका क्लिकवर डेमो विद्यार्थी, गुण व हजेरी काढून फ्रेश ब्लँक डेटाबेस तयार करा.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),

                  ElevatedButton.icon(
                    onPressed: _showResetForNewSchoolDialog,
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text('नवीन शाळेसाठी फ्रेश डेटा रिसेट करा (Clean Reset)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradeD,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 6: SUPABASE CLOUD SYNC
  // -------------------------------------------------------------
  Widget _buildSupabaseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_sync, color: AppColors.teal),
                  SizedBox(width: 8),
                  Text(
                    'Supabase Cloud जोडणी व रिअल-टाइम सिंक (Cloud Backend Integration)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.teal),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Supabase द्वारे सर्व शाळा, विद्यार्थी, गुण आणि उपस्थिती डेटा सुरक्षितपणे क्लाउडवर सेव्ह होतो. एकापेक्षा जास्त संगणकांवरून किंवा फोनवरून काम करण्यासाठी हे उपयुक्त आहे.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 32),

              TextFormField(
                controller: _supabaseUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Supabase Project URL',
                  prefixIcon: Icon(Icons.link),
                  hintText: 'https://xyzcompany.supabase.co',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _supabaseKeyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Supabase Anon Public API Key',
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _testSupabase,
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('क्लाउड जोडणी तपासा (Test & Connect)'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isSyncingCloud ? null : _syncAllToCloud,
                    icon: _isSyncingCloud
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.cloud_upload, size: 18),
                    label: Text(_isSyncingCloud ? 'सिंक होत आहे...' : 'सर्व डेटा क्लाउडवर पाठवा (Push All to Cloud)'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Consumer<AppStateProvider>(
                    builder: (context, state, _) {
                      return Row(
                        children: [
                          Icon(
                            state.isCloudConnected ? Icons.check_circle : Icons.info_outline,
                            color: state.isCloudConnected ? AppColors.gradeA1 : AppColors.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.isCloudConnected
                                ? 'Supabase क्लाउड जोडलेले आहे (Online Sync Active)'
                                : 'स्थानिक ऑफलाइन मोड (Local Storage Mode)',
                            style: TextStyle(
                              color: state.isCloudConnected ? AppColors.gradeA1 : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
