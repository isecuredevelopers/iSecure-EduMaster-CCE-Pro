import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SchoolLogoWidget extends StatelessWidget {
  final String? logoUrl;
  final double size;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const SchoolLogoWidget({
    super.key,
    this.logoUrl,
    this.size = 48,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(10);

    if (logoUrl != null && logoUrl!.trim().isNotEmpty) {
      final trimmed = logoUrl!.trim();

      // Case 1: Base64 data URI
      if (trimmed.startsWith('data:image')) {
        try {
          final base64String = trimmed.split(',').last;
          final bytes = base64Decode(base64String);
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: border ?? Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Image.memory(
                bytes,
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildFallback(radius),
              ),
            ),
          );
        } catch (e) {
          debugPrint('Logo Base64 decode error: $e');
        }
      }

      // Case 2: Web URL (http / https)
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: border ?? Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Image.network(
              trimmed,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallback(radius),
            ),
          ),
        );
      }

      // Case 3: Local File Path (e.g. C:\Users\... or /path/to/logo.png)
      if (!kIsWeb) {
        try {
          final file = File(trimmed);
          if (file.existsSync()) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: border ?? Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: Image.file(
                  file,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildFallback(radius),
                ),
              ),
            );
          }
        } catch (e) {
          debugPrint('Logo File error: $e');
        }
      }
    }

    return _buildFallback(radius);
  }

  Widget _buildFallback(BorderRadius radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: Icon(Icons.school, color: Colors.white, size: size * 0.55),
      ),
    );
  }
}
