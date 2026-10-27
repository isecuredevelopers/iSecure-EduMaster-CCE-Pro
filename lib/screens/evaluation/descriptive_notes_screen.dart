import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../data/models/descriptive_note_model.dart';
import '../../data/local/sample_data.dart';

class DescriptiveNotesScreen extends StatefulWidget {
  const DescriptiveNotesScreen({super.key});

  @override
  State<DescriptiveNotesScreen> createState() => _DescriptiveNotesScreenState();
}

class _DescriptiveNotesScreenState extends State<DescriptiveNotesScreen> {
  String? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.filteredStudents;

    if (_selectedStudentId == null && students.isNotEmpty) {
      _selectedStudentId = students.first.id;
    }

    final currentStudent = students.firstWhere(
      (s) => s.id == _selectedStudentId,
      orElse: () => students.isNotEmpty ? students.first : SampleData.defaultStudents.first,
    );

    final note = students.isNotEmpty
        ? state.getOrCreateDescriptiveNote(currentStudent.id, state.selectedSemester)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'वर्णनात्मक नोंदी: इ. ${state.selectedStd} तुकडी ${state.selectedDiv} (सत्र ${state.selectedSemester})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                if (note != null) state.updateDescriptiveNote(note);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('वर्णनात्मक नोंदी यशस्वीरित्या जतन केल्या!'),
                    backgroundColor: AppColors.gradeA1,
                  ),
                );
              },
              icon: const Icon(Icons.save, size: 18),
              label: const Text('नोंदी जतन करा (Save Notes)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          )
        ],
      ),
      body: students.isEmpty
          ? const Center(child: Text('या वर्गात विद्यार्थी नाहीत.'))
          : Row(
              children: [
                // Left Panel: Student Selector List
                Container(
                  width: 320,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFFF1F5F9),
                        child: Row(
                          children: [
                            const Icon(Icons.people, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'विद्यार्थी निवडा (${students.length})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: students.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final stu = students[idx];
                            final isSelected = stu.id == currentStudent.id;
                            final rollNo = stu.getRollNo(state.selectedSemester);

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: AppColors.primary.withOpacity(0.08),
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                                child: Text(
                                  '$rollNo',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                stu.studentNameMr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text('GR: ${stu.grNo} • ${stu.genderTextMr}', style: const TextStyle(fontSize: 11)),
                              trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                              onTap: () {
                                setState(() {
                                  _selectedStudentId = stu.id;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),

                // Right Panel: Descriptive Remark Entry Fields
                Expanded(
                  child: note == null
                      ? const SizedBox()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Selected Student Banner
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primaryLight,
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${currentStudent.studentNameMr} (हजेरी क्र. ${currentStudent.getRollNo(state.selectedSemester)})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            'इयत्ता ${state.selectedStd} • तुकडी ${state.selectedDiv} • सत्र ${state.selectedSemester}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _copyDefaultNotes(state, note),
                                      icon: const Icon(Icons.auto_awesome, size: 16),
                                      label: const Text('नमुन्यावरून भरा (Auto Fill)'),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentDark),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Section 1: General Observations (s10, s11, s12, s13)
                              const Text(
                                'सर्वकष निरीक्षणे (General Observations)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 12),
                              _buildRemarkRow(
                                title: 'विशेष प्रगती (s10 - Special Progress)',
                                code: 's10',
                                text: note.s10,
                                onChanged: (val) {
                                  note.s10 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              _buildRemarkRow(
                                title: 'आवड / छंद (s11 - Interests & Hobbies)',
                                code: 's11',
                                text: note.s11,
                                onChanged: (val) {
                                  note.s11 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              _buildRemarkRow(
                                title: 'सुधारणा आवश्यक (s12 - Scope for Improvement)',
                                code: 's12',
                                text: note.s12,
                                onChanged: (val) {
                                  note.s12 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              _buildRemarkRow(
                                title: 'व्यक्तिमत्त्व गुणविशेष (s13 - Personality & Habits)',
                                code: 's13',
                                text: note.s13,
                                onChanged: (val) {
                                  note.s13 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              const SizedBox(height: 24),

                              // Section 2: Subject-wise Observations (s1 to s9)
                              const Text(
                                'विषयनिहाय वर्णनात्मक नोंदी (Subject-wise Observations)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              const SizedBox(height: 12),
                              _buildRemarkRow(
                                title: 'प्रथम भाषा मराठी (s1)',
                                code: 's1',
                                text: note.s1,
                                onChanged: (val) {
                                  note.s1 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              _buildRemarkRow(
                                title: 'तृतीय भाषा इंग्रजी (s3)',
                                code: 's3',
                                text: note.s3,
                                onChanged: (val) {
                                  note.s3 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              _buildRemarkRow(
                                title: 'गणित (s4)',
                                code: 's4',
                                text: note.s4,
                                onChanged: (val) {
                                  note.s4 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              _buildRemarkRow(
                                title: 'कला शिक्षण (s7)',
                                code: 's7',
                                text: note.s7,
                                onChanged: (val) {
                                  note.s7 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              _buildRemarkRow(
                                title: 'कार्यानुभव (s8)',
                                code: 's8',
                                text: note.s8,
                                onChanged: (val) {
                                  note.s8 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                              _buildRemarkRow(
                                title: 'शारीरिक शिक्षण व आरोग्य (s9)',
                                code: 's9',
                                text: note.s9,
                                onChanged: (val) {
                                  note.s9 = val;
                                  state.updateDescriptiveNote(note);
                                },
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRemarkRow({
    required String title,
    required String code,
    required String text,
    required Function(String) onChanged,
  }) {
    final state = context.read<AppStateProvider>();
    final bankList = state.remarksBank[code] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
              if (bankList.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _openRemarksPickerModal(title, bankList, onChanged),
                  icon: const Icon(Icons.list_alt, size: 16, color: AppColors.primary),
                  label: const Text('भांडारातून निवडा (Pick from Bank)', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey('$code-$text'),
            initialValue: text,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'नोंद येथे टाइप करा किंवा उजवीकडील बटणावर क्लिक करून निवडा...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _openRemarksPickerModal(String title, List<String> bank, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$title - पूर्वनिर्धारित नोंदी निवडा', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 550,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: bank.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final remark = bank[idx];
              return ListTile(
                dense: true,
                title: Text(remark, style: const TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.add_circle_outline, color: AppColors.teal, size: 18),
                onTap: () {
                  onSelect(remark);
                  Navigator.pop(ctx);
                  setState(() {});
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('बंद करा')),
        ],
      ),
    );
  }

  void _copyDefaultNotes(AppStateProvider state, DescriptiveNoteModel note) {
    setState(() {
      note.s10 = 'शालेय शिस्त आत्मसात करतो. दररोज शाळेत उपस्थित राहतो. चित्रकलेत विशेष प्रगती.';
      note.s11 = 'चित्रे काढणे. खेळात सहभागी होणे.';
      note.s12 = 'इंग्रजी शब्दसंपत्ती वाढवावी. वाचन, लेखनाकडे लक्ष द्यावे.';
      note.s13 = 'नेहमी हसतमुख असतो. वैयक्तिक स्वच्छतेकडे सातत्याने लक्ष देतो. शिक्षकाविषयी आदर बाळगतो.';
      note.s1 = 'कविता तालासुरात साभिनय म्हणते.';
      note.s3 = 'Copies the letters and words correctly.';
      note.s4 = 'संख्या वाचन करतो व क्रम ओळखतो.';
      note.s7 = 'चित्रे सुंदर काढते व रंग भरते.';
      note.s8 = 'स्वनिर्मित कागदी वस्तू तयार करतो.';
      note.s9 = 'खेळात उस्फूर्तपणे भाग घेते.';
      state.updateDescriptiveNote(note);
    });
  }
}
