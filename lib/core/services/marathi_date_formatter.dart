class MarathiDateFormatter {
  static const List<String> days = [
    '',
    'एक',
    'दोन',
    'तीन',
    'चार',
    'पाच',
    'सहा',
    'सात',
    'आठ',
    'नऊ',
    'दहा',
    'अकरा',
    'बारा',
    'तेरा',
    'चौदा',
    'पंधरा',
    'सोळा',
    'सतरा',
    'अठरा',
    'एकोणीस',
    'वीस',
    'एकवीस',
    'बावीस',
    'तेवीस',
    'चोवीस',
    'पंचवीस',
    'सव्वीस',
    'सत्तावीस',
    'अठ्ठावीस',
    'एकोणतीस',
    'तीस',
    'एकतीस',
  ];

  static const List<String> months = [
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
    'डिसेंबर',
  ];

  static const Map<int, String> numbers1to99 = {
    1: 'एक',
    2: 'दोन',
    3: 'तीन',
    4: 'चार',
    5: 'पाच',
    6: 'सहा',
    7: 'सात',
    8: 'आठ',
    9: 'नऊ',
    10: 'दहा',
    11: 'अकरा',
    12: 'बारा',
    13: 'तेरा',
    14: 'चौदा',
    15: 'पंधरा',
    16: 'सोळा',
    17: 'सतरा',
    18: 'अठरा',
    19: 'एकोणीस',
    20: 'वीस',
    21: 'एकवीस',
    22: 'बावीस',
    23: 'तेवीस',
    24: 'चोवीस',
    25: 'पंचवीस',
    26: 'सव्वीस',
    27: 'सत्तावीस',
    28: 'अठ्ठावीस',
    29: 'एकोणतीस',
    30: 'तीस',
    31: 'एकतीस',
    32: 'बत्तीस',
    33: 'तेहतीस',
    34: 'चौतीस',
    35: 'पस्तीस',
    36: 'छत्तीस',
    37: 'सदतीस',
    38: 'अडतीस',
    39: 'एकेचाळीस',
    40: 'चाळीस',
    41: 'एक्केचाळीस',
    42: 'बेचाळीस',
    43: 'त्रेचाळीस',
    44: 'चव्वेचाळीस',
    45: 'पंचेचाळीस',
    46: 'शेहेचाळीस',
    47: 'सत्तेचाळीस',
    48: 'अठ्ठेचाळीस',
    49: 'एकोणपन्नास',
    50: 'पन्नास',
    51: 'एक्कावन्न',
    52: 'बावन्न',
    53: 'त्रेपन्न',
    54: 'चौपन्न',
    55: 'पंचावन्न',
    56: 'छप्पन्न',
    57: 'सत्तावन्न',
    58: 'अठ्ठावन्न',
    59: 'एकोणसाठ',
    60: 'साठ',
    61: 'एकसष्ठ',
    62: 'बासष्ठ',
    63: 'त्रेसष्ठ',
    64: 'चौसष्ठ',
    65: 'पासष्ठ',
    66: 'सहासष्ठ',
    67: 'सदुसष्ठ',
    68: 'अडुसष्ठ',
    69: 'एकोणसत्तर',
    70: 'सत्तर',
    71: 'एकाहत्तर',
    72: 'बाहत्तर',
    73: 'त्र्याहत्तर',
    74: 'चौर्‍याहत्तर',
    75: 'पंच्याहत्तर',
    76: 'शहात्तर',
    77: 'सत्त्याहत्तर',
    78: 'अठ्ठ्याहत्तर',
    79: 'एकोणऐंशी',
    80: 'ऐंशी',
    81: 'एक्याऐंशी',
    82: 'ब्याऐंशी',
    83: 'त्र्याऐंशी',
    84: 'चौऱ्याऐंशी',
    85: 'पंच्याऐंशी',
    86: 'शहाऐंशी',
    87: 'सत्त्याऐंशी',
    88: 'अठ्ठ्याऐंशी',
    89: 'एकोणनव्वद',
    90: 'नव्वद',
    91: 'एक्याण्णव',
    92: 'ब्याण्णव',
    93: 'त्र्याण्णव',
    94: 'चौऱ्याण्णव',
    95: 'पंच्याण्णव',
    96: 'शहाण्णव',
    97: 'सत्त्याण्णव',
    98: 'अठ्ठ्याण्णव',
    99: 'नव्व्याण्णव',
  };

  static String formatYear(int year) {
    if (year >= 2000) {
      final lastTwo = year % 100;
      if (lastTwo == 0) return 'दोन हजार';
      final word = numbers1to99[lastTwo] ?? '$lastTwo';
      return 'दोन हजार $word';
    } else if (year >= 1900) {
      final lastTwo = year % 100;
      if (lastTwo == 0) return 'एकोणीसशे';
      final word = numbers1to99[lastTwo] ?? '$lastTwo';
      return 'एकोणीसशे $word';
    }
    return year.toString();
  }

  static String toMarathiWords(DateTime date) {
    final d = date.day;
    final m = date.month;
    final y = date.year;

    final dayWord = (d >= 1 && d < days.length) ? days[d] : '$d';
    final monthWord = (m >= 1 && m < months.length) ? months[m] : '$m';
    final yearWord = formatYear(y);

    return '$dayWord $monthWord $yearWord';
  }

  static String classToMarathi(int std) {
    switch (std) {
      case 1:
        return '1 ली';
      case 2:
        return '2 री';
      case 3:
        return '3 री';
      case 4:
        return '4 थी';
      case 5:
        return '5 वी';
      case 6:
        return '6 वी';
      case 7:
        return '7 वी';
      case 8:
        return '8 वी';
      default:
        return '$std वी';
    }
  }

  static int marathiClassToInt(String classStr) {
    final clean = classStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 1;
  }

  static String toMarathiNumber(dynamic number) {
    if (number == null) return '';
    final str = number.toString();
    const eng = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const mar = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    String result = str;
    for (int i = 0; i < eng.length; i++) {
      result = result.replaceAll(eng[i], mar[i]);
    }
    return result;
  }

  static String formatMarathiDate(DateTime? date) {
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return toMarathiNumber('$d / $m / $y');
  }
}

