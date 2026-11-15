// शालेय ग्रंथालय नोंदवही (Library Accession & Issue Register)

class LibraryBookModel {
  final String id;
  final int accessionNumber; // ॲक्सेशन नोंद क्रमांक
  final String bookTitle; // पुस्तकाचे नाव
  final String author; // लेखक
  final String publisher; // प्रकाशक
  final String category; // 'बालसाहित्य', 'कथा/कादंबरी', 'चरित्र', 'विज्ञान/ज्ञान', 'कविता संग्रह'
  final double price; // किंमत
  final int totalPages; // पृष्ठे
  final bool isIssued; // सध्या कोणाला दिलेले आहे का
  final String currentBorrowerName; // घेतलेल्या विद्यार्थ्याचे/शिक्षकाचे नाव
  final DateTime? issueDate; // वाटप तारीख
  final DateTime? expectedReturnDate; // परत करण्याची तारीख

  LibraryBookModel({
    required this.id,
    required this.accessionNumber,
    required this.bookTitle,
    required this.author,
    this.publisher = '',
    this.category = 'बालसाहित्य',
    this.price = 0.0,
    this.totalPages = 0,
    this.isIssued = false,
    this.currentBorrowerName = '',
    this.issueDate,
    this.expectedReturnDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'accessionNumber': accessionNumber,
        'bookTitle': bookTitle,
        'author': author,
        'publisher': publisher,
        'category': category,
        'price': price,
        'totalPages': totalPages,
        'isIssued': isIssued,
        'currentBorrowerName': currentBorrowerName,
        'issueDate': issueDate?.toIso8601String(),
        'expectedReturnDate': expectedReturnDate?.toIso8601String(),
      };

  factory LibraryBookModel.fromJson(Map<String, dynamic> json) =>
      LibraryBookModel(
        id: json['id'] ?? '',
        accessionNumber: (json['accessionNumber'] as num?)?.toInt() ?? 1,
        bookTitle: json['bookTitle'] ?? '',
        author: json['author'] ?? '',
        publisher: json['publisher'] ?? '',
        category: json['category'] ?? 'बालसाहित्य',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
        isIssued: json['isIssued'] ?? false,
        currentBorrowerName: json['currentBorrowerName'] ?? '',
        issueDate:
            json['issueDate'] != null ? DateTime.parse(json['issueDate']) : null,
        expectedReturnDate: json['expectedReturnDate'] != null
            ? DateTime.parse(json['expectedReturnDate'])
            : null,
      );
}
