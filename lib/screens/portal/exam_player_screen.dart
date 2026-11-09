import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/online_exam_model.dart';
import '../../data/models/student_model.dart';
import '../../providers/app_state_provider.dart';

class ExamPlayerScreen extends StatefulWidget {
  final OnlineExamModel exam;
  final StudentModel student;

  const ExamPlayerScreen({
    super.key,
    required this.exam,
    required this.student,
  });

  @override
  State<ExamPlayerScreen> createState() => _ExamPlayerScreenState();
}

class _ExamPlayerScreenState extends State<ExamPlayerScreen> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionIndex -> optionIndex
  late int _remainingSeconds;
  Timer? _timer;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.exam.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        if (!_isSubmitted) {
          _submitExam(autoSubmit: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _submitExam({bool autoSubmit = false}) {
    _timer?.cancel();

    int totalScore = 0;
    for (int i = 0; i < widget.exam.questions.length; i++) {
      final question = widget.exam.questions[i];
      final selected = _selectedAnswers[i];
      if (selected != null && selected == question.correctOptionIndex) {
        totalScore += question.marks;
      }
    }

    final totalMarks = widget.exam.totalMarks;
    final percentage = totalMarks > 0 ? (totalScore / totalMarks) * 100 : 0.0;
    final isPassed = totalScore >= widget.exam.passingMarks;
    final grade = ExamResultModel.calculateGrade(percentage);

    final result = ExamResultModel(
      id: 'res_${widget.exam.id}_${widget.student.id}_${DateTime.now().millisecondsSinceEpoch}',
      examId: widget.exam.id,
      examTitle: widget.exam.title,
      studentId: widget.student.id,
      studentName: widget.student.studentNameMr.isNotEmpty
          ? widget.student.studentNameMr
          : widget.student.studentNameEn,
      standard: widget.student.standard,
      division: widget.student.division,
      score: totalScore,
      totalMarks: totalMarks,
      percentage: percentage,
      grade: grade,
      isPassed: isPassed,
      submittedAt: DateTime.now(),
      userAnswers: Map<int, int>.from(_selectedAnswers),
    );

    context.read<AppStateProvider>().submitExamResult(result);

    setState(() {
      _isSubmitted = true;
    });

    _showResultDialog(result, autoSubmit: autoSubmit);
  }

  void _showResultDialog(ExamResultModel res, {bool autoSubmit = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              res.isPassed ? Icons.emoji_events : Icons.info_outline,
              color: res.isPassed ? Colors.amber : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                res.isPassed ? 'अभिनंदन! परीक्षा पूर्ण झाली 🎉' : 'परीक्षा पूर्ण झाली!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (autoSubmit)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer_off, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'वेळ संपल्यामुळे परीक्षा आपोआप सबमिट झाली आहे.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: res.isPassed ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: res.isPassed ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('मिळालेले गुण:', style: TextStyle(fontSize: 15)),
                      Text(
                        '${res.score} / ${res.totalMarks}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: res.isPassed ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('टक्केवारी:', style: TextStyle(fontSize: 15)),
                      Text(
                        '${res.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('श्रेणी (Grade):', style: TextStyle(fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: res.isPassed ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          res.grade,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              res.isPassed
                  ? 'उत्कृष्ट कामगिरी! तुम्ही ही चाचणी उत्तीर्ण केली आहे.'
                  : 'चांगला प्रयत्न! पुन्हा सराव करा आणि अधिक गुण मिळवा.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog, stay on screen in review mode
            },
            child: const Text('उत्तरे तपासा (Review)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Back to portal
            },
            child: const Text('पूर्ण करा (Close)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.exam.questions;
    final currentQ = questions[_currentIndex];
    final isLast = _currentIndex == questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          if (!_isSubmitted)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _remainingSeconds < 60 ? Colors.red : Colors.blue.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            minHeight: 5,
          ),

          // Question selector pills
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.grey.shade100,
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: questions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isCurrent = idx == _currentIndex;
                final isAnswered = _selectedAnswers.containsKey(idx);
                Color bg = Colors.white;
                Color textCol = Colors.black87;

                if (_isSubmitted) {
                  final q = questions[idx];
                  final ans = _selectedAnswers[idx];
                  if (ans == q.correctOptionIndex) {
                    bg = Colors.green;
                    textCol = Colors.white;
                  } else {
                    bg = Colors.red.shade400;
                    textCol = Colors.white;
                  }
                } else if (isCurrent) {
                  bg = const Color(0xFF1E88E5);
                  textCol = Colors.white;
                } else if (isAnswered) {
                  bg = Colors.blue.shade100;
                  textCol = Colors.blue.shade900;
                }

                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = idx;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? const Color(0xFF1565C0) : Colors.grey.shade300,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      '${idx + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textCol,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Question & Options View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Meta Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          'प्रश्न ${_currentIndex + 1} / ${questions.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      Chip(
                        label: Text(
                          '${currentQ.marks} गुण',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Question Text Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      currentQ.question,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'पर्याय निवडा:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  // Options
                  ...List.generate(currentQ.options.length, (optIdx) {
                    final optionText = currentQ.options[optIdx];
                    final isSelected = _selectedAnswers[_currentIndex] == optIdx;
                    final isCorrect = currentQ.correctOptionIndex == optIdx;

                    Color cardColor = Colors.white;
                    Color borderColor = Colors.grey.shade300;
                    IconData? statusIcon;
                    Color statusColor = Colors.transparent;

                    if (_isSubmitted) {
                      if (isCorrect) {
                        cardColor = Colors.green.shade50;
                        borderColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        statusColor = Colors.green;
                      } else if (isSelected) {
                        cardColor = Colors.red.shade50;
                        borderColor = Colors.red;
                        statusIcon = Icons.cancel;
                        statusColor = Colors.red;
                      }
                    } else if (isSelected) {
                      cardColor = const Color(0xFFE3F2FD);
                      borderColor = const Color(0xFF1E88E5);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: isSelected || (_isSubmitted && isCorrect) ? 2 : 1),
                      ),
                      child: InkWell(
                        onTap: _isSubmitted
                            ? null
                            : () {
                                setState(() {
                                  _selectedAnswers[_currentIndex] = optIdx;
                                });
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF1E88E5)
                                      : Colors.grey.shade100,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade400,
                                  ),
                                ),
                                child: Text(
                                  String.fromCharCode(65 + optIdx), // A, B, C, D
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (statusIcon != null)
                                Icon(statusIcon, color: statusColor, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Explanation after submission
                  if (_isSubmitted && currentQ.explanation.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb, color: Color(0xFF1E88E5), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'स्पष्टीकरण:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentQ.explanation,
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Action Navigation Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () {
                          setState(() {
                            _currentIndex--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('मागे'),
                ),
                if (!_isSubmitted)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLast ? Colors.green : const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      if (isLast) {
                        _showConfirmSubmitDialog();
                      } else {
                        setState(() {
                          _currentIndex++;
                        });
                      }
                    },
                    icon: Icon(isLast ? Icons.check : Icons.arrow_forward, color: Colors.white),
                    label: Text(
                      isLast ? 'परीक्षा सबमिट करा' : 'पुढे',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    label: const Text('पोर्टलवर परत जा', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmSubmitDialog() {
    final unanswered = widget.exam.questions.length - _selectedAnswers.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('परीक्षा सबमिट करावी का?'),
        content: Text(
          unanswered > 0
              ? 'तुम्ही $unanswered प्रश्नांची उत्तरे दिलेली नाहीत. तरीही परीक्षा सबमिट करायची आहे का?'
              : 'तुम्ही सर्व प्रश्नांची उत्तरे दिली आहेत. आपण आता परीक्षा सबमिट करू शकता.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('नाही, परत जा'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              _submitExam();
            },
            child: const Text('होय, सबमिट करा', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
