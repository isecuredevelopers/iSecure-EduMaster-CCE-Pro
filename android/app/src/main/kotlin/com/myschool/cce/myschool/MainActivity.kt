package com.myschool.cce.myschool

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.myschool.cce.myschool/updates",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.error("INVALID_URL", "A URL is required.", null)
                    } else {
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("URL_OPEN_FAILED", error.message, null)
                        }
                    }
                }

                "getDownloadDirectory" -> {
                    try {
                        val dir = externalCacheDir ?: cacheDir
                        result.success(dir.absolutePath)
                    } catch (error: Exception) {
                        result.success(cacheDir.absolutePath)
                    }
                }

                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrBlank()) {
                        result.error("INVALID_APK_PATH", "An APK path is required.", null)
                        return@setMethodCallHandler
                    }
                    val apkFile = File(filePath)
                    if (!apkFile.exists() || !apkFile.isFile) {
                        result.error("APK_NOT_FOUND", "The downloaded APK was not found at $filePath", null)
                        return@setMethodCallHandler
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        !packageManager.canRequestPackageInstalls()
                    ) {
                        startActivity(
                            Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            },
                        )
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    try {
                        // Ensure target file is in externalCacheDir or cacheDir for maximum FileProvider compatibility
                        val targetDir = externalCacheDir ?: cacheDir
                        val targetFile = if (apkFile.parentFile?.canonicalPath != targetDir.canonicalPath) {
                            val dest = File(targetDir, apkFile.name)
                            try {
                                apkFile.copyTo(dest, overwrite = true)
                                dest
                            } catch (_: Exception) {
                                apkFile
                            }
                        } else {
                            apkFile
                        }

                        val apkUri = try {
                            FileProvider.getUriForFile(
                                this,
                                "$packageName.fileprovider",
                                targetFile,
                            )
                        } catch (_: Exception) {
                            FileProvider.getUriForFile(
                                this,
                                "$packageName.fileprovider",
                                apkFile,
                            )
                        }

                        val installIntent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(
                                apkUri,
                                "application/vnd.android.package-archive",
                            )
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }

                        // Explicitly grant URI permission to resolving installer activities
                        val resolveInfoList = packageManager.queryIntentActivities(installIntent, 0)
                        for (resolveInfo in resolveInfoList) {
                            val targetPackage = resolveInfo.activityInfo?.packageName
                            if (!targetPackage.isNullOrBlank()) {
                                grantUriPermission(
                                    targetPackage,
                                    apkUri,
                                    Intent.FLAG_GRANT_READ_URI_PERMISSION,
                                )
                            }
                        }

                        startActivity(installIntent)
                        result.success(true)
                    } catch (error: Exception) {
                        result.error("APK_INSTALL_FAILED", error.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
