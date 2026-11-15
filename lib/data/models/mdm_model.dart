// शालेय पोषण आहार (PM POSHAN / MDM) मॉडेल्स
// महाराष्ट्र शासन प्राथमिक शिक्षण विभाग नियमावलीनुसार

class MdmDailyAttendanceModel {
  final String id;
  final DateTime date;
  final int primaryBeneficiaries; // इ. १ ते ५ (दररोज लाभार्थी संख्या)
  final int upperPrimaryBeneficiaries; // इ. ६ ते ८ (दररोज लाभार्थी संख्या)
  final String menuName; // वरण-भात, मूग खिचडी, मटकी उसळ, चवळी उसळ, सोयाबीन पुलाव
  final double riceUsedKg; // वापरलेला तांदूळ (किलो)
  final double pulsesUsedKg; // वापरलेले कडधान्य / डाळी (किलो)
  final double oilUsedKg; // वापरलेले तेल (किलो/लिटर)
  final String tastedBy; // चव तपासणी करणारे (मुख्याध्यापक/शिक्षक/माता समिती)
  final String tasteQuality; // उत्तम, समाधानकारक, सुधारणा आवश्यक
  final String remark;

  MdmDailyAttendanceModel({
    required this.id,
    required this.date,
    required this.primaryBeneficiaries,
    required this.upperPrimaryBeneficiaries,
    required this.menuName,
    required this.riceUsedKg,
    required this.pulsesUsedKg,
    required this.oilUsedKg,
    required this.tastedBy,
    this.tasteQuality = 'उत्तम',
    this.remark = '',
  });

  int get totalBeneficiaries => primaryBeneficiaries + upperPrimaryBeneficiaries;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'primaryBeneficiaries': primaryBeneficiaries,
        'upperPrimaryBeneficiaries': upperPrimaryBeneficiaries,
        'menuName': menuName,
        'riceUsedKg': riceUsedKg,
        'pulsesUsedKg': pulsesUsedKg,
        'oilUsedKg': oilUsedKg,
        'tastedBy': tastedBy,
        'tasteQuality': tasteQuality,
        'remark': remark,
      };

  factory MdmDailyAttendanceModel.fromJson(Map<String, dynamic> json) =>
      MdmDailyAttendanceModel(
        id: json['id'] ?? '',
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        primaryBeneficiaries: (json['primaryBeneficiaries'] as num?)?.toInt() ?? 0,
        upperPrimaryBeneficiaries:
            (json['upperPrimaryBeneficiaries'] as num?)?.toInt() ?? 0,
        menuName: json['menuName'] ?? 'वरण-भात',
        riceUsedKg: (json['riceUsedKg'] as num?)?.toDouble() ?? 0.0,
        pulsesUsedKg: (json['pulsesUsedKg'] as num?)?.toDouble() ?? 0.0,
        oilUsedKg: (json['oilUsedKg'] as num?)?.toDouble() ?? 0.0,
        tastedBy: json['tastedBy'] ?? 'मुख्याध्यापक',
        tasteQuality: json['tasteQuality'] ?? 'उत्तम',
        remark: json['remark'] ?? '',
      );
}

class MdmStockItemModel {
  final String id;
  final String itemName; // तांदूळ, मूग डाळ, मटकी, हरभरा, सोयाबीन, तेल, मीठ, हळद, मोहरी, जिरे
  final String unit; // किलो, लिटर, पाकीट
  final double openingStock; // मागील शिल्लक
  final double receivedStock; // चालू महिन्यात आवक
  final double consumedStock; // एकूण खर्च
  final String batchOrChallanNo; // चलन क्र. / पावती क्र.

  MdmStockItemModel({
    required this.id,
    required this.itemName,
    required this.unit,
    required this.openingStock,
    required this.receivedStock,
    required this.consumedStock,
    this.batchOrChallanNo = '',
  });

  double get balanceStock => (openingStock + receivedStock) - consumedStock;

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'unit': unit,
        'openingStock': openingStock,
        'receivedStock': receivedStock,
        'consumedStock': consumedStock,
        'batchOrChallanNo': batchOrChallanNo,
      };

  factory MdmStockItemModel.fromJson(Map<String, dynamic> json) =>
      MdmStockItemModel(
        id: json['id'] ?? '',
        itemName: json['itemName'] ?? '',
        unit: json['unit'] ?? 'किलो',
        openingStock: (json['openingStock'] as num?)?.toDouble() ?? 0.0,
        receivedStock: (json['receivedStock'] as num?)?.toDouble() ?? 0.0,
        consumedStock: (json['consumedStock'] as num?)?.toDouble() ?? 0.0,
        batchOrChallanNo: json['batchOrChallanNo'] ?? '',
      );
}

class MdmMonthlyBillModel {
  final String id;
  final int month; // 1 to 12
  final int year;
  final int workingDays;
  final int totalPrimaryStudentDays; // इ. १ ते ५ एकूण लाभार्थी पट-दिवस
  final int totalUpperPrimaryStudentDays; // इ. ६ ते ८ एकूण लाभार्थी पट-दिवस
  final double primaryCookingCostRate; // उदा. रु. ५.४५
  final double upperPrimaryCookingCostRate; // उदा. रु. ८.१७
  final double cookHonorarium; // स्वयंपाकी / मदतनीस मानधन (उदा. रु. २५०० किंवा ३०००)
  final String cookName; // स्वयंपाकी / मदतनीस नाव
  final String status; // 'तयार', 'सादर केले', 'मंजूर'
  final DateTime generatedDate;

  MdmMonthlyBillModel({
    required this.id,
    required this.month,
    required this.year,
    required this.workingDays,
    required this.totalPrimaryStudentDays,
    required this.totalUpperPrimaryStudentDays,
    this.primaryCookingCostRate = 5.45,
    this.upperPrimaryCookingCostRate = 8.17,
    this.cookHonorarium = 2500.0,
    this.cookName = 'स्वयंपाकी',
    this.status = 'तयार',
    required this.generatedDate,
  });

  double get primaryCookingCostAmount =>
      totalPrimaryStudentDays * primaryCookingCostRate;
  double get upperPrimaryCookingCostAmount =>
      totalUpperPrimaryStudentDays * upperPrimaryCookingCostRate;
  double get totalCookingCost =>
      primaryCookingCostAmount + upperPrimaryCookingCostAmount;
  double get totalBillAmount => totalCookingCost + cookHonorarium;

  String get monthNameMarathi {
    const marathiMonths = [
      '',
      'जानेवारी',
      'फेब्रुवारी',
      'मार्च',
      'एप्रिल',
      'मे',
      'जून',
      'जुलै',
      'ऑगस्ट',
      'सप्टेंबर',
      'ऑक्टोबर',
      'नोव्हेंबर',
      'डिसेंबर'
    ];
    if (month >= 1 && month <= 12) return marathiMonths[month];
    return 'महिना $month';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'month': month,
        'year': year,
        'workingDays': workingDays,
        'totalPrimaryStudentDays': totalPrimaryStudentDays,
        'totalUpperPrimaryStudentDays': totalUpperPrimaryStudentDays,
        'primaryCookingCostRate': primaryCookingCostRate,
        'upperPrimaryCookingCostRate': upperPrimaryCookingCostRate,
        'cookHonorarium': cookHonorarium,
        'cookName': cookName,
        'status': status,
        'generatedDate': generatedDate.toIso8601String(),
      };

  factory MdmMonthlyBillModel.fromJson(Map<String, dynamic> json) =>
      MdmMonthlyBillModel(
        id: json['id'] ?? '',
        month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
        year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
        workingDays: (json['workingDays'] as num?)?.toInt() ?? 24,
        totalPrimaryStudentDays:
            (json['totalPrimaryStudentDays'] as num?)?.toInt() ?? 0,
        totalUpperPrimaryStudentDays:
            (json['totalUpperPrimaryStudentDays'] as num?)?.toInt() ?? 0,
        primaryCookingCostRate:
            (json['primaryCookingCostRate'] as num?)?.toDouble() ?? 5.45,
        upperPrimaryCookingCostRate:
            (json['upperPrimaryCookingCostRate'] as num?)?.toDouble() ?? 8.17,
        cookHonorarium:
            (json['cookHonorarium'] as num?)?.toDouble() ?? 2500.0,
        cookName: json['cookName'] ?? 'स्वयंपाकी',
        status: json['status'] ?? 'तयार',
        generatedDate: DateTime.parse(
            json['generatedDate'] ?? DateTime.now().toIso8601String()),
      );
}

