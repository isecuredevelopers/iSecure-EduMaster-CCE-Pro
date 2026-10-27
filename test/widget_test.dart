import 'package:flutter_test/flutter_test.dart';
import 'package:myschool/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MySchoolApp());
    expect(find.byType(MySchoolApp), findsOneWidget);
  });
}
