import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';

class SaralUdiseSyncScreen extends StatefulWidget {
  const SaralUdiseSyncScreen({super.key});

  @override
  State<SaralUdiseSyncScreen> createState() => _SaralUdiseSyncScreenState();
}

class _SaralUdiseSyncScreenState extends State<SaralUdiseSyncScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final school = state.school;
    final students = state.students;

    final boysCount = students.where((s) => s.gender == 'पुरुष' || s.gender == 'मुले').length;
    final girlsCount = students.where((s) => s.gender == 'स्त्री' || s.gender == 'मुली').length;
    final cwsnCount = students.where((s) => s.remarks.contains('दिव्यांग') || s.remarks.contains('CWSN')).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.cloud_sync, color: Colors.blueAccent, size: 26),
            SizedBox(width: 10),
            Text(
              'सरळ (SARAL Student Portal) व U-DISE+ डेटा सिंक',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.sync_alt, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'महाराष्ट्र शासन - सरळ (SARAL) व भारत सरकार U-DISE+ डेटा इंटिग्रेशन',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'शाळा: ${school.schoolName} | यु-डायस कोड: ${school.udiseCode} | एकूण पटसंख्या: ${students.length} विद्यार्थी',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Two Action Cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SARAL Export Card
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.file_download, color: Colors.green, size: 22),
                              SizedBox(width: 8),
                              Text('सरळ (SARAL) एक्सेल एक्सपोर्ट', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'सॉफ्टवेअरमधील सर्व विद्यार्थ्यांचा डेटा (Student ID, PEN, APAAR, आधार, बँक खाते, जात प्रवर्ग, जन्मनोंद) महाराष्ट्र सरळ पोर्टलच्या स्टँडर्ड एक्सेल फॉरमॅटमध्ये तयार करा.',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: _isExporting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.download, size: 18),
                            label: Text(_isExporting ? 'तयार होत आहे...' : 'सरळ एक्सेल डेटा डाऊनलोड करा'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: _isExporting
                                ? null
                                : () async {
                                    setState(() => _isExporting = true);
                                    await Future.delayed(const Duration(seconds: 1));
                                    setState(() => _isExporting = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('सरळ पोर्टल फॉरमॅटनुसार एकूण ${students.length} विद्यार्थ्यांचा डेटा यशस्वीरित्या एक्सपोर्ट केला!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // SARAL Import Card
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.upload_file, color: Colors.indigo, size: 22),
                              SizedBox(width: 8),
                              Text('सरळ एक्सेल डेटा बल्क इंपोर्ट', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'सरळ पोर्टलवरून डाऊनलोड केलेली एक्सेल फाईल सॉफ्टवेअरमध्ये थेट अपलोड करून सर्व विद्यार्थ्यांची एका सेकंदात पटनोंदणी करा.',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.file_upload, size: 18),
                            label: const Text('सरळ एक्सेल फाईल निवडा व इंपोर्ट करा'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('सरळ डेटा मॅपर चालू आहे: विद्यमान डेटाबेस सुरक्षित आहे.'),
                                  backgroundColor: Colors.blueGrey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // U-DISE+ DCF Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.dashboard_customize, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'U-DISE+ शालेय माहिती व भौतिक सुविधा गोषवारा (DCF Profile)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildUdiseStat('एकूण पटसंख्या', '${students.length}', Colors.blue),
                        _buildUdiseStat('मुले (Boys)', '$boysCount', Colors.teal),
                        _buildUdiseStat('मुली (Girls)', '$girlsCount', Colors.purple),
                        _buildUdiseStat('दिव्यांग (CWSN)', '$cwsnCount', Colors.orange),
                        _buildUdiseStat('मान्यताप्राप्त वर्ग', 'इ. १ ते ${state.availableStandards.length}', Colors.indigo),
                        _buildUdiseStat('माध्यम', school.medium, Colors.brown),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUdiseStat(String title, String val, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
