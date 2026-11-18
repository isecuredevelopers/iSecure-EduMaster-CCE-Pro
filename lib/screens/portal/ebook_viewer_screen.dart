import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ebook_service.dart';
import '../../data/models/curriculum_model.dart';

class EbookViewerScreen extends StatefulWidget {
  final CurriculumSubjectModel subject;
  final CurriculumEbookResource? specificEbook;

  const EbookViewerScreen({
    super.key,
    required this.subject,
    this.specificEbook,
  });

  @override
  State<EbookViewerScreen> createState() => _EbookViewerScreenState();
}

class _EbookViewerScreenState extends State<EbookViewerScreen> {
  late CurriculumEbookResource _currentResource;
  bool _isLoading = false;
  double _progress = 0.0;
  String _statusMessage = '';
  Uint8List? _pdfBytes;
  bool _isOfflineCached = false;
  File? _localFile;

  @override
  void initState() {
    super.initState();
    _currentResource = widget.specificEbook ??
        (widget.subject.allEbooks.isNotEmpty
            ? widget.subject.allEbooks.first
            : CurriculumEbookResource(
                title: widget.subject.bookTitle,
                bookCode: widget.subject.ebookCode,
                pdfUrl: widget.subject.ebookPdfUrl,
                coverUrl: widget.subject.ebookCoverUrl,
                sizeLabel: widget.subject.ebookSizeLabel,
              ));
    _checkAndLoadCachedBook();
  }

  Future<void> _checkAndLoadCachedBook() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'ई-पुस्तकाची पडताळणी करत आहे...';
    });

    final cachedBytes =
        await EbookService.readCachedPdfBytes(_currentResource.bookCode);
    if (!mounted) return;

    if (cachedBytes != null && cachedBytes.isNotEmpty) {
      final file = await EbookService.getLocalPdfFile(_currentResource.bookCode);
      setState(() {
        _pdfBytes = cachedBytes;
        _isOfflineCached = true;
        _localFile = file;
        _isLoading = false;
        _statusMessage = 'ऑफलाइन ई-पुस्तक उपलब्ध!';
      });
    } else {
      setState(() {
        _pdfBytes = null;
        _isOfflineCached = false;
        _isLoading = false;
        _statusMessage = '';
      });
    }
  }

  Future<void> _downloadOfficialPdf() async {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _statusMessage = 'बालभारती सर्व्हरवरून ई-पुस्तक डाउनलोड होत आहे...';
    });

    try {
      final bytes = await EbookService.downloadEbookPdf(
        _currentResource,
        onProgress: (prog, downloaded, total) {
          if (!mounted) return;
          setState(() {
            _progress = prog;
            if (total > 0) {
              final dMb = (downloaded / (1024 * 1024)).toStringAsFixed(1);
              final tMb = (total / (1024 * 1024)).toStringAsFixed(1);
              _statusMessage = 'डाउनलोड: $dMb MB / $tMb MB (${(prog * 100).toInt()}%)';
            } else {
              final dMb = (downloaded / (1024 * 1024)).toStringAsFixed(1);
              _statusMessage = 'डाउनलोड: $dMb MB...';
            }
          });
        },
      );

      final file = await EbookService.getLocalPdfFile(_currentResource.bookCode);

      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _isOfflineCached = true;
        _localFile = file;
        _isLoading = false;
        _statusMessage = 'ई-पुस्तक यशस्वीरित्या डाउनलोड झाले!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_currentResource.title} ऑफलाइन वाचनासाठी सेव्ह झाले!',
          ),
          backgroundColor: AppColors.gradeA1,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusMessage = 'डाउनलोड अयशस्वी: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('डाउनलोड करताना त्रुटी आली: $e'),
          backgroundColor: AppColors.gradeD,
          action: SnackBarAction(
            label: 'ब्राउझरमध्ये उघडा',
            textColor: Colors.white,
            onPressed: () => EbookService.openOfficialUrl(_currentResource.pdfUrl),
          ),
        ),
      );
    }
  }

  Future<void> _loadSyllabusSummaryPdf() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'मराठी अभ्यासक्रम व स्वाध्याय पुस्तिका तयार होत आहे...';
    });

    try {
      final bytes = await EbookService.generateOfflineSyllabusPdf(widget.subject);
      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _isLoading = false;
        _statusMessage = 'अभ्यासक्रम पुस्तिका तयार!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusMessage = 'त्रुटी: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(widget.subject.colorHex);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'इयत्ता ${widget.subject.standard} वी • ${widget.subject.subjectName}',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            Text(
              _currentResource.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'अधिकृत बालभारती लिंक ब्राउझरमध्ये उघडा',
            onPressed: () => EbookService.openOfficialUrl(_currentResource.pdfUrl),
          ),
          if (_localFile != null && !kIsWeb)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'संगणकावरील डीफॉल्ट ॲपमध्ये उघडा',
              onPressed: () =>
                  EbookService.openLocalPdfExternally(_localFile!.path),
            ),
        ],
      ),
      body: Column(
        children: [
          // Ebook Switcher Bar (if subject has multiple parts)
          if (widget.subject.allEbooks.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'पुस्तकाचा भाग:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    ...widget.subject.allEbooks.map((eb) {
                      final isSelected = eb.bookCode == _currentResource.bookCode;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(eb.title),
                          selected: isSelected,
                          selectedColor: themeColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _currentResource = eb;
                              });
                              _checkAndLoadCachedBook();
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // Action & Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isOfflineCached
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _isOfflineCached ? Icons.check_circle : Icons.cloud_download,
                    size: 18,
                    color: _isOfflineCached ? Colors.green : themeColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOfflineCached
                            ? 'अधिकृत बालभारती ई-पुस्तक ऑफलाइन सेव्ह आहे (${_currentResource.sizeLabel})'
                            : 'अधिकृत बालभारती ई-पुस्तक (${_currentResource.sizeLabel.isNotEmpty ? _currentResource.sizeLabel : "PDF"})',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'प्रकाशक: ${widget.subject.publisher} • कोड: ${_currentResource.bookCode}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isOfflineCached)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _downloadOfficialPdf,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('डाउनलोड करा'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _downloadOfficialPdf,
                    icon: const Icon(Icons.refresh, size: 15),
                    label: const Text('पुन्हा डाउनलोड'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: _loadSyllabusSummaryPdf,
                  icon: const Icon(Icons.auto_stories, size: 15),
                  label: const Text('अभ्यासक्रम वही'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // Loading Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              color: themeColor,
              backgroundColor: Colors.grey.shade200,
            ),

          if (_statusMessage.isNotEmpty && _isLoading)
            Container(
              width: double.infinity,
              color: Colors.amber.shade50,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Main PDF View or Fallback Prompts
          Expanded(
            child: _pdfBytes != null
                ? PdfPreview(
                    build: (_) => _pdfBytes!,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    allowPrinting: true,
                    allowSharing: true,
                    pdfFileName: '${_currentResource.bookCode}.pdf',
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        margin: const EdgeInsets.all(24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.menu_book,
                                  size: 40,
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _currentResource.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'इयत्ता ${widget.subject.standard} वी • ${widget.subject.medium}\n'
                                'बालभारती, पुणे अधिकृत ई-पुस्तक (आकार: ${_currentResource.sizeLabel})',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(44),
                                ),
                                onPressed: _downloadOfficialPdf,
                                icon: const Icon(Icons.download),
                                label: Text(
                                  'ई-पुस्तक डाउनलोड करा (${_currentResource.sizeLabel})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(42),
                                ),
                                onPressed: () => EbookService.openOfficialUrl(
                                  _currentResource.pdfUrl,
                                ),
                                icon: const Icon(Icons.open_in_browser),
                                label: const Text('थेट ब्राउझरमध्ये उघडा (PDF Link)'),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: _loadSyllabusSummaryPdf,
                                icon: const Icon(Icons.note_alt_outlined),
                                label: const Text('ऑफलाइन अभ्यासक्रम व स्वाध्याय पुस्तिका उघडा'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
