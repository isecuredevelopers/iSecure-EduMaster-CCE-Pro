import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/student_model.dart';
import '../../providers/app_state_provider.dart';

class StudentFormScreen extends StatefulWidget {
  final StudentModel? studentToEdit;

  const StudentFormScreen({super.key, this.studentToEdit});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late int _standard;
  late String _division;
  late TextEditingController _grNoCtrl;
  late TextEditingController _rollSem1Ctrl;
  late TextEditingController _rollSem2Ctrl;
  late TextEditingController _nameMrCtrl;
  late TextEditingController _nameEnCtrl;
  late TextEditingController _fatherNameCtrl;
  late TextEditingController _motherNameCtrl;
  String _gender = 'M';
  String _casteCategory = 'OPEN';
  late TextEditingController _subCasteCtrl;
  DateTime _dob = DateTime(2018, 1, 1);
  late TextEditingController _birthPlaceCtrl;
  late TextEditingController _talukaCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _saralIdCtrl;
  late TextEditingController _apaarIdCtrl;
  late TextEditingController _penNoCtrl;
  late TextEditingController _aadhaarNoCtrl;
  late TextEditingController _mobileNoCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _fatherWorkCtrl;
  late TextEditingController _motherWorkCtrl;
  late TextEditingController _heightSem1Ctrl;
  late TextEditingController _heightSem2Ctrl;
  late TextEditingController _weightSem1Ctrl;
  late TextEditingController _weightSem2Ctrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppStateProvider>();
    final s = widget.studentToEdit;

    _standard = s?.standard ?? state.selectedStd;
    _division = s?.division ?? state.selectedDiv;
    _grNoCtrl = TextEditingController(text: s?.grNo ?? '');
    _rollSem1Ctrl = TextEditingController(text: (s?.rollNoSem1 ?? (state.filteredStudents.length + 1)).toString());
    _rollSem2Ctrl = TextEditingController(text: (s?.rollNoSem2 ?? (state.filteredStudents.length + 1)).toString());
    _nameMrCtrl = TextEditingController(text: s?.studentNameMr ?? '');
    _nameEnCtrl = TextEditingController(text: s?.studentNameEn ?? '');
    _fatherNameCtrl = TextEditingController(text: s?.fatherName ?? '');
    _motherNameCtrl = TextEditingController(text: s?.motherName ?? '');
    _gender = s?.gender ?? 'M';
    _casteCategory = s?.casteCategory ?? 'OPEN';
    _subCasteCtrl = TextEditingController(text: s?.subCaste ?? '');
    _dob = s?.dateOfBirth ?? DateTime(2018, 1, 1);
    _birthPlaceCtrl = TextEditingController(text: s?.birthPlace ?? '');
    _talukaCtrl = TextEditingController(text: s?.taluka ?? state.school.blockTaluka);
    _districtCtrl = TextEditingController(text: s?.district ?? state.school.district);
    _saralIdCtrl = TextEditingController(text: s?.saralId ?? '');
    _apaarIdCtrl = TextEditingController(text: s?.apaarId ?? '');
    _penNoCtrl = TextEditingController(text: s?.penNo ?? '');
    _aadhaarNoCtrl = TextEditingController(text: s?.aadhaarNo ?? '');
    _mobileNoCtrl = TextEditingController(text: s?.mobileNo ?? '');
    _addressCtrl = TextEditingController(text: s?.address ?? state.school.address);
    _fatherWorkCtrl = TextEditingController(text: s?.fatherOccupation ?? 'शेती');
    _motherWorkCtrl = TextEditingController(text: s?.motherOccupation ?? 'गृहिणी');
    _heightSem1Ctrl = TextEditingController(text: s?.heightSem1?.toString() ?? '');
    _heightSem2Ctrl = TextEditingController(text: s?.heightSem2?.toString() ?? '');
    _weightSem1Ctrl = TextEditingController(text: s?.weightSem1?.toString() ?? '');
    _weightSem2Ctrl = TextEditingController(text: s?.weightSem2?.toString() ?? '');
  }

  @override
  void dispose() {
    _grNoCtrl.dispose();
    _rollSem1Ctrl.dispose();
    _rollSem2Ctrl.dispose();
    _nameMrCtrl.dispose();
    _nameEnCtrl.dispose();
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    _subCasteCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _talukaCtrl.dispose();
    _districtCtrl.dispose();
    _saralIdCtrl.dispose();
    _apaarIdCtrl.dispose();
    _penNoCtrl.dispose();
    _aadhaarNoCtrl.dispose();
    _mobileNoCtrl.dispose();
    _addressCtrl.dispose();
    _fatherWorkCtrl.dispose();
    _motherWorkCtrl.dispose();
    _heightSem1Ctrl.dispose();
    _heightSem2Ctrl.dispose();
    _weightSem1Ctrl.dispose();
    _weightSem2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppStateProvider>();

    final stu = StudentModel(
      id: widget.studentToEdit?.id ?? 'stu_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: state.school.id,
      academicYearId: state.currentYear.id,
      standard: _standard,
      division: _division,
      grNo: _grNoCtrl.text.trim(),
      rollNoSem1: int.tryParse(_rollSem1Ctrl.text.trim()) ?? 1,
      rollNoSem2: int.tryParse(_rollSem2Ctrl.text.trim()) ?? 1,
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
      heightSem1: double.tryParse(_heightSem1Ctrl.text.trim()),
      heightSem2: double.tryParse(_heightSem2Ctrl.text.trim()),
      weightSem1: double.tryParse(_weightSem1Ctrl.text.trim()),
      weightSem2: double.tryParse(_weightSem2Ctrl.text.trim()),
    );

    state.addOrUpdateStudent(stu);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.studentToEdit == null ? 'नवीन विद्यार्थी नोंदवला गेला!' : 'विद्यार्थी माहिती अपडेट झाली!'),
        backgroundColor: AppColors.gradeA1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isEditing = widget.studentToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'विद्यार्थी माहिती संपादन' : 'नवीन विद्यार्थी नोंदणी (Student Admission)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: _saveStudent,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('जतन करा (Save)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '१. वर्ग व हजेरी माहिती (Class & Roll Details)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _standard,
                              decoration: const InputDecoration(labelText: 'इयत्ता (Standard)'),
                              items: state.availableStandards.map((std) {
                                return DropdownMenuItem(value: std, child: Text('इयत्ता $std'));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _standard = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _division,
                              decoration: const InputDecoration(labelText: 'तुकडी (Division)'),
                              items: state.availableDivisions.map((div) {
                                return DropdownMenuItem(value: div, child: Text('तुकडी $div'));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _division = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _grNoCtrl,
                              decoration: const InputDecoration(labelText: 'जनरल रजिस्टर क्र. (GR No.) *'),
                              validator: (val) => val == null || val.isEmpty ? 'GR No आवश्यक आहे' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _rollSem1Ctrl,
                              decoration: const InputDecoration(labelText: 'हजेरी क्र. सत्र १ (Roll Sem 1) *'),
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'आवश्यक' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _rollSem2Ctrl,
                              decoration: const InputDecoration(labelText: 'हजेरी क्र. सत्र २ (Roll Sem 2)'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '२. विद्यार्थ्याचे नाव व वैयक्तिक तपशील (Student Personal Info)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nameMrCtrl,
                              decoration: const InputDecoration(
                                labelText: 'विद्यार्थ्याचे संपूर्ण नाव मराठीत (आडनाव नाव वडिलांचे नाव) *',
                                hintText: 'उदा. पाटील राहुल सचिन',
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'विद्यार्थ्याचे नाव आवश्यक आहे' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nameEnCtrl,
                              decoration: const InputDecoration(
                                labelText: 'विद्यार्थ्याचे नाव इंग्रजीत (In English)',
                                hintText: 'e.g. Patil Rahul Sachin',
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
                              decoration: const InputDecoration(labelText: 'वडिलांचे पूर्ण नाव'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _motherNameCtrl,
                              decoration: const InputDecoration(labelText: 'आईचे पूर्ण नाव'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _gender,
                              decoration: const InputDecoration(labelText: 'लिंग (Gender)'),
                              items: const [
                                DropdownMenuItem(value: 'M', child: Text('मुलगा (Male)')),
                                DropdownMenuItem(value: 'F', child: Text('मुलगी (Female)')),
                                DropdownMenuItem(value: 'T', child: Text('इतर (Other)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _gender = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _casteCategory,
                              decoration: const InputDecoration(labelText: 'जात प्रवर्ग (Category)'),
                              items: const [
                                DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                                DropdownMenuItem(value: 'OBC', child: Text('OBC')),
                                DropdownMenuItem(value: 'SC', child: Text('SC')),
                                DropdownMenuItem(value: 'ST', child: Text('ST')),
                                DropdownMenuItem(value: 'VJNT', child: Text('VJNT')),
                                DropdownMenuItem(value: 'SBC', child: Text('SBC')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _casteCategory = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'जन्मतारीख (Date of Birth) *',
                                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_dob),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _birthPlaceCtrl,
                              decoration: const InputDecoration(labelText: 'जन्मस्थळ (Birth Place)'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _talukaCtrl,
                              decoration: const InputDecoration(labelText: 'तालुका (Taluka)'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _districtCtrl,
                              decoration: const InputDecoration(labelText: 'जिल्हा (District)'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '३. शासन नोंदणी क्रमांक व शारीरिक मोजमाप (Government IDs & Health)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _saralIdCtrl,
                              decoration: const InputDecoration(labelText: 'सरल आयडी (Student Saral ID)'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _apaarIdCtrl,
                              decoration: const InputDecoration(labelText: 'अपार आयडी (APAAR ID)'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _penNoCtrl,
                              decoration: const InputDecoration(labelText: 'PEN क्रमांक (PEN No.)'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _aadhaarNoCtrl,
                              decoration: const InputDecoration(labelText: 'आधार कार्ड क्रमांक (Aadhaar)'),
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
                              decoration: const InputDecoration(labelText: 'उंची सत्र १ (सेमी / cm)'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightSem1Ctrl,
                              decoration: const InputDecoration(labelText: 'वजन सत्र १ (किग्रॅ / kg)'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _heightSem2Ctrl,
                              decoration: const InputDecoration(labelText: 'उंची सत्र २ (सेमी / cm)'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightSem2Ctrl,
                              decoration: const InputDecoration(labelText: 'वजन सत्र २ (किग्रॅ / kg)'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _mobileNoCtrl,
                              decoration: const InputDecoration(labelText: 'पालक संपर्क क्र.'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
