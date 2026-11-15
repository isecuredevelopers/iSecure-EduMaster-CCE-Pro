import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/dead_stock_model.dart';
import '../../providers/app_state_provider.dart';

class DeadStockScreen extends StatefulWidget {
  const DeadStockScreen({super.key});

  @override
  State<DeadStockScreen> createState() => _DeadStockScreenState();
}

class _DeadStockScreenState extends State<DeadStockScreen> {
  String _selectedCategory = 'सर्व';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    final filteredList = _selectedCategory == 'सर्व'
        ? state.deadStockList
        : state.deadStockList.where((d) => d.category == _selectedCategory).toList();

    final double totalDeadStockValue =
        filteredList.fold(0.0, (sum, item) => sum + item.totalAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory, color: Colors.brown, size: 26),
            SizedBox(width: 10),
            Text(
              'शालेय मृतसाठा नोंदवही (Dead Stock Register - नमुना १ ते ५)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header stats & Action bar
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.category, color: AppColors.primary),
                        const SizedBox(width: 10),
                        const Text('वर्गवारी: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _selectedCategory,
                          items: ['सर्व', 'फर्निचर', 'डिजिटल/आयटी साहित्य', 'क्रीडा साहित्य', 'प्रयोगशाळा साहित्य', 'इतर']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text('साहित्य: ${filteredList.length}'),
                          backgroundColor: Colors.blue.shade50,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('मूल्य: ₹${totalDeadStockValue.toStringAsFixed(0)}'),
                          backgroundColor: Colors.green.shade50,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_box, size: 18),
                          label: const Text('नवीन वस्तू नोंदवा'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                          onPressed: () => _showAddDeadStockDialog(context, state),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.print, size: 18),
                          label: const Text('ऑडिट प्रिंट'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          onPressed: () => _printDeadStockRegister(state, filteredList),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Dead Stock DataTable
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: filteredList.isEmpty
                      ? const Center(child: Text('या वर्गवारीत कोणतेही मृतसाठा साहित्य उपलब्ध नाही.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
                              columns: const [
                                DataColumn(label: Text('अ.क्र.', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('वस्तूचे नाव', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('वर्गवारी', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('संख्या/नग', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('खरेदी दिनांक', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('व्हाउचर क्र.', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('पुरवठादार', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('दर (रु.)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('एकूण रक्कम (रु.)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('निधी स्त्रोत', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('सद्यस्थिती', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('क्रिया', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredList.asMap().entries.map((entry) {
                                final idx = entry.key + 1;
                                final item = entry.value;
                                return DataRow(
                                  cells: [
                                    DataCell(Text('$idx')),
                                    DataCell(Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(item.category)),
                                    DataCell(Text('${item.quantity}')),
                                    DataCell(Text(DateFormat('dd-MM-yyyy').format(item.purchaseDate))),
                                    DataCell(Text(item.voucherOrBillNo)),
                                    DataCell(Text(item.supplierName)),
                                    DataCell(Text('₹${item.ratePerItem}')),
                                    DataCell(Text('₹${item.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(item.fundingSource)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: item.itemCondition.contains('उत्कृष्ट')
                                              ? Colors.green.shade100
                                              : (item.itemCondition.contains('दुरुस्ती')
                                                  ? Colors.orange.shade100
                                                  : Colors.red.shade100),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.itemCondition,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: item.itemCondition.contains('उत्कृष्ट')
                                                ? Colors.green.shade900
                                                : Colors.brown,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        tooltip: 'हटवा',
                                        onPressed: () async => await state.deleteDeadStockItem(item.id),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDeadStockDialog(BuildContext context, AppStateProvider state) {
    final nameCtrl = TextEditingController();
    String category = 'फर्निचर';
    final qtyCtrl = TextEditingController(text: '1');
    final voucherCtrl = TextEditingController();
    final supplierCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    String source = 'समग्र शिक्षा अनुदान';
    String condition = 'उत्कृष्ट/चालू';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('नवीन मृतसाठा साहित्य नोंद'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'वस्तूचे नाव', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(labelText: 'वर्गवारी', border: OutlineInputBorder()),
                          items: ['फर्निचर', 'डिजिटल/आयटी साहित्य', 'क्रीडा साहित्य', 'प्रयोगशाळा साहित्य', 'इतर']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (val) => setDialogState(() => category = val ?? 'फर्निचर'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'नग / संख्या', border: OutlineInputBorder())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(controller: voucherCtrl, decoration: const InputDecoration(labelText: 'व्हाउचर / बिल क्र.', border: OutlineInputBorder())),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText: 'पुरवठादार फर्म', border: OutlineInputBorder())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'प्रति नग दर (रु.)', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: source,
                          decoration: const InputDecoration(labelText: 'निधी स्त्रोत', border: OutlineInputBorder()),
                          items: ['समग्र शिक्षा अनुदान', 'ZP सेस फंड', 'SMC निधी', 'लोकसहभाग/दानशूर']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (val) => setDialogState(() => source = val ?? 'समग्र शिक्षा अनुदान'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: condition,
                          decoration: const InputDecoration(labelText: 'सद्यस्थिती', border: OutlineInputBorder()),
                          items: ['उत्कृष्ट/चालू', 'दुरुस्तीयोग्य', 'निर्लेखित (अपलेखित)']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (val) => setDialogState(() => condition = val ?? 'उत्कृष्ट/चालू'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final qty = int.tryParse(qtyCtrl.text) ?? 1;
                final rate = double.tryParse(rateCtrl.text) ?? 0.0;
                final item = DeadStockItemModel(
                  id: 'ds_${DateTime.now().millisecondsSinceEpoch}',
                  itemNumber: state.deadStockList.length + 1,
                  itemName: nameCtrl.text,
                  category: category,
                  quantity: qty,
                  purchaseDate: DateTime.now(),
                  voucherOrBillNo: voucherCtrl.text,
                  supplierName: supplierCtrl.text,
                  ratePerItem: rate,
                  totalAmount: qty * rate,
                  fundingSource: source,
                  itemCondition: condition,
                );
                await state.addOrUpdateDeadStockItem(item);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('जतन करा'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printDeadStockRegister(AppStateProvider state, List<DeadStockItemModel> list) async {
    final pdf = pw.Document();
    final school = state.school;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('महाराष्ट्र शासन - जिल्हा परिषद शिक्षण विभाग', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('शालेय मृतसाठा नोंदवही (Dead Stock Register - नमुना १ ते ५)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${school.schoolName} | केंद्र: ${school.cluster} | ता.: ${school.blockTaluka} | जि.: ${school.district}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Divider(thickness: 1),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('अ.क्र.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('वस्तूचे नाव', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('नग', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('खरेदी तारीख', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('व्हाउचर क्र.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('पुरवठादार', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('दर (रु.)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('एकूण रक्कम', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('निधी स्त्रोत', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('सद्यस्थिती', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...list.asMap().entries.map((e) {
                    final idx = e.key + 1;
                    final itm = e.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('$idx')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(itm.itemName)),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${itm.quantity}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(DateFormat('dd-MM-yyyy').format(itm.purchaseDate))),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(itm.voucherOrBillNo)),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(itm.supplierName)),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('रु. ${itm.ratePerItem}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('रु. ${itm.totalAmount}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(itm.fundingSource)),
                        pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(itm.itemCondition)),
                      ],
                    );
                  }),
                ],
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('साठा प्रमुख शिक्षक स्वाक्षरी', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('शासकीय लेखापरीक्षक (Auditor)', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('मुख्याध्यापक स्वाक्षरी व शिक्का', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Dead_Stock_Register.pdf',
    );
  }
}
