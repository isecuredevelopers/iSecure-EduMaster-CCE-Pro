import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myschool/data/models/curriculum_model.dart';
import 'package:myschool/screens/portal/ebook_viewer_screen.dart';

void main() {
  final testSubject = CurriculumSubjectModel(
    standard: 1,
    subjectCode: 'mar_1',
    medium: 'मराठी',
    subjectName: 'मराठी बालभारती',
    bookTitle: 'बालभारती इयत्ता पहिली',
    ebookCode: '101010001',
    ebookPdfUrl: 'https://books.balbharati.in/101010001.pdf',
    ebookCoverUrl: 'https://books.balbharati.in/covers/101010001.jpg',
    ebookSizeLabel: '18.4 MB',
    colorHex: 0xFF1E40AF,
    chapters: [],
  );

  testWidgets('EbookViewerScreen renders fallback view and handles actions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EbookViewerScreen(subject: testSubject),
      ),
    );

    await tester.pump();
    expect(find.text('बालभारती इयत्ता पहिली'), findsWidgets);
    expect(find.textContaining('ई-पुस्तक डाउनलोड करा'), findsOneWidget);
    expect(find.textContaining('थेट ब्राउझरमध्ये उघडा'), findsOneWidget);
  });
}
