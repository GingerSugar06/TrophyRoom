/// **Görünüm** — koyu zemin, altın vurgu, zümrüt "açık" durumu.
///
/// Aynı anda yüzlerce satır görünebildiği için hiyerarşi renkle değil
/// açıklıkla kurulur: kilitli satır soluk, açık satır tam opak ve zümrüt
/// işaretli; bekleyen değişiklik altın bir çerçeveyle ayrılır.
library;

import 'package:flutter/material.dart';

abstract final class TrophyColors {
  static const bg = Color(0xFF0B0E13);
  static const bar = Color(0xFF10141B);
  static const card = Color(0xFF151A23);
  static const cardHover = Color(0xFF1B212C);
  static const line = Color(0xFF212835);

  static const tx = Color(0xFFE9EEF5);
  static const tx2 = Color(0xFF98A4B6);
  static const tx3 = Color(0xFF5C6A7E);

  /// Birincil eylem, marka rengi.
  static const gold = Color(0xFFF5B83D);

  /// Açık (kazanılmış) başarım.
  static const accent = Color(0xFF34D399);

  /// Bekleyen değişiklik.
  static const pending = Color(0xFFF5B83D);

  static const danger = Color(0xFFF87171);
}

const kFont = 'Poppins';

ThemeData trophyTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  OutlineInputBorder border(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c, width: w));
  return base.copyWith(
    scaffoldBackgroundColor: TrophyColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: TrophyColors.gold,
      onPrimary: Colors.black,
      surface: TrophyColors.card,
      secondary: TrophyColors.accent,
    ),
    dividerColor: TrophyColors.line,
    textTheme: base.textTheme.apply(bodyColor: TrophyColors.tx, displayColor: TrophyColors.tx, fontFamily: kFont),
    iconTheme: const IconThemeData(color: TrophyColors.tx2),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TrophyColors.card,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border(TrophyColors.line),
      enabledBorder: border(TrophyColors.line),
      focusedBorder: border(TrophyColors.gold, 1.5),
      hintStyle: const TextStyle(color: TrophyColors.tx3, fontSize: 13.5, fontFamily: kFont),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: TrophyColors.gold,
        foregroundColor: Colors.black,
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: kFont, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: TrophyColors.tx2,
        textStyle: const TextStyle(fontFamily: kFont, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: TrophyColors.bar,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), side: const BorderSide(color: TrophyColors.line)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
          color: TrophyColors.cardHover,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TrophyColors.line)),
      textStyle: const TextStyle(fontFamily: kFont, color: TrophyColors.tx, fontSize: 12),
      waitDuration: const Duration(milliseconds: 400),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(TrophyColors.tx3.withValues(alpha: 0.5)),
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(8),
    ),
  );
}
