import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';

class StudentPromotionScreen extends StatefulWidget {
  const StudentPromotionScreen({super.key});

  @override
  State<StudentPromotionScreen> createState() => _StudentPromotionScreenState();
}

class _StudentPromotionScreenState extends State<StudentPromotionScreen> {
  int _sourceStd = 1;
  int _targetStd = 2;
  String _targetYearId = 'year-2025-26';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final studentsToPromote = state.students.where((s) => s.standard == _sourceStd && s.academicYearId == state.currentYear.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('विद्यार्थी वर्गोन्नती (Student Promotion / Year Migration)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.upgrade, color: AppColors.teal, size: 28),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('वार्षिक वर्गोन्नती प्रक्रिया (Annual Promotion Process)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('शैक्षणिक वर्ष संपल्यानंतर उत्तीर्ण विद्यार्थ्यांना पुढील वर्गात स्थलांतरित करा.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _sourceStd,
                            decoration: const InputDecoration(labelText: 'सध्याचा वर्ग (Current Standard)'),
                            items: state.availableStandards.where((s) => s < 8).map((std) {
                              return DropdownMenuItem(value: std, child: Text('इयत्ता $std (${state.currentYear.yearName})'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _sourceStd = val;
                                  _targetStd = val + 1;
                                });
                              }
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.arrow_forward, color: AppColors.primary),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _targetStd,
                            decoration: const InputDecoration(labelText: 'पुढील वर्ग (Next Standard)'),
                            items: state.availableStandards.where((s) => s > 1).map((std) {
                              return DropdownMenuItem(value: std, child: Text('इयत्ता $std'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _targetStd = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _targetYearId,
                            decoration: const InputDecoration(labelText: 'पुढील शैक्षणिक वर्ष (Target Year)'),
                            items: state.academicYears.map((yr) {
                              return DropdownMenuItem(value: yr.id, child: Text(yr.yearName));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _targetYearId = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: studentsToPromote.isEmpty
                          ? null
                          : () async {
                              final count = await state.promoteStudents(
                                fromStd: _sourceStd,
                                toStd: _targetStd,
                                nextYearId: _targetYearId,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$count विद्यार्थी यशस्वीरित्या इयत्ता $_targetStd मध्ये वर्गोन्नत केले!'),
                                  backgroundColor: AppColors.gradeA1,
                                ),
                              );
                            },
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text('इयत्ता $_sourceStd चे सर्व ${studentsToPromote.length} विद्यार्थी पुढील वर्गात वर्गोन्नत करा'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Students eligible for promotion table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'इयत्ता $_sourceStd मधील वर्गोन्नतीस पात्र विद्यार्थी (${studentsToPromote.length}):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: studentsToPromote.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final s = studentsToPromote[idx];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                            child: Text('${s.rollNoSem1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(s.studentNameMr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          subtitle: Text('GR: ${s.grNo} • प्रवर्ग: ${s.casteCategory}', style: const TextStyle(fontSize: 11)),
                          trailing: const Chip(
                            label: Text('पात्र (Eligible)', style: TextStyle(color: Colors.white, fontSize: 10)),
                            backgroundColor: AppColors.gradeA1,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
