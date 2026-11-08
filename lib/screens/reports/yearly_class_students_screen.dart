import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/services/marathi_date_formatter.dart';
import '../../providers/app_state_provider.dart';
import '../../data/models/student_model.dart';
import '../../data/models/academic_year_model.dart';
import 'leaving_certificate_screen.dart';
import 'general_register_extract_screen.dart';
import '../students/student_form_screen.dart';

class YearlyClassStudentsScreen extends StatefulWidget {
  final String? initialYearId;
  final int? initialStd;

  const YearlyClassStudentsScreen({
    super.key,
    this.initialYearId,
    this.initialStd,
  });

  @override
  State<YearlyClassStudentsScreen> createState() => _YearlyClassStudentsScreenState();
}

class _YearlyClassStudentsScreenState extends State<YearlyClassStudentsScreen> {
  String? _selectedYearId;
  int? _selectedStdFilter; // null = all classes
  String _selectedDivFilter = 'ALL';
  String _selectedGenderFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _yearSearchCtrl = TextEditingController();
  String _selectedDecadeKey = '2020s';

  final List<Map<String, dynamic>> _decades = [
    {'key': 'ALL', 'label': 'सर्व वर्षे (६०+)', 'start': null, 'end': null},
    {'key': '2020s', 'label': '२०२० ते २०२५ (चालू)', 'start': 2020, 'end': 2025},
    {'key': '2010s', 'label': '२०१० ते २०१९', 'start': 2010, 'end': 2019},
    {'key': '2000s', 'label': '२००० ते २००९', 'start': 2000, 'end': 2009},
    {'key': '1990s', 'label': '१९९० ते १९९९', 'start': 1990, 'end': 1999},
    {'key': '1980s', 'label': '१९८० ते १९८९', 'start': 1980, 'end': 1989},
    {'key': '1970s', 'label': '१९७० ते १९७९', 'start': 1970, 'end': 1979},
    {'key': '1960s', 'label': '१९६५ ते १९६९', 'start': 1965, 'end': 1969},
  ];

  @override
  void initState() {
    super.initState();
    _selectedYearId = widget.initialYearId;
    _selectedStdFilter = widget.initialStd;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _yearSearchCtrl.dispose();
    super.dispose();
  }

  void _syncDecadeForYear(String yearId, List<AcademicYearModel> years) {
    final y = years.firstWhere((item) => item.id == yearId, orElse: () => years.first);
    final startYear = int.tryParse(y.yearName.split('-').first);
    if (startYear != null) {
      for (var d in _decades) {
        if (d['start'] != null && d['end'] != null) {
          if (startYear >= d['start'] && startYear <= d['end']) {
            setState(() {
              _selectedDecadeKey = d['key'];
            });
            break;
          }
        }
      }
    }
  }

  List<AcademicYearModel> _getFilteredYears(List<AcademicYearModel> allYears) {
    final decade = _decades.firstWhere((d) => d['key'] == _selectedDecadeKey, orElse: () => _decades.first);
    final start = decade['start'] as int?;
    final end = decade['end'] as int?;
    final q = _yearSearchCtrl.text.trim().toLowerCase();

    return allYears.where((y) {
      final yStart = int.tryParse(y.yearName.split('-').first) ?? 0;
      // Do not show future years beyond current academic year 2025-26
      if (yStart > 2025) return false;

      if (start != null && end != null) {
        if (yStart < start || yStart > end) return false;
      }
      if (q.isNotEmpty) {
        if (!y.yearName.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final years = state.academicYears;
    final allStudents = state.students;

    // Set default year if not chosen
    _selectedYearId ??= state.currentYear.id;
    if (!years.any((y) => y.id == _selectedYearId) && years.isNotEmpty) {
      _selectedYearId = state.currentYear.id;
    }

    final currentYear = years.firstWhere(
      (y) => y.id == _selectedYearId,
      orElse: () => state.currentYear,
    );

    // Students enrolled in selected academic year
    final yearStudents = allStudents.where((s) => s.academicYearId == _selectedYearId).toList();

    // Filter students by Class, Division, Gender, Search
    final filteredStudents = yearStudents.where((s) {
      final matchesStd = _selectedStdFilter == null || s.standard == _selectedStdFilter;
      final matchesDiv = _selectedDivFilter == 'ALL' || s.division == _selectedDivFilter;
      final matchesGender = _selectedGenderFilter == 'ALL' || s.gender == _selectedGenderFilter;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          s.studentNameMr.toLowerCase().contains(q) ||
          s.studentNameEn.toLowerCase().contains(q) ||
          s.grNo.contains(q) ||
          s.aadhaarNo.contains(q) ||
          s.getRollNo(state.selectedSemester).toString().contains(q);
      return matchesStd && matchesDiv && matchesGender && matchesSearch;
    }).toList()
      ..sort((a, b) {
        if (a.standard != b.standard) return a.standard.compareTo(b.standard);
        return a.getRollNo(state.selectedSemester).compareTo(b.getRollNo(state.selectedSemester));
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'वर्ष व वर्गनिहाय विद्यार्थी नोंदवही (Yearly Student Directory)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              '${state.school.schoolName} • शैक्षणिक वर्ष सन ${currentYear.yearName}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          // 1. Add Student Button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StudentFormScreen(initialAcademicYearId: currentYear.id),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('नवीन विद्यार्थी नोंदवा', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          // 2. Promotion / Rollover Button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: () => _showPromotionDialog(context, state, currentYear),
              icon: const Icon(Icons.upgrade_outlined, size: 16, color: Color(0xFF4F46E5)),
              label: const Text('वर्गोन्नती / विद्यार्थी आणा', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4F46E5))),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FF),
                side: const BorderSide(color: Color(0xFFC7D2FE)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          // 3. Excel Export Button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _exportCsv(context, currentYear, filteredStudents),
              icon: const Icon(Icons.table_chart_outlined, size: 16),
              label: const Text('Excel / CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          // 4. Print / PDF Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'pdf') {
                  _printPdf(context, state, currentYear, filteredStudents);
                } else if (val == 'html') {
                  _openBrowserPrint(context, state, currentYear, filteredStudents);
                }
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'html',
                  child: Row(
                    children: [
                      Icon(Icons.language, size: 18, color: Color(0xFF0D6EFD)),
                      SizedBox(width: 8),
                      Text('ब्राउझर A4 प्रिंट (HTML Print)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 18, color: Color(0xFFDC2626)),
                      SizedBox(width: 8),
                      Text('PDF जतन करा / प्रिंट करा', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.print, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('प्रिंट यादी ▼', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sleek Academic Year Picker Card
            _buildYearSelectorCard(years, allStudents, state.currentYear.id),
            const SizedBox(height: 14),

            // 2. Key Metrics & Class Strength Summary
            _buildClassStatsSummaryCard(yearStudents, state.availableStandards, currentYear),
            const SizedBox(height: 14),

            // 3. Search and Filters Toolbar
            _buildFiltersToolbar(state, filteredStudents.length, yearStudents.length),
            const SizedBox(height: 14),

            // 4. Detailed Students Table Card
            _buildStudentsTableCard(context, state, currentYear, filteredStudents, yearStudents),
          ],
        ),
      ),
    );
  }

  // 1. Sleek Academic Year Selection Card
  Widget _buildYearSelectorCard(
    List<AcademicYearModel> allYears,
    List<StudentModel> allStudents,
    String activeYearId,
  ) {
    final displayedYears = _getFilteredYears(allYears);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Section Title + Quick Year Dropdown + Go to Active Year
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history_edu, color: Color(0xFF0D6EFD), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'शैक्षणिक वर्ष निवडा (मागील ६०+ वर्षांमधील कोणतेही वर्ष)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'सन १९६५-६६ ते २०२५-२६ • शाळेचे जुने व चालू सर्व रेकॉर्ड्स',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // Search input
              SizedBox(
                width: 150,
                height: 36,
                child: TextField(
                  controller: _yearSearchCtrl,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'वर्ष शोधा (उदा. 1985)',
                    hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
                    suffixIcon: _yearSearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 14),
                            onPressed: () {
                              setState(() => _yearSearchCtrl.clear());
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              // Direct Dropdown Picker
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: allYears.any((y) => y.id == _selectedYearId) ? _selectedYearId : allYears.first.id,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0D6EFD)),
                    items: allYears.where((y) => (int.tryParse(y.yearName.split('-').first) ?? 0) <= 2025).map((y) {
                      final count = allStudents.where((s) => s.academicYearId == y.id).length;
                      final isActive = y.id == activeYearId;
                      final isSel = y.id == _selectedYearId;
                      return DropdownMenuItem<String>(
                        value: y.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'सन ${y.yearName}${isActive ? " (चालू)" : ""}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: (isActive || isSel) ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? const Color(0xFF0D6EFD) : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: count > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                count > 0 ? '$count विद्यार्थी' : 'निरंक',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: count > 0 ? const Color(0xFF166534) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedYearId = val;
                          _syncDecadeForYear(val, allYears);
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Jump to Active Year Button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedYearId = activeYearId;
                    _syncDecadeForYear(activeYearId, allYears);
                  });
                },
                icon: const Icon(Icons.today, size: 15, color: Color(0xFF0D6EFD)),
                label: const Text('चालू वर्ष', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Decade Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _decades.map((d) {
                final isSel = _selectedDecadeKey == d['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDecadeKey = d['key'];
                        final inDecade = _getFilteredYears(allYears);
                        if (inDecade.isNotEmpty && !inDecade.any((y) => y.id == _selectedYearId)) {
                          _selectedYearId = inDecade.first.id;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF0D6EFD) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSel ? const Color(0xFF0D6EFD) : const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        d['label'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                          color: isSel ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Compact Horizontal Year Pills for Selected Decade
          if (displayedYears.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: const Text('शोधलेल्या निकषांनुसार कोणतेही वर्ष आढळले नाही.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: displayedYears.map((y) {
                  final isSelected = y.id == _selectedYearId;
                  final isActive = y.id == activeYearId;
                  final count = allStudents.where((s) => s.academicYearId == y.id).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedYearId = y.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0D6EFD) : (count > 0 ? const Color(0xFFF0FDF4) : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0D6EFD)
                                : (count > 0 ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: const Color(0xFF0D6EFD).withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Icon(Icons.check, size: 14, color: Colors.white),
                              ),
                            Text(
                              'सन ${y.yearName}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.25)
                                    : (count > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isActive ? 'चालू' : (count > 0 ? '$count' : '0'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (count > 0 ? const Color(0xFF166534) : const Color(0xFF94A3B8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // 2. Class Summary & Strength Metrics Card
  Widget _buildClassStatsSummaryCard(
    List<StudentModel> yearStudents,
    List<int> availableStandards,
    AcademicYearModel currentYear,
  ) {
    final totalCount = yearStudents.length;
    final boysCount = yearStudents.where((s) => s.gender == 'M').length;
    final girlsCount = yearStudents.where((s) => s.gender == 'F').length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: 4 Mini Metric Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'एकूण पटसंख्या (Total)',
                  value: '$totalCount',
                  sub: 'सन ${currentYear.yearName}',
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF0D6EFD),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'मुले (Boys)',
                  value: '$boysCount',
                  sub: totalCount > 0 ? '${((boysCount / totalCount) * 100).toStringAsFixed(1)}%' : '0%',
                  icon: Icons.boy_rounded,
                  iconColor: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFE0F2FE),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'मुली (Girls)',
                  value: '$girlsCount',
                  sub: totalCount > 0 ? '${((girlsCount / totalCount) * 100).toStringAsFixed(1)}%' : '0%',
                  icon: Icons.girl_rounded,
                  iconColor: const Color(0xFFDB2777),
                  bgColor: const Color(0xFFFCE7F3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'सक्रिय वर्ग (Classes)',
                  value: '${availableStandards.where((std) => yearStudents.any((s) => s.standard == std)).length} / ${availableStandards.length}',
                  sub: 'इ. १ ली ते ८ वी',
                  icon: Icons.school_rounded,
                  iconColor: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Row 2: Class Filter Pills (इयत्ता १ ली ते ८ वी)
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              const Text(
                'इयत्तानुसार यादी गाळा:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // "सर्व वर्ग" Quick Filter Chip
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('सर्व वर्ग ($totalCount)'),
                          selected: _selectedStdFilter == null,
                          selectedColor: const Color(0xFF0D6EFD),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: _selectedStdFilter == null ? FontWeight.bold : FontWeight.w500,
                            color: _selectedStdFilter == null ? Colors.white : const Color(0xFF0F172A),
                          ),
                          onSelected: (_) => setState(() => _selectedStdFilter = null),
                        ),
                      ),
                      // Individual Class Chips
                      ...availableStandards.map((std) {
                        final inStd = yearStudents.where((s) => s.standard == std).toList();
                        final count = inStd.length;
                        final isSelected = _selectedStdFilter == std;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text('${MarathiDateFormatter.classToMarathi(std)} ($count)'),
                            selected: isSelected,
                            selectedColor: const Color(0xFF0D6EFD),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedStdFilter = isSelected ? null : std;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String sub,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                Text(
                  sub,
                  style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Search and Filters Toolbar
  Widget _buildFiltersToolbar(AppStateProvider state, int filteredCount, int totalCount) {
    final hasActiveFilter = _searchQuery.isNotEmpty || _selectedDivFilter != 'ALL' || _selectedGenderFilter != 'ALL' || _selectedStdFilter != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Search Input
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'विद्यार्थ्याचे नाव, GR No., हजेरी क्र., आधार क्र. शोधा...',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          setState(() {
                            _searchCtrl.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),
          const SizedBox(width: 12),

          // Division Filter
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFFF8FAFC),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDivFilter,
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                items: [
                  const DropdownMenuItem(value: 'ALL', child: Text('सर्व तुकड्या', style: TextStyle(fontSize: 12))),
                  ...state.availableDivisions.map((div) {
                    return DropdownMenuItem(value: div, child: Text('तुकडी $div', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                  }),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDivFilter = val);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Gender Filter
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'ALL', label: Text('सर्व', style: TextStyle(fontSize: 11))),
              ButtonSegment(value: 'M', label: Text('मुले', style: TextStyle(fontSize: 11))),
              ButtonSegment(value: 'F', label: Text('मुली', style: TextStyle(fontSize: 11))),
            ],
            selected: {_selectedGenderFilter},
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onSelectionChanged: (set) {
              setState(() => _selectedGenderFilter = set.first);
            },
          ),

          if (hasActiveFilter) ...[
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchCtrl.clear();
                  _searchQuery = '';
                  _selectedDivFilter = 'ALL';
                  _selectedGenderFilter = 'ALL';
                  _selectedStdFilter = null;
                });
              },
              icon: const Icon(Icons.refresh, size: 14, color: Color(0xFFDC2626)),
              label: const Text('फिल्टर काढा', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
            ),
          ],
        ],
      ),
    );
  }

  // 4. Detailed Students Table Card
  Widget _buildStudentsTableCard(
    BuildContext context,
    AppStateProvider state,
    AcademicYearModel currentYear,
    List<StudentModel> students,
    List<StudentModel> allYearStudents,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.table_chart_rounded, color: Color(0xFF0D6EFD), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'विद्यार्थी तपशील नोंदवही: सन ${currentYear.yearName} (${_selectedStdFilter != null ? MarathiDateFormatter.classToMarathi(_selectedStdFilter!) : "सर्व वर्ग"})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    'एकूण नोंदी: ${students.length} / ${allYearStudents.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1D4ED8)),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFF1F5F9)),

            if (students.isEmpty)
              _buildEmptyState(context, state, currentYear, allYearStudents.isNotEmpty)
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                    dataRowHeight: 52,
                    horizontalMargin: 12,
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text('ह.क्र.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('GR No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('विद्यार्थ्याचे पूर्ण नाव (मराठीत)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('इंग्रजीत नाव', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('वर्ग (तुकडी)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('लिंग', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('जात / प्रवर्ग', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('जन्मतारीख (वय)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('आईचे नाव', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('वडिलांचे नाव', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('मोबाईल', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('दाखला स्थिती', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('कृती (Actions)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                    rows: students.map((stu) {
                      final rollNo = stu.getRollNo(state.selectedSemester);
                      final dobStr = DateFormat('dd/MM/yyyy').format(stu.dateOfBirth);
                      final existingLc = state.leavingCertificates.where((l) => l.studentId == stu.id).toList();
                      final hasLc = existingLc.isNotEmpty;

                      final casteDisplay = stu.caste.isNotEmpty
                          ? (stu.casteCategory.isNotEmpty ? '${stu.caste} (${stu.casteCategory})' : stu.caste)
                          : (stu.casteCategory.isNotEmpty ? stu.casteCategory : '-');

                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$rollNo',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD), fontSize: 12),
                              ),
                            ),
                          ),
                          DataCell(Text(stu.grNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataCell(
                            Text(
                              stu.studentNameMr,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 13),
                            ),
                          ),
                          DataCell(Text(stu.studentNameEn.isNotEmpty ? stu.studentNameEn : '-', style: const TextStyle(fontSize: 12))),
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
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
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
                              label: Text(casteDisplay, style: const TextStyle(fontSize: 10)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          DataCell(Text('$dobStr (${stu.ageInYears} वर्ष)', style: const TextStyle(fontSize: 12))),
                          DataCell(Text(stu.motherName, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(stu.fatherName, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(stu.mobileNo.isNotEmpty ? stu.mobileNo : '-', style: const TextStyle(fontSize: 12))),
                          DataCell(
                            hasLc
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                    ),
                                    child: Text(
                                      'दाखला दिला (क्र. ${existingLc.first.lcNo})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                    ),
                                  )
                                : const Text('शाळेत शिकत आहे', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ),
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
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF0F766E)),
                                  tooltip: 'माहिती पहा (View)',
                                  onPressed: () => _viewStudentDetails(context, stu, currentYear),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                  tooltip: 'हटवा (Delete)',
                                  onPressed: () => _confirmDelete(context, state, stu),
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
          ],
        ),
      ),
    );
  }

  // Helpful Empty State with 3 quick options
  Widget _buildEmptyState(
    BuildContext context,
    AppStateProvider state,
    AcademicYearModel currentYear,
    bool hasStudentsInOtherFilters,
  ) {
    if (hasStudentsInOtherFilters) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            children: [
              const Icon(Icons.filter_list_off, size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 10),
              const Text(
                'निवडलेल्या फिल्टरनुसार विद्यार्थी आढळले नाहीत.',
                style: TextStyle(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('कृपया वर्ग किंवा शोध फिल्टर बदलून पहा.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchCtrl.clear();
                    _searchQuery = '';
                    _selectedStdFilter = null;
                    _selectedDivFilter = 'ALL';
                    _selectedGenderFilter = 'ALL';
                  });
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('सर्व फिल्टर काढा'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school_outlined, size: 48, color: Color(0xFF0D6EFD)),
            ),
            const SizedBox(height: 14),
            Text(
              'सन ${currentYear.yearName} मध्ये अद्याप कोणत्याही विद्यार्थ्यांची नोंद झालेली नाही.',
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'आपण या शैक्षणिक वर्षात नवीन विद्यार्थ्यांची नोंद करू शकता किंवा मागील वर्षातील विद्यार्थी वर्गोन्नती करून आणू शकता.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StudentFormScreen(initialAcademicYearId: currentYear.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1, size: 16),
                  label: Text('सन ${currentYear.yearName} मध्ये नवीन विद्यार्थी नोंदवा'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showPromotionDialog(context, state, currentYear),
                  icon: const Icon(Icons.upgrade_outlined, size: 16),
                  label: const Text('मागील वर्षावरून विद्यार्थी वर्गोन्नती करा'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedYearId = state.currentYear.id;
                      _syncDecadeForYear(state.currentYear.id, state.academicYears);
                    });
                  },
                  icon: const Icon(Icons.today, size: 16),
                  label: Text('चालू वर्ष (${state.currentYear.yearName}) मधील यादी पहा'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Promotion / Rollover Dialog from prior year
  void _showPromotionDialog(BuildContext context, AppStateProvider state, AcademicYearModel targetYear) {
    final availableSourceYears = state.academicYears.where((y) => y.id != targetYear.id).toList();
    if (availableSourceYears.isEmpty) return;

    String sourceYearId = state.currentYear.id == targetYear.id
        ? (availableSourceYears.first.id)
        : state.currentYear.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final sourceStudents = state.students.where((s) => s.academicYearId == sourceYearId).toList();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              children: [
                const Icon(Icons.upgrade, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Text('विद्यार्थी वर्गोन्नती (सन ${targetYear.yearName} मध्ये)', style: const TextStyle(fontSize: 16)),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'मागील शैक्षणिक वर्षातील विद्यार्थ्यांना एका क्लिकमध्ये पुढील वर्गात वर्गोन्नती करून या शैक्षणिक वर्षात आणा:',
                    style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 16),
                  const Text('स्रोत वर्ष निवडा (कोणत्या वर्षातील विद्यार्थी आणायचे?):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: sourceYearId,
                        items: availableSourceYears.map((y) {
                          final count = state.students.where((s) => s.academicYearId == y.id).length;
                          return DropdownMenuItem(
                            value: y.id,
                            child: Text('सन ${y.yearName} ($count विद्यार्थी उपलब्ध)'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => sourceYearId = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('उपलब्ध विद्यार्थी: ${sourceStudents.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3730A3))),
                        const SizedBox(height: 4),
                        const Text(
                          '• इ. १ ली मधील विद्यार्थी -> इ. २ री मध्ये वर्गोन्नत होतील\n• इ. २ री मधील विद्यार्थी -> इ. ३ री मध्ये...\n• इ. ८ वी मधील विद्यार्थी उत्तीर्ण समजले जातील.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF4338CA)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('रद्द करा'),
              ),
              ElevatedButton.icon(
                onPressed: sourceStudents.isEmpty
                    ? null
                    : () async {
                        int totalPromoted = 0;
                        for (int std = 1; std <= 7; std++) {
                          final pCount = await state.promoteStudents(
                            fromStd: std,
                            toStd: std + 1,
                            nextYearId: targetYear.id,
                          );
                          totalPromoted += pCount;
                        }
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$totalPromoted विद्यार्थी यशस्वीरीत्या वर्गोन्नत झाले!'),
                              backgroundColor: const Color(0xFF166534),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('वर्गोन्नती पूर्ण करा'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Delete Confirmation Dialog
  void _confirmDelete(BuildContext context, AppStateProvider state, StudentModel stu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('विद्यार्थी नोंद हटवा'),
          ],
        ),
        content: Text(
          'तुम्हाला खात्री आहे का? "${stu.studentNameMr}" (GR: ${stu.grNo}) या विद्यार्थ्याचे रेकॉर्ड कायमचे हटवले जाईल.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('रद्द करा'),
          ),
          ElevatedButton(
            onPressed: () async {
              await state.deleteStudent(stu.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${stu.studentNameMr} चे रेकॉर्ड हटवले.'),
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('हटवा'),
          ),
        ],
      ),
    );
  }

  // View complete student profile dialog
  void _viewStudentDetails(BuildContext context, StudentModel s, AcademicYearModel year) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.badge, color: Color(0xFF0D6EFD)),
            const SizedBox(width: 8),
            Text('${s.studentNameMr} (GR: ${s.grNo})', style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('शैक्षणिक वर्ष', year.yearName),
                _buildInfoRow('इयत्ता व तुकडी', '${MarathiDateFormatter.classToMarathi(s.standard)} तुकडी ${s.division}'),
                _buildInfoRow('विद्यार्थ्याचे नाव (इंग्रजीत)', s.studentNameEn),
                _buildInfoRow('वडिलांचे नाव', s.fatherName),
                _buildInfoRow('आईचे नाव', s.motherName),
                _buildInfoRow('लिंग', s.genderTextMr),
                _buildInfoRow('धर्म व जात', '${s.religion} / ${s.caste} (${s.casteCategory})'),
                _buildInfoRow('पोटजात', s.subCaste),
                _buildInfoRow('जन्मतारीख', '${DateFormat('dd/MM/yyyy').format(s.dateOfBirth)} (${s.dobWords})'),
                _buildInfoRow('जन्मस्थळ', '${s.birthPlace} ता. ${s.taluka} जि. ${s.district}'),
                _buildInfoRow('पत्ता', s.address),
                _buildInfoRow('मोबाईल क्र.', s.mobileNo),
                _buildInfoRow('स्टूडेंट आय. डी. (Saral)', s.saralId),
                _buildInfoRow('आधार क्रमांक (UID)', s.aadhaarNo),
                _buildInfoRow('APAAR ID', s.apaarId),
                _buildInfoRow('PEN No.', s.penNo),
                _buildInfoRow('या पूर्वीची शाळा', s.previousSchool),
                _buildInfoRow('प्रवेश दिनांक', s.admissionDate != null ? DateFormat('dd/MM/yyyy').format(s.admissionDate!) : '-'),
                _buildInfoRow('वडिलांचा व्यवसाय', s.fatherOccupation),
                _buildInfoRow('आईचा व्यवसाय', s.motherOccupation),
                _buildInfoRow('शेरा', s.remarks),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('बंद करा'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }

  // Export to CSV with UTF-8 BOM so Marathi text opens cleanly in Microsoft Excel
  Future<void> _exportCsv(
    BuildContext context,
    AcademicYearModel year,
    List<StudentModel> students,
  ) async {
    final StringBuffer csv = StringBuffer();
    // Prepend UTF-8 BOM (\uFEFF)
    csv.write('\uFEFF');
    csv.writeln('हजेरी क्र,जनरल रजि क्र,विद्यार्थ्याचे नाव,इंग्रजीत नाव,इयत्ता,तुकडी,लिंग,जात,प्रवर्ग,जन्मतारीख,आईचे नाव,वडिलांचे नाव,मोबाईल,पत्ता');

    for (final s in students) {
      csv.writeln(
        '${s.rollNoSem1},${s.grNo},"${s.studentNameMr}","${s.studentNameEn}",${s.standard},"${s.division}",${s.genderTextMr},"${s.caste}","${s.casteCategory}",${DateFormat('dd/MM/yyyy').format(s.dateOfBirth)},"${s.motherName}","${s.fatherName}","${s.mobileNo}","${s.address}"',
      );
    }

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}\\Student_List_${year.yearName}.csv');
      await file.writeAsString(csv.toString(), encoding: utf8);
      await Process.run('cmd', ['/c', 'start', '', file.path]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel CSV फाइल यशस्वीरित्या तयार झाली: ${file.path}'),
            backgroundColor: const Color(0xFF0F766E),
          ),
        );
      }
    } catch (e) {
      debugPrint('CSV Export Error: $e');
    }
  }

  // Browser HTML Print (1:1 Web A4 Landscape Layout matching official register)
  Future<void> _openBrowserPrint(
    BuildContext context,
    AppStateProvider state,
    AcademicYearModel year,
    List<StudentModel> students,
  ) async {
    final school = state.school;
    final totalBoys = students.where((s) => s.gender == 'M').length;
    final totalGirls = students.where((s) => s.gender == 'F').length;
    final stdText = _selectedStdFilter != null ? MarathiDateFormatter.classToMarathi(_selectedStdFilter!) : "सर्व वर्ग";

    final studentRowsHtml = students.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final s = entry.value;
      final dobStr = DateFormat('dd/MM/yyyy').format(s.dateOfBirth);
      final casteDisplay = s.caste.isNotEmpty ? '${s.caste} (${s.casteCategory})' : s.casteCategory;
      return '''
        <tr>
          <td style="text-align: center;">$idx</td>
          <td style="text-align: center; font-weight: bold;">${s.grNo}</td>
          <td style="font-weight: 600; text-align: left;">${s.studentNameMr}</td>
          <td style="text-align: left;">${s.studentNameEn.isNotEmpty ? s.studentNameEn : "-"}</td>
          <td style="text-align: center;">${MarathiDateFormatter.classToMarathi(s.standard)} (${s.division})</td>
          <td style="text-align: center;">${s.genderTextMr}</td>
          <td style="text-align: center;">$casteDisplay</td>
          <td style="text-align: center;">$dobStr</td>
          <td style="text-align: left;">${s.motherName}</td>
          <td style="text-align: left;">${s.fatherName}</td>
          <td style="text-align: center;">${s.mobileNo.isNotEmpty ? s.mobileNo : "-"}</td>
        </tr>
      ''';
    }).join('\n');

    final htmlContent = '''
<!DOCTYPE html>
<html lang="mr">
<head>
    <meta charset="UTF-8">
    <title>विद्यार्थी नोंदवही - सन ${year.yearName}</title>
    <style>
        @page {
            size: A4 landscape;
            margin: 12mm 10mm 12mm 10mm;
        }
        body {
            font-family: 'Nirmala UI', Arial, sans-serif;
            color: #000;
            background: #fff;
            margin: 0;
            padding: 10px;
            font-size: 11px;
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #000;
            padding-bottom: 8px;
            margin-bottom: 12px;
        }
        .school-title {
            font-size: 20px;
            font-weight: bold;
            color: #b91c1c;
            margin: 0;
        }
        .school-sub {
            font-size: 11px;
            margin: 3px 0;
            color: #334155;
        }
        .doc-title {
            font-size: 14px;
            font-weight: bold;
            margin-top: 6px;
            text-decoration: underline;
        }
        .meta-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-weight: bold;
            font-size: 11px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 10px;
        }
        th, td {
            border: 1px solid #333;
            padding: 5px 4px;
        }
        th {
            background-color: #f1f5f9;
            font-weight: bold;
            text-align: center;
        }
        tr:nth-child(even) {
            background-color: #fafafa;
        }
        .footer-row {
            margin-top: 25px;
            display: flex;
            justify-content: space-between;
            font-size: 11px;
        }
        @media print {
            .no-print { display: none; }
            body { padding: 0; }
        }
    </style>
</head>
<body>
    <div class="no-print" style="text-align: right; margin-bottom: 15px;">
        <button onclick="window.print()" style="padding: 8px 16px; background: #0D6EFD; color: #fff; border: none; border-radius: 5px; font-weight: bold; cursor: pointer;">🖨️ प्रिंट करा (Print)</button>
    </div>

    <div class="header">
        <p style="margin: 0; font-size: 11px; font-weight: bold; color: #475569;">॥ शिक्षण हेच जीवन ॥</p>
        <h1 class="school-title">${school.schoolName.isNotEmpty ? school.schoolName : "जिल्हा परिषद प्राथमिक शाळा"}</h1>
        <p class="school-sub">${school.sansthaName} • U-DISE कोड: ${school.udiseCode} • तालुका: ${school.blockTaluka}, जिल्हा: ${school.district}</p>
        <p class="doc-title">वर्ष व वर्गनिहाय विद्यार्थी नोंदवही (Student Register)</p>
    </div>

    <div class="meta-row">
        <div>शैक्षणिक वर्ष: सन ${year.yearName} ($stdText)</div>
        <div>एकूण विद्यार्थी: ${students.length} (मुले: $totalBoys, मुली: $totalGirls)</div>
        <div>दिनांक: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}</div>
    </div>

    <table>
        <thead>
            <tr>
                <th style="width: 30px;">अ.क्र.</th>
                <th style="width: 55px;">GR क्र.</th>
                <th>विद्यार्थ्याचे नाव (मराठीत)</th>
                <th>इंग्रजीत नाव</th>
                <th style="width: 65px;">इयत्ता</th>
                <th style="width: 45px;">लिंग</th>
                <th style="width: 90px;">जात व प्रवर्ग</th>
                <th style="width: 75px;">जन्मतारीख</th>
                <th>आईचे नाव</th>
                <th>वडिलांचे नाव</th>
                <th style="width: 80px;">मोबाईल</th>
            </tr>
        </thead>
        <tbody>
            $studentRowsHtml
        </tbody>
    </table>

    <div class="footer-row">
        <div>
            <p style="margin: 0;">स्थळ: ${school.blockTaluka.isNotEmpty ? school.blockTaluka : "अकोले"}</p>
            <p style="margin: 3px 0 0 0;">दिनांक: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}</p>
        </div>
        <div style="text-align: center; font-weight: bold;">
            वर्गशिक्षक (स्वाक्षरी)
        </div>
        <div style="text-align: center; font-weight: bold;">
            मुख्याध्यापक (स्वाक्षरी व शिक्का)<br>
            <small style="font-weight: normal; color: #475569;">${school.schoolName}</small>
        </div>
    </div>

    <script>
        window.onload = function() {
            setTimeout(function() { window.print(); }, 400);
        };
    </script>
</body>
</html>
''';

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/Student_Directory_${year.yearName}.html');
      await file.writeAsString(htmlContent, encoding: utf8);
      await Process.run('cmd', ['/c', 'start', '', file.path]);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('प्रिंट फाइल तयार करताना त्रुटी: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Print Native PDF of Student Register
  Future<void> _printPdf(
    BuildContext context,
    AppStateProvider state,
    AcademicYearModel year,
    List<StudentModel> students,
  ) async {
    final school = state.school;
    final pdf = pw.Document();

    pw.Font? ttfRegular;
    pw.Font? ttfBold;
    try {
      final fReg = File(r'C:\Windows\Fonts\Nirmala.ttf');
      final fBold = File(r'C:\Windows\Fonts\NirmalaB.ttf');
      if (fReg.existsSync() && fBold.existsSync()) {
        ttfRegular = pw.Font.ttf(fReg.readAsBytesSync().buffer.asByteData());
        ttfBold = pw.Font.ttf(fBold.readAsBytesSync().buffer.asByteData());
      }
    } catch (e) {
      debugPrint('Font load error: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context ctx) {
          return [
            pw.Center(
              child: pw.Text(
                school.schoolName.isNotEmpty ? school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा',
                style: pw.TextStyle(font: ttfBold, fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text(
                '${school.sansthaName} • U-DISE: ${school.udiseCode} • तालुका: ${school.blockTaluka} जिल्हा: ${school.district}',
                style: pw.TextStyle(font: ttfRegular, fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Center(
              child: pw.Text(
                'विद्यार्थी नोंदवही - शैक्षणिक वर्ष: सन ${year.yearName} (${_selectedStdFilter != null ? MarathiDateFormatter.classToMarathi(_selectedStdFilter!) : "सर्व वर्ग"})',
                style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildPdfHeaderCell('अ.क्र.', ttfBold),
                    _buildPdfHeaderCell('GR No.', ttfBold),
                    _buildPdfHeaderCell('विद्यार्थ्याचे नाव', ttfBold),
                    _buildPdfHeaderCell('वर्ग', ttfBold),
                    _buildPdfHeaderCell('लिंग', ttfBold),
                    _buildPdfHeaderCell('जात / प्रवर्ग', ttfBold),
                    _buildPdfHeaderCell('जन्मतारीख', ttfBold),
                    _buildPdfHeaderCell('आईचे नाव', ttfBold),
                    _buildPdfHeaderCell('वडिलांचे नाव', ttfBold),
                    _buildPdfHeaderCell('मोबाईल', ttfBold),
                  ],
                ),
                ...students.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final s = entry.value;
                  return pw.TableRow(
                    children: [
                      _buildPdfCell('$idx', ttfRegular, alignCenter: true),
                      _buildPdfCell(s.grNo, ttfBold, alignCenter: true),
                      _buildPdfCell(s.studentNameMr, ttfRegular),
                      _buildPdfCell('${s.standard} (${s.division})', ttfRegular, alignCenter: true),
                      _buildPdfCell(s.genderTextMr, ttfRegular, alignCenter: true),
                      _buildPdfCell('${s.caste} (${s.casteCategory})', ttfRegular),
                      _buildPdfCell(DateFormat('dd/MM/yyyy').format(s.dateOfBirth), ttfRegular, alignCenter: true),
                      _buildPdfCell(s.motherName, ttfRegular),
                      _buildPdfCell(s.fatherName, ttfRegular),
                      _buildPdfCell(s.mobileNo, ttfRegular, alignCenter: true),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('एकूण विद्यार्थी: ${students.length}', style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                pw.Text('वर्गशिक्षक स्वाक्षरी', style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                pw.Text('मुख्याध्यापक स्वाक्षरी व शिक्का', style: pw.TextStyle(font: ttfBold, fontSize: 10)),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Students_${year.yearName}',
    );
  }

  pw.Widget _buildPdfHeaderCell(String text, pw.Font? font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildPdfCell(String text, pw.Font? font, {bool alignCenter = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        textAlign: alignCenter ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(font: font, fontSize: 8.5),
      ),
    );
  }
}
