import 'package:flutter/material.dart';

/// Farbpalette der App: Grün als Primärfarbe, erdige Braun- und Holztöne als
/// Akzent. Die Statusfarben stammen aus der Skizze des Auftraggebers.
abstract final class AppColors {
  /// Primärfarbe (Natur, GaLaBau).
  static const Color primaryGreen = Color(0xFF2E7D32);

  /// Erdiger Akzent.
  static const Color earthBrown = Color(0xFF8D6E63);

  /// Dunklerer Holzton für Hervorhebungen.
  static const Color woodBrown = Color(0xFF6D4C41);

  /// Warmer, heller Hintergrund.
  static const Color background = Color(0xFFF6F4EF);

  /// Status „offen“ (gelb).
  static const Color statusOpen = Color(0xFFF9A825);

  /// Status „wiederkehrend“ (blau).
  static const Color statusRecurring = Color(0xFF1E88E5);

  /// Status „erledigt“ (Haken in der Primärfarbe).
  static const Color statusDone = primaryGreen;
}
