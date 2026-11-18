import 'package:flutter/material.dart';
import '../../data/models/curriculum_model.dart';
import '../../data/models/online_exam_model.dart';
import '../../data/models/student_model.dart';
import 'ebook_viewer_screen.dart';
import 'exam_player_screen.dart';

class ChapterDetailScreen extends StatefulWidget {
  final CurriculumSubjectModel subject;
  final CurriculumChapterModel chapter;
  final StudentModel student;

  const ChapterDetailScreen({
    super.key,
    required this.subject,
    required this.chapter,
    required this.student,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(widget.subject.colorHex);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subject.subjectName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
            Text(
              widget.chapter.chapterTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EbookViewerScreen(subject: widget.subject),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
              label: const Text(
                'ई-बुक (PDF)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.18),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.menu_book, size: 20), text: 'अभ्यास व सारांश'),
            Tab(icon: Icon(Icons.help_outline, size: 20), text: 'स्वाध्याय (प्रश्न-उत्तरे)'),
            Tab(icon: Icon(Icons.quiz, size: 20), text: 'सराव चाचणी'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Study Notes & Summary
          _buildStudyNotesTab(themeColor),

          // Tab 2: Q&A / Flashcards
          _buildPracticeQuestionsTab(themeColor),

          // Tab 3: Interactive Chapter Quiz
          _buildQuizTab(themeColor),
        ],
      ),
    );
  }

  Widget _buildStudyNotesTab(Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Subject & Standard
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor.withOpacity(0.12), themeColor.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: themeColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_stories, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject.bookTitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.chapter.chapterTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EbookViewerScreen(subject: widget.subject),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: Text(
                        'अधिकृत ई-पुस्तक उघडा (${widget.subject.ebookSizeLabel.isNotEmpty ? widget.subject.ebookSizeLabel : "PDF"})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 1: Summary (धड्याचा सारांश)
          _buildSectionHeader('📖 धड्याचा सारांश (Chapter Summary)', themeColor),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.chapter.summary,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Section 2: Key Concepts (महत्त्वाच्या संकल्पना व शब्दार्थ)
          if (widget.chapter.keyConcepts.isNotEmpty) ...[
            _buildSectionHeader('💡 महत्त्वाच्या संकल्पना व शब्दार्थ', themeColor),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.chapter.keyConcepts.map((concept) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    concept,
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],

          // Section 3: Study Notes (अभ्यास नोंदी)
          if (widget.chapter.studyNotes.isNotEmpty) ...[
            _buildSectionHeader('📝 महत्त्वाचे मुद्दे व नोंदी (Study Notes)', themeColor),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                widget.chapter.studyNotes,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildPracticeQuestionsTab(Color themeColor) {
    final questions = widget.chapter.practiceQuestions;

    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'या पाठाचे स्वाध्याय प्रश्न लवकरच उपलब्ध होतील.',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, idx) {
        final item = questions[idx];
        final q = item['question'] ?? '';
        final a = item['answer'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            shape: const Border(),
            leading: CircleAvatar(
              backgroundColor: themeColor.withOpacity(0.12),
              foregroundColor: themeColor,
              radius: 16,
              child: Text(
                '${idx + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            title: Text(
              q,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text(
              'उत्तर पाहण्यासाठी येथे टॅप करा ▼',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green.shade800, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'उत्तर:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a,
                      style: const TextStyle(fontSize: 14.5, height: 1.4, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizTab(Color themeColor) {
    final quiz = widget.chapter.quizQuestions;

    if (quiz.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'या पाठाची सराव चाचणी लवकरच उपलब्ध होईल.',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lightbulb_outline, size: 48, color: themeColor),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.chapter.chapterTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'इयत्ता ${widget.subject.standard} वी • ${widget.subject.subjectName}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuizStat(Icons.format_list_numbered, '${quiz.length}', 'एकूण प्रश्न'),
                    _buildQuizStat(Icons.stars, '${quiz.length} गुण', 'एकूण गुण'),
                    _buildQuizStat(Icons.timer_outlined, '५ मिनिटे', 'कालावधी'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final exam = OnlineExamModel(
                        id: 'quiz_${widget.subject.subjectCode}_ch${widget.chapter.chapterNumber}',
                        standard: widget.subject.standard,
                        subjectCode: widget.subject.subjectCode,
                        subjectName: widget.subject.subjectName,
                        title: '${widget.chapter.chapterTitle} चाचणी',
                        description: 'या पाठावरील बहुपर्यायी सराव चाचणी.',
                        durationMinutes: 5,
                        questions: quiz,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamPlayerScreen(
                            exam: exam,
                            student: widget.student,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text(
                      'सराव चाचणी सुरू करा (Start Quiz)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: color.withOpacity(0.95),
      ),
    );
  }
}
