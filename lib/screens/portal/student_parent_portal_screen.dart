import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/local/curriculum_repository.dart';
import '../../data/models/homework_model.dart';
import '../../data/models/online_exam_model.dart';
import '../../data/models/student_model.dart';
import '../../providers/app_state_provider.dart';
import 'chapter_detail_screen.dart';
import 'exam_player_screen.dart';

class StudentParentPortalScreen extends StatefulWidget {
  final StudentModel? initialStudent;

  const StudentParentPortalScreen({super.key, this.initialStudent});

  @override
  State<StudentParentPortalScreen> createState() => _StudentParentPortalScreenState();
}

class _StudentParentPortalScreenState extends State<StudentParentPortalScreen> {
  int _currentTabIndex = 0;
  StudentModel? _selectedStudent;
  int _curriculumSelectedStd = 1;
  String _homeworkFilter = 'all'; // all, pending, completed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppStateProvider>();
      if (widget.initialStudent != null) {
        setState(() {
          _selectedStudent = widget.initialStudent;
          _curriculumSelectedStd = widget.initialStudent!.standard;
        });
      } else if (provider.students.isNotEmpty) {
        setState(() {
          _selectedStudent = provider.students.first;
          _curriculumSelectedStd = provider.students.first.standard;
        });
      }
    });
  }

  void _switchStudent(StudentModel student) {
    setState(() {
      _selectedStudent = student;
      _curriculumSelectedStd = student.standard;
    });
  }

  void _showStudentSwitcherBottomSheet(List<StudentModel> students) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'विद्यार्थी निवडा (Select Student)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final stu = students[idx];
                    final isSelected = stu.id == _selectedStudent?.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                        child: Text(
                          '${stu.rollNoSem1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        stu.studentNameMr.isNotEmpty ? stu.studentNameMr : stu.studentNameEn,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF1E88E5) : Colors.black87,
                        ),
                      ),
                      subtitle: Text('इयत्ता ${stu.standard} वी (${stu.division}) • हजेरी क्र. ${stu.rollNoSem1} • GR: ${stu.grNo}'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF1E88E5))
                          : null,
                      onTap: () {
                        _switchStudent(stu);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final students = provider.students;

    if (_selectedStudent == null && students.isNotEmpty) {
      _selectedStudent = students.first;
      _curriculumSelectedStd = _selectedStudent!.standard;
    }

    final student = _selectedStudent;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.school.schoolName.isNotEmpty ? provider.school.schoolName : 'जिल्हा परिषद प्राथमिक शाळा',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const Text(
              'विद्यार्थी व पालक पोर्टल 📱',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          if (students.isNotEmpty)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => _showStudentSwitcherBottomSheet(students),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('विद्यार्थी बदला', style: TextStyle(fontSize: 12)),
            ),
          if (provider.isLoggedIn && (provider.currentUser?.isStudent ?? false))
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              tooltip: 'लॉगआउट (Sign Out)',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('लॉगआउट करा'),
                    content: const Text('तुम्हाला विद्यार्थी खात्यातून बाहेर पडायचे आहे का?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('रद्द करा')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('लॉगआउट'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await provider.logout();
                }
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: student == null
          ? const Center(child: Text('विद्यार्थी माहिती उपलब्ध नाही.'))
          : Column(
              children: [
                // Top Student Profile Header Card
                _buildStudentHeaderCard(student, students),

                // Main Tab Body
                Expanded(
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      // Tab 0: Dashboard
                      _buildDashboardTab(student, provider),

                      // Tab 1: Attendance
                      _buildAttendanceTab(student, provider),

                      // Tab 2: Homework
                      _buildHomeworkTab(student, provider),

                      // Tab 3: Online Exams
                      _buildExamsTab(student, provider),

                      // Tab 4: E-Learning Syllabus
                      _buildCurriculumTab(student, provider),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 10,
        indicatorColor: const Color(0xFFE3F2FD),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1E88E5)),
            label: 'डॅशबोर्ड',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: Color(0xFF1E88E5)),
            label: 'उपस्थिती',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: Color(0xFF1E88E5)),
            label: 'घरचा अभ्यास',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz, color: Color(0xFF1E88E5)),
            label: 'ऑनलाइन परीक्षा',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF1E88E5)),
            label: 'ई-लर्निंग',
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Top Student Profile Header
  // ----------------------------------------------------
  Widget _buildStudentHeaderCard(StudentModel student, List<StudentModel> students) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E88E5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE3F2FD),
              foregroundColor: const Color(0xFF1E88E5),
              child: const Icon(Icons.person, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.studentNameMr.isNotEmpty ? student.studentNameMr : student.studentNameEn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'इ. ${student.standard} वी (${student.division})',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'हजेरी क्र: ${student.rollNoSem1}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'GR: ${student.grNo}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFF1E88E5)),
              tooltip: 'विद्यार्थी बदला',
              onPressed: () => _showStudentSwitcherBottomSheet(students),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 0: Dashboard (डॅशबोर्ड)
  // ----------------------------------------------------
  Widget _buildDashboardTab(StudentModel student, AppStateProvider provider) {
    final attSummary = provider.getStudentAttendanceSummary(student);
    final homeworkList = provider.getHomeworkForStudent(student);
    final pendingCount = homeworkList.where((h) => !h.isCompletedBy(student.id)).length;
    final exams = provider.getExamsForStandard(student.standard);
    final results = provider.getStudentExamResults(student.id);

    final double attPct = attSummary['percentage'] as double? ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'नमस्ते, ${student.studentNameMr.isNotEmpty ? student.studentNameMr : student.studentNameEn}! 🌟',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'आपल्या अभ्यास प्रगतीची सद्यस्थिती येथे उपलब्ध आहे. नियमित अभ्यास करा आणि यश मिळवा!',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.school, color: Colors.white, size: 48),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stat Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'उपस्थिती प्रमाण',
                  value: '${attPct.toStringAsFixed(1)}%',
                  icon: Icons.calendar_today,
                  color: attPct >= 75 ? Colors.green : Colors.orange,
                  subtitle: '${attSummary['totalAttendedDays']} / ${attSummary['totalWorkingDays']} दिवस',
                  onTap: () => setState(() => _currentTabIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'प्रलंबित अभ्यास',
                  value: '$pendingCount स्वाध्याय',
                  icon: Icons.assignment_outlined,
                  color: pendingCount == 0 ? Colors.green : Colors.red,
                  subtitle: pendingCount == 0 ? 'सर्व पूर्ण! 🎉' : 'तात्काळ पूर्ण करा',
                  onTap: () => setState(() => _currentTabIndex = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'दिलेल्या परीक्षा',
                  value: '${results.length} / ${exams.length}',
                  icon: Icons.quiz_outlined,
                  color: const Color(0xFF6A1B9A),
                  subtitle: results.isNotEmpty ? 'शेवटची श्रेणी: ${results.first.grade}' : 'चाचणी बाकी आहे',
                  onTap: () => setState(() => _currentTabIndex = 3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'ई-लर्निंग विषय',
                  value: '${CurriculumRepository.getSubjectsForStandard(student.standard).length} विषय',
                  icon: Icons.menu_book,
                  color: const Color(0xFF00838F),
                  subtitle: 'पुणे बालभारती अभ्यासक्रम',
                  onTap: () => setState(() => _currentTabIndex = 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pending Homework Preview Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'आजचा घरचा अभ्यास (स्वाध्याय)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _currentTabIndex = 2),
                child: const Text('सर्व पाहा >'),
              ),
            ],
          ),
          if (homeworkList.isEmpty)
            _buildEmptyCard('आज कोणताही गृहपाठ दिलेला नाही.', Icons.check_circle_outline)
          else
            ...homeworkList.take(2).map((hw) => _buildHomeworkCard(hw, student, provider)),

          const SizedBox(height: 16),

          // Available Online Exams Preview Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'सराव ऑनलाइन परीक्षा',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _currentTabIndex = 3),
                child: const Text('सर्व परीक्षा >'),
              ),
            ],
          ),
          if (exams.isEmpty)
            _buildEmptyCard('सध्या कोणतीही नवीन परीक्षा उपलब्ध नाही.', Icons.assignment_turned_in)
          else
            ...exams.take(2).map((exam) => _buildExamCard(exam, student, provider)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.12),
                  foregroundColor: color,
                  child: Icon(icon, size: 20),
                ),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 1: Attendance (उपस्थिती)
  // ----------------------------------------------------
  Widget _buildAttendanceTab(StudentModel student, AppStateProvider provider) {
    final summary = provider.getStudentAttendanceSummary(student);
    final double pct = summary['percentage'] as double? ?? 0.0;
    final totalAttended = summary['totalAttendedDays'] as int? ?? 0;
    final totalWorking = summary['totalWorkingDays'] as int? ?? 0;
    final monthly = summary['monthlyBreakdown'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Progress / Big Score Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: pct >= 75
                    ? [const Color(0xFF2E7D32), const Color(0xFF43A047)]
                    : [const Color(0xFFE65100), const Color(0xFFFB8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (pct >= 75 ? Colors.green : Colors.orange).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'वार्षिक उपस्थिती प्रमाण',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pct >= 75 ? 'उत्कृष्ट उपस्थिती! (नियमित विद्यार्थी)' : 'उपस्थिती कमी आहे, कृपया लक्ष द्या.',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(color: Colors.white24, height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttStat('एकूण कामाचे दिवस', '$totalWorking दिवस'),
                    Container(height: 30, width: 1, color: Colors.white24),
                    _buildAttStat('उपस्थित दिवस', '$totalAttended दिवस'),
                    Container(height: 30, width: 1, color: Colors.white24),
                    _buildAttStat('गैरहजर दिवस', '${totalWorking - totalAttended} दिवस'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Monthly Attendance Table
          const Text(
            'महिनानिहाय उपस्थिती तपशील (जून ते एप्रिल)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monthly.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final m = monthly[idx] as Map<String, dynamic>;
                final monthName = m['month']?.toString() ?? '';
                final present = m['present'] as int? ?? 0;
                final total = m['total'] as int? ?? 0;
                final monthPct = total > 0 ? (present / total) * 100 : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monthName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total > 0 ? present / total : 0,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  monthPct >= 75 ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$present / $total',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${monthPct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: monthPct >= 75 ? Colors.green.shade800 : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // ----------------------------------------------------
  // Tab 2: Homework (घरचा अभ्यास / स्वाध्याय)
  // ----------------------------------------------------
  Widget _buildHomeworkTab(StudentModel student, AppStateProvider provider) {
    final allHw = provider.getHomeworkForStudent(student);

    List<HomeworkModel> filteredHw = allHw;
    if (_homeworkFilter == 'pending') {
      filteredHw = allHw.where((h) => !h.isCompletedBy(student.id)).toList();
    } else if (_homeworkFilter == 'completed') {
      filteredHw = allHw.where((h) => h.isCompletedBy(student.id)).toList();
    }

    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              const Text('गाळणी (Filter):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 10),
              ChoiceChip(
                label: Text('सर्व (${allHw.length})'),
                selected: _homeworkFilter == 'all',
                onSelected: (_) => setState(() => _homeworkFilter = 'all'),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: Text('बाकी (${allHw.where((h) => !h.isCompletedBy(student.id)).length})'),
                selected: _homeworkFilter == 'pending',
                onSelected: (_) => setState(() => _homeworkFilter = 'pending'),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: Text('पूर्ण (${allHw.where((h) => h.isCompletedBy(student.id)).length})'),
                selected: _homeworkFilter == 'completed',
                onSelected: (_) => setState(() => _homeworkFilter = 'completed'),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: filteredHw.isEmpty
              ? _buildEmptyCard(
                  _homeworkFilter == 'pending'
                      ? 'अभिनंदन! कोणताही गृहपाठ बाकी नाही.'
                      : 'या वर्ग व तुकडीसाठी गृहपाठ उपलब्ध नाही.',
                  Icons.assignment_turned_in,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredHw.length,
                  itemBuilder: (context, idx) {
                    return _buildHomeworkCard(filteredHw[idx], student, provider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHomeworkCard(HomeworkModel hw, StudentModel student, AppStateProvider provider) {
    final isDone = hw.isCompletedBy(student.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone ? Colors.green.shade200 : Colors.grey.shade200,
          width: isDone ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hw.subjectName,
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  provider.toggleHomeworkStatus(hw.id, student.id);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDone ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isDone ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDone ? 'पूर्ण झाले' : 'बाकी आहे',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDone ? Colors.green.shade900 : Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hw.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            hw.description,
            style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    hw.teacherName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: hw.isOverdue && !isDone ? Colors.red : Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'अंतिम तारीख: ${hw.dueDate.day}/${hw.dueDate.month}/${hw.dueDate.year}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: hw.isOverdue && !isDone ? FontWeight.bold : FontWeight.normal,
                      color: hw.isOverdue && !isDone ? Colors.red : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 3: Online Exams (ऑनलाइन परीक्षा व सराव चाचण्या)
  // ----------------------------------------------------
  Widget _buildExamsTab(StudentModel student, AppStateProvider provider) {
    final exams = provider.getExamsForStandard(student.standard);
    final results = provider.getStudentExamResults(student.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: 40),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ऑनलाइन सराव चाचण्या',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'इयत्तानिहाय वस्तुनिष्ठ चाचण्या सोडवून आपला अभ्यास तपासा आणि गुण मिळवा!',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Available Exams Section
          const Text(
            'उपलब्ध ऑनलाइन चाचण्या (Active Tests)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (exams.isEmpty)
            _buildEmptyCard('सध्या कोणतीही परीक्षा उपलब्ध नाही.', Icons.assignment_outlined)
          else
            ...exams.map((exam) => _buildExamCard(exam, student, provider)),

          const SizedBox(height: 24),

          // Previous Results Section
          if (results.isNotEmpty) ...[
            const Text(
              'मागील परीक्षांचे निकालपत्र (Exam History)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...results.map((res) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: res.isPassed ? Colors.green.shade50 : Colors.red.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: res.isPassed ? Colors.green : Colors.red),
                      ),
                      child: Text(
                        res.grade,
                        style: TextStyle(
                          color: res.isPassed ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            res.examTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'दिनांक: ${res.submittedAt.day}/${res.submittedAt.month}/${res.submittedAt.year}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${res.score} / ${res.totalMarks}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: res.isPassed ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                        Text(
                          '${res.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildExamCard(OnlineExamModel exam, StudentModel student, AppStateProvider provider) {
    final existingResults = provider.getStudentExamResults(student.id).where((r) => r.examId == exam.id).toList();
    final hasTaken = existingResults.isNotEmpty;
    final latestResult = hasTaken ? existingResults.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  exam.subjectName,
                  style: TextStyle(
                    color: Colors.purple.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (hasTaken && latestResult != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: latestResult.isPassed ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: latestResult.isPassed ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    'गुण: ${latestResult.score}/${latestResult.totalMarks} (${latestResult.grade})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: latestResult.isPassed ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            exam.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            exam.description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('${exam.durationMinutes} मिनिटे', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(width: 14),
              Icon(Icons.format_list_numbered, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('${exam.questions.length} प्रश्न', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(width: 14),
              Icon(Icons.stars_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('${exam.totalMarks} गुण', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasTaken ? Colors.grey.shade700 : const Color(0xFF1E88E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamPlayerScreen(
                      exam: exam,
                      student: student,
                    ),
                  ),
                );
              },
              icon: Icon(hasTaken ? Icons.replay : Icons.play_arrow, color: Colors.white, size: 18),
              label: Text(
                hasTaken ? 'पुन्हा सराव चाचणी द्या' : 'चाचणी सुरू करा (Start Test)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 4: E-Learning Curriculum (पुणे विद्यापीठ / SCERT बालभारती)
  // ----------------------------------------------------
  Widget _buildCurriculumTab(StudentModel student, AppStateProvider provider) {
    final subjects = CurriculumRepository.getSubjectsForStandard(_curriculumSelectedStd);

    return Column(
      children: [
        // Class Selector Pills (इ. १ ली ते ७ वी)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          color: Colors.white,
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
                  Text(
                    'पुणे विद्यापीठ / SCERT अभ्यासक्रम',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (idx) {
                    final std = idx + 1;
                    final isSelected = std == _curriculumSelectedStd;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('इयत्ता $std ली'),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1E88E5),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _curriculumSelectedStd = std;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // Subjects & Chapters List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, sIdx) {
              final sub = subjects[sIdx];
              final themeColor = Color(sub.colorHex);

              return Card(
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
                    initiallyExpanded: sIdx == 0,
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
                        fontSize: 16,
                        color: themeColor,
                      ),
                    ),
                    subtitle: Text(
                      '${sub.bookTitle} • ${sub.chapters.length} धडे',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    children: [
                      const Divider(height: 1),
                      ...sub.chapters.map((ch) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: themeColor.withOpacity(0.1),
                            foregroundColor: themeColor,
                            child: Text(
                              '${ch.chapterNumber}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          title: Text(
                            ch.chapterTitle,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            ch.summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChapterDetailScreen(
                                  subject: sub,
                                  chapter: ch,
                                  student: student,
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
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
