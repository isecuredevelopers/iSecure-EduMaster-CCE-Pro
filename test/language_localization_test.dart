import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschool/core/localization/app_translations.dart';
import 'package:myschool/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTranslations Tests', () {
    test('Supported languages include Marathi, English, Hindi', () {
      expect(AppTranslations.supportedLanguages.length, 3);
      final codes = AppTranslations.supportedLanguages.map((l) => l['code']).toList();
      expect(codes, containsAll([AppTranslations.marathi, AppTranslations.english, AppTranslations.hindi]));
    });

    test('Language names resolve correctly', () {
      expect(AppTranslations.getLanguageName('mr'), 'मराठी');
      expect(AppTranslations.getLanguageName('en'), 'English');
      expect(AppTranslations.getLanguageName('hi'), 'हिंदी');
    });

    test('Translation keys exist for mr, en, and hi', () {
      final keys = [
        'dashboard',
        'students_list',
        'marks_entry',
        'ebooks_library',
        'select_language',
        'user_profile',
        'role_teacher',
        'role_admin',
        'stat_total_students',
        'app_language_settings',
      ];

      for (final key in keys) {
        final mr = AppTranslations.tr(key, 'mr');
        final en = AppTranslations.tr(key, 'en');
        final hi = AppTranslations.tr(key, 'hi');

        expect(mr.isNotEmpty, true, reason: 'mr translation for $key should not be empty');
        expect(en.isNotEmpty, true, reason: 'en translation for $key should not be empty');
        expect(hi.isNotEmpty, true, reason: 'hi translation for $key should not be empty');
        expect(mr != en, true, reason: 'mr and en should differ for $key');
      }
    });

    test('screenTitle resolves translated title for staff and student indexes', () {
      expect(AppTranslations.screenTitle(0, 'mr'), 'डॅशबोर्ड');
      expect(AppTranslations.screenTitle(0, 'en'), 'Dashboard');
      expect(AppTranslations.screenTitle(0, 'hi'), 'डैशबोर्ड');

      expect(AppTranslations.screenTitle(27, 'mr'), contains('ई-पुस्तके'));
      expect(AppTranslations.screenTitle(27, 'en'), contains('E-Books'));

      // Student portal index 15
      expect(AppTranslations.screenTitle(15, 'mr', isStudent: true), contains('पोर्टल'));
      expect(AppTranslations.screenTitle(15, 'en', isStudent: true), contains('Portal'));
    });
  });

  group('AppStateProvider Language State & Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Default language is Marathi (mr)', () {
      final provider = AppStateProvider();
      expect(provider.currentLanguage, 'mr');
    });

    test('setLanguage updates currentLanguage and saves to SharedPreferences', () async {
      final provider = AppStateProvider();
      expect(provider.currentLanguage, 'mr');

      await provider.setLanguage('en');
      expect(provider.currentLanguage, 'en');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cce_app_language'), 'en');

      await provider.setLanguage('hi');
      expect(provider.currentLanguage, 'hi');
      expect(prefs.getString('cce_app_language'), 'hi');
    });
  });
}
