import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  static String currentVersion = '1.5.2';
  static String buildNumber = '12';
  static const String githubOwner = 'isecuredevelopers';
  static const String githubRepo = 'iSecure-EduMaster-CCE-Pro';
  static const String repoUrl =
      'https://github.com/isecuredevelopers/iSecure-EduMaster-CCE-Pro';
  static const MethodChannel _androidUpdateChannel = MethodChannel(
    'com.myschool.cce.myschool/updates',
  );
  static Future<void>? _packageInfoLoad;

  static const String apiLatestReleaseUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';
  static const String rawVersionJsonUrl =
      'https://raw.githubusercontent.com/$githubOwner/$githubRepo/main/version.json';

  /// Compare two semantic version strings (e.g. "1.1.0" vs "1.0.0")
  static bool isVersionNewer(String remoteVer, String localVer) {
    try {
      final cleanRemote = remoteVer.toLowerCase().replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      final cleanLocal = localVer.toLowerCase().replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );

      final rParts = cleanRemote
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final lParts = cleanLocal
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

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

  /// Open a URL in the platform's default browser.
  static Future<void> launchUrl(String url) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', url]);
      } else if (Platform.isAndroid) {
        await _androidUpdateChannel.invokeMethod<void>('openUrl', {'url': url});
      }
    } catch (e) {
      debugPrint('Launch URL error: $e');
    }
  }

  static Future<bool> installAndroidApk(String filePath) async {
    if (!Platform.isAndroid) return false;
    return await _androidUpdateChannel.invokeMethod<bool>('installApk', {
          'filePath': filePath,
        }) ??
        false;
  }

  /// Get the safest download directory for installers.
  /// On Android, requests native externalCacheDir/cacheDir to ensure FileProvider compatibility.
  static Future<String> getDownloadDirectoryPath() async {
    if (Platform.isAndroid) {
      try {
        final path = await _androidUpdateChannel.invokeMethod<String>(
          'getDownloadDirectory',
        );
        if (path != null && path.trim().isNotEmpty) {
          return path.trim();
        }
      } catch (e) {
        debugPrint('Android getDownloadDirectory error: $e');
      }
      return Directory.systemTemp.path;
    } else {
      final userProfile =
          Platform.environment['USERPROFILE'] ?? 'C:\\Users\\Default';
      return '$userProfile\\Downloads\\iSecure_Updates';
    }
  }

  /// Check online GitHub repository for new release
  static Future<AppUpdateInfo?> checkForUpdate() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return null;
    }
    _packageInfoLoad ??= PackageInfo.fromPlatform().then((packageInfo) {
      currentVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
    await _packageInfoLoad;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    // 1. Try GitHub Releases API first
    try {
      final request = await client.getUrl(Uri.parse(apiLatestReleaseUrl));
      request.headers.set('User-Agent', 'iSecure-EduMaster-CCE-Pro');
      request.headers.set('Accept', 'application/vnd.github.v3+json');
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(body);

        final tagName = data['tag_name']?.toString() ?? '';
        final title =
            data['name']?.toString() ?? 'iSecure EduMaster नवीन आवृत्ती';
        final notes = data['body']?.toString() ?? 'नवीन कार्यक्षमता व सुधारणा';
        final htmlUrl = data['html_url']?.toString() ?? repoUrl;
        final publishedAt =
            data['published_at']?.toString().split('T').first ?? '';

        String? downloadUrl;
        int? assetSize;

        if (data['assets'] is List && (data['assets'] as List).isNotEmpty) {
          final assets = (data['assets'] as List).whereType<Map>();
          final extension = Platform.isAndroid ? '.apk' : '.exe';
          final matchingAssets = assets.where((asset) {
            final name = (asset['name']?.toString() ?? '').toLowerCase();
            return Platform.isAndroid
                ? name.endsWith(extension)
                : name.endsWith(extension) || name.endsWith('.zip');
          }).toList();
          if (matchingAssets.isNotEmpty) {
            final match = Platform.isAndroid
                ? matchingAssets.firstWhere(
                    (asset) => (asset['name']?.toString() ?? '')
                        .toLowerCase()
                        .contains('universal'),
                    orElse: () => matchingAssets.first,
                  )
                : matchingAssets.first;
            downloadUrl = match['browser_download_url']?.toString();
            assetSize = match['size'] is int ? match['size'] as int : null;
          }
        }

        downloadUrl ??= htmlUrl;

        final hasUpdate = isVersionNewer(tagName, currentVersion);

        client.close();
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
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(body);

        final remoteVer = data['version']?.toString() ?? '';
        final title =
            data['title']?.toString() ??
            'iSecure EduMaster CCE Pro नवीन आवृत्ती';
        final notes =
            data['changelog']?.toString() ?? 'नवीन कार्यक्षमता व सुधारणा';
        final platformDownloadUrl = Platform.isAndroid
            ? data['android_download_url']
            : Platform.isWindows
            ? data['windows_download_url']
            : null;
        final downloadUrl =
            platformDownloadUrl?.toString() ??
            data['download_url']?.toString() ??
            '$repoUrl/releases/latest';
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

  /// Download the installer on desktop or the APK into Android's private cache with auto-resume.
  static Future<void> downloadInstaller({
    required String downloadUrl,
    required String fileName,
    required void Function(double progress, int downloaded, int total)
    onProgress,
    required void Function(String filePath) onComplete,
    required void Function(String error) onError,
  }) async {
    try {
      final downloadDirPath = await getDownloadDirectoryPath();
      final downloadDir = Directory(downloadDirPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final extension = Platform.isAndroid ? '.apk' : '.exe';
      final safeFileName =
          fileName.endsWith('.exe') ||
              fileName.endsWith('.zip') ||
              fileName.endsWith('.apk')
          ? fileName
          : '$fileName$extension';
      final filePath = Platform.isWindows
          ? '${downloadDir.path}\\$safeFileName'
          : '${downloadDir.path}/$safeFileName';
      final file = File(filePath);

      int downloadedBytes = 0;
      int totalBytes = -1;
      int retryCount = 0;
      const maxRetries = 6;
      String currentUrl = downloadUrl;

      // Resolve redirects upfront to get the direct CDN download URL
      final resolveClient = HttpClient();
      resolveClient.connectionTimeout = const Duration(seconds: 20);
      try {
        var headReq = await resolveClient.getUrl(Uri.parse(currentUrl));
        headReq.followRedirects = false;
        var headRes = await headReq.close();
        while (headRes.isRedirect &&
            headRes.headers.value(HttpHeaders.locationHeader) != null) {
          final loc = headRes.headers.value(HttpHeaders.locationHeader)!;
          currentUrl = Uri.parse(currentUrl).resolve(loc).toString();
          headReq = await resolveClient.getUrl(Uri.parse(currentUrl));
          headReq.followRedirects = false;
          headRes = await headReq.close();
        }
      } catch (_) {
        currentUrl = downloadUrl;
      } finally {
        resolveClient.close();
      }

      if (await file.exists()) {
        downloadedBytes = await file.length();
      } else {
        downloadedBytes = 0;
      }

      while (retryCount < maxRetries) {
        HttpClient? client;
        IOSink? sink;
        try {
          client = HttpClient();
          client.connectionTimeout = const Duration(seconds: 30);
          client.idleTimeout = const Duration(seconds: 60);

          final request = await client.getUrl(Uri.parse(currentUrl));
          request.headers.set(
            'User-Agent',
            'Mozilla/5.0 (Linux; Android) iSecure-EduMaster-CCE-Pro',
          );
          request.headers.set('Accept-Encoding', 'identity');

          if (downloadedBytes > 0) {
            request.headers.set('Range', 'bytes=$downloadedBytes-');
          }

          final response = await request.close();

          if (response.isRedirect &&
              response.headers.value(HttpHeaders.locationHeader) != null) {
            final loc = response.headers.value(HttpHeaders.locationHeader)!;
            currentUrl = Uri.parse(currentUrl).resolve(loc).toString();
            client.close();
            continue;
          }

          final isPartial = response.statusCode == HttpStatus.partialContent;
          final isOk = response.statusCode == HttpStatus.ok;

          if (!isPartial && !isOk) {
            if (response.statusCode == 416 && downloadedBytes > 0) {
              client.close();
              onComplete(filePath);
              return;
            }
            throw HttpException('सर्व्हर एरर: ${response.statusCode}');
          }

          if (isPartial) {
            sink = file.openWrite(mode: FileMode.append);
            if (totalBytes <= 0 && response.contentLength > 0) {
              totalBytes = downloadedBytes + response.contentLength;
            }
          } else {
            downloadedBytes = 0;
            totalBytes = response.contentLength;
            sink = file.openWrite(mode: FileMode.write);
          }

          await for (var chunk in response) {
            downloadedBytes += chunk.length;
            sink.add(chunk);
            if (totalBytes > 0) {
              onProgress(
                (downloadedBytes / totalBytes).clamp(0.0, 1.0),
                downloadedBytes,
                totalBytes,
              );
            } else {
              onProgress(0.5, downloadedBytes, -1);
            }
          }

          await sink.flush();
          await sink.close();
          sink = null;
          client.close();
          client = null;

          onComplete(filePath);
          return;
        } catch (e) {
          try {
            await sink?.flush();
            await sink?.close();
          } catch (_) {}
          client?.close();

          retryCount++;
          if (await file.exists()) {
            downloadedBytes = await file.length();
          }

          if (retryCount >= maxRetries) {
            onError(
              'डाउनलोड पूर्ण होऊ शकले नाही. कृपया इंटरनेट तपासा किंवा पुन्हा प्रयत्न करा.',
            );
            return;
          }

          await Future.delayed(Duration(seconds: retryCount));
        }
      }
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
  bool _hasError = false;

  Future<void> _startDirectDownload() async {
    final url = widget.info.downloadUrl;
    if (url == null || !url.startsWith('http')) {
      AppUpdateService.launchUrl(widget.info.releasePageUrl);
      return;
    }

    if (Platform.isAndroid && _downloadedFilePath != null) {
      await _installDownloadedApk();
      return;
    }

    final isInstallableAsset = Platform.isAndroid
        ? url.toLowerCase().split('?').first.endsWith('.apk')
        : url.toLowerCase().split('?').first.endsWith('.exe') ||
              url.toLowerCase().split('?').first.endsWith('.zip');
    if (!isInstallableAsset) {
      await AppUpdateService.launchUrl(widget.info.releasePageUrl);
      return;
    }

    setState(() {
      _isDownloading = true;
      _hasError = false;
      _downloadProgress = 0.0;
      _statusText = 'डाउनलोड सुरू होत आहे...';
    });

    final fileName = Platform.isAndroid
        ? 'iSecure-EduMaster-${widget.info.latestVersion}.apk'
        : 'iSecure-EduMaster-${widget.info.latestVersion}-Setup.exe';

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
            _statusText =
                'डाउनलोड होत आहे: $dMb MB / $tMb MB (${(prog * 100).toInt()}%)';
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
          _hasError = false;
          _downloadProgress = 1.0;
          _downloadedFilePath = filePath;
          _statusText = Platform.isAndroid
              ? 'डाउनलोड पूर्ण. इन्स्टॉलर उघडत आहे...'
              : 'डाउनलोड पूर्ण झाले!';
        });

        if (Platform.isAndroid) {
          _installDownloadedApk();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'अपडेट पॅकेज यशस्वीरित्या डाउनलोड झाले! सेटअप सुरू केला जात आहे...',
              ),
              backgroundColor: AppColors.gradeA1,
            ),
          );
          try {
            Process.start(filePath, [], runInShell: true);
          } catch (e) {
            debugPrint('Execute installer error: $e');
          }
        }
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isDownloading = false;
          _hasError = true;
          _statusText = err;
        });
      },
    );
  }

  Future<void> _installDownloadedApk() async {
    final filePath = _downloadedFilePath;
    if (filePath == null) return;
    try {
      final installerOpened = await AppUpdateService.installAndroidApk(
        filePath,
      );
      if (!mounted) return;
      setState(() {
        _hasError = !installerOpened;
        _statusText = installerOpened
            ? 'इन्स्टॉलरमध्ये अपडेटची पुष्टी करा.'
            : 'या ॲपसाठी अज्ञात ॲप्स इन्स्टॉल करण्याची परवानगी द्या आणि पुन्हा प्रयत्न करा.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _statusText = 'इन्स्टॉलर उघडताना अडचण आली: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final isCompact = MediaQuery.sizeOf(context).width < 500;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.system_update_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'नवीन व्हर्जन अपडेट (New Version Update)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: isCompact ? MediaQuery.sizeOf(context).width * 0.8 : 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Old Version and New Version comparison box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Old Version
                  Flexible(
                    child: Column(
                      children: [
                        const Text(
                          'जुनी आवृत्ती\n(Old Version)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'v${info.currentVersion}',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),

                  // New Version
                  Flexible(
                    child: Column(
                      children: [
                        const Text(
                          'नवीन आवृत्ती\n(New Version)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Text(
                            'v${info.latestVersion}',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Download Progress Bar if downloading or status
            if (_isDownloading || _downloadProgress > 0 || _hasError) ...[
              const SizedBox(height: 16),
              if (!_hasError) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: AppColors.primary,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                _statusText.isNotEmpty
                    ? _statusText
                    : 'अपडेट डाउनलोड होत आहे...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hasError ? const Color(0xFFDC2626) : AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        if (_hasError) ...[
          TextButton(
            onPressed: () {
              final directUrl = widget.info.downloadUrl ?? widget.info.releasePageUrl;
              AppUpdateService.launchUrl(directUrl);
            },
            child: const Text(
              'ब्राउझरमध्ये डाउनलोड करा',
              style: TextStyle(fontSize: 12),
            ),
          ),
          ElevatedButton(
            onPressed: _startDirectDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('पुन्हा प्रयत्न करा'),
          ),
        ] else ...[
          if (!info.isMandatory && !_isDownloading)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'रद्द करा (Cancel)',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ElevatedButton.icon(
            onPressed: _isDownloading ? null : _startDirectDownload,
            icon: _isDownloading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 18),
            label: Text(
              _isDownloading
                  ? 'डाउनलोड होत आहे...'
                  : (_downloadedFilePath != null && Platform.isAndroid)
                  ? 'इन्स्टॉल करा'
                  : 'अपडेट करा (Update)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
