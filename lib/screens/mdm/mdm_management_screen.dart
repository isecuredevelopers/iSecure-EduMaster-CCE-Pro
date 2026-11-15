import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/mdm_model.dart';
import '../../providers/app_state_provider.dart';

class MdmManagementScreen extends StatefulWidget {
  const MdmManagementScreen({super.key});

  @override
  State<MdmManagementScreen> createState() => _MdmManagementScreenState();
}

class _MdmManagementScreenState extends State<MdmManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Controllers for Daily Entry
  DateTime _selectedDate = DateTime.now();
  final _primaryBeneficiariesCtrl = TextEditingController(text: '45');
  final _upperPrimaryBeneficiariesCtrl = TextEditingController(text: '38');
  String _selectedMenu = 'मूग डाळ खिचडी व सोयाबीन उसळ';
  final _tastedByCtrl = TextEditingController(text: 'श्री. एस. आर. पाटील (मुख्याध्यापक)');
  String _tasteQuality = 'उत्कृष्ट व पौष्टिक';
  final _remarkCtrl = TextEditingController();

  final List<String> _menuOptions = [
    'मूग डाळ खिचडी व सोयाबीन उसळ',
    'मटकी उसळ व भात',
    'वरण-भात व भाजी',
    'चवळी उसळ व भात',
    'सोयाबीन पुलाव',
    'हरभरा उसळ व भात',
    'मसाले भात',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _primaryBeneficiariesCtrl.dispose();
    _upperPrimaryBeneficiariesCtrl.dispose();
    _tastedByCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.amber, size: 26),
            SizedBox(width: 10),
            Text(
              'शालेय पोषण आहार (PM POSHAN / MDM)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'दैनिक हजेरी व चव नोंद'),
            Tab(icon: Icon(Icons.inventory_2), text: 'धान्य व किराणा साठा नोंदवही'),
            Tab(icon: Icon(Icons.receipt_long), text: 'मासिक बिल व ताळेबंद'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyAttendanceTab(context, state),
          _buildStockRegisterTab(context, state),
          _buildMonthlyBillsTab(context, state),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: दैनिक पोषण आहार हजेरी व चव तपासणी
  // ==========================================
  Widget _buildDailyAttendanceTab(BuildContext context, AppStateProvider state) {
    final int pCount = int.tryParse(_primaryBeneficiariesCtrl.text) ?? 0;
    final int upCount = int.tryParse(_upperPrimaryBeneficiariesCtrl.text) ?? 0;
    // Calculation: Primary 100g, Upper Primary 150g rice
    final double calcRice = ((pCount * 0.100) + (upCount * 0.150));
    // Pulses: Primary 20g, Upper Primary 30g
    final double calcPulses = ((pCount * 0.020) + (upCount * 0.030));
    // Oil: Primary 5g, Upper Primary 7.5g
    final double calcOil = ((pCount * 0.005) + (upCount * 0.0075));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Daily Entry Form
        SizedBox(
          width: 420,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_calendar, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'आजची पोषण आहार नोंद',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Chip(
                          label: Text(
                            DateFormat('dd-MM-yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Date Picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month, color: Colors.blueGrey),
                      title: const Text('तारीख निवडा', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                      trailing: TextButton.icon(
                        icon: const Icon(Icons.event),
                        label: const Text('बदला'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2023),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Beneficiaries Inputs
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _primaryBeneficiariesCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'इ. १ ते ५ लाभार्थी',
                              hintText: 'संख्या',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _upperPrimaryBeneficiariesCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'इ. ६ ते ८ लाभार्थी',
                              hintText: 'संख्या',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Menu Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedMenu,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'आजचा मेनू (खाद्यान्न प्रकार)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: _menuOptions
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMenu = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Auto Calculation Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calculate, size: 16, color: Colors.orange),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'शासकीय मापदंडानुसार लागणारे साहित्य:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('• एकूण लाभार्थी: ${pCount + upCount} विद्यार्थी', style: const TextStyle(fontSize: 12)),
                          Text('• तांदूळ: ${calcRice.toStringAsFixed(2)} किलो (प्राथमिक १००g + उ.प्रा. १५०g)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('• कडधान्य/डाळी: ${calcPulses.toStringAsFixed(2)} किलो (प्राथमिक २०g + उ.प्रा. ३०g)',
                              style: const TextStyle(fontSize: 12)),
                          Text('• तेल: ${calcOil.toStringAsFixed(3)} लिटर / किलो', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tasting by
                    TextField(
                      controller: _tastedByCtrl,
                      decoration: const InputDecoration(
                        labelText: 'चव तपासणी अधिकारी / व्यक्तीचे नाव',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Taste Quality Dropdown
                    DropdownButtonFormField<String>(
                      value: _tasteQuality,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'चव व अन्नाचा दर्जा',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: ['उत्कृष्ट व पौष्टिक', 'उत्तम', 'समाधानकारक', 'सुधारणा आवश्यक']
                          .map((q) => DropdownMenuItem(value: q, child: Text(q, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _tasteQuality = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Remark
                    TextField(
                      controller: _remarkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'शेरा / विशेष नोंद',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text('नोंद जतन करा', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final model = MdmDailyAttendanceModel(
                            id: 'mdm_${_selectedDate.millisecondsSinceEpoch}',
                            date: _selectedDate,
                            primaryBeneficiaries: pCount,
                            upperPrimaryBeneficiaries: upCount,
                            menuName: _selectedMenu,
                            riceUsedKg: double.parse(calcRice.toStringAsFixed(2)),
                            pulsesUsedKg: double.parse(calcPulses.toStringAsFixed(2)),
                            oilUsedKg: double.parse(calcOil.toStringAsFixed(3)),
                            tastedBy: _tastedByCtrl.text,
                            tasteQuality: _tasteQuality,
                            remark: _remarkCtrl.text,
                          );
                          await state.addMdmDailyAttendance(model);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('दैनिक पोषण आहार नोंद यशस्वीरित्या जतन केली!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right Column: Attendance History Table
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'दैनिक पोषण आहार नोंदवही (मागील नोंदी)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('एकूण नोंदी: ${state.mdmAttendanceList.length}'),
                          backgroundColor: Colors.blue.shade50,
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Expanded(
                      child: state.mdmAttendanceList.isEmpty
                          ? const Center(child: Text('अद्याप कोणत्याही नोंदी नाहीत.'))
                          : ListView.separated(
                              itemCount: state.mdmAttendanceList.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = state.mdmAttendanceList[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.amber.shade100,
                                    child: const Icon(Icons.lunch_dining, color: Colors.orange),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        DateFormat('dd-MM-yyyy').format(item.date),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.menuName,
                                          style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    'लाभार्थी: ${item.totalBeneficiaries} (इ.१-५: ${item.primaryBeneficiaries}, इ.६-८: ${item.upperPrimaryBeneficiaries}) | तांदूळ: ${item.riceUsedKg} kg | चव तपासणी: ${item.tastedBy}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    tooltip: 'हटवा',
                                    onPressed: () async {
                                      await state.deleteMdmDailyAttendance(item.id);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: धान्य व किराणा साठा नोंदवही
  // ==========================================
  Widget _buildStockRegisterTab(BuildContext context, AppStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text(
                    'शालेय पोषण आहार धान्य व किराणा साठा नोंदवही (Stock Register)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('नवीन आवक नोंदवा'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showAddStockDialog(context, state),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
                      columns: const [
                        DataColumn(label: Text('अ.क्र.', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('वस्तूचे नाव', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('एकक', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('मागील शिल्लक (Opening)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('प्राप्त आवक (Received)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('एकूण खर्च (Consumed)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('सद्य शिल्लक (Balance)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('चलन / पावती क्र.', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: state.mdmStockList.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final item = entry.value;
                        final isLowStock = item.balanceStock <= 5.0;
                        return DataRow(
                          color: isLowStock ? WidgetStateProperty.all(Colors.red.shade50) : null,
                          cells: [
                            DataCell(Text('$idx')),
                            DataCell(Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(item.unit)),
                            DataCell(Text('${item.openingStock.toStringAsFixed(2)} ${item.unit}')),
                            DataCell(Text('${item.receivedStock.toStringAsFixed(2)} ${item.unit}',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                            DataCell(Text('${item.consumedStock.toStringAsFixed(2)} ${item.unit}',
                                style: const TextStyle(color: Colors.red))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isLowStock ? Colors.red.shade100 : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${item.balanceStock.toStringAsFixed(2)} ${item.unit}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isLowStock ? Colors.red.shade900 : Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(item.batchOrChallanNo.isNotEmpty ? item.batchOrChallanNo : '-')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStockDialog(BuildContext context, AppStateProvider state) {
    String selectedItem = 'तांदूळ (शासकीय पुरवठा)';
    final receivedCtrl = TextEditingController(text: '50');
    final challanCtrl = TextEditingController(text: 'CH-2025/');
    String unit = 'किलो';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_shopping_cart, color: Colors.teal),
              SizedBox(width: 8),
              Text('नवीन आवक साठा नोंदवा'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedItem,
                  decoration: const InputDecoration(labelText: 'वस्तूचे नाव', border: OutlineInputBorder()),
                  items: [
                    'तांदूळ (शासकीय पुरवठा)',
                    'मूग डाळ',
                    'मटकी / चवळी',
                    'खाद्यतेल (फोर्टिफाइड)',
                    'आयोडिनयुक्त मीठ व मसाले',
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedItem = val;
                        unit = val.contains('तेल') ? 'लिटर' : 'किलो';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: receivedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'प्राप्त प्रमाण ($unit)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: challanCtrl,
                  decoration: const InputDecoration(
                    labelText: 'चलन / पावती क्र.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () async {
                final qty = double.tryParse(receivedCtrl.text) ?? 0.0;
                final existing = state.mdmStockList.firstWhere(
                  (s) => s.itemName == selectedItem,
                  orElse: () => MdmStockItemModel(
                    id: 'stk_${DateTime.now().millisecondsSinceEpoch}',
                    itemName: selectedItem,
                    unit: unit,
                    openingStock: 0,
                    receivedStock: 0,
                    consumedStock: 0,
                  ),
                );

                final updated = MdmStockItemModel(
                  id: existing.id,
                  itemName: existing.itemName,
                  unit: existing.unit,
                  openingStock: existing.openingStock,
                  receivedStock: existing.receivedStock + qty,
                  consumedStock: existing.consumedStock,
                  batchOrChallanNo: challanCtrl.text,
                );

                await state.addOrUpdateMdmStock(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('साठा जोडा'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: मासिक बिल व ताळेबंद (Cooking Cost Bill)
  // ==========================================
  Widget _buildMonthlyBillsTab(BuildContext context, AppStateProvider state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top action bar
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.calculate, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text(
                    'शालेय पोषण आहार मासिक बिल व ताळेबंद (Monthly MDM Bills)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.post_add),
                    label: const Text('चालू महिन्याचे नवीन बिल तयार करा'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _generateNewBillModal(context, state),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bills List
          Expanded(
            child: ListView.builder(
              itemCount: state.mdmBillsList.length,
              itemBuilder: (context, index) {
                final bill = state.mdmBillsList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text('${bill.month}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'माहे: ${bill.monthNameMarathi} ${bill.year}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'कामाचे दिवस: ${bill.workingDays} | स्वयंपाकी: ${bill.cookName}',
                                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: bill.status == 'मंजूर' ? Colors.green.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'स्थिती: ${bill.status}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: bill.status == 'मंजूर' ? Colors.green.shade900 : Colors.orange.shade900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.print, size: 16),
                              label: const Text('अधिकृत बिल प्रिंट'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _printMdmBill(state, bill),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildBillStatCard(
                              'इ. १ ते ५ खर्च भत्ता',
                              '${bill.totalPrimaryStudentDays} पट-दिवस × ₹${bill.primaryCookingCostRate}',
                              '₹${bill.primaryCookingCostAmount.toStringAsFixed(2)}',
                              Colors.blue,
                            ),
                            _buildBillStatCard(
                              'इ. ६ ते ८ खर्च भत्ता',
                              '${bill.totalUpperPrimaryStudentDays} पट-दिवस × ₹${bill.upperPrimaryCookingCostRate}',
                              '₹${bill.upperPrimaryCookingCostAmount.toStringAsFixed(2)}',
                              Colors.teal,
                            ),
                            _buildBillStatCard(
                              'स्वयंपाकी मानधन',
                              bill.cookName,
                              '₹${bill.cookHonorarium.toStringAsFixed(2)}',
                              Colors.orange,
                            ),
                            _buildBillStatCard(
                              'एकूण देय रक्कम (Total Bill)',
                              'इंधन भाजीपाला + मानधन',
                              '₹${bill.totalBillAmount.toStringAsFixed(2)}',
                              Colors.purple,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillStatCard(String title, String subtitle, String amount, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(amount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _generateNewBillModal(BuildContext context, AppStateProvider state) {
    int month = DateTime.now().month;
    int year = DateTime.now().year;
    final workingDaysCtrl = TextEditingController(text: '24');
    final pDaysCtrl = TextEditingController(text: '1080');
    final upDaysCtrl = TextEditingController(text: '912');
    final pRateCtrl = TextEditingController(text: '5.45');
    final upRateCtrl = TextEditingController(text: '8.17');
    final cookHonorariumCtrl = TextEditingController(text: '2500');
    final cookNameCtrl = TextEditingController(text: 'सौ. लताबाई शिंदे (स्वयंपाकी)');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt, color: AppColors.primary),
            SizedBox(width: 8),
            Text('मासिक पोषण आहार बिल तयार करा'),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: month,
                        decoration: const InputDecoration(labelText: 'महिना', border: OutlineInputBorder()),
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(value: m, child: Text('महिना $m')))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) month = val;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: workingDaysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'शासकीय कामकाजाचे दिवस', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: pDaysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'इ. १-५ एकूण पट-दिवस', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: pRateCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'प्राथमिक दर (रु.)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: upDaysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'इ. ६-८ एकूण पट-दिवस', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: upRateCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'उच्च प्रा. दर (रु.)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cookHonorariumCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'स्वयंपाकी मानधन (रु.)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: cookNameCtrl,
                        decoration: const InputDecoration(labelText: 'स्वयंपाकी / मदतनीस नाव', border: OutlineInputBorder()),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final bill = MdmMonthlyBillModel(
                id: 'bill_${month}_$year',
                month: month,
                year: year,
                workingDays: int.tryParse(workingDaysCtrl.text) ?? 24,
                totalPrimaryStudentDays: int.tryParse(pDaysCtrl.text) ?? 0,
                totalUpperPrimaryStudentDays: int.tryParse(upDaysCtrl.text) ?? 0,
                primaryCookingCostRate: double.tryParse(pRateCtrl.text) ?? 5.45,
                upperPrimaryCookingCostRate: double.tryParse(upRateCtrl.text) ?? 8.17,
                cookHonorarium: double.tryParse(cookHonorariumCtrl.text) ?? 2500.0,
                cookName: cookNameCtrl.text,
                status: 'तयार',
                generatedDate: DateTime.now(),
              );
              await state.saveMdmMonthlyBill(bill);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('बिल तयार करा'),
          ),
        ],
      ),
    );
  }

  // PDF / Print Generation for Official ZP MDM Bill
  Future<void> _printMdmBill(AppStateProvider state, MdmMonthlyBillModel bill) async {
    final pdf = pw.Document();
    final school = state.school;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('महाराष्ट्र शासन - शालेय शिक्षण व क्रीडा विभाग',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('प्रधानमंत्री पोषण शक्ती निर्माण योजना (शालेय पोषण आहार)',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${school.schoolName}, ता. ${school.blockTaluka}, जि. ${school.district}',
                        style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('U-DISE कोड: ${school.udiseCode}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Divider(thickness: 1),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('मासिक इंधन व भाजीपाला खर्च भत्ता (Cooking Cost) व मानधन बिल',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Text('माहे: ${bill.monthNameMarathi} ${bill.year} | कामकाजाचे दिवस: ${bill.workingDays} दिवस',
                  style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 14),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('तपशील', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('पट-दिवस संख्या', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('शासकीय दर', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('एकूण रक्कम (रु.)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('प्राथमिक विभाग (इ. १ ते ५) खर्च भत्ता')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${bill.totalPrimaryStudentDays}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('रु. ${bill.primaryCookingCostRate}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('रु. ${bill.primaryCookingCostAmount.toStringAsFixed(2)}')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('उच्च प्राथमिक विभाग (इ. ६ ते ८) खर्च भत्ता')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${bill.totalUpperPrimaryStudentDays}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('रु. ${bill.upperPrimaryCookingCostRate}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('रु. ${bill.upperPrimaryCookingCostAmount.toStringAsFixed(2)}')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('स्वयंपाकी / मदतनीस मानधन (${bill.cookName})')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('१ व्यक्ती')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('रु. ${bill.cookHonorarium}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('रु. ${bill.cookHonorarium.toStringAsFixed(2)}')),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('एकूण देय रक्कम (Total Bill Amount)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('-')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('-')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('रु. ${bill.totalBillAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('प्रमाणपत्र: प्रमाणित करण्यात येते की वरील कालावधीत सर्व पात्र लाभार्थी विद्यार्थ्यांना पोषण आहाराचे नियमित वाटप करण्यात आले असून साठा नोंदवही व खर्चाचा हिशोब अचूक ठेवण्यात आलेला आहे.',
                  style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800)),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('स्वाक्षरी स्वयंपाकी / मदतनीस', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('(${bill.cookName})', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('अध्यक्ष, शा.पो.आ. समिती', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('(शाळा व्यवस्थापन समिती)', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('मुख्याध्यापक स्वाक्षरी व शिक्का', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 30),
                      pw.Text('${school.headmasterPrefix} ${school.headmasterName}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'MDM_Bill_${bill.month}_${bill.year}.pdf',
    );
  }
}
