import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1E3A8A); // Classic Navy / Indigo
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF172554);

  static const Color accent = Color(0xFFF59E0B); // Amber / Gold
  static const Color accentDark = Color(0xFFD97706);

  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF14B8A6);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sidebarBg = Color(0xFF0F172A); // Dark Slate Sidebar
  static const Color sidebarActive = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFFCBD5E1);

  // Status & Grade Colors
  static const Color gradeA1 = Color(0xFF10B981); // Emerald
  static const Color gradeA2 = Color(0xFF059669); // Forest
  static const Color gradeB1 = Color(0xFF0284C7); // Sky Blue
  static const Color gradeB2 = Color(0xFF2563EB); // Royal Blue
  static const Color gradeC1 = Color(0xFFD97706); // Amber
  static const Color gradeC2 = Color(0xFFEA580C); // Orange
  static const Color gradeD = Color(0xFFDC2626); // Crimson
  static const Color gradeE = Color(0xFF991B1B); // Dark Red

  static Color getGradeColor(String? grade) {
    if (grade == null) return textMuted;
    final g = grade.trim();
    if (g.contains('अ-1') || g.contains('A1') || g.contains('A-1')) return gradeA1;
    if (g.contains('अ-2') || g.contains('A2') || g.contains('A-2')) return gradeA2;
    if (g.contains('ब-1') || g.contains('B1') || g.contains('B-1')) return gradeB1;
    if (g.contains('ब-2') || g.contains('B2') || g.contains('B-2')) return gradeB2;
    if (g.contains('क-1') || g.contains('C1') || g.contains('C-1')) return gradeC1;
    if (g.contains('क-2') || g.contains('C2') || g.contains('C-2')) return gradeC2;
    if (g.contains('ड') || g.contains('D')) return gradeD;
    if (g.contains('ई') || g.contains('E')) return gradeE;
    return primaryLight;
  }
}
