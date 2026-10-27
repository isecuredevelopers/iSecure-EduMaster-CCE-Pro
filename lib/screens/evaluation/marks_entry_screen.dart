import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.filteredStudents;
    final currentSubject = state.selectedSubject;
    final stdSubjects = state.currentStdSubjects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'आकारिक व संकलित गुणनोंद: इ. ${state.selectedStd} तुकडी ${state.selectedDiv} (सत्र ${state.selectedSemester})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('सर्व विद्यार्थ्यांचे गुण यशस्वीरित्या सेव्ह केले!'),
                    backgroundColor: AppColors.gradeA1,
                  ),
                );
              },
              icon: const Icon(Icons.save, size: 18),
              label: const Text('गुण सेव्ह करा (Save Marks)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Subject Selection Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: stdSubjects.map((sub) {
                  final isSelected = sub.subjectCode == currentSubject.subjectCode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${sub.shortName} (${sub.formativeMax}+${sub.summativeMax})',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFF1F5F9),
                      onSelected: (selected) {
                        if (selected) state.setSubject(sub);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Marks Matrix Table
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text('या वर्गात विद्यार्थी नाहीत. प्रथम विद्यार्थी यादी नोंदवा.'))
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                              columnSpacing: 16,
                              dataRowHeight: 52,
                              columns: [
                                const DataColumn(label: Text('हजेरी क्र.', style: TextStyle(fontWeight: FontWeight.bold))),
                                const DataColumn(label: Text('विद्यार्थ्याचे नाव', style: TextStyle(fontWeight: FontWeight.bold))),
                                // Formative Columns
                                DataColumn(
                                  label: Tooltip(
                                    message: 'तोंडी काम (कमाल २०)',
                                    child: Text('FE2 तोंडी\n(20)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                ),
                                DataColumn(
                                  label: Tooltip(
                                    message: 'उपक्रम / कृती (कमाल १०)',
                                    child: Text('FE4 कृती\n(10)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                ),
                                DataColumn(
                                  label: Tooltip(
                                    message: 'चाचणी लेखी (कमाल २०)',
                                    child: Text('FE6 चाचणी\n(20)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                ),
                                DataColumn(
                                  label: Tooltip(
                                    message: 'स्वाध्याय / वर्गकार्य (कमाल १०)',
                                    child: Text('FE7 स्वाध्याय\n(10)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                                    child: Text('FET आकारिक\n(${currentSubject.formativeMax})', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal, fontSize: 11)),
                                  ),
                                ),
                                // Summative Columns
                                DataColumn(
                                  label: Tooltip(
                                    message: 'संकलित तोंडी (कमाल १०)',
                                    child: Text('SE1 तोंडी\n(10)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                ),
                                DataColumn(
                                  label: Tooltip(
                                    message: 'संकलित लेखी (कमाल २०)',
                                    child: Text('SE3 लेखी\n(20)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                                    child: Text('SET संकलित\n(${currentSubject.summativeMax})', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11)),
                                  ),
                                ),
                                const DataColumn(label: Text('एकूण (TET)\n(100)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                const DataColumn(label: Text('टक्केवारी\n(%)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                const DataColumn(label: Text('श्रेणी\n(Grade)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              ],
                              rows: students.map((stu) {
                                final eval = state.getOrCreateEvaluation(stu.id, state.selectedSemester, currentSubject.subjectCode);
                                final rollNo = stu.getRollNo(state.selectedSemester);

                                return DataRow(
                                  cells: [
                                    DataCell(Center(child: Text('$rollNo', style: const TextStyle(fontWeight: FontWeight.bold)))),
                                    DataCell(
                                      SizedBox(
                                        width: 170,
                                        child: Text(stu.studentNameMr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    // FE2
                                    DataCell(_buildMarksCell(
                                      value: eval.fe2,
                                      max: 20,
                                      onChanged: (val) {
                                        eval.fe2 = val;
                                        eval.recalculate(currentSubject.formativeMax, currentSubject.summativeMax);
                                        state.updateEvaluation(eval);
                                      },
                                    )),
                                    // FE4
                                    DataCell(_buildMarksCell(
                                      value: eval.fe4,
                                      max: 10,
                                      onChanged: (val) {
                                        eval.fe4 = val;
                                        eval.recalculate(currentSubject.formativeMax, currentSubject.summativeMax);
                                        state.updateEvaluation(eval);
                                      },
                                    )),
                                    // FE6
                                    DataCell(_buildMarksCell(
                                      value: eval.fe6,
                                      max: 20,
                                      onChanged: (val) {
                                        eval.fe6 = val;
                                        eval.recalculate(currentSubject.formativeMax, currentSubject.summativeMax);
                                        state.updateEvaluation(eval);
                                      },
                                    )),
                                    // FE7
                                    DataCell(_buildMarksCell(
                                      value: eval.fe7,
                                      max: 10,
                                      onChanged: (val) {
                                        eval.fe7 = val;
                                        eval.recalculate(currentSubject.formativeMax, currentSubject.summativeMax);
                                        state.updateEvaluation(eval);
                                      },
                                    )),
                                    // FET Total
                                    DataCell(
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                          child: Text(
                                            eval.fet.toStringAsFixed(0),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // SE1
                                    DataCell(_buildMarksCell(
                                      value: eval.se1,
                                      max: 15,
                                      onChanged: (val) {
                                        eval.se1 = val;
                                        eval.recalculate(currentSubject.formativeMax, currentSubject.summativeMax);
                                        state.updateEvaluation(eval);
                                      },
                                    )),
                                    // SE3
                                    DataCell(_buildMarksCell(
                                      value: eval.se3,
                                      max: 25,
                                      onChanged: (val) {
                                        eval.se3 = val;
                                        eval.recalculate(currentSubject.formativeMax, currentSubject.summativeMax);
                                        state.updateEvaluation(eval);
                                      },
                                    )),
                                    // SET Total
                                    DataCell(
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                          child: Text(
                                            eval.set.toStringAsFixed(0),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // TET Total Marks
                                    DataCell(
                                      Center(
                                        child: Text(
                                          eval.tet.toStringAsFixed(0),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                        ),
                                      ),
                                    ),
                                    // Percentage
                                    DataCell(
                                      Center(
                                        child: Text(
                                          '${eval.percentage.toStringAsFixed(0)}%',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    // Grade Badge
                                    DataCell(
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.getGradeColor(eval.grade).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.getGradeColor(eval.grade).withOpacity(0.5)),
                                          ),
                                          child: Text(
                                            eval.grade,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.getGradeColor(eval.grade),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarksCell({
    required double value,
    required double max,
    required Function(double) onChanged,
  }) {
    return SizedBox(
      width: 58,
      height: 36,
      child: TextFormField(
        initialValue: value > 0 ? value.toStringAsFixed(0) : '',
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: (text) {
          final val = double.tryParse(text) ?? 0;
          if (val <= max) {
            onChanged(val);
          }
        },
      ),
    );
  }
}
