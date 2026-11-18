import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class WindowsPageNavBar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final bool isHome;
  final String currentTitle;
  final String? previousTitle;
  final String? nextTitle;
  final String homeLabel;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onHome;

  const WindowsPageNavBar({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    required this.isHome,
    required this.currentTitle,
    this.previousTitle,
    this.nextTitle,
    required this.homeLabel,
    required this.onBack,
    required this.onForward,
    required this.onHome,
  });

  static String titleForIndex(int index, {bool isStudent = false}) {
    if (isStudent) {
      switch (index) {
        case 5:
          return 'माझी उपस्थिती (Attendance)';
        case 6:
          return 'प्रगती पुस्तक (Report Card)';
        case 25:
          return 'डिजिटल ओळखपत्र (ID Card)';
        case 27:
          return 'ई-पुस्तके व अभ्यासक्रम (E-Books 📚)';
        case 15:
        default:
          return 'विद्यार्थी व पालक पोर्टल (Portal)';
      }
    }

    switch (index) {
      case 0:
        return 'डॅशबोर्ड (Dashboard)';
      case 1:
        return 'सॉफ्टवेअर सेटिंग्ज (School Settings)';
      case 2:
        return 'विद्यार्थी यादी (Students)';
      case 3:
        return 'आकारिक-संकलित गुणनोंद (Marks)';
      case 4:
        return 'वर्णनात्मक नोंदी (Remarks)';
      case 5:
        return 'माहेवार उपस्थिती (Attendance)';
      case 6:
        return 'प्रगती पुस्तक (Progress Card)';
      case 7:
        return 'निकाल पत्रक (Result Gazette)';
      case 8:
        return 'ओळखपत्रे / बोनाफाईड (Certificates)';
      case 9:
        return 'शाळा सोडल्याचा दाखला (L.C.)';
      case 10:
        return 'रजिस्टर नं. १ उतारा (GR Extract)';
      case 11:
        return 'वर्ष व वर्गनिहाय नोंद (Yearly Archive)';
      case 12:
        return 'सांख्यिकी तक्ता (Statistics)';
      case 13:
        return 'वर्गोन्नती (Promotion)';
      case 14:
        return 'शिक्षक वाटप (Teacher Allocation)';
      case 15:
        return 'विद्यार्थी-पालक ॲप (Portal)';
      case 16:
        return 'स्वाध्याय व परीक्षा (HW & Exams)';
      case 17:
        return 'शालेय पोषण आहार (PM POSHAN)';
      case 18:
        return 'मोफत पाठ्यपुस्तके व गणवेश (समग्र शिक्षा)';
      case 19:
        return 'मासिक उपस्थिती गोषवारा (Form A/B)';
      case 20:
        return 'शाळा व्यवस्थापन समिती (SMC ठराव वही)';
      case 21:
        return 'शालेय मृतसाठा नोंदवही (Dead Stock)';
      case 22:
        return 'ग्रंथालय नोंदवही (Library Register)';
      case 23:
        return 'शिक्षक रजा व हालचाल वही (Service)';
      case 24:
        return 'आवक-जावक व आरोग्य (RBSK)';
      case 25:
        return 'डिजिटल ओळखपत्रे (ID Cards)';
      case 26:
        return 'सरळ व U-DISE+ सिंक (SARAL Sync)';
      case 27:
        return 'बालभारती ई-पुस्तके व अभ्यासक्रम (E-Books 📚)';
      default:
        return 'डॅशबोर्ड (Dashboard)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final backTooltip = canGoBack
        ? (previousTitle != null
              ? 'मागे जा: $previousTitle (Alt + ←)'
              : 'मागे जा (Alt + ←)')
        : 'आपण मुख्य पानावर आहात';

    final forwardTooltip = canGoForward
        ? (nextTitle != null
              ? 'पुढे जा: $nextTitle (Alt + →)'
              : 'पुढे जा (Alt + →)')
        : 'पुढील पान उपलब्ध नाही';

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Tooltip(
            message: backTooltip,
            child: Material(
              color: canGoBack
                  ? const Color(0xFFEEF2FF)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                key: const Key('windows_back_button'),
                onTap: canGoBack ? onBack : null,
                borderRadius: BorderRadius.circular(8),
                hoverColor: const Color(0xFFE0E7FF),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: canGoBack
                          ? const Color(0xFFC7D2FE)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 17,
                        color: canGoBack
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'मागे जा',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: canGoBack
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: forwardTooltip,
            child: Material(
              color: canGoForward
                  ? const Color(0xFFF8FAFC)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                key: const Key('windows_forward_button'),
                onTap: canGoForward ? onForward : null,
                borderRadius: BorderRadius.circular(8),
                hoverColor: const Color(0xFFE2E8F0),
                child: Container(
                  width: 32,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: canGoForward
                          ? AppColors.border
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: canGoForward
                        ? AppColors.textPrimary
                        : AppColors.borderDark,
                  ),
                ),
              ),
            ),
          ),
          if (!isHome) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: '$homeLabel वर जा',
              child: Material(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  key: const Key('windows_home_button'),
                  onTap: onHome,
                  borderRadius: BorderRadius.circular(8),
                  hoverColor: const Color(0xFFE2E8F0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          homeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: AppColors.border),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                if (canGoBack && previousTitle != null) ...[
                  Flexible(
                    child: Text(
                      previousTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                Flexible(
                  flex: 2,
                  child: Text(
                    currentTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
