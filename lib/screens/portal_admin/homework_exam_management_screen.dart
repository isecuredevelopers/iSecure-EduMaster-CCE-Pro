import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/local/curriculum_repository.dart';
import '../../data/models/homework_model.dart';
import '../../data/models/online_exam_model.dart';
import '../../data/models/student_model.dart';
import '../../providers/app_state_provider.dart';

class HomeworkExamManagementScreen extends StatefulWidget {
  const HomeworkExamManagementScreen({super.key});

  @override
  State<HomeworkExamManagementScreen> createState() => _HomeworkExamManagementScreenState();
}

class _HomeworkExamManagementScreenState extends State<HomeworkExamManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStd = 1;
  String _selectedDiv = '1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final state = context.read<AppStateProvider>();
    _selectedStd = state.selectedStd;
    _selectedDiv = state.selectedDiv;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Screen Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book, color: Color(0xFF2563EB), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'स्वाध्याय व ऑनलाइन परीक्षा व्यवस्थापन (Homework & Online Exams)',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'येथे दिलेला गृहपाठ व परीक्षा अँड्रॉइड व आयओएस ॲपमध्ये विद्यार्थ्यांना त्वरित उपलब्ध होतात. 📱',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // App Sync Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync, color: Colors.green, size: 15),
                      SizedBox(width: 5),
                      Text(
                        'मोबाइल ॲपशी थेट जोडलेले',
                        style: TextStyle(
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar & Filter Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                // Tabs
                SizedBox(
                  width: 480,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF2563EB),
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicatorColor: const Color(0xFF2563EB),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(icon: Icon(Icons.assignment, size: 18), text: 'घरचा अभ्यास (Homework)'),
                      Tab(icon: Icon(Icons.quiz, size: 18), text: 'ऑनलाइन परीक्षा व निकाल (Exams)'),
                    ],
                  ),
                ),
                const Spacer(),

                // Class & Div Selector
                Row(
                  children: [
                    const Text('इयत्ता:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedStd,
                          items: state.availableStandards.map((std) {
                            return DropdownMenuItem(
                              value: std,
                              child: Text('इयत्ता $std ली', style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedStd = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('तुकडी:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.availableDivisions.contains(_selectedDiv)
                              ? _selectedDiv
                              : (state.availableDivisions.isNotEmpty ? state.availableDivisions.first : '1'),
                          items: state.availableDivisions.map((div) {
                            return DropdownMenuItem(
                              value: div,
                              child: Text('तुकडी $div', style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDiv = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Homework Management
                _buildHomeworkManagementTab(state),

                // Tab 2: Online Exam Management
                _buildOnlineExamManagementTab(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: HOMEWORK MANAGEMENT
  // =========================================================================
  Widget _buildHomeworkManagementTab(AppStateProvider state) {
    // Filter homework by standard and division
    final classHomework = state.homeworkList.where((h) {
      return h.standard == _selectedStd && (h.division == _selectedDiv || h.division.isEmpty);
    }).toList();

    final classStudents = state.students.where((s) {
      return s.standard == _selectedStd &&
          s.division == _selectedDiv &&
          s.academicYearId == state.currentYear.id;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Toolbar
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'इयत्ता $_selectedStd ली (तुकडी $_selectedDiv) गृहपाठ यादी',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text('${classHomework.length} स्वाध्याय'),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  Chip(
                    label: Text('वर्ग विद्यार्थी: ${classStudents.length}'),
                    backgroundColor: Colors.grey.shade100,
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showAddOrEditHomeworkDialog(state, classStudents),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  '+ नवीन स्वाध्याय द्या (Assign Homework)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Homework Cards List
          Expanded(
            child: classHomework.isEmpty
                ? _buildEmptyState(
                    title: 'या वर्गासाठी सध्या कोणताही स्वाध्याय दिलेला नाही.',
                    subtitle: 'वर दिलेल्या "+ नवीन स्वाध्याय द्या" बटणावर क्लिक करून नवीन गृहपाठ द्या.',
                    icon: Icons.assignment_outlined,
                  )
                : ListView.builder(
                    itemCount: classHomework.length,
                    itemBuilder: (context, idx) {
                      final hw = classHomework[idx];
                      return _buildHomeworkCard(hw, classStudents, state);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(
    HomeworkModel hw,
    List<StudentModel> classStudents,
    AppStateProvider state,
  ) {
    final completedCount = classStudents.where((s) => hw.isCompletedBy(s.id)).length;
    final totalStudents = classStudents.length;
    final double completionPct = totalStudents > 0 ? (completedCount / totalStudents) * 100 : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hw.subjectName,
                        style: const TextStyle(
                          color: Color(0xFF1D4ED8),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'इ. ${hw.standard} (${hw.division})',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Action Buttons (View Status, Edit, Delete)
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF93C5FD)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showStudentCompletionDialog(hw, classStudents, state),
                      icon: const Icon(Icons.people_outline, size: 16),
                      label: Text('विद्यार्थी स्थिती ($completedCount/$totalStudents)'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF475569)),
                      tooltip: 'स्वाध्याय संपादन',
                      onPressed: () => _showAddOrEditHomeworkDialog(state, classStudents, existingHw: hw),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                      tooltip: 'स्वाध्याय हटवा',
                      onPressed: () => _confirmDeleteHomework(hw, state),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hw.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              hw.description,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155), height: 1.4),
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'दिनांक: ${hw.assignedDate.day}/${hw.assignedDate.month}/${hw.assignedDate.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.alarm,
                          size: 14,
                          color: hw.isOverdue && completionPct < 100 ? Colors.red : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'अंतिम तारीख: ${hw.dueDate.day}/${hw.dueDate.month}/${hw.dueDate.year}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: hw.isOverdue && completionPct < 100 ? FontWeight.bold : FontWeight.normal,
                            color: hw.isOverdue && completionPct < 100 ? Colors.red : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          hw.teacherName,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 160, maxWidth: 350),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'विद्यार्थी पूर्णता: ',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          children: [
                            TextSpan(
                              text: '$completedCount / $totalStudents (${completionPct.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: completionPct >= 75 ? Colors.green.shade800 : Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalStudents > 0 ? completedCount / totalStudents : 0,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completionPct >= 75 ? Colors.green : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dialog: Assign / Edit Homework
  void _showAddOrEditHomeworkDialog(
    AppStateProvider state,
    List<StudentModel> classStudents, {
    HomeworkModel? existingHw,
  }) {
    final isEdit = existingHw != null;
    final titleCtrl = TextEditingController(text: existingHw?.title ?? '');
    final descCtrl = TextEditingController(text: existingHw?.description ?? '');
    final teacherCtrl = TextEditingController(
      text: existingHw?.teacherName ?? (state.currentUser?.name ?? 'वर्गशिक्षक'),
    );

    int dialogStd = existingHw?.standard ?? _selectedStd;
    String dialogDiv = existingHw?.division ?? _selectedDiv;

    // Available subjects for this standard
    final curriculumSubjects = CurriculumRepository.getSubjectsForStandard(dialogStd);
    String selectedSubjectCode = existingHw?.subjectCode ??
        (curriculumSubjects.isNotEmpty ? curriculumSubjects.first.subjectCode : 'marathi');
    String selectedSubjectName = existingHw?.subjectName ??
        (curriculumSubjects.isNotEmpty ? curriculumSubjects.first.subjectName : 'मराठी');

    DateTime dueDate = existingHw?.dueDate ?? DateTime.now().add(const Duration(days: 2));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  isEdit ? Icons.edit : Icons.assignment_add,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(width: 10),
                Text(
                  isEdit ? 'स्वाध्याय संपादन करा' : 'नवीन स्वाध्याय द्या (Assign Homework)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            content: SizedBox(
              width: 580,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Standard & Division Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: dialogStd,
                            decoration: const InputDecoration(
                              labelText: 'इयत्ता (Standard)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: state.availableStandards.map((std) {
                              return DropdownMenuItem(value: std, child: Text('इयत्ता $std ली'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  dialogStd = val;
                                  final newSubs = CurriculumRepository.getSubjectsForStandard(dialogStd);
                                  if (newSubs.isNotEmpty) {
                                    selectedSubjectCode = newSubs.first.subjectCode;
                                    selectedSubjectName = newSubs.first.subjectName;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state.availableDivisions.contains(dialogDiv)
                                ? dialogDiv
                                : (state.availableDivisions.isNotEmpty ? state.availableDivisions.first : '1'),
                            decoration: const InputDecoration(
                              labelText: 'तुकडी (Division)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: state.availableDivisions.map((div) {
                              return DropdownMenuItem(value: div, child: Text('तुकडी $div'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => dialogDiv = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Subject Selector
                    DropdownButtonFormField<String>(
                      value: selectedSubjectCode,
                      decoration: const InputDecoration(
                        labelText: 'विषय (Subject)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: curriculumSubjects.map((sub) {
                        return DropdownMenuItem(
                          value: sub.subjectCode,
                          child: Text(sub.subjectName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final match = curriculumSubjects.firstWhere((s) => s.subjectCode == val);
                          setDialogState(() {
                            selectedSubjectCode = val;
                            selectedSubjectName = match.subjectName;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Title
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'स्वाध्याय शीर्षक (Title)',
                        hintText: 'उदा. धडा २ मधील स्वाध्याय प्रश्न वहीत सोडवा',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description / Questions
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'तपशील / प्रश्न (Instructions & Questions)',
                        hintText: 'विद्यार्थ्यांसाठी स्वाध्याय सूचना, प्रश्न क्रमांक किंवा पानाचा संदर्भ...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Due Date & Teacher Name
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dueDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 180)),
                              );
                              if (picked != null) {
                                setDialogState(() => dueDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'अंतिम तारीख (Due Date)',
                                border: OutlineInputBorder(),
                                isDense: true,
                                suffixIcon: Icon(Icons.calendar_today, size: 18),
                              ),
                              child: Text('${dueDate.day}/${dueDate.month}/${dueDate.year}'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: teacherCtrl,
                            decoration: const InputDecoration(
                              labelText: 'शिक्षकाचे नाव (Teacher Name)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('रद्द करा'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('कृपया स्वाध्याय शीर्षक प्रविष्ट करा.')),
                    );
                    return;
                  }

                  final hw = HomeworkModel(
                    id: existingHw?.id ?? 'hw_${DateTime.now().millisecondsSinceEpoch}',
                    schoolId: state.school.id,
                    academicYearId: state.currentYear.id,
                    standard: dialogStd,
                    division: dialogDiv,
                    subjectCode: selectedSubjectCode,
                    subjectName: selectedSubjectName,
                    title: title,
                    description: descCtrl.text.trim(),
                    assignedDate: existingHw?.assignedDate ?? DateTime.now(),
                    dueDate: dueDate,
                    teacherName: teacherCtrl.text.trim().isNotEmpty ? teacherCtrl.text.trim() : 'वर्गशिक्षक',
                    completedStudentIds: existingHw?.completedStudentIds ?? [],
                  );

                  state.addHomework(hw);
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'स्वाध्याय अद्यतनित झाला! मोबाइल ॲपवर बदल दिसेल.'
                            : 'नवीन स्वाध्याय दिला! हा स्वाध्याय विद्यार्थ्यांच्या मोबाइल ॲपवर त्वरित उपलब्ध झाला आहे. 📱',
                      ),
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                },
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                label: Text(
                  isEdit ? 'बदल जतन करा' : 'स्वाध्याय प्रसिद्ध करा',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog: View & Toggle Student Completion
  void _showStudentCompletionDialog(
    HomeworkModel hw,
    List<StudentModel> classStudents,
    AppStateProvider state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final completedCount = classStudents.where((s) => hw.isCompletedBy(s.id)).length;
          final total = classStudents.length;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'विद्यार्थी स्वाध्याय स्थिती ($completedCount / $total पूर्ण)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${hw.subjectName} • ${hw.title}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: 520,
              height: 400,
              child: classStudents.isEmpty
                  ? const Center(child: Text('या वर्गात विद्यार्थी नाहीत.'))
                  : ListView.separated(
                      itemCount: classStudents.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final stu = classStudents[idx];
                        final isCompleted = hw.isCompletedBy(stu.id);

                        return CheckboxListTile(
                          value: isCompleted,
                          activeColor: Colors.green,
                          title: Text(
                            stu.studentNameMr.isNotEmpty ? stu.studentNameMr : stu.studentNameEn,
                            style: TextStyle(
                              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                              color: isCompleted ? Colors.green.shade900 : Colors.black87,
                            ),
                          ),
                          subtitle: Text('हजेरी क्र. ${stu.rollNoSem1} • GR: ${stu.grNo}'),
                          secondary: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isCompleted ? Colors.green.shade200 : Colors.orange.shade200,
                              ),
                            ),
                            child: Text(
                              isCompleted ? 'पूर्ण केले ✓' : 'बाकी आहे ⏳',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
                              ),
                            ),
                          ),
                          onChanged: (val) async {
                            await state.toggleHomeworkStatus(hw.id, stu.id);
                            setModalState(() {});
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('बंद करा'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteHomework(HomeworkModel hw, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('स्वाध्याय हटवावा का?'),
        content: Text('"${hw.title}" हा स्वाध्याय कायमचा हटवला जाईल. आपण खात्री केली आहे का?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              state.deleteHomework(hw.id);
              Navigator.pop(ctx);
            },
            child: const Text('हटवा', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: ONLINE EXAM MANAGEMENT
  // =========================================================================
  Widget _buildOnlineExamManagementTab(AppStateProvider state) {
    final classExams = state.onlineExams.where((e) => e.standard == _selectedStd).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Toolbar
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'इयत्ता $_selectedStd ली ऑनलाइन परीक्षा व सराव चाचण्या',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text('${classExams.length} चाचण्या उपलब्ध'),
                    backgroundColor: Colors.purple.shade50,
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showAddOrEditExamDialog(state),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  '+ नवीन ऑनलाइन परीक्षा तयार करा (Create Exam)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Exams Cards List
          Expanded(
            child: classExams.isEmpty
                ? _buildEmptyState(
                    title: 'या वर्गासाठी सध्या कोणतीही ऑनलाइन परीक्षा तयार केलेली नाही.',
                    subtitle: 'वर दिलेल्या "+ नवीन ऑनलाइन परीक्षा तयार करा" बटणावर क्लिक करून वस्तुनिष्ठ चाचणी तयार करा.',
                    icon: Icons.quiz_outlined,
                  )
                : ListView.builder(
                    itemCount: classExams.length,
                    itemBuilder: (context, idx) {
                      final exam = classExams[idx];
                      return _buildExamAdminCard(exam, state);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamAdminCard(OnlineExamModel exam, AppStateProvider state) {
    final results = state.getResultsForExam(exam.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exam.subjectName,
                        style: TextStyle(
                          color: Colors.purple.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'इयत्ता ${exam.standard} वी',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Actions
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showExamResultsTableDialog(exam, results, state),
                      icon: const Icon(Icons.leaderboard, size: 16),
                      label: Text('विद्यार्थ्यांचे निकाल (${results.length} निकाल)'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF475569)),
                      tooltip: 'परीक्षा संपादन',
                      onPressed: () => _showAddOrEditExamDialog(state, existingExam: exam),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                      tooltip: 'परीक्षा हटवा',
                      onPressed: () => _confirmDeleteExam(exam, state),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              exam.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              exam.description,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155), height: 1.4),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('कालावधी: ${exam.durationMinutes} मिनिटे', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(width: 16),
                Icon(Icons.format_list_numbered, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('प्रश्न: ${exam.questions.length}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(width: 16),
                Icon(Icons.stars, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('एकूण गुण: ${exam.totalMarks}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(width: 16),
                Icon(Icons.check_circle_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('उत्तीर्ण गुण: ${exam.passingMarks}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dialog: Create or Edit Online Exam with Question Builder
  void _showAddOrEditExamDialog(AppStateProvider state, {OnlineExamModel? existingExam}) {
    final isEdit = existingExam != null;
    final titleCtrl = TextEditingController(text: existingExam?.title ?? '');
    final descCtrl = TextEditingController(text: existingExam?.description ?? '');
    final durationCtrl = TextEditingController(text: '${existingExam?.durationMinutes ?? 15}');
    final passingCtrl = TextEditingController(text: '${existingExam?.passingMarks ?? 4}');

    int dialogStd = existingExam?.standard ?? _selectedStd;
    final curriculumSubjects = CurriculumRepository.getSubjectsForStandard(dialogStd);
    String selectedSubjectCode = existingExam?.subjectCode ??
        (curriculumSubjects.isNotEmpty ? curriculumSubjects.first.subjectCode : 'marathi');
    String selectedSubjectName = existingExam?.subjectName ??
        (curriculumSubjects.isNotEmpty ? curriculumSubjects.first.subjectName : 'मराठी');

    // Questions List editable in dialog
    List<ExamQuestionModel> questions = existingExam != null
        ? List<ExamQuestionModel>.from(existingExam.questions)
        : [
            ExamQuestionModel(
              id: 'q_${DateTime.now().millisecondsSinceEpoch}_1',
              question: '',
              options: ['', '', '', ''],
              correctOptionIndex: 0,
              explanation: '',
              marks: 1,
            ),
          ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final totalMarks = questions.fold<int>(0, (sum, q) => sum + q.marks);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(isEdit ? Icons.edit : Icons.quiz, color: const Color(0xFF7C3AED)),
                const SizedBox(width: 10),
                Text(
                  isEdit ? 'ऑनलाइन परीक्षा संपादन' : 'नवीन ऑनलाइन परीक्षा तयार करा (Create Online Exam)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            content: SizedBox(
              width: 750,
              height: 550,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class & Subject Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: dialogStd,
                            decoration: const InputDecoration(
                              labelText: 'इयत्ता (Class)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: state.availableStandards.map((std) {
                              return DropdownMenuItem(value: std, child: Text('इयत्ता $std ली'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  dialogStd = val;
                                  final newSubs = CurriculumRepository.getSubjectsForStandard(dialogStd);
                                  if (newSubs.isNotEmpty) {
                                    selectedSubjectCode = newSubs.first.subjectCode;
                                    selectedSubjectName = newSubs.first.subjectName;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedSubjectCode,
                            decoration: const InputDecoration(
                              labelText: 'विषय (Subject)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: curriculumSubjects.map((sub) {
                              return DropdownMenuItem(value: sub.subjectCode, child: Text(sub.subjectName));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final match = curriculumSubjects.firstWhere((s) => s.subjectCode == val);
                                setDialogState(() {
                                  selectedSubjectCode = val;
                                  selectedSubjectName = match.subjectName;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Exam Title
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'परीक्षेचे नाव (Exam Title)',
                        hintText: 'उदा. इयत्ता ४ थी - परिसर अभ्यास चाचणी क्र. १',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'वर्णन / सूचना (Instructions)',
                        hintText: 'उदा. सर्व प्रश्न सोडवणे अनिवार्य आहे. अचूक पर्याय निवडा.',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Duration and Passing Marks
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: durationCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'वेळ (कालावधी मिनिटांत)',
                              border: OutlineInputBorder(),
                              isDense: true,
                              suffixText: 'मिनिटे',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: passingCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'उत्तीर्ण गुण (Passing Marks)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // Questions Builder Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'प्रश्न संच (Questions Builder):',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text('${questions.length} प्रश्न • एकूण गुण: $totalMarks'),
                              backgroundColor: Colors.purple.shade50,
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
                          onPressed: () {
                            setDialogState(() {
                              questions.add(
                                ExamQuestionModel(
                                  id: 'q_${DateTime.now().millisecondsSinceEpoch}_${questions.length + 1}',
                                  question: '',
                                  options: ['', '', '', ''],
                                  correctOptionIndex: 0,
                                  explanation: '',
                                  marks: 1,
                                ),
                              );
                            });
                          },
                          icon: const Icon(Icons.add, color: Colors.white, size: 16),
                          label: const Text('+ प्रश्न जोडा', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Questions List
                    ...List.generate(questions.length, (qIdx) {
                      final q = questions[qIdx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'प्रश्न ${qIdx + 1}:',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                if (questions.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                    onPressed: () {
                                      setDialogState(() {
                                        questions.removeAt(qIdx);
                                      });
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: q.question,
                              decoration: const InputDecoration(
                                labelText: 'प्रश्नाचा मजकूर (Question)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                questions[qIdx] = ExamQuestionModel(
                                  id: q.id,
                                  question: val,
                                  options: q.options,
                                  correctOptionIndex: q.correctOptionIndex,
                                  explanation: q.explanation,
                                  marks: q.marks,
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'पर्याय व योग्य उत्तराची निवड (Select correct radio button):',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            ...List.generate(4, (optIdx) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Radio<int>(
                                      value: optIdx,
                                      groupValue: q.correctOptionIndex,
                                      activeColor: Colors.green,
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() {
                                            questions[qIdx] = ExamQuestionModel(
                                              id: q.id,
                                              question: q.question,
                                              options: q.options,
                                              correctOptionIndex: val,
                                              explanation: q.explanation,
                                              marks: q.marks,
                                            );
                                          });
                                        }
                                      },
                                    ),
                                    Text(
                                      '${String.fromCharCode(65 + optIdx)}:', // A, B, C, D
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: optIdx < q.options.length ? q.options[optIdx] : '',
                                        decoration: InputDecoration(
                                          hintText: 'पर्याय ${optIdx + 1}',
                                          border: const OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        onChanged: (val) {
                                          final newOpts = List<String>.from(q.options);
                                          while (newOpts.length <= optIdx) {
                                            newOpts.add('');
                                          }
                                          newOpts[optIdx] = val;
                                          questions[qIdx] = ExamQuestionModel(
                                            id: q.id,
                                            question: q.question,
                                            options: newOpts,
                                            correctOptionIndex: q.correctOptionIndex,
                                            explanation: q.explanation,
                                            marks: q.marks,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: q.explanation,
                              decoration: const InputDecoration(
                                labelText: 'स्पष्टीकरण (Explanation - ऐच्छिक)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                questions[qIdx] = ExamQuestionModel(
                                  id: q.id,
                                  question: q.question,
                                  options: q.options,
                                  correctOptionIndex: q.correctOptionIndex,
                                  explanation: val,
                                  marks: q.marks,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('कृपया परीक्षेचे नाव प्रविष्ट करा.')),
                    );
                    return;
                  }

                  // Verify questions have text
                  for (int i = 0; i < questions.length; i++) {
                    if (questions[i].question.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('कृपया प्रश्न क्रमांक ${i + 1} चा मजकूर प्रविष्ट करा.')),
                      );
                      return;
                    }
                  }

                  final exam = OnlineExamModel(
                    id: existingExam?.id ?? 'exam_${DateTime.now().millisecondsSinceEpoch}',
                    standard: dialogStd,
                    subjectCode: selectedSubjectCode,
                    subjectName: selectedSubjectName,
                    title: title,
                    description: descCtrl.text.trim(),
                    durationMinutes: int.tryParse(durationCtrl.text.trim()) ?? 15,
                    passingMarks: int.tryParse(passingCtrl.text.trim()) ?? (totalMarks * 0.35).ceil(),
                    totalMarks: totalMarks,
                    questions: questions,
                  );

                  state.addOnlineExam(exam);
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'परीक्षा अद्यतनित झाली!'
                            : 'नवीन ऑनलाइन परीक्षा तयार झाली! ही परीक्षा विद्यार्थ्यांच्या मोबाइल ॲपवर त्वरित उपलब्ध झाली आहे. 📱',
                      ),
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                },
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                label: Text(
                  isEdit ? 'बदल जतन करा' : 'परीक्षा प्रसिद्ध करा',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog: View All Student Results for an Exam
  void _showExamResultsTableDialog(
    OnlineExamModel exam,
    List<ExamResultModel> results,
    AppStateProvider state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final liveResults = state.getResultsForExam(exam.id);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${exam.title} - निकालपत्रक',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      Text(
                        'इयत्ता ${exam.standard} वी • ${exam.subjectName} • एकूण गुण: ${exam.totalMarks} • एकूण सबमिशन: ${liveResults.length}',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            content: SizedBox(
              width: 820,
              height: 480,
              child: liveResults.isEmpty
                  ? _buildEmptyState(
                      title: 'अद्याप कोणत्याही विद्यार्थ्याने ही परीक्षा दिलेली नाही.',
                      subtitle: 'विद्यार्थ्यांनी त्यांच्या Android / iOS ॲपवरून चाचणी सोडवल्यानंतर निकाल येथे थेट दिसतील.',
                      icon: Icons.hourglass_empty,
                    )
                  : SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.purple.shade50),
                        columns: const [
                          DataColumn(label: Text('विद्यार्थ्याचे नाव', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('वर्ग व तुकडी', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('मिळालेले गुण', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('टक्केवारी', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('श्रेणी', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('निकाल', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('दिनांक व वेळ', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('क्रिया', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: liveResults.map((res) {
                          return DataRow(
                            cells: [
                              DataCell(Text(res.studentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text('इ. ${res.standard} (${res.division})')),
                              DataCell(
                                Text(
                                  '${res.score} / ${res.totalMarks}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: res.isPassed ? Colors.green.shade800 : Colors.red.shade800,
                                  ),
                                ),
                              ),
                              DataCell(Text('${res.percentage.toStringAsFixed(1)}%')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: res.isPassed ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    res.grade,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: res.isPassed ? Colors.green.shade900 : Colors.red.shade900,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  res.isPassed ? 'उत्तीर्ण ✓' : 'अनुत्तीर्ण',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: res.isPassed ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${res.submittedAt.day}/${res.submittedAt.month} ${res.submittedAt.hour}:${res.submittedAt.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  tooltip: 'विद्यार्थ्याला पुन्हा परीक्षा देण्याची संधी द्या (Reset)',
                                  onPressed: () async {
                                    await state.deleteExamResult(res.id);
                                    setModalState(() {});
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('बंद करा')),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteExam(OnlineExamModel exam, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('परीक्षा हटवावी का?'),
        content: Text('"${exam.title}" ही परीक्षा कायमची हटवली जाईल. आपण खात्री केली आहे का?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              state.deleteOnlineExam(exam.id);
              Navigator.pop(ctx);
            },
            child: const Text('हटवा', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
