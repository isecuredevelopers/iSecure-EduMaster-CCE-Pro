import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseTitle;
  final String releaseNotes;
  final String releaseDate;
  final String releasePageUrl;
  final String? downloadUrl;
  final int? assetSizeBytes;
  final bool hasUpdate;
  final bool isMandatory;

  AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.releaseDate,
    required this.releasePageUrl,
    this.downloadUrl,
    this.assetSizeBytes,
    required this.hasUpdate,
    this.isMandatory = false,
  });

  String get formattedSize {
    if (assetSizeBytes == null || assetSizeBytes! <= 0) return '';
    final mb = assetSizeBytes! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class AppUpdateService {
  static const String currentVersion = '1.1.0';
  static const String buildNumber = '2';
  static const String githubOwner = 'isecuredevelopers';
  static const String githubRepo = 'iSecure-EduMaster-CCE-Pro';
  static const String repoUrl = 'https://github.com/isecuredevelopers/iSecure-EduMaster-CCE-Pro';

  static const String apiLatestReleaseUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';
  static const String rawVersionJsonUrl =
      'https://raw.githubusercontent.com/$githubOwner/$githubRepo/main/version.json';

  /// Compare two semantic version strings (e.g. "1.1.0" vs "1.0.0")
  static bool isVersionNewer(String remoteVer, String localVer) {
    try {
      final cleanRemote = remoteVer.toLowerCase().replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanLocal = localVer.toLowerCase().replaceAll(RegExp(r'[^0-9.]'), '');

      final rParts = cleanRemote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final lParts = cleanLocal.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (rParts.length < 3) {
        rParts.add(0);
      }
      while (lParts.length < 3) {
        lParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (rParts[i] > lParts[i]) return true;
        if (rParts[i] < lParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Launch external URL in Windows default browser
  static Future<void> launchUrl(String url) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', url]);
      }
    } catch (e) {
      debugPrint('Launch URL error: $e');
    }
  }

  /// Check online GitHub repository for new release
  static Future<AppUpdateInfo?> checkForUpdate() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    // 1. Try GitHub Releases API first
    try {
      final request = await client.getUrl(Uri.parse(apiLatestReleaseUrl));
      request.headers.set('User-Agent', 'iSecure-EduMaster-CCE-Pro');
      request.headers.set('Accept', 'application/vnd.github.v3+json');
      final response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(body);

        final tagName = data['tag_name']?.toString() ?? '';
        final title = data['name']?.toString() ?? 'iSecure EduMaster नवीन आवृत्ती';
        final notes = data['body']?.toString() ?? 'नवीन कार्यक्षमता व सुधारणा';
        final htmlUrl = data['html_url']?.toString() ?? repoUrl;
        final publishedAt = data['published_at']?.toString().split('T').first ?? '';

        String? downloadUrl;
        int? assetSize;

        if (data['assets'] is List && (data['assets'] as List).isNotEmpty) {
          final assets = data['assets'] as List;
          // Prefer .exe or .zip asset
          final match = assets.firstWhere(
            (a) {
              final n = (a['name']?.toString() ?? '').toLowerCase();
              return n.endsWith('.exe') || n.endsWith('.zip');
            },
            orElse: () => assets.first,
          );
          downloadUrl = match['browser_download_url']?.toString();
          assetSize = match['size'] is int ? match['size'] as int : null;
        }

        downloadUrl ??= '$repoUrl/releases/latest';

        final hasUpdate = isVersionNewer(tagName, currentVersion);

        return AppUpdateInfo(
          currentVersion: currentVersion,
          latestVersion: tagName.replaceAll('v', '').replaceAll('V', ''),
          releaseTitle: title,
          releaseNotes: notes,
          releaseDate: publishedAt,
          releasePageUrl: htmlUrl,
          downloadUrl: downloadUrl,
          assetSizeBytes: assetSize,
          hasUpdate: hasUpdate,
        );
      }
    } catch (e) {
      debugPrint('GitHub Releases API check error: $e');
    }

    // 2. Fallback to raw version.json if Releases API is empty or rate-limited
    try {
      final request = await client.getUrl(Uri.parse(rawVersionJsonUrl));
      request.headers.set('User-Agent', 'iSecure-EduMaster-CCE-Pro');
      final response = await request.close().timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(body);

        final remoteVer = data['version']?.toString() ?? '';
        final title = data['title']?.toString() ?? 'iSecure EduMaster CCE Pro नवीन आवृत्ती';
        final notes = data['changelog']?.toString() ?? 'नवीन कार्यक्षमता व सुधारणा';
        final downloadUrl = data['download_url']?.toString() ?? '$repoUrl/releases/latest';
        final releaseDate = data['release_date']?.toString() ?? '';
        final isMandatory = data['is_mandatory'] == true;

        final hasUpdate = isVersionNewer(remoteVer, currentVersion);

        return AppUpdateInfo(
          currentVersion: currentVersion,
          latestVersion: remoteVer,
          releaseTitle: title,
          releaseNotes: notes,
          releaseDate: releaseDate,
          releasePageUrl: repoUrl,
          downloadUrl: downloadUrl,
          hasUpdate: hasUpdate,
          isMandatory: isMandatory,
        );
      }
    } catch (e) {
      debugPrint('Raw version.json check error: $e');
    } finally {
      client.close();
    }

    return null;
  }

  /// Download installer file from URL to Downloads folder
  static Future<void> downloadInstaller({
    required String downloadUrl,
    required String fileName,
    required void Function(double progress, int downloaded, int total) onProgress,
    required void Function(String filePath) onComplete,
    required void Function(String error) onError,
  }) async {
    try {
      final userProfile = Platform.environment['USERPROFILE'] ?? 'C:\\Users\\Default';
      final downloadDir = Directory('$userProfile\\Downloads\\iSecure_Updates');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final safeFileName = fileName.endsWith('.exe') || fileName.endsWith('.zip')
          ? fileName
          : '$fileName.exe';
      final filePath = '${downloadDir.path}\\$safeFileName';
      final file = File(filePath);

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      final request = await client.getUrl(Uri.parse(downloadUrl));
      request.headers.set('User-Agent', 'iSecure-EduMaster-CCE-Pro');
      final response = await request.close();

      if (response.statusCode != 200) {
        onError('डाउनलोड अयशस्वी: सर्व्हर एरर ${response.statusCode}');
        client.close();
        return;
      }

      final contentLength = response.contentLength;
      final sink = file.openWrite();
      int bytesDownloaded = 0;

      await for (var chunk in response) {
        bytesDownloaded += chunk.length;
        sink.add(chunk);
        if (contentLength > 0) {
          onProgress(bytesDownloaded / contentLength, bytesDownloaded, contentLength);
        } else {
          onProgress(0.5, bytesDownloaded, -1);
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      onComplete(filePath);
    } catch (e) {
      onError('डाउनलोड करताना त्रुटी आली: $e');
    }
  }

  /// Show beautiful interactive update dialog
  static void showUpdateModal(BuildContext context, AppUpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: !info.isMandatory,
      builder: (ctx) => _UpdateDialogContent(info: info),
    );
  }
}

class _UpdateDialogContent extends StatefulWidget {
  final AppUpdateInfo info;

  const _UpdateDialogContent({required this.info});

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends State<_UpdateDialogContent> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusText = '';
  String? _downloadedFilePath;

  Future<void> _startDirectDownload() async {
    final url = widget.info.downloadUrl;
    if (url == null || !url.startsWith('http')) {
      AppUpdateService.launchUrl(widget.info.releasePageUrl);
      return;
    }

    // If it's a direct link to github releases page rather than .exe, open browser
    if (!url.endsWith('.exe') && !url.endsWith('.zip')) {
      AppUpdateService.launchUrl(url);
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusText = 'डाउनलोड सुरू होत आहे...';
    });

    final fileName = 'iSecure-EduMaster-${widget.info.latestVersion}-Setup.exe';

    await AppUpdateService.downloadInstaller(
      downloadUrl: url,
      fileName: fileName,
      onProgress: (prog, downloaded, total) {
        if (!mounted) return;
        setState(() {
          _downloadProgress = prog;
          if (total > 0) {
            final dMb = (downloaded / (1024 * 1024)).toStringAsFixed(1);
            final tMb = (total / (1024 * 1024)).toStringAsFixed(1);
            _statusText = 'डाउनलोड होत आहे: $dMb MB / $tMb MB (${(prog * 100).toInt()}%)';
          } else {
            final dMb = (downloaded / (1024 * 1024)).toStringAsFixed(1);
            _statusText = 'डाउनलोड होत आहे: $dMb MB...';
          }
        });
      },
      onComplete: (filePath) {
        if (!mounted) return;
        setState(() {
          _isDownloading = false;
          _downloadProgress = 1.0;
          _downloadedFilePath = filePath;
          _statusText = 'डाउनलोड पूर्ण झाले!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('अपडेट पॅकेज यशस्वीरित्या डाउनलोड झाले! सेटअप सुरू केला जात आहे...'),
            backgroundColor: AppColors.gradeA1,
          ),
        );

        // Run installer on Windows
        try {
          Process.start(filePath, [], runInShell: true);
        } catch (e) {
          debugPrint('Execute installer error: $e');
        }
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isDownloading = false;
          _statusText = err;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'नवीन व्हर्जन अपडेट उपलब्ध!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'iSecure Systems • ${info.releaseTitle}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version comparison row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'सध्याची आवृत्ती',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v${info.currentVersion}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                  Column(
                    children: [
                      const Text(
                        'नवीन उपलब्ध आवृत्ती',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gradeA1.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.gradeA1),
                        ),
                        child: Text(
                          'v${info.latestVersion}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gradeA1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (info.releaseDate.isNotEmpty)
                    Column(
                      children: [
                        const Text(
                          'रिलीज तारीख',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          info.releaseDate,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Changelog / Release Notes
            const Text(
              'सुधारणा व नवीन वैशिष्ट्ये (What\'s New):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 140),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  info.releaseNotes.isNotEmpty
                      ? info.releaseNotes
                      : '• कार्यक्षमता व सुरक्षेत सुधारणा\n• महाराष्ट्र CCE नियमावलीनुसार मूल्यांकन व गॅझेट सुधारणा\n• बग फिक्स व वेग वाढवला',
                  style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF334155)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Download Progress Bar if downloading
            if (_isDownloading || _downloadProgress > 0) ...[
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: const Color(0xFFE2E8F0),
                color: AppColors.gradeA1,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _statusText,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  Text(
                    '${(_downloadProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gradeA1),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            if (_downloadedFilePath != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gradeA1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.gradeA1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.gradeA1),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'फाईल सेव्ह झाली: $_downloadedFilePath',
                        style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Process.run('explorer.exe', ['/select,', _downloadedFilePath!]);
                      },
                      child: const Text('फोल्डर उघडा', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        if (!info.isMandatory)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('नंतर करा (Remind Later)'),
          ),
        OutlinedButton.icon(
          onPressed: () {
            AppUpdateService.launchUrl(info.releasePageUrl);
          },
          icon: const Icon(Icons.open_in_browser, size: 16),
          label: const Text('GitHub वर पहा'),
        ),
        ElevatedButton.icon(
          onPressed: _isDownloading ? null : _startDirectDownload,
          icon: _isDownloading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.download, size: 16),
          label: Text(
            _isDownloading
                ? 'डाउनलोड होत आहे...'
                : (_downloadedFilePath != null ? 'पुन्हा रन करा' : 'आता अपडेट करा'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }
}
