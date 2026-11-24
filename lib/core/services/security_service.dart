import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Centralized Enterprise Security & Cryptography Service
/// iSecure CCE Pro - Maharashtra ZP Statutory Security Compliance
class SecurityService {
  // Application secret pepper for cryptographic defense-in-depth
  static const String _pepper = 'iSecure_CCE_Pro_ZP_Statutory_2026_Key#SecureGov';

  // In-memory rate limiting and brute force tracking: identifier -> AttemptRecord
  static final Map<String, _LoginAttemptRecord> _loginAttempts = {};

  // Maximum allowed consecutive failed attempts before triggering lockout
  static const int maxFailedAttemptsBeforeLock = 5;

  // ==========================================
  // 1. CRYPTOGRAPHIC PASSWORD HASHING
  // ==========================================

  /// Generate a cryptographically secure random salt (16 bytes hex)
  static String generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Hash a plaintext password using SHA-256 with a salt and internal pepper
  /// Output format: "sha256$<salt>$<hashHex>"
  static String hashPassword(String plainPassword, {String? salt}) {
    final effectiveSalt = salt ?? generateSalt();
    final bytes = utf8.encode('$effectiveSalt:$plainPassword:$_pepper');
    final digest = sha256.convert(bytes);
    return 'sha256\$$effectiveSalt\$${digest.toString()}';
  }

  /// Check if a stored string is in hashed format
  static bool isHashed(String? value) {
    if (value == null) return false;
    return value.startsWith('sha256\$') && value.split('\$').length == 3;
  }

  /// Verify plaintext against a stored password (supporting both hashed and backward-compatible legacy passwords)
  static bool verifyPassword(String plainPassword, String? storedPasswordOrHash) {
    if (storedPasswordOrHash == null || storedPasswordOrHash.isEmpty) return false;

    // Case 1: Stored password is in secure sha256$ format
    if (isHashed(storedPasswordOrHash)) {
      final parts = storedPasswordOrHash.split('\$');
      if (parts.length != 3) return false;
      final salt = parts[1];
      final expectedHash = parts[2];

      final computed = sha256.convert(utf8.encode('$salt:$plainPassword:$_pepper')).toString();
      return _constantTimeEquals(computed, expectedHash);
    }

    // Case 2: Legacy plaintext password (backward compatibility for existing offline databases)
    return _constantTimeEquals(plainPassword, storedPasswordOrHash);
  }

  /// Constant-time string comparison to prevent side-channel timing attacks
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // ==========================================
  // 2. BRUTE FORCE DEFENSE & RATE LIMITING
  // ==========================================

  /// Check whether login is currently allowed for the given username or student GR
  /// Returns a record: (isAllowed, remainingLockoutSeconds, failedAttemptsCount)
  static ({bool isAllowed, int remainingSeconds, int failedCount}) checkLoginAllowed(String identifier) {
    final key = identifier.trim().toLowerCase();
    final record = _loginAttempts[key];

    if (record == null) {
      return (isAllowed: true, remainingSeconds: 0, failedCount: 0);
    }

    final now = DateTime.now();

    // Check if currently locked out
    if (record.lockedUntil != null && now.isBefore(record.lockedUntil!)) {
      final remaining = record.lockedUntil!.difference(now).inSeconds + 1;
      return (isAllowed: false, remainingSeconds: remaining, failedCount: record.failedCount);
    }

    // Lockout has expired; check if cooldown period (10 minutes of inactivity) passed
    if (record.lastAttempt != null && now.difference(record.lastAttempt!).inMinutes >= 10) {
      _loginAttempts.remove(key);
      return (isAllowed: true, remainingSeconds: 0, failedCount: 0);
    }

    return (isAllowed: true, remainingSeconds: 0, failedCount: record.failedCount);
  }

  /// Record a failed login attempt and apply exponential lockout if threshold reached
  static ({bool isLocked, int lockSeconds, int totalFailed}) recordFailedAttempt(String identifier) {
    final key = identifier.trim().toLowerCase();
    final now = DateTime.now();
    final record = _loginAttempts.putIfAbsent(key, () => _LoginAttemptRecord());

    record.failedCount++;
    record.lastAttempt = now;

    int lockoutDuration = 0;
    if (record.failedCount >= 10) {
      // 10+ failed attempts: 10 minutes lockout
      lockoutDuration = 600;
    } else if (record.failedCount >= 7) {
      // 7-9 failed attempts: 2 minutes lockout
      lockoutDuration = 120;
    } else if (record.failedCount >= maxFailedAttemptsBeforeLock) {
      // 5-6 failed attempts: 30 seconds lockout
      lockoutDuration = 30;
    }

    if (lockoutDuration > 0) {
      record.lockedUntil = now.add(Duration(seconds: lockoutDuration));
      return (isLocked: true, lockSeconds: lockoutDuration, totalFailed: record.failedCount);
    }

    return (isLocked: false, lockSeconds: 0, totalFailed: record.failedCount);
  }

  /// Reset failed attempt counter upon successful login
  static void resetFailedAttempts(String identifier) {
    final key = identifier.trim().toLowerCase();
    _loginAttempts.remove(key);
  }

  // ==========================================
  // 3. INPUT SANITIZATION & PATH TRAVERSAL DEFENSE
  // ==========================================

  /// Strip dangerous control characters, null bytes, and script tags from text inputs
  static String sanitizeText(String input) {
    if (input.isEmpty) return input;
    return input
        .replaceAll('\u0000', '') // Null byte
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '') // Non-printable controls
        .replaceAll(RegExp(r'<\s*script[^>]*>.*?<\s*/\s*script\s*>', caseSensitive: false), '')
        .trim();
  }

  /// Sanitize file name for export/import to prevent Directory Traversal attacks (../ or ..\)
  static String sanitizeFileName(String fileName) {
    if (fileName.isEmpty) return 'document';
    return fileName
        .replaceAll(RegExp(r'\.\./|\.\.\\'), '') // Block path traversal
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_') // Windows/Unix illegal filename chars
        .trim();
  }

  // ==========================================
  // 4. DATA INTEGRITY CHECKSUMS (TAMPER PROOFING)
  // ==========================================

  /// Calculate HMAC-SHA256 signature for local database tamper detection
  static String computeIntegrityChecksum(String payload) {
    final hmac = Hmac(sha256, utf8.encode(_pepper));
    return hmac.convert(utf8.encode(payload)).toString();
  }

  /// Verify payload against an HMAC-SHA256 signature
  static bool verifyIntegrityChecksum(String payload, String expectedSignature) {
    final computed = computeIntegrityChecksum(payload);
    return _constantTimeEquals(computed, expectedSignature);
  }

  // ==========================================
  // 5. PII MASKING & UI PRIVACY
  // ==========================================

  /// Mask a password for display in administrative lists
  static String maskPassword(String? password) {
    if (password == null || password.isEmpty) return '';
    return '••••••••';
  }

  /// Mask a 10-digit mobile number: e.g. "9876543210" -> "98****3210"
  static String maskMobile(String? mobile) {
    if (mobile == null || mobile.trim().length < 10) return mobile ?? '';
    final m = mobile.trim();
    return '${m.substring(0, 2)}****${m.substring(m.length - 4)}';
  }

  /// Mask a 12-digit Aadhaar number: e.g. "123456789012" -> "XXXX-XXXX-9012"
  static String maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.trim().length < 12) return aadhaar ?? '';
    final clean = aadhaar.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 12) return aadhaar;
    return 'XXXX-XXXX-${clean.substring(8, 12)}';
  }
}

class _LoginAttemptRecord {
  int failedCount = 0;
  DateTime? lastAttempt;
  DateTime? lockedUntil;
}
