import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ebook_service.dart';
import '../../data/local/curriculum_repository.dart';
import '../../data/models/curriculum_model.dart';
import '../../data/models/student_model.dart';
import '../../providers/app_state_provider.dart';
import 'chapter_detail_screen.dart';
import 'ebook_viewer_screen.dart';

/// Standalone screen accessible from the main navigation sidebar
/// for Teachers, Headmasters, Admins, and Students.
class EbooksLibraryScreen extends StatefulWidget {
  const EbooksLibraryScreen({super.key});

  @override
  State<EbooksLibraryScreen> createState() => _EbooksLibraryScreenState();
}

class _EbooksLibraryScreenState extends State<EbooksLibraryScreen> {
  int? _selectedStd;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final defaultStd =
        (state.currentStudent?.standard ?? state.selectedStd).clamp(1, 7);
    final activeStd = _selectedStd ?? defaultStd;
    final StudentModel activeStudent = state.currentStudent ??
        (state.filteredStudents.isNotEmpty
            ? state.filteredStudents.first
            : (state.students.isNotEmpty
                ? state.students.first
                : StudentModel(
                    id: 'guest_student',
                    schoolId: state.school.id.isNotEmpty ? state.school.id : 'school_001',
                    academicYearId: state.currentYear.id,
                    standard: activeStd,
                    division: '1',
                    grNo: '0',
                    rollNoSem1: 1,
                    rollNoSem2: 1,
                    studentNameMr: 'विद्यार्थी',
                    studentNameEn: 'Student',
                    motherName: '',
                    dateOfBirth: DateTime(2015, 1, 1),
                    gender: 'M',
                  )));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'संपूर्ण अभ्यासक्रम व बालभारती ई-बुक्स (इ. १ ते ७ 📚)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'महाराष्ट्र राज्य पाठ्यपुस्तक निर्मिती मंडळ (बालभारती), पुणे / SCERT अधिकृत ई-पुस्तके',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: () =>
                  EbookService.openOfficialUrl(EbookService.officialPortalUrl),
              icon: const Icon(Icons.public, size: 16),
              label: const Text(
                'ई-बालभारती पोर्टल',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: CurriculumEbooksBody(
        selectedStandard: activeStd,
        onStandardChanged: (std) => setState(() => _selectedStd = std),
        student: activeStudent,
      ),
    );
  }
}

/// Reusable Class 1–7 Complete Curriculum + Official Balbharati E-Books Library widget.
/// Used both in [EbooksLibraryScreen] and in [StudentParentPortalScreen]'s E-Learning tab.
class CurriculumEbooksBody extends StatefulWidget {
  final int selectedStandard;
  final ValueChanged<int> onStandardChanged;
  final StudentModel student;

  const CurriculumEbooksBody({
    super.key,
    required this.selectedStandard,
    required this.onStandardChanged,
    required this.student,
  });

  @override
  State<CurriculumEbooksBody> createState() => _CurriculumEbooksBodyState();
}

class _CurriculumEbooksBodyState extends State<CurriculumEbooksBody> {
  int _viewMode = 0; // 0 = सर्व ई-पुस्तके (E-Books), 1 = संपूर्ण अभ्यासक्रम व धडे (Syllabus)
  String _searchQuery = '';
  String? _expandedSubjectCode;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _stdSuffix(int std) {
    switch (std) {
      case 1:
        return '१ ली';
      case 2:
        return '२ री';
      case 3:
        return '३ री';
      case 4:
        return '४ थी';
      case 5:
        return '५ वी';
      case 6:
        return '६ वी';
      case 7:
        return '७ वी';
      default:
        return '$std वी';
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects =
        CurriculumRepository.getSubjectsForStandard(widget.selectedStandard);
    final q = _searchQuery.trim().toLowerCase();

    final filteredSubjects = q.isEmpty
        ? subjects
        : subjects.where((sub) {
            if (sub.subjectName.toLowerCase().contains(q) ||
                sub.bookTitle.toLowerCase().contains(q) ||
                sub.ebookCode.toLowerCase().contains(q)) {
              return true;
            }
            return sub.chapters.any(
              (ch) =>
                  ch.chapterTitle.toLowerCase().contains(q) ||
                  ch.summary.toLowerCase().contains(q),
            );
          }).toList();

    final allEbooksInStd = <({CurriculumSubjectModel subject, CurriculumEbookResource ebook})>[];
    for (final sub in filteredSubjects) {
      for (final eb in sub.allEbooks) {
        allEbooksInStd.add((subject: sub, ebook: eb));
      }
    }

    final totalChaptersInStd =
        subjects.fold<int>(0, (sum, s) => sum + s.chapters.length);

    return Column(
      children: [
        // Top Class Selector + Mode Toggle + Search
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'इयत्ता निवडा (Class):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        'बालभारती पुणे • ${CurriculumRepository.totalEbooksCount} ई-बुक्स • ${CurriculumRepository.totalChaptersCount} धडे',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (idx) {
                    final std = idx + 1;
                    final isSelected = std == widget.selectedStandard;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('इयत्ता ${_stdSuffix(std)}'),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1E88E5),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _expandedSubjectCode = null;
                          });
                          widget.onStandardChanged(std);
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              // View Mode Toggle + Search
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ChoiceChip(
                    key: const Key('ebooks_mode_chip'),
                    avatar: Icon(
                      Icons.menu_book,
                      size: 16,
                      color: _viewMode == 0 ? Colors.white : AppColors.primary,
                    ),
                    label: Text(
                      'सर्व ई-बुक्स PDF (${allEbooksInStd.length})',
                    ),
                    selected: _viewMode == 0,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _viewMode == 0 ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                    onSelected: (_) => setState(() => _viewMode = 0),
                  ),
                  ChoiceChip(
                    key: const Key('syllabus_mode_chip'),
                    avatar: Icon(
                      Icons.list_alt,
                      size: 16,
                      color: _viewMode == 1 ? Colors.white : AppColors.teal,
                    ),
                    label: Text(
                      'संपूर्ण अभ्यासक्रम व धडे ($totalChaptersInStd)',
                    ),
                    selected: _viewMode == 1,
                    selectedColor: AppColors.teal,
                    labelStyle: TextStyle(
                      color: _viewMode == 1 ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                    onSelected: (_) => setState(() => _viewMode = 1),
                  ),
                  SizedBox(
                    width: 260,
                    height: 36,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: 'विषय, पुस्तक किंवा धडा शोधा...',
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: filteredSubjects.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'शोधलेला विषय किंवा धडा या इयत्तेत आढळला नाही.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : _viewMode == 0
                  ? _buildEbooksGrid(allEbooksInStd)
                  : _buildSyllabusList(filteredSubjects, q),
        ),
      ],
    );
  }

  Widget _buildEbooksGrid(
    List<({CurriculumSubjectModel subject, CurriculumEbookResource ebook})>
        items,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100
            ? 3
            : width >= 700
                ? 2
                : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 205,
          ),
          itemCount: items.length,
          itemBuilder: (context, idx) {
            final entry = items[idx];
            return _EbookCard(
              subject: entry.subject,
              ebook: entry.ebook,
              onOpenReader: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EbookViewerScreen(
                      subject: entry.subject,
                      specificEbook: entry.ebook,
                    ),
                  ),
                );
              },
              onOpenSyllabus: () {
                setState(() {
                  _expandedSubjectCode = entry.subject.subjectCode;
                  _viewMode = 1;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSyllabusList(
    List<CurriculumSubjectModel> subjects,
    String query,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, sIdx) {
        final sub = subjects[sIdx];
        final themeColor = Color(sub.colorHex);
        final chapters = query.isEmpty
            ? sub.chapters
            : sub.chapters
                .where(
                  (ch) =>
                      ch.chapterTitle.toLowerCase().contains(query) ||
                      ch.summary.toLowerCase().contains(query) ||
                      sub.subjectName.toLowerCase().contains(query),
                )
                .toList();
        final shouldExpand = _expandedSubjectCode != null
            ? sub.subjectCode == _expandedSubjectCode
            : (sIdx == 0 || query.isNotEmpty);

        return Card(
          key: ValueKey('sub_${sub.subjectCode}_$shouldExpand'),
          margin: const EdgeInsets.only(bottom: 14),
          color: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: shouldExpand,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.book, color: themeColor, size: 24),
              ),
              title: Text(
                sub.subjectName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: themeColor,
                ),
              ),
              subtitle: Text(
                '${sub.bookTitle} • ${sub.chapters.length} धडे • ${sub.allEbooks.length} अधिकृत PDF',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EbookViewerScreen(subject: sub),
                        ),
                      );
                    },
                    icon: Icon(Icons.picture_as_pdf, size: 16, color: themeColor),
                    label: Text(
                      'ई-बुक',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: themeColor.withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more),
                ],
              ),
              children: [
                const Divider(height: 1),
                ...chapters.map((ch) {
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: themeColor.withOpacity(0.1),
                      foregroundColor: themeColor,
                      child: Text(
                        '${ch.chapterNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      ch.chapterTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: Text(
                      ch.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterDetailScreen(
                            subject: sub,
                            chapter: ch,
                            student: widget.student,
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EbookCard extends StatelessWidget {
  final CurriculumSubjectModel subject;
  final CurriculumEbookResource ebook;
  final VoidCallback onOpenReader;
  final VoidCallback onOpenSyllabus;

  const _EbookCard({
    required this.subject,
    required this.ebook,
    required this.onOpenReader,
    required this.onOpenSyllabus,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(subject.colorHex);

    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: themeColor.withOpacity(0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stylized Textbook Cover Badge
                Container(
                  width: 64,
                  height: 86,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeColor, themeColor.withOpacity(0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (ebook.coverUrl.isNotEmpty &&
                            Uri.tryParse(ebook.coverUrl)?.hasAbsolutePath == true)
                        ? Image.network(
                            ebook.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackCover(),
                          )
                        : _buildFallbackCover(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'इयत्ता ${subject.standard} • कोड ${ebook.bookCode}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ebook.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${subject.chapters.length} धडे • ${ebook.sizeLabel.isNotEmpty ? ebook.sizeLabel : "अधिकृत PDF"} • बालभारती, पुणे',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onOpenReader,
                    icon: const Icon(Icons.picture_as_pdf, size: 15),
                    label: const Text(
                      'ई-बुक वाचा (PDF)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onOpenSyllabus,
                  icon: const Icon(Icons.list_alt, size: 15),
                  label: const Text(
                    'धडे',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColor,
                    side: BorderSide(color: themeColor.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCover() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            'इ. ${subject.standard}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'PDF',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
