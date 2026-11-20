import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myschool/core/services/app_update_service.dart';

void main() {
  testWidgets('Update modal displays simplified clean UI with only old/new version and update button',
      (WidgetTester tester) async {
    final testInfo = AppUpdateInfo(
      currentVersion: '1.4.1',
      latestVersion: '1.4.2',
      releaseTitle: 'Release Title Extra Info',
      releaseNotes: 'Detailed changelog that should not be visible anywhere in the dialog',
      releaseDate: '2026-11-20',
      releasePageUrl: 'https://github.com/isecuredevelopers/iSecure-EduMaster-CCE-Pro/releases/tag/v1.4.2',
      downloadUrl: 'https://github.com/isecuredevelopers/iSecure-EduMaster-CCE-Pro/releases/download/v1.4.2/update.apk',
      hasUpdate: true,
      isMandatory: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => AppUpdateService.showUpdateModal(context, testInfo),
              child: const Text('Open Modal'),
            );
          },
        ),
      ),
    );

    // Tap to open update modal
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // 1. Verify Header contains New Version Update
    expect(find.textContaining('नवीन व्हर्जन अपडेट'), findsOneWidget);
    expect(find.textContaining('New Version Update'), findsOneWidget);

    // 2. Verify Old Version and New Version are displayed
    expect(find.textContaining('जुनी आवृत्ती'), findsOneWidget);
    expect(find.text('v1.4.1'), findsOneWidget);
    expect(find.textContaining('नवीन आवृत्ती'), findsOneWidget);
    expect(find.text('v1.4.2'), findsOneWidget);

    // 3. Verify Update Button is present
    expect(find.textContaining('अपडेट करा'), findsOneWidget);
    expect(find.textContaining('रद्द करा'), findsOneWidget);

    // 4. Verify extra details are strictly NOT displayed
    expect(find.textContaining('GitHub वर पहा'), findsNothing);
    expect(find.textContaining('Detailed changelog'), findsNothing);
    expect(find.textContaining('Release Title Extra Info'), findsNothing);
    expect(find.textContaining('2026-11-20'), findsNothing);
  });
}
