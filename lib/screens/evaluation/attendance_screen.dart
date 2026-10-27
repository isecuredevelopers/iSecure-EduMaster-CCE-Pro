import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.filteredStudents;
    final wd = state.workingDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'माहेवार विद्यार्थी उपस्थिती: इ. ${state.selectedStd} तुकडी ${state.selectedDiv} (${state.currentYear.yearName})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('विद्यार्थी हजेरी यशस्वीरित्या सेव्ह केली!'),
                    backgroundColor: AppColors.gradeA1,
                  ),
                );
              },
              icon: const Icon(Icons.save, size: 18),
              label: const Text('हजेरी जतन करा (Save Attendance)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          )
        ],
      ),
      body: students.isEmpty
          ? const Center(child: Text('या वर्गात विद्यार्थी नाहीत.'))
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
                        headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                        columnSpacing: 12,
                        dataRowHeight: 48,
                        columns: const [
                          DataColumn(label: Text('हजेरी क्र.', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('विद्यार्थ्याचे नाव', style: TextStyle(fontWeight: FontWeight.bold))),
                          // Semester 1 Months
                          DataColumn(label: Text('जून\n(12)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('जुलै\n(24)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('ऑगस्ट\n(23)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('सप्टें.\n(22)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('ऑक्टो.\n(18)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('सत्र १ एकूण\n(99)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal, fontSize: 11))),
                          // Semester 2 Months
                          DataColumn(label: Text('नोव्हें.\n(19)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('डिसें.\n(24)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('जाने.\n(24)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('फेब्रु.\n(22)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('मार्च\n(24)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('एप्रिल\n(20)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('सत्र २ एकूण\n(133)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11))),
                          DataColumn(label: Text('वार्षिक एकूण\n(232)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataColumn(label: Text('हजेरी %\n(%)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        ],
                        rows: students.map((stu) {
                          final att = state.getOrCreateAttendance(stu.id);
                          final rollNo = stu.getRollNo(state.selectedSemester);
                          final pct = wd.grandTotal > 0 ? (att.grandTotal / wd.grandTotal) * 100 : 0.0;

                          return DataRow(
                            cells: [
                              DataCell(Center(child: Text('$rollNo', style: const TextStyle(fontWeight: FontWeight.bold)))),
                              DataCell(
                                SizedBox(
                                  width: 160,
                                  child: Text(stu.studentNameMr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                              // Jun
                              DataCell(_buildDayCell(att.jun, 12, (v) { att.jun = v; state.updateAttendance(att); })),
                              // Jul
                              DataCell(_buildDayCell(att.jul, 24, (v) { att.jul = v; state.updateAttendance(att); })),
                              // Aug
                              DataCell(_buildDayCell(att.aug, 23, (v) { att.aug = v; state.updateAttendance(att); })),
                              // Sep
                              DataCell(_buildDayCell(att.sep, 22, (v) { att.sep = v; state.updateAttendance(att); })),
                              // Oct
                              DataCell(_buildDayCell(att.oct, 18, (v) { att.oct = v; state.updateAttendance(att); })),
                              // Sem 1 Total
                              DataCell(
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text('${att.sem1Total}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal)),
                                  ),
                                ),
                              ),
                              // Nov
                              DataCell(_buildDayCell(att.nov, 19, (v) { att.nov = v; state.updateAttendance(att); })),
                              // Dec
                              DataCell(_buildDayCell(att.dec, 24, (v) { att.dec = v; state.updateAttendance(att); })),
                              // Jan
                              DataCell(_buildDayCell(att.jan, 24, (v) { att.jan = v; state.updateAttendance(att); })),
                              // Feb
                              DataCell(_buildDayCell(att.feb, 22, (v) { att.feb = v; state.updateAttendance(att); })),
                              // Mar
                              DataCell(_buildDayCell(att.mar, 24, (v) { att.mar = v; state.updateAttendance(att); })),
                              // Apr
                              DataCell(_buildDayCell(att.apr, 20, (v) { att.apr = v; state.updateAttendance(att); })),
                              // Sem 2 Total
                              DataCell(
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text('${att.sem2Total}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ),
                                ),
                              ),
                              // Grand Total
                              DataCell(Center(child: Text('${att.grandTotal}', style: const TextStyle(fontWeight: FontWeight.bold)))),
                              // Percentage
                              DataCell(
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: pct >= 75 ? AppColors.gradeA1.withOpacity(0.12) : AppColors.gradeD.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${pct.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: pct >= 75 ? AppColors.gradeA1 : AppColors.gradeD,
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
    );
  }

  Widget _buildDayCell(int value, int max, Function(int) onChanged) {
    return SizedBox(
      width: 44,
      height: 32,
      child: TextFormField(
        initialValue: value > 0 ? value.toString() : '',
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onChanged: (text) {
          final v = int.tryParse(text) ?? 0;
          if (v <= max) onChanged(v);
        },
      ),
    );
  }
}
