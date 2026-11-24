import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/constants/app_colors.dart';
import '../../core/services/marathi_date_formatter.dart';
import '../../providers/app_state_provider.dart';
import '../../data/models/student_model.dart';
import '../../data/models/leaving_certificate_model.dart';
import '../../data/local/sample_data.dart';
import '../../widgets/school_logo_widget.dart';

class LeavingCertificateScreen extends StatefulWidget {
  final StudentModel? initialStudent;

  const LeavingCertificateScreen({super.key, this.initialStudent});

  @override
  State<LeavingCertificateScreen> createState() => _LeavingCertificateScreenState();
}

class _LeavingCertificateScreenState extends State<LeavingCertificateScreen> {
  String? _selectedStudentId;
  String _searchQuery = '';
  String? _selectedYearIdFilter; // null = all years
  int? _selectedStdFilter; // null = all standards
  String? _selectedDivFilter; // null = all divisions
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialStudent != null) {
      _selectedStudentId = widget.initialStudent!.id;
      _selectedYearIdFilter = widget.initialStudent!.academicYearId;
      _selectedStdFilter = widget.initialStudent!.standard;
      _selectedDivFilter = widget.initialStudent!.division;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final allStudents = state.students;
    final school = state.school;

    // Filter students by Academic Year, Class, Division and Search Query
    final filteredStudents = allStudents.where((s) {
      final matchesYear = _selectedYearIdFilter == null || s.academicYearId == _selectedYearIdFilter;
      final matchesStd = _selectedStdFilter == null || s.standard == _selectedStdFilter;
      final matchesDiv = _selectedDivFilter == null || s.division == _selectedDivFilter;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          s.studentNameMr.toLowerCase().contains(q) ||
          s.grNo.contains(q) ||
          s.studentNameEn.toLowerCase().contains(q) ||
          s.saralId.toLowerCase().contains(q);
      return matchesYear && matchesStd && matchesDiv && matchesSearch;
    }).toList();

    if (_selectedStudentId == null && filteredStudents.isNotEmpty) {
      _selectedStudentId = filteredStudents.first.id;
    }

    final currentStudent = allStudents.firstWhere(
      (s) => s.id == _selectedStudentId,
      orElse: () => filteredStudents.isNotEmpty
          ? filteredStudents.first
          : (allStudents.isNotEmpty ? allStudents.first : SampleData.defaultStudents.first),
    );

    final lc = state.getOrCreateLeavingCertificate(currentStudent);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'शाळा सोडल्याचा दाखला (School Leaving Certificate - LC)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Official Issue LC / Revoke App Access Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _toggleIssueLc(context, state, currentStudent, lc),
              icon: Icon(
                state.isStudentLeftSchool(currentStudent) ? Icons.lock_open : Icons.lock_person,
                size: 18,
              ),
              label: Text(
                state.isStudentLeftSchool(currentStudent)
                    ? 'दाखला रद्द करा (ॲप चालू करा)'
                    : 'दाखला वितरित करा (ॲप बंद करा)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isStudentLeftSchool(currentStudent)
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _openEditDialog(context, state, lc, currentStudent),
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('दाखला माहिती संपादित करा'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _printBrowserHtml(context, state, lc),
              icon: const Icon(Icons.language, size: 18),
              label: const Text('ब्राउझर प्रिंट (Exact HTML)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () => _printPdf(context, state, lc),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('दाखला प्रिंट करा (PDF)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar: Student Selection Panel with Name, Class, Academic Year Filters
          Container(
            width: 330,
            color: Colors.white,
            child: Column(
              children: [
                // Filter Control Box
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.filter_alt, size: 18, color: Color(0xFF0D6EFD)),
                              SizedBox(width: 6),
                              Text(
                                'विद्यार्थी निवडा (Filters)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          if (_selectedYearIdFilter != null || _selectedStdFilter != null || _selectedDivFilter != null || _searchQuery.isNotEmpty)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedYearIdFilter = null;
                                  _selectedStdFilter = null;
                                  _selectedDivFilter = null;
                                  _searchQuery = '';
                                  _searchCtrl.clear();
                                });
                              },
                              child: const Text(
                                'सर्व रिसेट (Reset)',
                                style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 1. Academic Year Filter Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedYearIdFilter,
                            isExpanded: true,
                            hint: const Text('शैक्षणिक वर्ष: सर्व वर्षे', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('शैक्षणिक वर्ष: सर्व वर्षे (All Years)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
                              ),
                              ...state.academicYears.map((y) {
                                final count = state.students.where((s) => s.academicYearId == y.id).length;
                                final isActive = y.id == state.currentYear.id;
                                return DropdownMenuItem<String?>(
                                  value: y.id,
                                  child: Text(
                                    'सन ${y.yearName}${isActive ? " (चालू)" : ""} - $count विद्यार्थी',
                                    style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedYearIdFilter = val;
                                if (!filteredStudents.any((s) => s.id == _selectedStudentId) && filteredStudents.isNotEmpty) {
                                  _selectedStudentId = filteredStudents.first.id;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 2. Class & Division Filter Row
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: _selectedStdFilter,
                                  isExpanded: true,
                                  hint: const Text('इयत्ता: सर्व वर्ग', style: TextStyle(fontSize: 12)),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('सर्व वर्ग', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    ...state.availableStandards.map((std) {
                                      final count = state.students.where((s) => (_selectedYearIdFilter == null || s.academicYearId == _selectedYearIdFilter) && s.standard == std).length;
                                      return DropdownMenuItem<int?>(
                                        value: std,
                                        child: Text('${MarathiDateFormatter.classToMarathi(std)} ($count)', style: const TextStyle(fontSize: 12)),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedStdFilter = val;
                                      if (!filteredStudents.any((s) => s.id == _selectedStudentId) && filteredStudents.isNotEmpty) {
                                        _selectedStudentId = filteredStudents.first.id;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String?>(
                                  value: _selectedDivFilter,
                                  isExpanded: true,
                                  hint: const Text('तुकडी', style: TextStyle(fontSize: 12)),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('सर्व तुकडी', style: TextStyle(fontSize: 12)),
                                    ),
                                    ...state.availableDivisions.map((div) {
                                      return DropdownMenuItem<String?>(
                                        value: div,
                                        child: Text('तुक. $div', style: const TextStyle(fontSize: 12)),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedDivFilter = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 3. Search Box with Clear Button
                      TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'विद्यार्थ्याचे नाव किंवा GR No. शोधा...',
                          hintStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.search, size: 18),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                      ),
                      const SizedBox(height: 6),

                      // Count Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'सापडलेले विद्यार्थी: ${filteredStudents.length}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD)),
                          ),
                          if (_selectedYearIdFilter != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Text(
                                state.academicYears.firstWhere((y) => y.id == _selectedYearIdFilter, orElse: () => state.currentYear).yearName,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // 4. Student List with Year, Class, GR & LC Badges
                Expanded(
                  child: filteredStudents.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_search, size: 42, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                const Text('कोणतेही विद्यार्थी आढळले नाहीत', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                const Text('कृपया फिल्टर बदलून किंवा नाव पुन्हा शोधून पहा.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedYearIdFilter = null;
                                      _selectedStdFilter = null;
                                      _selectedDivFilter = null;
                                      _searchQuery = '';
                                      _searchCtrl.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.refresh, size: 14),
                                  label: const Text('सर्व दाखवा (Reset Filters)', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D6EFD)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredStudents.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final stu = filteredStudents[idx];
                            final isSelected = stu.id == _selectedStudentId;
                            final existingLc = state.leavingCertificates.where((l) => l.studentId == stu.id).toList();
                            final hasLc = existingLc.isNotEmpty;
                            final year = state.academicYears.firstWhere((y) => y.id == stu.academicYearId, orElse: () => state.currentYear);

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: const Color(0xFFEFF6FF),
                              dense: true,
                              title: Text(
                                stu.studentNameMr,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 13,
                                  color: isSelected ? const Color(0xFF0D6EFD) : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: Text(
                                          'GR: ${stu.grNo}',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${MarathiDateFormatter.classToMarathi(stu.standard)} (${stu.division})',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          year.yearName,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (state.isStudentLeftSchool(stu)) ...[
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFFCA5A5)),
                                          ),
                                          child: Text(
                                            '🔒 शाळा सोडली (LC क्र. ${stu.lcNo ?? ""}) • ॲप बंद',
                                            style: const TextStyle(fontSize: 9, color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else if (hasLc) ...[
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFF86EFAC)),
                                          ),
                                          child: Text(
                                            '✓ दाखला तयार (क्र. ${MarathiDateFormatter.toMarathiNumber(existingLc.first.lcNo)})',
                                            style: const TextStyle(fontSize: 9, color: Color(0xFF166534), fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              onTap: () {
                                setState(() => _selectedStudentId = stu.id);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),

          // Main Certificate Canvas & Selector Bar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Status Banner if Student has left school (L.C. Issued)
                  if (state.isStudentLeftSchool(currentStudent))
                    Container(
                      width: 850,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_person, color: Color(0xFFDC2626), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'शाळा सोडल्याचा दाखला अधिकृतपणे वितरित करण्यात आला आहे (L.C. क्र. ${lc.lcNo}). या विद्यार्थ्याचा मोबाइल ॲप ॲक्सेस बंद करण्यात आला आहे. सर्व ऐतिहासिक निकाल, गुण व जनरल रजिस्टर नं. १ मधील माहिती विंडोज सॉफ्टवेअरमध्ये कायमस्वरूपी सुरक्षित आहे.',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF991B1B), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Top Copy Type Selector Bar (matching PHP .selector-bar)
                  Container(
                    width: 850,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'प्रत निवडा: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            state.updateLcCopyType(lc, 'Original');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lc.copyType == 'Original' ? const Color(0xFF28A745) : Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text('मूळ प्रत (Original)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            state.updateLcCopyType(lc, 'Duplicate');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lc.copyType == 'Duplicate' ? const Color(0xFFFD7E14) : Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text('द्वितीय प्रत (Duplicate)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _confirmFreshOriginal(context, state, lc),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('नवीन Original Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17A2B8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // The Certificate Container (Exact design of dakhla-print.php)
                  Container(
                    width: 850,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD32F2F), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Top Right Copy Label Box
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Text(
                              lc.copyType == 'Original'
                                  ? 'मूळ प्रत (Original Copy)'
                                  : 'द्वितीय प्रत (Duplicate Copy)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. School Header
                            Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              margin: const EdgeInsets.only(bottom: 10, top: 4),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFD32F2F), width: 1.5)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SchoolLogoWidget(
                                    logoUrl: school.logoUrl,
                                    size: 85,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text: 'व्यवस्थापनाचे नाव : ',
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text: school.sansthaName.isNotEmpty ? school.sansthaName : 'जिल्हा परिषद',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline,
                                                      decorationStyle: TextDecorationStyle.dotted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          school.schoolName.isNotEmpty ? school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा गारवाडी',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFFD32F2F),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          '(शासन निर्णय क्र. संकीर्ण- २३१६/(२२९/१६)/एस./डी.४ दि. १९/०९/२०१६ नुसार)',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'ता. ${school.blockTaluka}, जिल्हा - ${school.district}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text: 'तालुका : ',
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text: school.blockTaluka,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline,
                                                      decorationStyle: TextDecorationStyle.dotted,
                                                    ),
                                                  ),
                                                  const TextSpan(text: '   जिल्हा : '),
                                                  TextSpan(
                                                    text: school.district,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      decoration: TextDecoration.underline,
                                                      decorationStyle: TextDecorationStyle.dotted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              MarathiDateFormatter.toMarathiNumber(DateFormat('dd.MM.yyyy').format(DateTime.now())),
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 2. Sub-row: UDISE & GR No
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('यु डायस क्र.: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(width: 4),
                                    _buildDigitBoxes(lc.uDiseNo.isNotEmpty ? lc.uDiseNo : school.udiseCode, 15),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('जनरल रजि. क्र.: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
                                      ),
                                      child: Text(
                                        MarathiDateFormatter.toMarathiNumber(lc.generalRegNo),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 3. Main Title
                            const Center(
                              child: Text(
                                'शाळा सोडल्याचे प्रमाणपत्र',
                                style: TextStyle(
                                  color: Color(0xFFD32F2F),
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // 4. LC Number
                            Row(
                              children: [
                                const Text('दाखला क्रमांक : ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text(
                                  MarathiDateFormatter.toMarathiNumber(lc.lcNo),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // 5. 16-Row Data Table (Exact Layout & Borders)
                            Table(
                              border: TableBorder.all(color: const Color(0xFFD32F2F), width: 1.5),
                              columnWidths: const {
                                0: FlexColumnWidth(4.0),
                                1: FlexColumnWidth(6.0),
                              },
                              children: [
                                // Row 1: Student ID
                                _buildTableRow(
                                  label: 'स्टूडेंट आय. डी.',
                                  child: _buildDigitBoxes(lc.studentSaralId, 19),
                                ),
                                // Row 2: UID / Aadhaar
                                _buildTableRow(
                                  label: 'यु आय डी नं. (आधार कार्ड क्रमांक)',
                                  child: _buildDigitBoxes(lc.uidNo, 12),
                                ),
                                // Row 3: Full Name
                                _buildTableRow(
                                  label: '१) विद्यार्थ्याचे पूर्ण नाव',
                                  child: Text(lc.studentName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                ),
                                // Row 4: Mother's Name
                                _buildTableRow(
                                  label: '२) आईचे नाव',
                                  child: Text(lc.motherName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                ),
                                // Row 5: Nationality & Mother Tongue
                                TableRow(
                                  children: [
                                    _buildCell(
                                      child: Text.rich(
                                        TextSpan(
                                          text: '३) राष्ट्रीयत्व : ',
                                          style: const TextStyle(fontSize: 14),
                                          children: [
                                            TextSpan(text: lc.nationality, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    _buildCell(
                                      child: Text.rich(
                                        TextSpan(
                                          text: '४) मातृभाषा - ',
                                          style: const TextStyle(fontSize: 14),
                                          children: [
                                            TextSpan(text: lc.motherTongue, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Row 6: Religion, Caste & Sub-caste
                                _buildTableRow(
                                  label: '५) धर्म, जात व पोटजात',
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'धर्म- ',
                                      style: const TextStyle(fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: lc.religion.isNotEmpty ? lc.religion : '-',
                                          style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted),
                                        ),
                                        const TextSpan(text: '   जात- '),
                                        TextSpan(
                                          text: lc.caste.isNotEmpty ? lc.caste : '-',
                                          style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted),
                                        ),
                                        const TextSpan(text: '   पोटजात- '),
                                        TextSpan(
                                          text: lc.subCaste.isNotEmpty ? lc.subCaste : '-',
                                          style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Row 7: Birth Place
                                _buildTableRow(
                                  label: '६) जन्मस्थळ',
                                  child: Text(lc.birthPlace, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                                // Row 8: Birth Date (Numerals)
                                _buildTableRow(
                                  label: '७) जन्म दिनांक (इ. स. प्रमाणे)',
                                  child: _buildDigitBoxes(_formatDmY(lc.dob), 8),
                                ),
                                // Row 9: Birth Date in Words
                                _buildTableRow(
                                  label: '८) जन्म दिनांक (अक्षरी)',
                                  child: Text(lc.dobWords, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                ),
                                // Row 10: Previous School
                                _buildTableRow(
                                  label: '९) या पूर्वीची शाळा',
                                  child: Text(lc.previousSchool.isNotEmpty ? lc.previousSchool : '-', style: const TextStyle(fontSize: 14)),
                                ),
                                // Row 11: Admission Date & Class
                                _buildTableRow(
                                  label: '१०) शाळेत प्रवेश घेतल्याचा दिनांक व इयत्ता',
                                  child: Row(
                                    children: [
                                      _buildDigitBoxes(_formatDmY(lc.admissionDate ?? lc.dob), 8),
                                      const SizedBox(width: 10),
                                      const Text('इयत्ता- ', style: TextStyle(fontSize: 13)),
                                      Text(
                                        lc.admissionClass,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          decorationStyle: TextDecorationStyle.dotted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Row 12: Progress & Conduct
                                TableRow(
                                  children: [
                                    _buildCell(
                                      child: Text.rich(
                                        TextSpan(
                                          text: '११) अभ्यासातील प्रगती : ',
                                          style: const TextStyle(fontSize: 14),
                                          children: [
                                            TextSpan(text: lc.progress, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    _buildCell(
                                      child: Text.rich(
                                        TextSpan(
                                          text: '१२) वर्तणूक : ',
                                          style: const TextStyle(fontSize: 14),
                                          children: [
                                            TextSpan(text: lc.conduct, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Row 13: Leaving Date
                                _buildTableRow(
                                  label: '१३) शाळा सोडल्याचा दिनांक',
                                  child: _buildDigitBoxes(_formatDmY(lc.leavingDate), 8),
                                ),
                                // Row 14: Current Class & Since
                                _buildTableRow(
                                  label: '१४) कोणत्या इयत्तेत शिकत होता व केव्हापासून',
                                  child: Text(lc.currentClass, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                ),
                                // Row 15: Reason for Leaving
                                _buildTableRow(
                                  label: '१५) शाळा सोडण्याचे कारण',
                                  child: Text(lc.reasonForLeaving, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                                // Row 16: Remarks
                                _buildTableRow(
                                  label: '१६) शेरा',
                                  child: Text(lc.remarks.isNotEmpty ? lc.remarks : '-', style: const TextStyle(fontSize: 14)),
                                ),
                              ],
                            ),

                            // 6. Declaration
                            const Padding(
                              padding: EdgeInsets.only(top: 15, bottom: 8),
                              child: Text(
                                'दाखला देण्यात येतो की, वरील माहिती शाळेतील जनरल रजि. नं. १ प्रमाणे बरोबर आहे.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFD32F2F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 7. Issue Date
                            Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 20),
                              child: Text(
                                'दाखला दिल्याची तारीख : ${MarathiDateFormatter.formatMarathiDate(lc.issueDate)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),

                            // 8. Signature Area
                            Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Column(
                                    children: [
                                      SizedBox(height: 25),
                                      Text('वर्गशिक्षक', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const Column(
                                    children: [
                                      SizedBox(height: 25),
                                      Text('लेखनिक', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('मुख्याध्यापक', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                        school.schoolName.isNotEmpty ? school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build table row with label and child
  TableRow _buildTableRow({required String label, required Widget child}) {
    return TableRow(
      children: [
        _buildCell(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        _buildCell(child: child),
      ],
    );
  }

  Widget _buildCell({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: child,
    );
  }

  // Format date as ddmmyyyy for digit boxes
  String _formatDmY(DateTime? date) {
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d$m$y';
  }

  // Render digit boxes exactly like renderBoxes in dakhla-print.php
  Widget _buildDigitBoxes(String data, int count) {
    final clean = data.replaceAll(RegExp(r'[\s\-/]'), '');
    final marathi = MarathiDateFormatter.toMarathiNumber(clean);
    final runes = marathi.runes.map((r) => String.fromCharCode(r)).toList();
    final List<Widget> boxes = [];
    for (final char in runes) {
      boxes.add(_buildSingleDigitBox(char));
    }
    final remaining = count - runes.length;
    for (int i = 0; i < remaining; i++) {
      boxes.add(_buildSingleDigitBox(' '));
    }
    return Wrap(children: boxes);
  }

  Widget _buildSingleDigitBox(String char) {
    return Container(
      width: 22,
      height: 26,
      margin: const EdgeInsets.only(right: 2, bottom: 2),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F), width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.0,
        ),
      ),
    );
  }

  // Confirm fresh original issue
  void _confirmFreshOriginal(BuildContext context, AppStateProvider state, LeavingCertificateModel lc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('नवीन Original Copy देऊ का?'),
        content: Text(
          'विद्यार्थी: ${lc.studentName}\nया विद्यार्थ्यासाठी copy count रिसेट करून नवीन Original प्रत जारी करायची आहे का?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A2B8)),
            onPressed: () {
              state.issueFreshOriginalLc(lc);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('नवीन Original Copy यशस्वीरित्या तयार केली!'),
                  backgroundColor: Color(0xFF28A745),
                ),
              );
            },
            child: const Text('होय, नवीन मूळ प्रत द्या'),
          ),
        ],
      ),
    );
  }

  // Edit LC details dialog
  void _openEditDialog(
    BuildContext context,
    AppStateProvider state,
    LeavingCertificateModel lc,
    StudentModel student,
  ) {
    final lcNoCtrl = TextEditingController(text: lc.lcNo);
    final grNoCtrl = TextEditingController(text: lc.generalRegNo);
    final saralCtrl = TextEditingController(text: lc.studentSaralId);
    final aadhaarCtrl = TextEditingController(text: lc.uidNo);
    final nameCtrl = TextEditingController(text: lc.studentName);
    final motherCtrl = TextEditingController(text: lc.motherName);
    final nationalityCtrl = TextEditingController(text: lc.nationality);
    final tongueCtrl = TextEditingController(text: lc.motherTongue);
    final religionCtrl = TextEditingController(text: lc.religion);
    final casteCtrl = TextEditingController(text: lc.caste);
    final subCasteCtrl = TextEditingController(text: lc.subCaste);
    final birthPlaceCtrl = TextEditingController(text: lc.birthPlace);
    final dobWordsCtrl = TextEditingController(text: lc.dobWords);
    final prevSchoolCtrl = TextEditingController(text: lc.previousSchool);
    final admClassCtrl = TextEditingController(text: lc.admissionClass);
    final progressCtrl = TextEditingController(text: lc.progress);
    final conductCtrl = TextEditingController(text: lc.conduct);
    final currentClassCtrl = TextEditingController(text: lc.currentClass);
    final reasonCtrl = TextEditingController(text: lc.reasonForLeaving);
    final remarksCtrl = TextEditingController(text: lc.remarks);

    DateTime dobVal = lc.dob;
    DateTime? admDateVal = lc.admissionDate;
    DateTime leavingDateVal = lc.leavingDate;
    DateTime issueDateVal = lc.issueDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.edit_note, color: Color(0xFF0D6EFD)),
                const SizedBox(width: 8),
                Text('दाखला माहिती संपादन - ${lc.studentName}'),
              ],
            ),
            content: SizedBox(
              width: 780,
              height: 520,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('१. दाखला व नोंदणी क्रमांक', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: lcNoCtrl, decoration: const InputDecoration(labelText: 'दाखला क्रमांक (LC No.)'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: grNoCtrl, decoration: const InputDecoration(labelText: 'जनरल रजिस्टर क्र. (GR No.)'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: saralCtrl, decoration: const InputDecoration(labelText: 'स्टूडेंट आय.डी. (Saral ID)'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: aadhaarCtrl, decoration: const InputDecoration(labelText: 'आधार कार्ड क्र. (UID)'))),
                      ],
                    ),
                    const Divider(height: 24),

                    const Text('२. विद्यार्थ्याची माहिती', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(flex: 2, child: TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'विद्यार्थ्याचे नाव'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: motherCtrl, decoration: const InputDecoration(labelText: 'आईचे नाव'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: nationalityCtrl, decoration: const InputDecoration(labelText: 'राष्ट्रीयत्व'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: tongueCtrl, decoration: const InputDecoration(labelText: 'मातृभाषा'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: religionCtrl, decoration: const InputDecoration(labelText: 'धर्म'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: casteCtrl, decoration: const InputDecoration(labelText: 'जात'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: subCasteCtrl, decoration: const InputDecoration(labelText: 'पोटजात'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(flex: 2, child: TextFormField(controller: birthPlaceCtrl, decoration: const InputDecoration(labelText: 'जन्मस्थळ (गाव, ता., जि.)'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dobVal,
                                firstDate: DateTime(1990),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDlgState(() {
                                  dobVal = picked;
                                  dobWordsCtrl.text = MarathiDateFormatter.toMarathiWords(picked);
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'जन्मदिनांक (अंकी)'),
                              child: Text(DateFormat('dd/MM/yyyy').format(dobVal)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(controller: dobWordsCtrl, decoration: const InputDecoration(labelText: 'जन्मदिनांक (अक्षरी)')),
                    const Divider(height: 24),

                    const Text('३. शाळा प्रवेश व प्रगती', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: prevSchoolCtrl, decoration: const InputDecoration(labelText: 'या पूर्वीची शाळा'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: admDateVal ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDlgState(() => admDateVal = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'प्रवेश दिनांक'),
                              child: Text(admDateVal != null ? DateFormat('dd/MM/yyyy').format(admDateVal!) : '-'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: admClassCtrl, decoration: const InputDecoration(labelText: 'प्रवेशाची इयत्ता'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: progressCtrl, decoration: const InputDecoration(labelText: 'अभ्यासातील प्रगती'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: conductCtrl, decoration: const InputDecoration(labelText: 'वर्तणूक'))),
                      ],
                    ),
                    const Divider(height: 24),

                    const Text('४. शाळा सोडल्याचा तपशील', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: leavingDateVal,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setDlgState(() => leavingDateVal = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'शाळा सोडल्याचा दिनांक'),
                              child: Text(DateFormat('dd/MM/yyyy').format(leavingDateVal)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: currentClassCtrl, decoration: const InputDecoration(labelText: 'कोणत्या इयत्तेत शिकत होता व केव्हापासून'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(flex: 2, child: TextFormField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'शाळा सोडण्याचे कारण'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'शेरा'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: issueDateVal,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setDlgState(() => issueDateVal = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'दाखला दिल्याची तारीख'),
                        child: Text(DateFormat('dd/MM/yyyy').format(issueDateVal)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('जतन करा (Save)'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D6EFD)),
                onPressed: () {
                  lc.lcNo = lcNoCtrl.text.trim();
                  lc.generalRegNo = grNoCtrl.text.trim();
                  lc.studentSaralId = saralCtrl.text.trim();
                  lc.uidNo = aadhaarCtrl.text.trim();
                  lc.studentName = nameCtrl.text.trim();
                  lc.motherName = motherCtrl.text.trim();
                  lc.nationality = nationalityCtrl.text.trim();
                  lc.motherTongue = tongueCtrl.text.trim();
                  lc.religion = religionCtrl.text.trim();
                  lc.caste = casteCtrl.text.trim();
                  lc.subCaste = subCasteCtrl.text.trim();
                  lc.birthPlace = birthPlaceCtrl.text.trim();
                  lc.dob = dobVal;
                  lc.dobWords = dobWordsCtrl.text.trim();
                  lc.previousSchool = prevSchoolCtrl.text.trim();
                  lc.admissionDate = admDateVal;
                  lc.admissionClass = admClassCtrl.text.trim();
                  lc.progress = progressCtrl.text.trim();
                  lc.conduct = conductCtrl.text.trim();
                  lc.leavingDate = leavingDateVal;
                  lc.currentClass = currentClassCtrl.text.trim();
                  lc.reasonForLeaving = reasonCtrl.text.trim();
                  lc.remarks = remarksCtrl.text.trim();
                  lc.issueDate = issueDateVal;

                  state.saveLeavingCertificate(lc);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('दाखल्याची माहिती यशस्वीरित्या जतन झाली!'), backgroundColor: Color(0xFF28A745)),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleIssueLc(BuildContext context, AppStateProvider state, StudentModel student, LeavingCertificateModel lc) async {
    final isLeft = state.isStudentLeftSchool(student);
    if (!isLeft) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.assignment_turned_in, color: Color(0xFF059669)),
              SizedBox(width: 8),
              Text('शाळा सोडल्याचा दाखला वितरित करा'),
            ],
          ),
          content: Text(
            'तुम्ही खात्रीने "${student.studentNameMr}" (GR: ${student.grNo}) या विद्यार्थ्याला शाळा सोडल्याचा दाखला (L.C. क्र. ${lc.lcNo}) वितरित करत आहात का?\n\n'
            '• परिणाम: विद्यार्थ्याचा मोबाइल ॲप ॲक्सेस कायमस्वरूपी बंद होईल.\n'
            '• शासकीय नोंद: विद्यार्थ्याचे सर्व जुने रेकॉर्ड, निकाल पत्रके व जनरल रजिस्टर नं. १ मधील सर्व माहिती विंडोज सॉफ्टवेअरमध्ये कायमस्वरूपी सुरक्षित राहील.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('रद्द करा'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
              ),
              child: const Text('होय, दाखला वितरित करा'),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        await state.issueLeavingCertificate(student, lc);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('दाखला यशस्वीरित्या वितरित झाला! विद्यार्थ्याचा मोबाइल ॲप ॲक्सेस बंद करण्यात आला आहे.'),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
      }
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('दाखला वितरण रद्द करा'),
          content: Text('तुम्ही खात्रीने "${student.studentNameMr}" या विद्यार्थ्याचा शाळा सोडल्याचा दाखला रद्द करून नियमित विद्यार्थी म्हणून पुन्हा ॲप ॲक्सेस चालू करू इच्छिता का?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('रद्द करा')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              child: const Text('होय, पूर्ववत करा'),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        await state.cancelLeavingCertificate(student);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('विद्यार्थी पूर्ववत नियमित करण्यात आला आहे व ॲप ॲक्सेस पुन्हा चालू झाला आहे.'),
              backgroundColor: Color(0xFF2563EB),
            ),
          );
        }
      }
    }
  }

  // Exact HTML Browser Print (Generating exact dakhla-print.php HTML file)
  Future<void> _printBrowserHtml(BuildContext context, AppStateProvider state, LeavingCertificateModel lc) async {
    final school = state.school;
    final copyText = lc.copyType == 'Original' ? 'मूळ प्रत (Original Copy)' : 'द्वितीय प्रत (Duplicate Copy)';

    // Build Boxes HTML helper
    String renderBoxesHtml(String data, int count) {
      final clean = data.replaceAll(RegExp(r'[\s\-/]'), '');
      final marathi = MarathiDateFormatter.toMarathiNumber(clean);
      final runes = marathi.runes.map((r) => String.fromCharCode(r)).toList();
      String out = '';
      for (final ch in runes) {
        out += "<span class='digit-box'>$ch</span>";
      }
      final remaining = count - runes.length;
      for (int i = 0; i < remaining; i++) {
        out += "<span class='digit-box'>&nbsp;</span>";
      }
      return out;
    }

    final String dobDmY = _formatDmY(lc.dob);
    final String admDmY = _formatDmY(lc.admissionDate ?? lc.dob);
    final String leaveDmY = _formatDmY(lc.leavingDate);
    final String todayDate = MarathiDateFormatter.toMarathiNumber(DateFormat('dd.MM.yyyy').format(DateTime.now()));
    final String issueDateStr = MarathiDateFormatter.formatMarathiDate(lc.issueDate);

    final htmlContent = '''
<!DOCTYPE html>
<html lang="mr">
<head>
    <meta charset="UTF-8">
    <title>LC Print - ${lc.studentName}</title>
    <style>
        @media print { 
            .no-print { display: none; } 
            body { padding: 0; margin: 0; -webkit-print-color-adjust: exact; print-color-adjust: exact; } 
            .cert-container { border: 2.5px solid #D32F2F !important; }
        }
        body { font-family: 'Arial', sans-serif; background: #f4f4f4; padding: 20px; }
        .cert-container {
            width: 850px;
            margin: auto;
            border: 2.5px solid #D32F2F;
            padding: 15px;
            position: relative;
            background: #fff;
            box-sizing: border-box;
        }
        .copy-label {
            position: absolute;
            top: 10px;
            right: 15px;
            border: 1px solid #000;
            padding: 2px 8px;
            font-size: 12px;
            font-weight: bold;
        }
        .selector-bar {
            text-align: center;
            margin-bottom: 20px;
            background: #fff;
            padding: 15px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .btn {
            padding: 8px 15px;
            margin: 0 5px;
            border: none;
            cursor: pointer;
            font-weight: bold;
            text-decoration: none;
            display: inline-block;
            border-radius: 4px;
        }
        .btn-green { background: #28a745; color: #fff; }
        .btn-orange { background: #fd7e14; color: #fff; }
        .btn-red { background: #D32F2F; color: #fff; }

        .school-header { display: flex; align-items: center; border-bottom: 1.5px solid #D32F2F; padding-bottom: 10px; margin-bottom: 10px; }
        .logo { width: 85px; height: 85px; margin-right: 15px; object-fit: contain; }
        .school-info { flex-grow: 1; text-align: center; }
        .school-info h1 { margin: 0; color: #D32F2F; font-size: 24px; font-weight: bold; }
        .school-info p { margin: 2px 0; font-size: 14px; font-weight: bold; }

        .dotted { border-bottom: 1.5px dotted #000; padding: 0 5px; font-weight: bold; }
        .main-title { color: #D32F2F; text-align: center; font-size: 28px; font-weight: bold; text-decoration: underline; margin: 10px 0; }
        
        .data-table { width: 100%; border-collapse: collapse; border: 1.5px solid #D32F2F; }
        .data-table td { border: 1.5px solid #D32F2F; padding: 8px 10px; font-size: 15px; vertical-align: middle; }
        
        .digit-box {
            display: inline-block; width: 22px; height: 26px; border: 1.2px solid #D32F2F;
            text-align: center; line-height: 26px; margin-right: 2px; font-weight: bold; font-size: 16px;
        }
        .sign-area { margin-top: 50px; display: flex; justify-content: space-between; text-align: center; font-weight: bold; }
    </style>
</head>
<body>

<div class="no-print selector-bar">
    <button onclick="window.print()" class="btn btn-red">🖨️ प्रिंट करा (Print)</button>
    <button onclick="window.close()" class="btn" style="background: #6c757d; color: #fff;">बंद करा (Close)</button>
</div>

<div class="cert-container">
    <div class="copy-label">$copyText</div>

    <div class="school-header">
        <div class="school-info">
            <p style="text-align: left;">व्यवस्थापनाचे नाव : <span class="dotted">${school.sansthaName.isNotEmpty ? school.sansthaName : 'जिल्हा परिषद'}</span></p>
            <h1>${school.schoolName.isNotEmpty ? school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा गारवाडी'}</h1>
            <p style="font-size: 11px;">(शासन निर्णय क्र. संकीर्ण- २३१६/(२२९/१६)/एस./डी.४ दि. १९/०९/२०१६ नुसार)</p>
            <p>ता. ${school.blockTaluka}, जिल्हा - ${school.district}</p>
            <p style="text-align: left; margin-top: 5px;">तालुका : <span class="dotted">${school.blockTaluka}</span> &nbsp; जिल्हा : <span class="dotted">${school.district}</span> <span style="float: right;">$todayDate</span></p>
        </div>
    </div>

    <div style="display: flex; justify-content: space-between; margin-top: 10px; align-items: center;">
        <div>यु डायस क्र.: ${renderBoxesHtml(lc.uDiseNo.isNotEmpty ? lc.uDiseNo : school.udiseCode, 15)}</div>
        <div>जनरल रजि. क्र.: <span style="border:1.5px solid #D32F2F; padding: 2px 15px; font-weight:bold;">${MarathiDateFormatter.toMarathiNumber(lc.generalRegNo)}</span></div>
    </div>

    <div class="main-title">शाळा सोडल्याचे प्रमाणपत्र</div>

    <div style="margin-bottom: 5px;">दाखला क्रमांक : <strong style="font-size: 20px;">${MarathiDateFormatter.toMarathiNumber(lc.lcNo)}</strong></div>

    <table class="data-table">
        <tr><td width="38%">स्टूडेंट आय. डी.</td><td>${renderBoxesHtml(lc.studentSaralId, 19)}</td></tr>
        <tr><td>यु आय डी नं. (आधार कार्ड क्रमांक)</td><td>${renderBoxesHtml(lc.uidNo, 12)}</td></tr>
        <tr><td>१) विद्यार्थ्याचे पूर्ण नाव</td><td><strong>${lc.studentName}</strong></td></tr>
        <tr><td>२) आईचे नाव</td><td>${lc.motherName}</td></tr>
        <tr><td>३) राष्ट्रीयत्व : <strong>${lc.nationality}</strong></td><td>४) मातृभाषा - <strong>${lc.motherTongue}</strong></td></tr>
        <tr><td>५) धर्म, जात व पोटजात</td><td>धर्म- <span class="dotted">${lc.religion}</span> जात- <span class="dotted">${lc.caste}</span> पोटजात- <span class="dotted">${lc.subCaste}</span></td></tr>
        <tr><td>६) जन्मस्थळ</td><td>${lc.birthPlace}</td></tr>
        <tr><td>७) जन्म दिनांक (इ. स. प्रमाणे)</td><td>${renderBoxesHtml(dobDmY, 8)}</td></tr>
        <tr><td>८) जन्म दिनांक (अक्षरी)</td><td>${lc.dobWords}</td></tr>
        <tr><td>९) या पूर्वीची शाळा</td><td>${lc.previousSchool}</td></tr>
        <tr><td>१०) शाळेत प्रवेश घेतल्याचा दिनांक व इयत्ता</td><td>${renderBoxesHtml(admDmY, 8)} &nbsp; इयत्ता- <span class="dotted">${lc.admissionClass}</span></td></tr>
        <tr><td>११) अभ्यासातील प्रगती : <strong>${lc.progress}</strong></td><td>१२) वर्तणूक : <strong>${lc.conduct}</strong></td></tr>
        <tr><td>१३) शाळा सोडल्याचा दिनांक</td><td>${renderBoxesHtml(leaveDmY, 8)}</td></tr>
        <tr><td>१४) कोणत्या इयत्तेत शिकत होता व केव्हापासून</td><td>${lc.currentClass}</td></tr>
        <tr><td>१५) शाळा सोडण्याचे कारण</td><td>${lc.reasonForLeaving}</td></tr>
        <tr><td>१६) शेरा</td><td>${lc.remarks}</td></tr>
    </table>

    <div style="color: #D32F2F; text-align: center; font-weight: bold; margin-top: 15px;">दाखला देण्यात येतो की, वरील माहिती शाळेतील जनरल रजि. नं. १ प्रमाणे बरोबर आहे.</div>
    
    <div style="margin-top: 10px; font-weight:bold;">
        दाखला दिल्याची तारीख : $issueDateStr
    </div>

    <div class="sign-area">
        <div><br>वर्गशिक्षक</div>
        <div><br>लेखनिक</div>
        <div>मुख्याध्यापक<br><small>${school.schoolName.isNotEmpty ? school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा गारवाडी'}</small></div>
    </div>
</div>

<script>
    window.onload = function() {
        // window.print();
    };
</script>

</body>
</html>
''';

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}\\dakhla_print_${lc.generalRegNo}.html');
      await file.writeAsString(htmlContent, encoding: utf8);
      await Process.run('cmd', ['/c', 'start', '', file.path]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('दाखला ब्राउझरमध्ये उघडला आहे! (Ctrl+P दाबून प्रिंट करा)'),
            backgroundColor: Color(0xFF0D6EFD),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching browser print: $e');
    }
  }

  // Vector PDF Printing with Devanagari font
  Future<void> _printPdf(BuildContext context, AppStateProvider state, LeavingCertificateModel lc) async {
    final school = state.school;
    final pdf = pw.Document();

    // Load Windows Font
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

    final redColor = PdfColor.fromInt(0xFFD32F2F);
    final copyText = lc.copyType == 'Original' ? 'मूळ प्रत (Original Copy)' : 'द्वितीय प्रत (Duplicate Copy)';

    pw.Widget buildPdfBox(String char) {
      return pw.Container(
        width: 14,
        height: 17,
        margin: const pw.EdgeInsets.only(right: 1.5),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: redColor, width: 0.8),
        ),
        alignment: pw.Alignment.center,
        child: pw.Text(
          char,
          style: pw.TextStyle(
            font: ttfBold,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    pw.Widget buildPdfBoxes(String data, int count) {
      final clean = data.replaceAll(RegExp(r'[\s\-/]'), '');
      final marathi = MarathiDateFormatter.toMarathiNumber(clean);
      final runes = marathi.runes.map((r) => String.fromCharCode(r)).toList();
      final List<pw.Widget> boxes = [];
      for (final ch in runes) {
        boxes.add(buildPdfBox(ch));
      }
      final remaining = count - runes.length;
      for (int i = 0; i < remaining; i++) {
        boxes.add(buildPdfBox(' '));
      }
      return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: boxes);
    }

    pw.TableRow buildPdfRow({required String label, required pw.Widget child}) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: pw.Text(label, style: pw.TextStyle(font: ttfRegular, fontSize: 9.5)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: child,
          ),
        ],
      );
    }

    final dobDmY = _formatDmY(lc.dob);
    final admDmY = _formatDmY(lc.admissionDate ?? lc.dob);
    final leaveDmY = _formatDmY(lc.leavingDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: redColor, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Copy Label
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    child: pw.Text(copyText, style: pw.TextStyle(font: ttfBold, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                  ),
                ),
                pw.SizedBox(height: 2),

                // School Header
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: redColor, width: 1.2)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text('व्यवस्थापनाचे नाव : ${school.sansthaName.isNotEmpty ? school.sansthaName : "जिल्हा परिषद"}', style: pw.TextStyle(font: ttfBold, fontSize: 9.5)),
                      ),
                      pw.Center(
                        child: pw.Text(
                          school.schoolName.isNotEmpty ? school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा',
                          style: pw.TextStyle(font: ttfBold, color: redColor, fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Center(
                        child: pw.Text('(शासन निर्णय क्र. संकीर्ण- २३१६/(२२९/१६)/एस./डी.४ दि. १९/०९/२०१६ नुसार)', style: pw.TextStyle(font: ttfBold, fontSize: 7.5)),
                      ),
                      pw.Center(
                        child: pw.Text('ता. ${school.blockTaluka}, जिल्हा - ${school.district}', style: pw.TextStyle(font: ttfBold, fontSize: 9.5)),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('तालुका : ${school.blockTaluka}   जिल्हा : ${school.district}', style: pw.TextStyle(font: ttfBold, fontSize: 9)),
                          pw.Text(MarathiDateFormatter.toMarathiNumber(DateFormat('dd.MM.yyyy').format(DateTime.now())), style: pw.TextStyle(font: ttfBold, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 5),

                // UDISE & GR No
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text('यु डायस क्र.: ', style: pw.TextStyle(font: ttfBold, fontSize: 9.5)),
                        buildPdfBoxes(lc.uDiseNo.isNotEmpty ? lc.uDiseNo : school.udiseCode, 15),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Text('जनरल रजि. क्र.: ', style: pw.TextStyle(font: ttfBold, fontSize: 9.5)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: redColor, width: 1.2)),
                          child: pw.Text(MarathiDateFormatter.toMarathiNumber(lc.generalRegNo), style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),

                // Main Title
                pw.Center(
                  child: pw.Text(
                    'शाळा सोडल्याचे प्रमाणपत्र',
                    style: pw.TextStyle(font: ttfBold, color: redColor, fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 2),

                // LC No
                pw.Text('दाखला क्रमांक : ${MarathiDateFormatter.toMarathiNumber(lc.lcNo)}', style: pw.TextStyle(font: ttfBold, fontSize: 11)),
                pw.SizedBox(height: 4),

                // 16-Row Table
                pw.Table(
                  border: pw.TableBorder.all(color: redColor, width: 1.0),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(3.8),
                    1: pw.FlexColumnWidth(6.2),
                  },
                  children: [
                    buildPdfRow(label: 'स्टूडेंट आय. डी.', child: buildPdfBoxes(lc.studentSaralId, 19)),
                    buildPdfRow(label: 'यु आय डी नं. (आधार कार्ड क्रमांक)', child: buildPdfBoxes(lc.uidNo, 12)),
                    buildPdfRow(label: '१) विद्यार्थ्याचे पूर्ण नाव', child: pw.Text(lc.studentName, style: pw.TextStyle(font: ttfBold, fontSize: 10))),
                    buildPdfRow(label: '२) आईचे नाव', child: pw.Text(lc.motherName, style: pw.TextStyle(font: ttfRegular, fontSize: 9.5))),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('३) राष्ट्रीयत्व : ${lc.nationality}', style: pw.TextStyle(font: ttfRegular, fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('४) मातृभाषा - ${lc.motherTongue}', style: pw.TextStyle(font: ttfRegular, fontSize: 9)),
                        ),
                      ],
                    ),
                    buildPdfRow(
                      label: '५) धर्म, जात व पोटजात',
                      child: pw.Text('धर्म- ${lc.religion}   जात- ${lc.caste}   पोटजात- ${lc.subCaste}', style: pw.TextStyle(font: ttfRegular, fontSize: 9)),
                    ),
                    buildPdfRow(label: '६) जन्मस्थळ', child: pw.Text(lc.birthPlace, style: pw.TextStyle(font: ttfRegular, fontSize: 9))),
                    buildPdfRow(label: '७) जन्म दिनांक (इ. स. प्रमाणे)', child: buildPdfBoxes(dobDmY, 8)),
                    buildPdfRow(label: '८) जन्म दिनांक (अक्षरी)', child: pw.Text(lc.dobWords, style: pw.TextStyle(font: ttfRegular, fontSize: 9))),
                    buildPdfRow(label: '९) या पूर्वीची शाळा', child: pw.Text(lc.previousSchool, style: pw.TextStyle(font: ttfRegular, fontSize: 9))),
                    buildPdfRow(
                      label: '१०) शाळेत प्रवेश घेतल्याचा दिनांक व इयत्ता',
                      child: pw.Row(
                        children: [
                          buildPdfBoxes(admDmY, 8),
                          pw.SizedBox(width: 6),
                          pw.Text('इयत्ता- ${lc.admissionClass}', style: pw.TextStyle(font: ttfBold, fontSize: 9)),
                        ],
                      ),
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('११) अभ्यासातील प्रगती : ${lc.progress}', style: pw.TextStyle(font: ttfRegular, fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('१२) वर्तणूक : ${lc.conduct}', style: pw.TextStyle(font: ttfRegular, fontSize: 9)),
                        ),
                      ],
                    ),
                    buildPdfRow(label: '१३) शाळा सोडल्याचा दिनांक', child: buildPdfBoxes(leaveDmY, 8)),
                    buildPdfRow(label: '१४) कोणत्या इयत्तेत शिकत होता व केव्हापासून', child: pw.Text(lc.currentClass, style: pw.TextStyle(font: ttfRegular, fontSize: 9))),
                    buildPdfRow(label: '१५) शाळा सोडण्याचे कारण', child: pw.Text(lc.reasonForLeaving, style: pw.TextStyle(font: ttfRegular, fontSize: 9))),
                    buildPdfRow(label: '१६) शेरा', child: pw.Text(lc.remarks, style: pw.TextStyle(font: ttfRegular, fontSize: 9))),
                  ],
                ),
                pw.SizedBox(height: 6),

                // Declaration
                pw.Center(
                  child: pw.Text(
                    'दाखला देण्यात येतो की, वरील माहिती शाळेतील जनरल रजि. नं. १ प्रमाणे बरोबर आहे.',
                    style: pw.TextStyle(font: ttfBold, color: redColor, fontSize: 9),
                  ),
                ),
                pw.SizedBox(height: 4),

                // Issue date
                pw.Text('दाखला दिल्याची तारीख : ${MarathiDateFormatter.formatMarathiDate(lc.issueDate)}', style: pw.TextStyle(font: ttfBold, fontSize: 9)),
                pw.SizedBox(height: 18),

                // Sign Area
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('वर्गशिक्षक', style: pw.TextStyle(font: ttfBold, fontSize: 9.5)),
                    pw.Text('लेखनिक', style: pw.TextStyle(font: ttfBold, fontSize: 9.5)),
                    pw.Column(
                      children: [
                        pw.Text('मुख्याध्यापक', style: pw.TextStyle(font: ttfBold, fontSize: 9.5)),
                        pw.Text(school.schoolName, style: pw.TextStyle(font: ttfRegular, fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'LC_${lc.generalRegNo}_${lc.studentName}',
    );
  }
}
