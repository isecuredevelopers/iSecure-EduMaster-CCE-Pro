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

  // Zoom & Screen controls
  final TransformationController _transformationController =
      TransformationController();
  double _currentZoomScale = 1.0;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
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

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentZoomScale).abs() > 0.04) {
      setState(() {
        _currentZoomScale = scale;
      });
    }
  }

  void _zoomIn() {
    final newScale = (_currentZoomScale + 0.25).clamp(0.7, 4.5);
    _applyScale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentZoomScale - 0.25).clamp(0.7, 4.5);
    _applyScale(newScale);
  }

  void _resetZoom() {
    _applyScale(1.0);
  }

  void _applyScale(double targetScale) {
    _transformationController.value = Matrix4.identity()..scale(targetScale);
    setState(() {
      _currentZoomScale = targetScale;
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_currentZoomScale > 1.25) {
      _resetZoom();
    } else {
      final position = details.localPosition;
      final x = -position.dx * (2.0 - 1.0);
      final y = -position.dy * (2.0 - 1.0);
      _transformationController.value = Matrix4.identity()
        ..translate(x, y)
        ..scale(2.0);
      setState(() {
        _currentZoomScale = 2.0;
      });
    }
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
              _statusMessage =
                  'डाउनलोड: $dMb MB / $tMb MB (${(prog * 100).toInt()}%)';
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
            onPressed: () =>
                EbookService.openOfficialUrl(_currentResource.pdfUrl),
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
      final bytes =
          await EbookService.generateOfflineSyllabusPdf(widget.subject);
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
      appBar: _isFullscreen
          ? null
          : AppBar(
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                if (_pdfBytes != null) ...[
                  IconButton(
                    icon: const Icon(Icons.zoom_out, size: 20),
                    tooltip: 'झूम कमी करा (-)',
                    onPressed: _zoomOut,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        if (_currentZoomScale < 1.25) {
                          _applyScale(1.5);
                        } else if (_currentZoomScale < 1.75) {
                          _applyScale(2.0);
                        } else {
                          _resetZoom();
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${(_currentZoomScale * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, size: 20),
                    tooltip: 'झूम वाढवा (+)',
                    onPressed: _zoomIn,
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, size: 22),
                    tooltip: 'पूर्ण स्क्रीन वाचन',
                    onPressed: () => setState(() => _isFullscreen = true),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.open_in_browser, size: 20),
                  tooltip: 'अधिकृत बालभारती लिंक ब्राउझरमध्ये उघडा',
                  onPressed: () =>
                      EbookService.openOfficialUrl(_currentResource.pdfUrl),
                ),
                if (_localFile != null && !kIsWeb)
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    tooltip: 'डीफॉल्ट ॲपमध्ये उघडा',
                    onPressed: () =>
                        EbookService.openLocalPdfExternally(_localFile!.path),
                  ),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            // Ebook Switcher Bar (hidden in fullscreen)
            if (!_isFullscreen && widget.subject.allEbooks.length > 1)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'पुस्तकाचा भाग:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      ...widget.subject.allEbooks.map((eb) {
                        final isSelected =
                            eb.bookCode == _currentResource.bookCode;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(eb.title),
                            selected: isSelected,
                            selectedColor: themeColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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

            // Action & Status Banner (hidden in fullscreen)
            if (!_isFullscreen)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        _isOfflineCached
                            ? Icons.check_circle
                            : Icons.cloud_download,
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'प्रकाशक: ${widget.subject.publisher} • कोड: ${_currentResource.bookCode}',
                            style: TextStyle(
                              fontSize: 10.5,
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
                        icon: const Icon(Icons.download, size: 15),
                        label: const Text('डाउनलोड'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _downloadOfficialPdf,
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('पुन्हा डाउनलोड'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          textStyle: const TextStyle(fontSize: 10.5),
                        ),
                      ),
                    const SizedBox(width: 6),
                    OutlinedButton.icon(
                      onPressed: _loadSyllabusSummaryPdf,
                      icon: const Icon(Icons.auto_stories, size: 14),
                      label: const Text('अभ्यासक्रम वही'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        textStyle: const TextStyle(fontSize: 10.5),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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

            // Main PDF View with Pinch-to-Zoom & Dedicated Zoom Controls
            Expanded(
              child: _pdfBytes != null
                  ? Stack(
                      children: [
                        // Zoomable PDF Canvas with Pinch, Double-tap & Pan Gestures
                        Positioned.fill(
                          child: GestureDetector(
                            onDoubleTapDown: _handleDoubleTap,
                            child: InteractiveViewer(
                              transformationController:
                                  _transformationController,
                              minScale: 0.7,
                              maxScale: 4.5,
                              panEnabled: true,
                              scaleEnabled: true,
                              boundaryMargin: const EdgeInsets.symmetric(
                                horizontal: 120,
                                vertical: 60,
                              ),
                              child: PdfPreview(
                                build: (_) => _pdfBytes!,
                                canChangeOrientation: false,
                                canChangePageFormat: false,
                                canDebug: false,
                                allowPrinting: true,
                                allowSharing: true,
                                dpi: 144,
                                maxPageWidth: 720,
                                pdfFileName: '${_currentResource.bookCode}.pdf',
                              ),
                            ),
                          ),
                        ),

                        // Exit Fullscreen Floating Button (Top Left when in Fullscreen)
                        if (_isFullscreen)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black87.withOpacity(0.8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () =>
                                    setState(() => _isFullscreen = false),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_back,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'सामान्य व्ह्यू',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Sleek Floating Zoom & Fullscreen Control Pill (Bottom Right)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(30),
                            color: const Color(0xDD1E293B), // Slate-800 backdrop
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    key: const Key('ebook_zoom_out_btn'),
                                    icon: const Icon(Icons.remove,
                                        color: Colors.white, size: 19),
                                    tooltip: 'झूम कमी करा (-)',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: _zoomOut,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (_currentZoomScale < 1.25) {
                                        _applyScale(1.5);
                                      } else if (_currentZoomScale < 1.75) {
                                        _applyScale(2.0);
                                      } else {
                                        _resetZoom();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 4),
                                      child: Text(
                                        '${(_currentZoomScale * 100).toInt()}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    key: const Key('ebook_zoom_in_btn'),
                                    icon: const Icon(Icons.add,
                                        color: Colors.white, size: 19),
                                    tooltip: 'झूम वाढवा (+)',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: _zoomIn,
                                  ),
                                  Container(
                                    height: 18,
                                    width: 1,
                                    color: Colors.white24,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                  ),
                                  IconButton(
                                    key: const Key('ebook_zoom_reset_btn'),
                                    icon: const Icon(Icons.fit_screen,
                                        color: Colors.white, size: 18),
                                    tooltip: 'स्क्रीननुसार फिट करा (100%)',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: _resetZoom,
                                  ),
                                  IconButton(
                                    key: const Key('ebook_fullscreen_btn'),
                                    icon: Icon(
                                      _isFullscreen
                                          ? Icons.fullscreen_exit
                                          : Icons.fullscreen,
                                      color: Colors.amberAccent,
                                      size: 20,
                                    ),
                                    tooltip: _isFullscreen
                                        ? 'पूर्ण स्क्रीन बंद करा'
                                        : 'पूर्ण स्क्रीन वाचन मोड',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => setState(
                                        () => _isFullscreen = !_isFullscreen),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Card(
                            margin: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.menu_book,
                                      size: 36,
                                      color: themeColor,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _currentResource.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'इयत्ता ${widget.subject.standard} वी • ${widget.subject.medium}\n'
                                    'बालभारती, पुणे अधिकृत ई-पुस्तक (आकार: ${_currentResource.sizeLabel})',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeColor,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(42),
                                    ),
                                    onPressed: _downloadOfficialPdf,
                                    icon: const Icon(Icons.download, size: 18),
                                    label: Text(
                                      'ई-पुस्तक डाउनलोड करा (${_currentResource.sizeLabel})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                    onPressed: () =>
                                        EbookService.openOfficialUrl(
                                      _currentResource.pdfUrl,
                                    ),
                                    icon: const Icon(Icons.open_in_browser, size: 18),
                                    label: const Text(
                                        'थेट ब्राउझरमध्ये उघडा (PDF Link)'),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: _loadSyllabusSummaryPdf,
                                    icon: const Icon(Icons.note_alt_outlined, size: 18),
                                    label: const Text(
                                        'ऑफलाइन अभ्यासक्रम व स्वाध्याय पुस्तिका उघडा'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
