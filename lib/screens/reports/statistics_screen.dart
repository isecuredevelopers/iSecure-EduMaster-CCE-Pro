import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.students;

    final categories = ['OPEN', 'OBC', 'SC', 'ST', 'VJNT', 'SBC'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('सांख्यिकी तक्ते (School Statistical Reports)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table 1: Category & Gender Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '१. जात संवर्ग व लिंगनिहाय विद्यार्थी सांख्यिकी (Caste Category & Gender Distribution)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Table(
                      border: TableBorder.all(color: AppColors.border),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                          children: [
                            Padding(padding: EdgeInsets.all(8), child: Text('प्रवर्ग (Category)', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('मुले (Boys)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('मुली (Girls)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('एकूण (Total)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        ...categories.map((cat) {
                          final boys = students.where((s) => s.casteCategory == cat && s.gender == 'M').length;
                          final girls = students.where((s) => s.casteCategory == cat && s.gender == 'F').length;
                          return TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(8), child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600))),
                              Padding(padding: const EdgeInsets.all(8), child: Text('$boys', textAlign: TextAlign.center)),
                              Padding(padding: const EdgeInsets.all(8), child: Text('$girls', textAlign: TextAlign.center)),
                              Padding(padding: const EdgeInsets.all(8), child: Text('${boys + girls}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          );
                        }).toList(),
                        TableRow(
                          decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
                          children: [
                            const Padding(padding: EdgeInsets.all(8), child: Text('एकूण सर्व प्रवर्ग', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${students.where((s) => s.gender == 'M').length}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${students.where((s) => s.gender == 'F').length}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${students.length}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Table 2: Grade distribution across evaluated marks
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '२. श्रेणीनिहाय निकाल तक्ता (Grade Scale Distribution)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Table(
                      border: TableBorder.all(color: AppColors.border),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                          children: [
                            Padding(padding: EdgeInsets.all(8), child: Text('श्रेणी (Grade)', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('गुण मर्यादा (Marks Range)', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('वर्णन (Description)', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('विद्यार्थी संख्या (Count)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        ...state.gradingScales.map((scale) {
                          final count = state.evaluations.where((e) => e.grade == scale.gradeName).length;
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(scale.gradeName, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getGradeColor(scale.gradeName))),
                              ),
                              Padding(padding: const EdgeInsets.all(8), child: Text('${scale.minMarks.toInt()}% ते ${scale.maxMarks.toInt()}%')),
                              Padding(padding: const EdgeInsets.all(8), child: Text(scale.description)),
                              Padding(padding: const EdgeInsets.all(8), child: Text('$count', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          );
                        }).toList(),
                      ],
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
