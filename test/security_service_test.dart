import 'package:flutter_test/flutter_test.dart';
import 'package:myschool/core/services/security_service.dart';

void main() {
  group('SecurityService - Password Hashing & Verification', () {
    test('Hashes passwords with unique salts', () {
      final pass = 'MySecretPass@123';
      final hash1 = SecurityService.hashPassword(pass);
      final hash2 = SecurityService.hashPassword(pass);

      expect(SecurityService.isHashed(hash1), isTrue);
      expect(SecurityService.isHashed(hash2), isTrue);
      expect(hash1, startsWith('sha256\$'));
      expect(hash2, startsWith('sha256\$'));
      // Different salts produce different hashes
      expect(hash1, isNot(equals(hash2)));
    });

    test('Verifies correct password against hash', () {
      final pass = 'Teacher@2026';
      final hash = SecurityService.hashPassword(pass);

      expect(SecurityService.verifyPassword(pass, hash), isTrue);
      expect(SecurityService.verifyPassword('WrongPass', hash), isFalse);
      expect(SecurityService.verifyPassword('', hash), isFalse);
    });

    test('Verifies legacy plain text password for backward compatibility', () {
      expect(SecurityService.verifyPassword('admin', 'admin'), isTrue);
      expect(SecurityService.verifyPassword('123', 'admin'), isFalse);
    });
  });

  group('SecurityService - Anti-Brute-Force Rate Limiting', () {
    test('Enforces lockout after 5 consecutive failed attempts', () {
      const user = 'hacker_target';
      SecurityService.resetFailedAttempts(user);

      // Attempts 1 to 4 should be allowed
      for (int i = 1; i <= 4; i++) {
        expect(SecurityService.checkLoginAllowed(user).isAllowed, isTrue);
        final result = SecurityService.recordFailedAttempt(user);
        expect(result.isLocked, isFalse);
        expect(result.totalFailed, equals(i));
      }

      // 5th attempt must lock the account
      final fifth = SecurityService.recordFailedAttempt(user);
      expect(fifth.isLocked, isTrue);
      expect(fifth.lockSeconds, greaterThan(0));

      // Subsequent checks should be blocked
      final check = SecurityService.checkLoginAllowed(user);
      expect(check.isAllowed, isFalse);
      expect(check.remainingSeconds, greaterThan(0));

      // Resetting on successful login clears the lockout
      SecurityService.resetFailedAttempts(user);
      expect(SecurityService.checkLoginAllowed(user).isAllowed, isTrue);
    });
  });

  group('SecurityService - Input Sanitization & Path Traversal', () {
    test('Blocks directory traversal attack vectors', () {
      expect(SecurityService.sanitizeFileName('../../etc/passwd'), equals('etc_passwd'));
      expect(SecurityService.sanitizeFileName('..\\..\\Windows\\System32'), equals('Windows_System32'));
      expect(SecurityService.sanitizeFileName('report:2026*?.pdf'), equals('report_2026__.pdf'));
    });

    test('Strips script tags, null bytes, and non-printable control chars', () {
      final malicious = '<script>alert("hack")</script>Student Name\u0000\x07';
      final clean = SecurityService.sanitizeText(malicious);
      expect(clean, equals('Student Name'));
    });
  });

  group('SecurityService - PII Data Masking', () {
    test('Masks password, mobile number, and Aadhaar', () {
      expect(SecurityService.maskPassword('Sagar@1998'), equals('••••••••'));
      expect(SecurityService.maskMobile('9876543210'), equals('98****3210'));
      expect(SecurityService.maskAadhaar('123456789012'), equals('XXXX-XXXX-9012'));
    });
  });
}
