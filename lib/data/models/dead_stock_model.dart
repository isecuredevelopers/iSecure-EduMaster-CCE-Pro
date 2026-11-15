// शालेय मृतसाठा नोंदवही (Dead Stock Register - नमुना १ ते ५)
// शासकीय लेखापरीक्षण (Audit) व तपासणीसाठी

class DeadStockItemModel {
  final String id;
  final int itemNumber; // अनुक्रमांक
  final String itemName; // वस्तूचे नाव (उदा. लोखंडी बाकडी, लाकडी टेबल, कपाट, डिजिटल टीव्ही, लॅपटॉप, प्रिंटर, सोलर पॅनेल, ध्वनिवर्धक)
  final String category; // 'फर्निचर', 'डिजिटल/आयटी साहित्य', 'क्रीडा साहित्य', 'प्रयोगशाळा साहित्य', 'इतर'
  final int quantity; // संख्या / नग
  final DateTime purchaseDate; // खरेदी दिनांक
  final String voucherOrBillNo; // व्हाउचर / पावती क्र.
  final String supplierName; // पुरवठादाराचे नाव
  final double ratePerItem; // प्रति नग दर (रु.)
  final double totalAmount; // एकूण खर्च (रु.)
  final String fundingSource; // निधी स्त्रोत: 'समग्र शिक्षा अनुदान', 'ZP सेस फंड', 'SMC निधी', 'लोकसहभाग/दानशूर'
  final String itemCondition; // 'उत्कृष्ट/चालू', 'दुरुस्तीयोग्य', 'निर्लेखित (Condemned/अपलेखित)'
  final String remark; // शेरा / लोकेशन (उदा. वर्ग खोली क्र. २)

  DeadStockItemModel({
    required this.id,
    required this.itemNumber,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.purchaseDate,
    required this.voucherOrBillNo,
    required this.supplierName,
    required this.ratePerItem,
    required this.totalAmount,
    required this.fundingSource,
    this.itemCondition = 'उत्कृष्ट/चालू',
    this.remark = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemNumber': itemNumber,
        'itemName': itemName,
        'category': category,
        'quantity': quantity,
        'purchaseDate': purchaseDate.toIso8601String(),
        'voucherOrBillNo': voucherOrBillNo,
        'supplierName': supplierName,
        'ratePerItem': ratePerItem,
        'totalAmount': totalAmount,
        'fundingSource': fundingSource,
        'itemCondition': itemCondition,
        'remark': remark,
      };

  factory DeadStockItemModel.fromJson(Map<String, dynamic> json) =>
      DeadStockItemModel(
        id: json['id'] ?? '',
        itemNumber: (json['itemNumber'] as num?)?.toInt() ?? 1,
        itemName: json['itemName'] ?? '',
        category: json['category'] ?? 'फर्निचर',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        purchaseDate: DateTime.parse(
            json['purchaseDate'] ?? DateTime.now().toIso8601String()),
        voucherOrBillNo: json['voucherOrBillNo'] ?? '',
        supplierName: json['supplierName'] ?? '',
        ratePerItem: (json['ratePerItem'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        fundingSource: json['fundingSource'] ?? 'समग्र शिक्षा अनुदान',
        itemCondition: json['itemCondition'] ?? 'उत्कृष्ट/चालू',
        remark: json['remark'] ?? '',
      );
}

