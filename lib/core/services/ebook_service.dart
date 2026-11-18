import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/curriculum_model.dart';
import 'app_update_service.dart';

class EbookService {
  static const String officialPortalUrl =
      'https://books.ebalbharati.in/ebook.aspx';

  /// Directory where downloaded official Balbharati PDFs are cached for offline reading.
  static Future<Directory> getCacheDirectory() async {
    Directory dir;
    if (!kIsWeb && Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'] ??
          Platform.environment['USERPROFILE'] ??
          Directory.systemTemp.path;
      dir = Directory('$localAppData\\iSecureEduMaster\\Balbharati_Ebooks');
    } else {
      dir = Directory('${Directory.systemTemp.path}/isecure_balbharati_ebooks');
    }
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> getLocalPdfFile(String bookCode) async {
    final dir = await getCacheDirectory();
    final safeCode = bookCode.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    final sep = (!kIsWeb && Platform.isWindows) ? '\\' : '/';
    return File('${dir.path}$sep$safeCode.pdf');
  }

  static Future<bool> isBookDownloaded(String bookCode) async {
    if (kIsWeb || bookCode.isEmpty) return false;
    try {
      final file = await getLocalPdfFile(bookCode);
      if (!await file.exists()) return false;
      return await file.length() > 10 * 1024;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List?> readCachedPdfBytes(String bookCode) async {
    if (kIsWeb || bookCode.isEmpty) return null;
    try {
      final file = await getLocalPdfFile(bookCode);
      if (await file.exists() && await file.length() > 10 * 1024) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error reading cached ebook $bookCode: $e');
    }
    return null;
  }

  static Future<void> deleteCachedBook(String bookCode) async {
    if (kIsWeb || bookCode.isEmpty) return;
    try {
      final file = await getLocalPdfFile(bookCode);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting cached ebook $bookCode: $e');
    }
  }

  /// Downloads official eBalbharati PDF with live progress and caches it locally.
  static Future<Uint8List> downloadEbookPdf(
    CurriculumEbookResource ebook, {
    void Function(double progress, int downloadedBytes, int totalBytes)?
        onProgress,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.getUrl(Uri.parse(ebook.pdfUrl));
      request.headers.set('User-Agent', 'iSecure-EduMaster-CCE-Pro');
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception(
          'अधिकृत ई-बुक सर्व्हरवरून डाउनलोड करता आले नाही (HTTP ${response.statusCode}).',
        );
      }

      final totalBytes = response.contentLength;
      final file = await getLocalPdfFile(ebook.bookCode);
      final partFile = File('${file.path}.part');
      final sink = partFile.openWrite();
      int downloaded = 0;

      try {
        await for (final chunk in response) {
          sink.add(chunk);
          downloaded += chunk.length;
          if (onProgress != null) {
            final progress =
                totalBytes > 0 ? (downloaded / totalBytes).clamp(0.0, 1.0) : -1.0;
            onProgress(progress, downloaded, totalBytes);
          }
        }
        await sink.flush();
        await sink.close();
      } catch (e) {
        await sink.close();
        if (await partFile.exists()) {
          await partFile.delete();
        }
        rethrow;
      }

      if (await file.exists()) {
        await file.delete();
      }
      await partFile.rename(file.path);
      return await file.readAsBytes();
    } finally {
      client.close();
    }
  }

  static Future<void> openOfficialUrl(String url) async {
    await AppUpdateService.launchUrl(url);
  }

  static Future<void> openLocalPdfExternally(String filePath) async {
    if (kIsWeb) return;
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', filePath]);
      } else {
        await AppUpdateService.launchUrl(filePath);
      }
    } catch (e) {
      debugPrint('Error opening PDF externally: $e');
    }
  }

  /// Generates an offline printable Marathi Unicode syllabus & study-notes PDF
  /// for the given subject (all chapters, notes & Q&A).
  static Future<Uint8List> generateOfflineSyllabusPdf(
    CurriculumSubjectModel subject,
  ) async {
    final fontRegular = await PdfGoogleFonts.notoSansDevanagariRegular();
    final fontBold = await PdfGoogleFonts.notoSansDevanagariBold();

    final pdf = pw.Document();
    final baseStyle = pw.TextStyle(font: fontRegular, fontSize: 10.5);
    final boldStyle = pw.TextStyle(font: fontBold, fontSize: 11);
    final headerStyle = pw.TextStyle(font: fontBold, fontSize: 16);
    final subHeaderStyle = pw.TextStyle(font: fontBold, fontSize: 12);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.only(bottom: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.8),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${subject.bookTitle} (इयत्ता ${subject.standard})',
                style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.blue900),
              ),
              pw.Text(
                'बालभारती, पुणे • अभ्यासक्रम ई-बुक',
                style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'पान ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (ctx) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(subject.bookTitle, style: headerStyle),
                pw.SizedBox(height: 4),
                pw.Text(
                  'विषय: ${subject.subjectName}  |  इयत्ता: ${subject.standard}  |  एकूण घटक: ${subject.chapters.length}',
                  style: baseStyle,
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'प्रकाशक: ${subject.publisher}  •  अधिकृत ई-बुक कोड: ${subject.ebookCode}',
                  style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          ...subject.chapters.map(
            (ch) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(ch.chapterTitle, style: subHeaderStyle),
                  pw.SizedBox(height: 4),
                  pw.Text('सारांश: ${ch.summary}', style: baseStyle),
                  if (ch.keyConcepts.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'मुख्य संकल्पना: ${ch.keyConcepts.join(', ')}',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 9.5,
                        color: PdfColors.indigo900,
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 4),
                  pw.Text(ch.studyNotes, style: baseStyle),
                  if (ch.practiceQuestions.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text('स्वाध्याय (प्रश्नोत्तरे):', style: boldStyle),
                    ...ch.practiceQuestions.map(
                      (qa) => pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 3),
                        child: pw.Text(
                          'प्र. ${qa['question'] ?? ''}\nउ. ${qa['answer'] ?? ''}',
                          style: baseStyle,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
