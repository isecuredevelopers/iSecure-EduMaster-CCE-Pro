import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/marathi_date_formatter.dart';
import '../../providers/app_state_provider.dart';
import '../../data/models/student_model.dart';
import '../reports/leaving_certificate_screen.dart';
import '../reports/general_register_extract_screen.dart';
import 'student_form_screen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  String _searchQuery = '';
  String _selectedGenderFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final students = state.filteredStudents.where((s) {
      final sName = s.studentNameMr.toLowerCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          sName.contains(q) ||
          s.grNo.contains(q) ||
          s.getRollNo(state.selectedSemester).toString().contains(q);
      final matchesGender = _selectedGenderFilter == 'ALL' || s.gender == _selectedGenderFilter;
      return matchesSearch && matchesGender;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'विद्यार्थी यादी: ${MarathiDateFormatter.classToMarathi(state.selectedStd)} तुकडी ${state.selectedDiv} (सत्र ${state.selectedSemester})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudentFormScreen()),
                );
              },
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('नवीन प्रवेश नोंदणी (New Admission)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Standard / Class Quick Switcher Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 20, color: Color(0xFF0D6EFD)),
                  const SizedBox(width: 8),
                  const Text(
                    'इयत्ता निवडा:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: state.availableStandards.map((std) {
                          final isSelected = state.selectedStd == std;
                          final count = state.students
                              .where((s) => s.standard == std && s.academicYearId == state.currentYear.id)
                              .length;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${MarathiDateFormatter.classToMarathi(std)} ($count)'),
                              selected: isSelected,
                              selectedColor: const Color(0xFF0D6EFD),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  state.setStandard(std);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Division Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.availableDivisions.contains(state.selectedDiv)
                            ? state.selectedDiv
                            : (state.availableDivisions.isNotEmpty ? state.availableDivisions.first : null),
                        items: state.availableDivisions.map((div) {
                          return DropdownMenuItem(
                            value: div,
                            child: Text('तुकडी $div', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) state.setDivision(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search & Gender Filter Toolbar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'विद्यार्थ्याचे नाव, हजेरी क्र. किंवा जनरल रजि. क्र. (GR No.) शोधा...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'ALL', label: Text('सर्व')),
                      ButtonSegment(value: 'M', label: Text('मुले')),
                      ButtonSegment(value: 'F', label: Text('मुली')),
                    ],
                    selected: {_selectedGenderFilter},
                    onSelectionChanged: (set) {
                      setState(() {
                        _selectedGenderFilter = set.first;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Students Data Table
            Expanded(
              child: Card(
                child: students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 56, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              '${MarathiDateFormatter.classToMarathi(state.selectedStd)} तुकडी ${state.selectedDiv} मध्ये विद्यार्थी आढळले नाहीत.',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const StudentFormScreen()),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('नवीन विद्यार्थी प्रवेश करा (Add Admission)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D6EFD),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                              dataRowHeight: 56,
                              columns: const [
                                DataColumn(label: Text('हजेरी क्र.', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('जनरल रजि. (GR)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('विद्यार्थ्याचे पूर्ण नाव (मराठीत)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('वडिलांचे नाव', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('आईचे नाव', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('वर्ग (तुकडी)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('लिंग', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('जात / प्रवर्ग', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('जन्मतारीख', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('कृती (Actions)', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: students.map((stu) {
                                final rollNo = stu.getRollNo(state.selectedSemester);
                                final dobFormatted = DateFormat('dd/MM/yyyy').format(stu.dateOfBirth);
                                final casteVal = stu.caste.trim();
                                final catVal = stu.casteCategory.trim();
                                final casteDisplay = casteVal.isNotEmpty
                                    ? (catVal.isNotEmpty ? '$casteVal ($catVal)' : casteVal)
                                    : (catVal.isNotEmpty ? catVal : '-');

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '$rollNo',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(stu.grNo, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(
                                      Text(
                                        stu.studentNameMr,
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    DataCell(Text(stu.fatherName)),
                                    DataCell(Text(stu.motherName)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFBFDBFE)),
                                        ),
                                        child: Text(
                                          '${MarathiDateFormatter.classToMarathi(stu.standard)} (${stu.division})',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1D4ED8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: stu.gender == 'F' ? const Color(0xFFFCE7F3) : const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          stu.genderTextMr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: stu.gender == 'F' ? const Color(0xFFDB2777) : const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Chip(
                                        label: Text(
                                          casteDisplay,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    DataCell(Text(dobFormatted)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.description_outlined, size: 18, color: Color(0xFFD32F2F)),
                                            tooltip: 'शाळा सोडल्याचा दाखला (LC)',
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (_) => LeavingCertificateScreen(initialStudent: stu)),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.menu_book_outlined, size: 18, color: Color(0xFFB45309)),
                                            tooltip: 'रजिस्टर नं. १ चा उतारा (GR Extract)',
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (_) => GeneralRegisterExtractScreen(initialStudent: stu)),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0D6EFD)),
                                            tooltip: 'संपादित करा (Edit)',
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (_) => StudentFormScreen(studentToEdit: stu)),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.gradeD),
                                            tooltip: 'हटवा (Delete)',
                                            onPressed: () {
                                              _confirmDelete(context, stu);
                                            },
                                          ),
                                        ],
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
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('विद्यार्थी हटवा?'),
        content: Text('${student.studentNameMr} (हजेरी क्र. ${student.rollNoSem1}) या विद्यार्थ्याची सर्व माहिती हटवायची आहे का?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gradeD),
            onPressed: () {
              context.read<AppStateProvider>().deleteStudent(student.id);
              Navigator.pop(ctx);
            },
            child: const Text('हटवा'),
          ),
        ],
      ),
    );
  }
}
