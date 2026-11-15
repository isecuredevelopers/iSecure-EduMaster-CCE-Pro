import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/library_model.dart';
import '../../providers/app_state_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final books = state.libraryBooks.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b.bookTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.accessionNumber.toString().contains(_searchQuery);
    }).toList();

    final int totalBooks = state.libraryBooks.length;
    final int issuedBooks = state.libraryBooks.where((b) => b.isIssued).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_library, color: Colors.teal, size: 26),
            SizedBox(width: 10),
            Text(
              'शालेय ग्रंथालय नोंदवही व पुस्तक देवाणघेवाण (Library Register)',
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
            // Top Stats & Action bar
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
                    SizedBox(
                      width: 250,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'पुस्तक, लेखक किंवा ॲक्सेशन नं. शोधा...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text('पुस्तके: $totalBooks'),
                          backgroundColor: Colors.blue.shade50,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('वाटप: $issuedBooks'),
                          backgroundColor: Colors.orange.shade50,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('उपलब्ध: ${totalBooks - issuedBooks}'),
                          backgroundColor: Colors.green.shade50,
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('नवीन पुस्तक नोंदवा'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      onPressed: () => _showAddBookDialog(context, state),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Books List
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: books.isEmpty
                      ? const Center(child: Text('कोणतीही पुस्तके उपलब्ध नाहीत.'))
                      : ListView.separated(
                          itemCount: books.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final b = books[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: b.isIssued ? Colors.orange.shade100 : Colors.teal.shade50,
                                child: Text('${b.accessionNumber}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: b.isIssued ? Colors.orange.shade900 : Colors.teal.shade900,
                                    )),
                              ),
                              title: Row(
                                children: [
                                  Text(b.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                                    child: Text(b.category, style: const TextStyle(fontSize: 10)),
                                  ),
                                ],
                              ),
                              subtitle: Text('लेखक: ${b.author} | किंमत: ₹${b.price} | पृष्ठे: ${b.totalPages} ${b.isIssued ? " | वाटप: ${b.currentBorrowerName} (दिनांक: ${DateFormat("dd-MM-yyyy").format(b.issueDate!)})" : ""}'),
                              trailing: ElevatedButton.icon(
                                icon: Icon(b.isIssued ? Icons.assignment_return : Icons.menu_book, size: 16),
                                label: Text(b.isIssued ? 'जमा करून घ्या' : 'पुस्तक वाटप करा'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: b.isIssued ? Colors.orange.shade700 : Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  if (b.isIssued) {
                                    state.toggleBookIssue(b.id, '', false);
                                  } else {
                                    _showIssueBookDialog(context, state, b);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBookDialog(BuildContext context, AppStateProvider state) {
    int accNo = state.libraryBooks.length + 101;
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    String category = 'बालसाहित्य';
    final priceCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('नवीन पुस्तक नोंद (Acc No: $accNo)'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'पुस्तकाचे नाव', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: authorCtrl, decoration: const InputDecoration(labelText: 'लेखक', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'वर्गवारी', border: OutlineInputBorder()),
                items: ['बालसाहित्य', 'कथा/कादंबरी', 'चरित्र', 'विज्ञान/ज्ञान', 'कविता संग्रह']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) category = val;
                },
              ),
              const SizedBox(height: 10),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'किंमत (रु.)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करा')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              final b = LibraryBookModel(
                id: 'lib_${DateTime.now().millisecondsSinceEpoch}',
                accessionNumber: accNo,
                bookTitle: titleCtrl.text,
                author: authorCtrl.text,
                category: category,
                price: double.tryParse(priceCtrl.text) ?? 100.0,
              );
              await state.addOrUpdateLibraryBook(b);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('नोंदवा'),
          ),
        ],
      ),
    );
  }

  void _showIssueBookDialog(BuildContext context, AppStateProvider state, LibraryBookModel book) {
    final borrowerCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${book.bookTitle} - पुस्तक वाटप'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('पुस्तकाचे वाटप करण्यासाठी विद्यार्थी अथवा शिक्षकाचे नाव टाका:'),
              const SizedBox(height: 12),
              TextField(
                controller: borrowerCtrl,
                decoration: const InputDecoration(
                  labelText: 'विद्यार्थी / शिक्षक नाव (उदा. आरव पाटील - इ. २ री)',
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
              if (borrowerCtrl.text.isEmpty) return;
              await state.toggleBookIssue(book.id, borrowerCtrl.text, true);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('वाटप करा'),
          ),
        ],
      ),
    );
  }
}
