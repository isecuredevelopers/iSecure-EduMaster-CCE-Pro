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
import '../../data/models/student_model.dart';
import '../../data/models/general_register_extract_model.dart';
import '../../data/local/sample_data.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/school_logo_widget.dart';

class GeneralRegisterExtractScreen extends StatefulWidget {
  final StudentModel? initialStudent;

  const GeneralRegisterExtractScreen({super.key, this.initialStudent});

  @override
  State<GeneralRegisterExtractScreen> createState() => _GeneralRegisterExtractScreenState();
}

class _GeneralRegisterExtractScreenState extends State<GeneralRegisterExtractScreen> {
  String? _selectedStudentId;
  String _searchQuery = '';
  String? _selectedYearIdFilter; // null = all years
  int? _selectedStdFilter; // null = all standards
  String? _selectedDivFilter; // null = all divisions
  String _studentTypeFilter = 'ALL'; // 'ALL', 'CURRENT', 'EX'
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

    // Filter students by type (Current vs Ex), Academic Year, Class, Div, and Search Query
    final filteredStudents = allStudents.where((s) {
      // Check if student has LC (ex-student)
      final hasLc = state.leavingCertificates.any((l) => l.studentId == s.id);
      if (_studentTypeFilter == 'CURRENT' && hasLc) return false;
      if (_studentTypeFilter == 'EX' && !hasLc) return false;

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

    final extract = state.getOrCreateGrExtract(currentStudent);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'रजिस्टर नंबर १ चा उतारा (General Register Extract)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: () => _openEditDialog(context, state, extract, currentStudent),
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('उतारा संपादन करा (Edit)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white70),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _printBrowserHtml(context, state, extract),
              icon: const Icon(Icons.open_in_browser, size: 18),
              label: const Text('ब्राउझर प्रिंट (HTML Print)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _printPdf(context, state, extract),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('प्रिंट / PDF जतन करा'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar Filter & Student Selector (Select2 Style)
          Container(
            width: 360,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              children: [
                // Filter Controls Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                      left: BorderSide(color: Color(0xFFD32F2F), width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.person_search, size: 18, color: Color(0xFFD32F2F)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'विद्यार्थी शोधा व निवडा',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD32F2F)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_searchQuery.isNotEmpty || _selectedYearIdFilter != null || _selectedStdFilter != null || _selectedDivFilter != null || _studentTypeFilter != 'ALL')
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchCtrl.clear();
                                  _selectedYearIdFilter = null;
                                  _selectedStdFilter = null;
                                  _selectedDivFilter = null;
                                  _studentTypeFilter = 'ALL';
                                });
                              },
                              child: const Text(
                                'रिसेट (Reset)',
                                style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Current vs Ex-Students Filter Chips
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildTypeFilterChip('ALL', 'सर्व विद्यार्थी'),
                            _buildTypeFilterChip('CURRENT', 'चालू विद्यार्थी'),
                            _buildTypeFilterChip('EX', 'माजी विद्यार्थी'),
                          ],
                        ),
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

                      // 3. Search Text Field
                      TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'नाव, GR किंवा सरळ आयडी शोधा...',
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchCtrl.clear();
                                    });
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Student List Header & Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: const Color(0xFFE2E8F0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'विद्यार्थी यादी (${filteredStudents.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155)),
                        ),
                      ),
                      const Text(
                        'रजि. क्र. - नाव',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                // Selectable Students List (Select2 / Sidebar list)
                Expanded(
                  child: filteredStudents.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'कोणताही विद्यार्थी आढळला नाही.\nकृपया फिल्टर बदला.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredStudents.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (ctx, i) {
                            final stu = filteredStudents[i];
                            final isSelected = stu.id == _selectedStudentId;
                            final hasLc = state.leavingCertificates.any((l) => l.studentId == stu.id);
                            final grMar = MarathiDateFormatter.toMarathiNumber(stu.grNo);

                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                dense: true,
                                selected: isSelected,
                                selectedTileColor: const Color(0xFFEFF6FF),
                                selectedColor: const Color(0xFF1D4ED8),
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFCBD5E1)),
                                  ),
                                  child: Text(
                                    'GR $grMar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  stu.studentNameMr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      'इ. ${MarathiDateFormatter.classToMarathi(stu.standard)} (${stu.division})',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: hasLc ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        hasLc ? 'माजी (LC)' : 'चालू',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: hasLc ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 18)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedStudentId = stu.id;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Main Center Content: Certificate Options Bar & Preview Canvas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Top Copy Type Selector & Toolbar (matching general-register.php style)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Copy Type Segmented Controls (मूळ / द्वितीय)
                        Row(
                          children: [
                            const Text(
                              'उतारा प्रत निवडा:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      state.updateGrExtractCopyType(extract, 'Original');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: extract.copyType == 'Original' ? const Color(0xFF1E293B) : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                                      ),
                                      child: Text(
                                        'मूळ (Original)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: extract.copyType == 'Original' ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      state.updateGrExtractCopyType(extract, 'Duplicate');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: extract.copyType == 'Duplicate' ? const Color(0xFF1E293B) : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                                      ),
                                      child: Text(
                                        'द्वितीय (Duplicate)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: extract.copyType == 'Duplicate' ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: extract.copyType == 'Duplicate' ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: extract.copyType == 'Duplicate' ? const Color(0xFFF59E0B) : const Color(0xFF0284C7),
                                ),
                              ),
                              child: Text(
                                extract.copyTypeTextMr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: extract.copyType == 'Duplicate' ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Action Buttons
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _openEditDialog(context, state, extract, currentStudent),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('माहिती संपादित करा'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0D6EFD),
                                side: const BorderSide(color: Color(0xFF0D6EFD)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _printBrowserHtml(context, state, extract),
                              icon: const Icon(Icons.print, size: 16),
                              label: const Text('🖨️ प्रिंट (Print)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ==================== THE PRINT CARD (रजिस्टर नंबर १ चा उतारा) ====================
                  Center(
                    child: Container(
                      width: 800,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFCCCCCC)),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background Watermark (same as general-register.php)
                          Positioned.fill(
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.523599, // -30 degrees
                                child: Text(
                                  school.schoolName.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.03),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Certificate Content
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Header Section
                              Container(
                                padding: const EdgeInsets.only(bottom: 12),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // School Logo
                                    SchoolLogoWidget(
                                      logoUrl: school.logoUrl,
                                      size: 65,
                                    ),
                                    const SizedBox(width: 16),
                                    // Header Text
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text(
                                            '॥ शिक्षण हेच जीवन ॥',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            school.schoolName,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFD32F2F),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'ता. ${school.blockTaluka}, जि. ${school.district} (महाराष्ट्र)',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'रजिस्टर नंबर १ चा उतारा',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Symmetry spacer
                                    const SizedBox(width: 72),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // 2. Copy Type Box (Right aligned)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black, width: 1),
                                  ),
                                  child: Text(
                                    extract.copyTypeTextMr,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // 3. Subheader: U-DISE & Register Number
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'यु-डायस क्र.: ${MarathiDateFormatter.toMarathiNumber(extract.uDiseNo)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  Text(
                                    'रजिस्टर नंबर: ${MarathiDateFormatter.toMarathiNumber(extract.generalRegNo)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 4. Data Table (13 Official Rows)
                              Table(
                                border: TableBorder.all(color: Colors.black, width: 1),
                                columnWidths: const {
                                  0: FlexColumnWidth(4.5),
                                  1: FlexColumnWidth(5.5),
                                },
                                children: [
                                  _buildTableRow(
                                    label: '१) विद्यार्थ्याचे पूर्ण नाव',
                                    value: extract.studentName,
                                    isBold: true,
                                  ),
                                  _buildTableRow(
                                    label: '२) आईचे नाव',
                                    value: extract.motherName,
                                  ),
                                  _buildTableRow(
                                    label: '३) जात व पोटजात',
                                    value: [extract.caste, extract.subCaste].where((s) => s.trim().isNotEmpty).join(' '),
                                  ),
                                  _buildTableRow(
                                    label: '४) जन्म ठिकाण',
                                    value: extract.birthPlace,
                                  ),
                                  _buildTableRow(
                                    label: '५) जन्मतारीख (अंकी)',
                                    value: _formatDate(extract.dob),
                                  ),
                                  _buildTableRow(
                                    label: '६) जन्मतारीख (अक्षरी)',
                                    value: extract.dobWords,
                                  ),
                                  _buildTableRow(
                                    label: '७) यापूर्वीची शाळा',
                                    value: extract.previousSchool.isNotEmpty ? extract.previousSchool : '-',
                                  ),
                                  _buildTableRow(
                                    label: '८) प्रवेश दिनांक / इयत्ता',
                                    value: '${_formatDate(extract.admissionDate ?? extract.dob)} / ${extract.admissionClass}',
                                  ),
                                  _buildTableRow(
                                    label: '९) प्रगती व वर्तणूक',
                                    value: '${extract.progress} व ${extract.conduct}',
                                  ),
                                  _buildTableRow(
                                    label: '१०) शाळा सोडल्याचा दिनांक',
                                    value: extract.isCurrentlyStudying || extract.leavingDate == null
                                        ? 'अद्याप शिकत आहे'
                                        : _formatDate(extract.leavingDate),
                                  ),
                                  _buildTableRow(
                                    label: '११) शाळा सोडतानाची इयत्ता',
                                    value: extract.currentClass,
                                  ),
                                  _buildTableRow(
                                    label: '१२) शाळा सोडल्याचे कारण',
                                    value: extract.reasonForLeaving,
                                  ),
                                  _buildTableRow(
                                    label: '१३) शेरा (Remarks)',
                                    value: extract.remarks.isNotEmpty ? extract.remarks : '-',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 36),

                              // 5. Footer Section (दिनांक, स्थळ व मुख्याध्यापक)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'दिनांक: ${_formatDate(DateTime.now())}',
                                          style: const TextStyle(fontSize: 13, color: Colors.black),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'स्थळ: ${_getSchoolPlace(school.address, school.blockTaluka)}',
                                          style: const TextStyle(fontSize: 13, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 30),
                                      Text(
                                        'मुख्याध्यापक',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      Text(
                                        '(शिक्का व सही)',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildTypeFilterChip(String type, String label) {
    final isSelected = _studentTypeFilter == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _studentTypeFilter = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF0D6EFD) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow({required String label, required String value, bool isBold = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            value.isNotEmpty ? value : '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return MarathiDateFormatter.toMarathiNumber('$d/$m/$y');
  }

  String _getSchoolPlace(String address, String blockTaluka) {
    if (address.trim().isNotEmpty) {
      final parts = address.split(',');
      final first = parts.first.replaceAll('मु.', '').replaceAll('पो.', '').trim();
      if (first.isNotEmpty) return first;
    }
    return blockTaluka.isNotEmpty ? blockTaluka : 'गारवाडी';
  }

  // ==================== EDIT DIALOG ====================
  void _openEditDialog(BuildContext context, AppStateProvider state, GeneralRegisterExtractModel extract, StudentModel student) {
    final nameCtrl = TextEditingController(text: extract.studentName);
    final motherCtrl = TextEditingController(text: extract.motherName);
    final grCtrl = TextEditingController(text: extract.generalRegNo);
    final udiseCtrl = TextEditingController(text: extract.uDiseNo);
    final casteCtrl = TextEditingController(text: extract.caste);
    final subCasteCtrl = TextEditingController(text: extract.subCaste);
    final birthPlaceCtrl = TextEditingController(text: extract.birthPlace);
    final dobWordsCtrl = TextEditingController(text: extract.dobWords);
    final prevSchoolCtrl = TextEditingController(text: extract.previousSchool);
    final admClassCtrl = TextEditingController(text: extract.admissionClass);
    final progressCtrl = TextEditingController(text: extract.progress);
    final conductCtrl = TextEditingController(text: extract.conduct);
    final curClassCtrl = TextEditingController(text: extract.currentClass);
    final reasonCtrl = TextEditingController(text: extract.reasonForLeaving);
    final remarksCtrl = TextEditingController(text: extract.remarks);

    DateTime dobVal = extract.dob;
    DateTime? admDateVal = extract.admissionDate;
    DateTime? leaveDateVal = extract.leavingDate;
    bool isStudyingVal = extract.isCurrentlyStudying;
    String copyTypeVal = extract.copyType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: Color(0xFFD32F2F)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('रजिस्टर नं. १ उतारा माहिती संपादन (${extract.studentName})'),
              ),
            ],
          ),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status switcher: Current vs Ex-student
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'विद्यार्थी सद्यस्थिती:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('चालू विद्यार्थी (शिकत आहे)'),
                              selected: isStudyingVal,
                              onSelected: (val) {
                                setDlgState(() {
                                  isStudyingVal = true;
                                  leaveDateVal = null;
                                  if (reasonCtrl.text.isEmpty || reasonCtrl.text == 'पुढील शिक्षणासाठी') {
                                    reasonCtrl.text = '-';
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('माजी विद्यार्थी (शाळा सोडली)'),
                              selected: !isStudyingVal,
                              onSelected: (val) {
                                setDlgState(() {
                                  isStudyingVal = false;
                                  leaveDateVal ??= DateTime.now();
                                  if (reasonCtrl.text == '-') {
                                    reasonCtrl.text = 'पुढील शिक्षणासाठी';
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: grCtrl,
                          decoration: const InputDecoration(labelText: 'रजिस्टर नंबर (GR No.)', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: udiseCtrl,
                          decoration: const InputDecoration(labelText: 'यु-डायस नंबर (U-DISE)', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: copyTypeVal,
                          decoration: const InputDecoration(labelText: 'प्रत प्रकार', isDense: true, border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Original', child: Text('मूळ प्रत (Original)')),
                            DropdownMenuItem(value: 'Duplicate', child: Text('द्वितीय प्रत (Duplicate)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDlgState(() => copyTypeVal = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: '१) विद्यार्थ्याचे पूर्ण नाव', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: motherCtrl,
                          decoration: const InputDecoration(labelText: '२) आईचे नाव', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: casteCtrl,
                          decoration: const InputDecoration(labelText: '३) जात', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: subCasteCtrl,
                          decoration: const InputDecoration(labelText: 'पोटजात', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: birthPlaceCtrl,
                          decoration: const InputDecoration(labelText: '४) जन्म ठिकाण', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('५) जन्मतारीख (अंकी)', style: TextStyle(fontSize: 12)),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(dobVal), style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.calendar_today, size: 18),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: dobVal,
                              firstDate: DateTime(1960),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDlgState(() {
                                dobVal = picked;
                                dobWordsCtrl.text = MarathiDateFormatter.toMarathiWords(picked);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: dobWordsCtrl,
                          decoration: const InputDecoration(labelText: '६) जन्मतारीख (अक्षरी)', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: prevSchoolCtrl,
                    decoration: const InputDecoration(labelText: '७) यापूर्वीची शाळा', isDense: true, border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('८) प्रवेश दिनांक', style: TextStyle(fontSize: 12)),
                          subtitle: Text(admDateVal != null ? DateFormat('dd/MM/yyyy').format(admDateVal!) : 'तारीख निवडा', style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.calendar_today, size: 18),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: admDateVal ?? dobVal,
                              firstDate: DateTime(1960),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDlgState(() => admDateVal = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: admClassCtrl,
                          decoration: const InputDecoration(labelText: 'प्रवेशाची इयत्ता (उदा. 1 ली)', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: progressCtrl,
                          decoration: const InputDecoration(labelText: '९) प्रगती', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: conductCtrl,
                          decoration: const InputDecoration(labelText: 'वर्तणूक', isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (!isStudyingVal) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('१०) शाळा सोडल्याचा दिनांक', style: TextStyle(fontSize: 12)),
                            subtitle: Text(leaveDateVal != null ? DateFormat('dd/MM/yyyy').format(leaveDateVal!) : 'तारीख निवडा', style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.calendar_today, size: 18),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: leaveDateVal ?? DateTime.now(),
                                firstDate: DateTime(1960),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDlgState(() => leaveDateVal = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: curClassCtrl,
                            decoration: const InputDecoration(labelText: '११) शाळा सोडतानाची इयत्ता', isDense: true, border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    TextField(
                      controller: curClassCtrl,
                      decoration: const InputDecoration(labelText: '११) सध्या शिकत असलेली इयत्ता', isDense: true, border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(labelText: '१२) शाळा सोडल्याचे कारण', isDense: true, border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: remarksCtrl,
                    decoration: const InputDecoration(labelText: '१३) शेरा (Remarks)', isDense: true, border: OutlineInputBorder()),
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
              onPressed: () async {
                extract.generalRegNo = grCtrl.text.trim();
                extract.uDiseNo = udiseCtrl.text.trim();
                extract.copyType = copyTypeVal;
                extract.studentName = nameCtrl.text.trim();
                extract.motherName = motherCtrl.text.trim();
                extract.caste = casteCtrl.text.trim();
                extract.subCaste = subCasteCtrl.text.trim();
                extract.birthPlace = birthPlaceCtrl.text.trim();
                extract.dob = dobVal;
                extract.dobWords = dobWordsCtrl.text.trim();
                extract.previousSchool = prevSchoolCtrl.text.trim();
                extract.admissionDate = admDateVal;
                extract.admissionClass = admClassCtrl.text.trim();
                extract.progress = progressCtrl.text.trim();
                extract.conduct = conductCtrl.text.trim();
                extract.isCurrentlyStudying = isStudyingVal;
                extract.leavingDate = isStudyingVal ? null : leaveDateVal;
                extract.currentClass = curClassCtrl.text.trim();
                extract.reasonForLeaving = reasonCtrl.text.trim();
                extract.remarks = remarksCtrl.text.trim();

                await state.saveGrExtract(extract);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('रजिस्टर नं. १ उतारा माहिती यशस्वीरित्या जतन केली!'),
                      backgroundColor: Color(0xFF16A34A),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('माहिती जतन करा (Save)'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D6EFD)),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BROWSER HTML PRINT (Identical to general-register.php) ====================
  Future<void> _printBrowserHtml(BuildContext context, AppStateProvider state, GeneralRegisterExtractModel extract) async {
    final school = state.school;
    final String casteFull = [extract.caste, extract.subCaste].where((s) => s.trim().isNotEmpty).join(' ');
    final String dobFormatted = _formatDate(extract.dob);
    final String admFormatted = _formatDate(extract.admissionDate ?? extract.dob);
    final String leaveFormatted = extract.isCurrentlyStudying || extract.leavingDate == null
        ? 'अद्याप शिकत आहे'
        : _formatDate(extract.leavingDate);
    final String todayDate = _formatDate(DateTime.now());
    final String placeName = _getSchoolPlace(school.address, school.blockTaluka);

    final htmlContent = '''
<!DOCTYPE html>
<html lang="mr">
<head>
    <meta charset="UTF-8">
    <title>रजि. नं. १ उतारा - ${extract.studentName}</title>
    <style>
        html, body { height: 100%; margin: 0; }
        body { display: flex; flex-direction: column; background-color: #f4f6f9; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .content-wrapper { flex: 1 0 auto; padding: 20px; }
        .print-card {
            background: white; padding: 25px; margin: 20px auto; 
            max-width: 800px; border: 1px solid #ddd; position: relative; box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .header-section { display: flex; align-items: center; border-bottom: 2px solid #000; padding-bottom: 8px; margin-bottom: 12px; }
        .logo-img { width: 65px; height: auto; margin-right: 15px; }
        .header-text { flex-grow: 1; text-align: center; margin-right: 65px; }
        .school-name { font-size: 22px; font-weight: bold; color: #d32f2f; margin: 0; }
        .data-table { width: 100%; border-collapse: collapse; margin-top: 12px; }
        .data-table td { border: 1px solid #000; padding: 8px 12px; font-size: 15px; color: #000; }
        .watermark { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%) rotate(-30deg); font-size: 54px; color: rgba(0,0,0,0.03); font-weight: bold; pointer-events: none; z-index: 0; white-space: nowrap; }
        .copy-badge { border: 1px solid #000; padding: 3px 8px; font-size: 13px; font-weight: bold; display: inline-block; }
        .meta-row { display: flex; justify-content: space-between; font-weight: bold; font-size: 15px; margin-bottom: 8px; }
        .footer-row { display: flex; justify-content: space-between; margin-top: 40px; }
        .text-end { text-align: right; }
        .no-print { text-align: center; margin-bottom: 20px; }
        .print-btn { background: #d32f2f; color: white; border: none; padding: 10px 24px; font-size: 16px; font-weight: bold; border-radius: 6px; cursor: pointer; }

        @media print {
            * { margin: 0 !important; padding: 0 !important; }
            body * { visibility: hidden; }
            .print-card, .print-card * { visibility: visible; }
            .print-card {
                visibility: visible;
                position: absolute;
                left: 0; top: 0; width: 100% !important;
                margin: 0 !important; 
                padding: 10mm !important;
                border: none !important; 
                box-shadow: none !important;
                page-break-after: avoid;
                page-break-inside: avoid;
            }
            @page { 
                size: A4; 
                margin: 5mm !important;
            }
            .no-print { display: none !important; }
            .logo-img { -webkit-print-color-adjust: exact; width: 60px !important; height: auto !important; }
            .data-table { width: 100% !important; }
            .data-table td { padding: 8px 10px !important; font-size: 14px !important; }
            .header-section { margin-bottom: 10px !important; }
            .school-name { font-size: 20px !important; color: #d32f2f !important; }
            .watermark { display: none !important; }
        }
    </style>
</head>
<body>
    <div class="content-wrapper">
        <div class="no-print">
            <button class="print-btn" onclick="window.print()">🖨️ प्रिंट काढा (Print / Save as PDF)</button>
        </div>

        <div class="print-card">
            <div class="watermark">${school.schoolName.toUpperCase()}</div>
            
            <div class="header-section">
                <div style="width: 65px; height: 65px; display: flex; align-items: center; justify-content: center; font-size: 32px; color: #d32f2f; border: 2px solid #d32f2f; border-radius: 50%; margin-right: 15px;">🏫</div>
                <div class="header-text">
                    <p style="margin: 0; font-weight: bold; font-size: 12px;">॥ शिक्षण हेच जीवन ॥</p>
                    <h2 class="school-name">${school.schoolName}</h2>
                    <p style="margin: 0; font-weight: bold; font-size: 12px;">ता. ${school.blockTaluka}, जि. ${school.district} (महाराष्ट्र)</p>
                    <h4 style="margin: 8px 0 0 0; text-decoration: underline; font-weight: bold; font-size: 18px;">रजिस्टर नंबर १ चा उतारा</h4>
                </div>
            </div>

            <div style="text-align: right; margin-bottom: 8px;">
                <span class="copy-badge">${extract.copyTypeTextMr}</span>
            </div>

            <div class="meta-row">
                <span>यु-डायस क्र.: ${MarathiDateFormatter.toMarathiNumber(extract.uDiseNo)}</span>
                <span>रजिस्टर नंबर: ${MarathiDateFormatter.toMarathiNumber(extract.generalRegNo)}</span>
            </div>

            <table class="data-table">
                <tbody>
                    <tr><td width="45%">१) विद्यार्थ्याचे पूर्ण नाव</td><td><strong>${extract.studentName}</strong></td></tr>
                    <tr><td>२) आईचे नाव</td><td>${extract.motherName}</td></tr>
                    <tr><td>३) जात व पोटजात</td><td>${casteFull.isNotEmpty ? casteFull : '-'}</td></tr>
                    <tr><td>४) जन्म ठिकाण</td><td>${extract.birthPlace.isNotEmpty ? extract.birthPlace : '-'}</td></tr>
                    <tr><td>५) जन्मतारीख (अंकी)</td><td>$dobFormatted</td></tr>
                    <tr><td>६) जन्मतारीख (अक्षरी)</td><td>${extract.dobWords}</td></tr>
                    <tr><td>७) यापूर्वीची शाळा</td><td>${extract.previousSchool.isNotEmpty ? extract.previousSchool : '-'}</td></tr>
                    <tr><td>८) प्रवेश दिनांक / इयत्ता</td><td>$admFormatted / ${extract.admissionClass}</td></tr>
                    <tr><td>९) प्रगती व वर्तणूक</td><td>${extract.progress} व ${extract.conduct}</td></tr>
                    <tr><td>१०) शाळा सोडल्याचा दिनांक</td><td>$leaveFormatted</td></tr>
                    <tr><td>११) शाळा सोडतानाची इयत्ता</td><td>${extract.currentClass}</td></tr>
                    <tr><td>१२) शाळा सोडल्याचे कारण</td><td>${extract.reasonForLeaving}</td></tr>
                    <tr><td>१३) शेरा (Remarks)</td><td>${extract.remarks.isNotEmpty ? extract.remarks : '-'}</td></tr>
                </tbody>
            </table>

            <div class="footer-row">
                <div>
                    <p style="margin: 0; font-size: 14px;">दिनांक: $todayDate</p>
                    <p style="margin: 4px 0 0 0; font-size: 14px;">स्थळ: $placeName</p>
                </div>
                <div class="text-end" style="font-weight: bold; font-size: 14px;">
                    <br><br>मुख्याध्यापक<br><small style="color: #64748B; font-weight: normal;">(शिक्का व सही)</small>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
''';

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/gr_extract_${extract.studentId}.html');
      await file.writeAsString(htmlContent, encoding: utf8);

      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', file.path]);
      } else {
        await Process.run('open', [file.path]);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('प्रिंट फाइल तयार करताना त्रुटी: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==================== VECTOR HIGH-RES PDF PRINT ====================
  Future<void> _printPdf(BuildContext context, AppStateProvider state, GeneralRegisterExtractModel extract) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.notoSansDevanagariRegular();
    final fontBold = await PdfGoogleFonts.notoSansDevanagariBold();
    final school = state.school;
    final String casteFull = [extract.caste, extract.subCaste].where((s) => s.trim().isNotEmpty).join(' ');
    final String dobFormatted = _formatDate(extract.dob);
    final String admFormatted = _formatDate(extract.admissionDate ?? extract.dob);
    final String leaveFormatted = extract.isCurrentlyStudying || extract.leavingDate == null
        ? 'अद्याप शिकत आहे'
        : _formatDate(extract.leavingDate);
    final String todayDate = _formatDate(DateTime.now());
    final String placeName = _getSchoolPlace(school.address, school.blockTaluka);

    pw.TableRow buildPdfRow(String label, String value, {bool isBold = false}) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 11)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: pw.Text(
              value.isNotEmpty ? value : '-',
              style: pw.TextStyle(font: isBold ? fontBold : font, fontSize: 11),
            ),
          ),
        ],
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1.5)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('॥ शिक्षण हेच जीवन ॥', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      school.schoolName,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColor.fromHex('#D32F2F')),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text('ता. ${school.blockTaluka}, जि. ${school.district} (महाराष्ट्र)', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'रजिस्टर नंबर १ चा उतारा',
                      style: pw.TextStyle(font: fontBold, fontSize: 15, decoration: pw.TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // Copy Badge
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
                  child: pw.Text(extract.copyTypeTextMr, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                ),
              ),
              pw.SizedBox(height: 6),

              // Subhead: U-DISE & General Reg No
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('यु-डायस क्र.: ${MarathiDateFormatter.toMarathiNumber(extract.uDiseNo)}', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.Text('रजिस्टर नंबर: ${MarathiDateFormatter.toMarathiNumber(extract.generalRegNo)}', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 10),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                columnWidths: const {
                  0: pw.FlexColumnWidth(4.5),
                  1: pw.FlexColumnWidth(5.5),
                },
                children: [
                  buildPdfRow('१) विद्यार्थ्याचे पूर्ण नाव', extract.studentName, isBold: true),
                  buildPdfRow('२) आईचे नाव', extract.motherName),
                  buildPdfRow('३) जात व पोटजात', casteFull),
                  buildPdfRow('४) जन्म ठिकाण', extract.birthPlace),
                  buildPdfRow('५) जन्मतारीख (अंकी)', dobFormatted),
                  buildPdfRow('६) जन्मतारीख (अक्षरी)', extract.dobWords),
                  buildPdfRow('७) यापूर्वीची शाळा', extract.previousSchool),
                  buildPdfRow('८) प्रवेश दिनांक / इयत्ता', '$admFormatted / ${extract.admissionClass}'),
                  buildPdfRow('९) प्रगती व वर्तणूक', '${extract.progress} व ${extract.conduct}'),
                  buildPdfRow('१०) शाळा सोडल्याचा दिनांक', leaveFormatted),
                  buildPdfRow('११) शाळा सोडतानाची इयत्ता', extract.currentClass),
                  buildPdfRow('१२) शाळा सोडल्याचे कारण', extract.reasonForLeaving),
                  buildPdfRow('१३) शेरा (Remarks)', extract.remarks),
                ],
              ),
              pw.SizedBox(height: 36),

              // Footer
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('दिनांक: $todayDate', style: pw.TextStyle(font: font, fontSize: 10)),
                        pw.SizedBox(height: 3),
                        pw.Text('स्थळ: $placeName', style: pw.TextStyle(font: font, fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 25),
                      pw.Text('मुख्याध्यापक', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                      pw.Text('(शिक्का व सही)', style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'GR_Extract_${extract.studentName}.pdf',
    );
  }
}
