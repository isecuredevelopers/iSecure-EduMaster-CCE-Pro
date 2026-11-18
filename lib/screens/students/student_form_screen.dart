import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/marathi_date_formatter.dart';
import '../../data/models/student_model.dart';
import '../../providers/app_state_provider.dart';

class StudentFormScreen extends StatefulWidget {
  final StudentModel? studentToEdit;
  final String? initialAcademicYearId;

  const StudentFormScreen({
    super.key,
    this.studentToEdit,
    this.initialAcademicYearId,
  });

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedAcademicYearId;

  // १. शालेय ओळख (School Identification)
  late TextEditingController _grNoCtrl;
  late TextEditingController _uDiseNoCtrl;
  late TextEditingController _saralIdCtrl;
  late TextEditingController _aadhaarNoCtrl;

  // २. विद्यार्थ्याची वैयक्तिक माहिती (Student Personal Info)
  late TextEditingController _nameMrCtrl;
  late TextEditingController _nameEnCtrl;
  late TextEditingController _fatherNameCtrl;
  late TextEditingController _motherNameCtrl;
  String _gender = 'M';
  late TextEditingController _nationalityCtrl;
  late TextEditingController _motherTongueCtrl;
  late TextEditingController _religionCtrl;
  late TextEditingController _casteCtrl;
  late TextEditingController _subCasteCtrl;
  String _casteCategory = 'OPEN';
  late TextEditingController _birthPlaceCtrl;
  late TextEditingController _talukaCtrl;
  late TextEditingController _districtCtrl;
  DateTime _dob = DateTime(2018, 1, 1);
  late TextEditingController _dobWordsCtrl;

  // ३. प्रवेश तपशील (Admission Details)
  late TextEditingController _previousSchoolCtrl;
  DateTime _admissionDate = DateTime.now();
  late int _standard;
  late String _division;
  late TextEditingController _rollSem1Ctrl;
  late TextEditingController _rollSem2Ctrl;
  late TextEditingController _remarksCtrl;

  // ४. अतिरिक्त संपर्क व शारीरिक माहिती (Additional Info)
  late TextEditingController _mobileNoCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _apaarIdCtrl;
  late TextEditingController _penNoCtrl;
  late TextEditingController _fatherWorkCtrl;
  late TextEditingController _motherWorkCtrl;
  late TextEditingController _heightSem1Ctrl;
  late TextEditingController _heightSem2Ctrl;
  late TextEditingController _weightSem1Ctrl;
  late TextEditingController _weightSem2Ctrl;

  bool _showAdditionalDetails = false;

  final List<String> _religionOptions = [
    'हिंदू',
    'मुस्लीम',
    'बौद्ध',
    'जैन',
    'ख्रिश्चन',
    'शीख',
    'लिंगायत',
    'इतर',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<AppStateProvider>();
    final s = widget.studentToEdit;

    _selectedAcademicYearId =
        s?.academicYearId ??
        widget.initialAcademicYearId ??
        state.currentYear.id;
    _standard = s?.standard ?? state.selectedStd;
    _division = s?.division ?? state.selectedDiv;

    // शालेय ओळख
    _grNoCtrl = TextEditingController(text: s?.grNo ?? '');
    _uDiseNoCtrl = TextEditingController(
      text: (s?.uDiseNo != null && s!.uDiseNo.isNotEmpty)
          ? s.uDiseNo
          : state.school.udiseCode,
    );
    _saralIdCtrl = TextEditingController(text: s?.saralId ?? '');
    _aadhaarNoCtrl = TextEditingController(text: s?.aadhaarNo ?? '');

    // वैयक्तिक माहिती
    _nameMrCtrl = TextEditingController(text: s?.studentNameMr ?? '');
    _nameEnCtrl = TextEditingController(text: s?.studentNameEn ?? '');
    _fatherNameCtrl = TextEditingController(text: s?.fatherName ?? '');
    _motherNameCtrl = TextEditingController(text: s?.motherName ?? '');
    _gender = s?.gender ?? 'M';
    _nationalityCtrl = TextEditingController(
      text: (s?.nationality != null && s!.nationality.isNotEmpty)
          ? s.nationality
          : 'भारतीय',
    );
    _motherTongueCtrl = TextEditingController(
      text: (s?.motherTongue != null && s!.motherTongue.isNotEmpty)
          ? s.motherTongue
          : 'मराठी',
    );
    _religionCtrl = TextEditingController(
      text: (s?.religion != null && s!.religion.isNotEmpty)
          ? s.religion
          : 'हिंदू',
    );
    _casteCtrl = TextEditingController(text: s?.caste ?? '');
    _subCasteCtrl = TextEditingController(text: s?.subCaste ?? '');
    _casteCategory = s?.casteCategory ?? 'OPEN';
    _birthPlaceCtrl = TextEditingController(text: s?.birthPlace ?? '');
    _talukaCtrl = TextEditingController(
      text: s?.taluka ?? state.school.blockTaluka,
    );
    _districtCtrl = TextEditingController(
      text: s?.district ?? state.school.district,
    );
    _dob = s?.dateOfBirth ?? DateTime(2018, 1, 1);
    _dobWordsCtrl = TextEditingController(
      text: (s?.dobWords != null && s!.dobWords.isNotEmpty)
          ? s.dobWords
          : MarathiDateFormatter.toMarathiWords(_dob),
    );

    // प्रवेश तपशील
    _previousSchoolCtrl = TextEditingController(text: s?.previousSchool ?? '');
    _admissionDate = s?.admissionDate ?? DateTime.now();
    _rollSem1Ctrl = TextEditingController(
      text: (s?.rollNoSem1 ?? 1).toString(),
    );
    _rollSem2Ctrl = TextEditingController(
      text: (s?.rollNoSem2 ?? (s?.rollNoSem1 ?? 1)).toString(),
    );
    _remarksCtrl = TextEditingController(text: s?.remarks ?? '');

    // संपर्क व शारीरिक
    _mobileNoCtrl = TextEditingController(text: s?.mobileNo ?? '');
    _addressCtrl = TextEditingController(
      text: s?.address ?? state.school.address,
    );
    _apaarIdCtrl = TextEditingController(text: s?.apaarId ?? '');
    _penNoCtrl = TextEditingController(text: s?.penNo ?? '');
    _fatherWorkCtrl = TextEditingController(
      text: s?.fatherOccupation ?? 'शेती',
    );
    _motherWorkCtrl = TextEditingController(
      text: s?.motherOccupation ?? 'गृहिणी',
    );
    _heightSem1Ctrl = TextEditingController(
      text: s?.heightSem1?.toString() ?? '',
    );
    _heightSem2Ctrl = TextEditingController(
      text: s?.heightSem2?.toString() ?? '',
    );
    _weightSem1Ctrl = TextEditingController(
      text: s?.weightSem1?.toString() ?? '',
    );
    _weightSem2Ctrl = TextEditingController(
      text: s?.weightSem2?.toString() ?? '',
    );

    if (s == null) {
      _autoSuggestGrNo();
      _updateRollNoForStandardAndDiv(_standard, _division);
    }
  }

  void _autoSuggestGrNo() {
    if (widget.studentToEdit != null) return;
    final state = context.read<AppStateProvider>();
    int maxGr = 0;
    for (var stu in state.students) {
      final parsed = int.tryParse(stu.grNo);
      if (parsed != null && parsed > maxGr) maxGr = parsed;
    }
    if (maxGr > 0) {
      _grNoCtrl.text = (maxGr + 1).toString();
    }
  }

  void _updateRollNoForStandardAndDiv(int std, String div) {
    if (widget.studentToEdit != null) return;
    final state = context.read<AppStateProvider>();
    final count = state.students
        .where(
          (s) =>
              s.standard == std &&
              s.division == div &&
              s.academicYearId == state.currentYear.id,
        )
        .length;
    final nextRoll = count + 1;
    _rollSem1Ctrl.text = nextRoll.toString();
    _rollSem2Ctrl.text = nextRoll.toString();
  }

  @override
  void dispose() {
    _grNoCtrl.dispose();
    _uDiseNoCtrl.dispose();
    _saralIdCtrl.dispose();
    _aadhaarNoCtrl.dispose();
    _nameMrCtrl.dispose();
    _nameEnCtrl.dispose();
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    _nationalityCtrl.dispose();
    _motherTongueCtrl.dispose();
    _religionCtrl.dispose();
    _casteCtrl.dispose();
    _subCasteCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _talukaCtrl.dispose();
    _districtCtrl.dispose();
    _dobWordsCtrl.dispose();
    _previousSchoolCtrl.dispose();
    _rollSem1Ctrl.dispose();
    _rollSem2Ctrl.dispose();
    _remarksCtrl.dispose();
    _mobileNoCtrl.dispose();
    _addressCtrl.dispose();
    _apaarIdCtrl.dispose();
    _penNoCtrl.dispose();
    _fatherWorkCtrl.dispose();
    _motherWorkCtrl.dispose();
    _heightSem1Ctrl.dispose();
    _heightSem2Ctrl.dispose();
    _weightSem1Ctrl.dispose();
    _weightSem2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1995),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobWordsCtrl.text = MarathiDateFormatter.toMarathiWords(picked);
      });
    }
  }

  Future<void> _pickAdmissionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _admissionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _admissionDate = picked;
      });
    }
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'कृपया आवश्यक माहिती भरा (Please fill all mandatory fields)',
          ),
          backgroundColor: AppColors.gradeD,
        ),
      );
      return;
    }

    final state = context.read<AppStateProvider>();
    final stu = StudentModel(
      id:
          widget.studentToEdit?.id ??
          'stu_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: state.school.id,
      academicYearId: _selectedAcademicYearId,
      standard: _standard,
      division: _division,
      grNo: _grNoCtrl.text.trim(),
      rollNoSem1: int.tryParse(_rollSem1Ctrl.text.trim()) ?? 1,
      rollNoSem2:
          int.tryParse(_rollSem2Ctrl.text.trim()) ??
          (int.tryParse(_rollSem1Ctrl.text.trim()) ?? 1),
      studentNameMr: _nameMrCtrl.text.trim(),
      studentNameEn: _nameEnCtrl.text.trim(),
      fatherName: _fatherNameCtrl.text.trim(),
      motherName: _motherNameCtrl.text.trim(),
      gender: _gender,
      casteCategory: _casteCategory,
      subCaste: _subCasteCtrl.text.trim(),
      dateOfBirth: _dob,
      birthPlace: _birthPlaceCtrl.text.trim(),
      taluka: _talukaCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      saralId: _saralIdCtrl.text.trim(),
      apaarId: _apaarIdCtrl.text.trim(),
      penNo: _penNoCtrl.text.trim(),
      aadhaarNo: _aadhaarNoCtrl.text.trim(),
      mobileNo: _mobileNoCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      fatherOccupation: _fatherWorkCtrl.text.trim(),
      motherOccupation: _motherWorkCtrl.text.trim(),
      uDiseNo: _uDiseNoCtrl.text.trim(),
      nationality: _nationalityCtrl.text.trim(),
      motherTongue: _motherTongueCtrl.text.trim(),
      religion: _religionCtrl.text.trim(),
      caste: _casteCtrl.text.trim(),
      dobWords: _dobWordsCtrl.text.trim(),
      previousSchool: _previousSchoolCtrl.text.trim(),
      admissionDate: _admissionDate,
      remarks: _remarksCtrl.text.trim(),
      heightSem1: double.tryParse(_heightSem1Ctrl.text.trim()),
      heightSem2: double.tryParse(_heightSem2Ctrl.text.trim()),
      weightSem1: double.tryParse(_weightSem1Ctrl.text.trim()),
      weightSem2: double.tryParse(_weightSem2Ctrl.text.trim()),
    );

    // Save and automatically switch active view to this standard
    state.addOrUpdateStudent(stu, switchToStudentClass: true);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.studentToEdit == null
                    ? 'नवीन प्रवेशाची माहिती यशस्वीरित्या जतन झाली! (इयत्ता ${MarathiDateFormatter.classToMarathi(_standard)} तुकडी $_division मध्ये जोडले)'
                    : 'विद्यार्थी माहिती यशस्वीरित्या अपडेट झाली!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isEditing = widget.studentToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'विद्यार्थी माहिती संपादन'
              : 'नवीन विद्यार्थी प्रवेश (New Admission)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: _saveStudent,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(isEditing ? 'माहिती जतन करा' : 'प्रवेश निश्चित करा'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF0D6EFD), width: 5),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 28,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.how_to_reg,
                                color: Color(0xFF0D6EFD),
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  isEditing
                                      ? 'विद्यार्थी माहिती संपादन (Edit Student Details)'
                                      : 'नवीन विद्यार्थी प्रवेश (New Admission)',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D6EFD),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'कृपया सर्व माहिती अचूक भरा (Please fill all information accurately)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // १. शालेय ओळख (School Identification)
                  _buildSectionCard(
                    icon: Icons.badge_outlined,
                    title: '१. शालेय ओळख',
                    content: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value:
                                    state.academicYears.any(
                                      (y) => y.id == _selectedAcademicYearId,
                                    )
                                    ? _selectedAcademicYearId
                                    : state.currentYear.id,
                                decoration: const InputDecoration(
                                  labelText: 'शैक्षणिक वर्ष (Academic Year) *',
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    size: 18,
                                  ),
                                ),
                                isExpanded: true,
                                items: state.academicYears.map((yr) {
                                  final isCurrent =
                                      yr.id == state.currentYear.id;
                                  return DropdownMenuItem(
                                    value: yr.id,
                                    child: Text(
                                      'सन ${yr.yearName}${isCurrent ? " (चालू वर्ष)" : ""}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(
                                      () => _selectedAcademicYearId = val,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _grNoCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'जनरल रजि. क्र. (GR No.) *',
                                  hintText: 'उदा. 785',
                                  prefixIcon: Icon(Icons.pin, size: 18),
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                    ? 'जनरल रजि. क्र. आवश्यक आहे'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _uDiseNoCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'यु डायस क्र. (U-DISE No.)',
                                  hintText: 'उदा. 27260105501',
                                  prefixIcon: Icon(Icons.school, size: 18),
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
                                controller: _saralIdCtrl,
                                maxLength: 19,
                                buildCounter:
                                    (
                                      ctx, {
                                      required currentLength,
                                      required isFocused,
                                      maxLength,
                                    }) => null,
                                decoration: const InputDecoration(
                                  labelText: 'स्टूडेंट आय. डी. (Saral ID)',
                                  hintText: '19 अंकी सरल आयडी',
                                  prefixIcon: Icon(Icons.numbers, size: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _aadhaarNoCtrl,
                                maxLength: 12,
                                keyboardType: TextInputType.number,
                                buildCounter:
                                    (
                                      ctx, {
                                      required currentLength,
                                      required isFocused,
                                      maxLength,
                                    }) => null,
                                decoration: const InputDecoration(
                                  labelText: 'आधार कार्ड क्रमांक (Aadhaar)',
                                  hintText: '12 अंकी आधार नंबर',
                                  prefixIcon: Icon(Icons.credit_card, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // २. विद्यार्थ्याची वैयक्तिक माहिती (Personal Details)
                  _buildSectionCard(
                    icon: Icons.person_outline,
                    title: '२. विद्यार्थ्याची वैयक्तिक माहिती',
                    content: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _nameMrCtrl,
                                decoration: const InputDecoration(
                                  labelText:
                                      'विद्यार्थ्याचे पूर्ण नाव (मराठीत) *',
                                  hintText:
                                      'नाव - वडिलांचे नाव - आडनाव (उदा. सचिन रमेश तेंडुलकर)',
                                  prefixIcon: Icon(Icons.person, size: 18),
                                ),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty)
                                    ? 'विद्यार्थ्याचे नाव आवश्यक आहे'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _motherNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'आईचे नाव (Mother Name)',
                                  hintText: 'उदा. अनघा',
                                  prefixIcon: Icon(Icons.female, size: 18),
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
                                controller: _fatherNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'वडिलांचे नाव (Father Name)',
                                  hintText: 'उदा. रमेश',
                                  prefixIcon: Icon(Icons.male, size: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _gender,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'लिंग (Gender)',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'M',
                                    child: Text('मुलगा (Male)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'F',
                                    child: Text('मुलगी (Female)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'T',
                                    child: Text('इतर (Other)'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _gender = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _nationalityCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'राष्ट्रीयत्व (Nationality)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _motherTongueCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'मातृभाषा (Mother Tongue)',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Autocomplete<String>(
                                initialValue: TextEditingValue(
                                  text: _religionCtrl.text,
                                ),
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return _religionOptions;
                                      }
                                      return _religionOptions.where((
                                        String option,
                                      ) {
                                        return option.contains(
                                          textEditingValue.text,
                                        );
                                      });
                                    },
                                onSelected: (String selection) {
                                  _religionCtrl.text = selection;
                                },
                                fieldViewBuilder:
                                    (
                                      context,
                                      controller,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      controller.addListener(() {
                                        _religionCtrl.text = controller.text;
                                      });
                                      return TextFormField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: const InputDecoration(
                                          labelText: 'धर्म (Religion)',
                                          hintText:
                                              'उदा. हिंदू, मुस्लीम, बौद्ध',
                                        ),
                                      );
                                    },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _casteCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'जात (Caste)',
                                  hintText: 'उदा. मराठा, माळी, कुणबी, बौद्ध',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _subCasteCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'पोटजात (Sub Caste)',
                                  hintText: 'उदा. 96 कुळी, हिंदू कुणबी',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _casteCategory,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'जात प्रवर्ग (Category)',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'OPEN',
                                    child: Text('OPEN'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'OBC',
                                    child: Text('OBC'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'SC',
                                    child: Text('SC'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ST',
                                    child: Text('ST'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'VJNT',
                                    child: Text('VJNT'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'SBC',
                                    child: Text('SBC'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'SEBC',
                                    child: Text('SEBC'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'EWS',
                                    child: Text('EWS'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _casteCategory = val);
                                  }
                                },
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
                                controller: _birthPlaceCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'जन्मस्थळ (Birth Place)',
                                  hintText:
                                      'गाव, तालुका, जिल्हा (उदा. अकोले, अहिल्यानगर)',
                                  prefixIcon: Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: _pickDob,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'जन्म दिनांक (अंकी) *',
                                    suffixIcon: Icon(
                                      Icons.calendar_month,
                                      color: Color(0xFF0D6EFD),
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').format(_dob),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _dobWordsCtrl,
                                readOnly: true,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'जन्म दिनांक (अक्षरी)',
                                  fillColor: const Color(0xFFF8FAFC),
                                  filled: true,
                                  prefixIcon: const Icon(
                                    Icons.text_fields,
                                    size: 18,
                                  ),
                                  helperText:
                                      'जन्मतारीख निवडल्यास मराठीत आपोआप तयार होईल',
                                  helperStyle: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blueGrey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ३. प्रवेश तपशील (Admission Details)
                  _buildSectionCard(
                    icon: Icons.domain_add_outlined,
                    title: '३. प्रवेश तपशील',
                    content: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _previousSchoolCtrl,
                                decoration: const InputDecoration(
                                  labelText:
                                      'या पूर्वीची शाळा (Previous School)',
                                  hintText: 'शाळेचे नाव व पत्ता',
                                  prefixIcon: Icon(Icons.history_edu, size: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: _pickAdmissionDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'प्रवेश दिनांक (Admission Date)',
                                    suffixIcon: Icon(
                                      Icons.event,
                                      color: Color(0xFF0D6EFD),
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_admissionDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<int>(
                                  value:
                                      state.availableStandards.contains(
                                        _standard,
                                      )
                                      ? _standard
                                      : (state.availableStandards.isNotEmpty
                                            ? state.availableStandards.first
                                            : null),
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'प्रवेशाची इयत्ता (Admission Class) *',
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: state.availableStandards.map((std) {
                                    return DropdownMenuItem(
                                      value: std,
                                      child: Text(
                                        '${MarathiDateFormatter.classToMarathi(std)} (इयत्ता $std)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _standard = val;
                                        _updateRollNoForStandardAndDiv(
                                          _standard,
                                          _division,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value:
                                      state.availableDivisions.contains(
                                        _division,
                                      )
                                      ? _division
                                      : (state.availableDivisions.isNotEmpty
                                            ? state.availableDivisions.first
                                            : null),
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'तुकडी (Division) *',
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: state.availableDivisions.map((div) {
                                    return DropdownMenuItem(
                                      value: div,
                                      child: Text('तुकडी $div'),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _division = val;
                                        _updateRollNoForStandardAndDiv(
                                          _standard,
                                          _division,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _rollSem1Ctrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'हजेरी क्र. (Roll No.) *',
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (val) =>
                                      (val == null || val.trim().isEmpty)
                                      ? 'हजेरी क्र. आवश्यक'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _remarksCtrl,
                          decoration: const InputDecoration(
                            labelText: 'शेरा (Remarks)',
                            hintText: 'काही विशेष नोंद असल्यास येथे नमूद करा',
                            prefixIcon: Icon(Icons.comment_outlined, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ४. अतिरिक्त तपशील (Additional Details - Toggleable)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showAdditionalDetails = !_showAdditionalDetails;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showAdditionalDetails
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: const Color(0xFF0D6EFD),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _showAdditionalDetails
                                  ? 'अतिरिक्त संपर्क व आरोग्य तपशील लपवा'
                                  : 'अतिरिक्त संपर्क, पत्ता व आरोग्य तपशील भरा (Optional Details)',
                              style: const TextStyle(
                                color: Color(0xFF0D6EFD),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showAdditionalDetails) ...[
                    const SizedBox(height: 10),
                    _buildSectionCard(
                      icon: Icons.contact_phone_outlined,
                      title: '४. अतिरिक्त संपर्क, पत्ता व शारीरिक मोजमाप',
                      content: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _nameEnCtrl,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'विद्यार्थ्याचे नाव इंग्रजीत (In English)',
                                    hintText: 'e.g. Patil Sachin Ramesh',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _mobileNoCtrl,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'पालक संपर्क क्र. (Mobile)',
                                    prefixIcon: Icon(Icons.phone, size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _fatherWorkCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'वडिलांचा व्यवसाय',
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
                                    labelText: 'घरचा संपूर्ण पत्ता (Address)',
                                    prefixIcon: Icon(
                                      Icons.home_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _apaarIdCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'अपार आयडी (APAAR ID)',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _penNoCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'PEN क्रमांक (PEN No.)',
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
                                  controller: _heightSem1Ctrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'उंची सत्र १ (सेमी / cm)',
                                    suffixText: 'सेमी',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightSem1Ctrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'वजन सत्र १ (किग्रॅ / kg)',
                                    suffixText: 'किग्रॅ',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _heightSem2Ctrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'उंची सत्र २ (सेमी / cm)',
                                    suffixText: 'सेमी',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightSem2Ctrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'वजन सत्र २ (किग्रॅ / kg)',
                                    suffixText: 'किग्रॅ',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),

                  // Big Center Save Button matching student-admission.php style
                  Center(
                    child: SizedBox(
                      width: 320,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saveStudent,
                        icon: const Icon(Icons.how_to_reg, size: 22),
                        label: Text(
                          isEditing
                              ? 'माहिती जतन करा'
                              : 'प्रवेश निश्चित करा (Save Admission)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0D6EFD), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1.2, color: Color(0xFFE2E8F0)),
            content,
          ],
        ),
      ),
    );
  }
}
