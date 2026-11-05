import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Eingebettete Inter-Schriften für den PDF-Generator.
///
/// Produktion: Laden über [load] (rootBundle). Tests können die Fonts
/// weiterhin direkt aus den Dateien unter `assets/fonts/` erzeugen.
class InvoicePdfFonts {
  const InvoicePdfFonts({required this.regular, required this.bold});

  final pw.Font regular;
  final pw.Font bold;

  static Future<InvoicePdfFonts> load() async {
    final regular = await rootBundle.load('assets/fonts/Inter-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Inter-Bold.ttf');
    return InvoicePdfFonts(
      regular: pw.Font.ttf(regular),
      bold: pw.Font.ttf(bold),
    );
  }
}