import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschool/providers/app_state_provider.dart';
import 'package:myschool/screens/mdm/mdm_management_screen.dart';
import 'package:myschool/screens/entitlements/free_entitlements_screen.dart';
import 'package:myschool/screens/reports/monthly_attendance_abstract_screen.dart';
import 'package:myschool/screens/smc/smc_management_screen.dart';
import 'package:myschool/screens/dead_stock/dead_stock_screen.dart';
import 'package:myschool/screens/library/library_screen.dart';
import 'package:myschool/screens/teachers/teacher_service_screen.dart';
import 'package:myschool/screens/admin_registers/inward_outward_health_screen.dart';
import 'package:myschool/screens/students/student_id_cards_screen.dart';
import 'package:myschool/screens/tools/saral_udise_sync_screen.dart';

Widget createTestWidget(Widget child, AppStateProvider provider) {
  return ChangeNotifierProvider<AppStateProvider>.value(
    value: provider,
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppStateProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    provider = AppStateProvider();
  });

  testWidgets('MdmManagementScreen renders tabs and daily entry form',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const MdmManagementScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('शालेय पोषण आहार (PM POSHAN / MDM)'), findsOneWidget);
    expect(find.text('दैनिक हजेरी व चव नोंद'), findsOneWidget);
    expect(find.text('धान्य व किराणा साठा नोंदवही'), findsOneWidget);
    expect(find.text('मासिक बिल व ताळेबंद'), findsOneWidget);
    expect(find.text('नोंद जतन करा'), findsOneWidget);
  });

  testWidgets('FreeEntitlementsScreen renders textbooks and uniforms tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const FreeEntitlementsScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('समग्र शिक्षा - मोफत पाठ्यपुस्तके व गणवेश वाटप नोंदवही'), findsOneWidget);
    expect(find.text('मोफत पाठ्यपुस्तक वाटप नोंदवही'), findsOneWidget);
    expect(find.text('मोफत गणवेश वाटप नोंदवही'), findsOneWidget);
  });

  testWidgets('MonthlyAttendanceAbstractScreen renders Form A/B table',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const MonthlyAttendanceAbstractScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('मासिक उपस्थिती गोषवारा (Monthly Attendance Abstract - Form A/B)'), findsOneWidget);
    expect(find.text('अधिकृत गोषवारा प्रिंट करा'), findsOneWidget);
  });

  testWidgets('SmcManagementScreen renders SMC members and meetings tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const SmcManagementScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('शाळा व्यवस्थापन समिती (SMC) व ठराव नोंदवही'), findsOneWidget);
    expect(find.text('SMC कार्यकारिणी सदस्य यादी'), findsOneWidget);
    expect(find.text('मासिक सभा व ठराव वही (Resolutions)'), findsOneWidget);
  });

  testWidgets('DeadStockScreen renders dead stock items and print button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const DeadStockScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('शालेय मृतसाठा नोंदवही (Dead Stock Register - नमुना १ ते ५)'), findsOneWidget);
    expect(find.text('नवीन वस्तू नोंदवा'), findsOneWidget);
  });

  testWidgets('LibraryScreen renders book catalog and issue actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const LibraryScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('शालेय ग्रंथालय नोंदवही व पुस्तक देवाणघेवाण (Library Register)'), findsOneWidget);
    expect(find.text('नवीन पुस्तक नोंदवा'), findsOneWidget);
  });

  testWidgets('TeacherServiceScreen renders CL leave tracker and movement tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const TeacherServiceScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('शिक्षक रजा खातावणी व हालचाल नोंदवही (Staff Service Register)'), findsOneWidget);
    expect(find.text('किरकोळ रजा खातावणी (CL Balance)'), findsOneWidget);
    expect(find.text('शिक्षक हालचाल नोंदवही (Movement)'), findsOneWidget);
  });

  testWidgets('InwardOutwardHealthScreen renders inward, outward, and health tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const InwardOutwardHealthScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('शासकीय आवक-जावक व विद्यार्थी आरोग्य तपासणी (RBSK)'), findsOneWidget);
    expect(find.text('शासकीय आवक वही (Inward)'), findsOneWidget);
    expect(find.text('शासकीय जावक वही (Outward)'), findsOneWidget);
    expect(find.text('विद्यार्थी आरोग्य तपासणी (Health Card)'), findsOneWidget);
  });

  testWidgets('StudentIdCardsScreen renders ID card grid and print option',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const StudentIdCardsScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('विद्यार्थी डिजिटल ओळखपत्र जनरेटर (Student ID Cards)'), findsOneWidget);
    expect(find.text('ओळखपत्रे प्रिंट करा (A4 Sheet)'), findsOneWidget);
  });

  testWidgets('SaralUdiseSyncScreen renders export and import options',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget(const SaralUdiseSyncScreen(), provider));
    await tester.pumpAndSettle();

    expect(find.text('सरळ (SARAL Student Portal) व U-DISE+ डेटा सिंक'), findsOneWidget);
    expect(find.text('सरळ (SARAL) एक्सेल एक्सपोर्ट'), findsOneWidget);
    expect(find.text('सरळ एक्सेल डेटा बल्क इंपोर्ट'), findsOneWidget);
  });
}
