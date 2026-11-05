import 'dart:typed_data';

import 'package:excel/excel.dart';

/// Eine Zeile in `Einnahmen.xlsx` (Spalten laut Vision, Abschnitt 6.1).
class EinnahmenXlsxRow {
  const EinnahmenXlsxRow({
    required this.datum,
    required this.kundenname,
    required this.adresse,
    required this.auftragstitel,
    required this.rechnungsnummer,
    required this.summeBruttoCents,
    required this.summeNettoCents,
  });

  final DateTime datum;
  final String kundenname;
  final String adresse;
  final String auftragstitel;
  final String rechnungsnummer;
  final int summeBruttoCents;
  final int summeNettoCents;
}

/// Schreibt die lokale `Einnahmen.xlsx` (append-only).
///
/// Jede bestätigte Rechnung hängt eine neue Zeile an. Es gibt keine Updates:
/// Rechnungen werden bei Bedarf storniert (Nummer bleibt erhalten) und nicht
/// überschrieben – so entstehen keine Konflikte mit einer parallel geöffneten
/// Datei (z. B. LibreOffice). Entscheidung dokumentiert in M6.
class EinnahmenXlsxMapper {
  const EinnahmenXlsxMapper();

  static const headers = [
    'Datum',
    'Kundenname',
    'Adresse',
    'Auftragstitel',
    'Rechnungsnummer',
    'Summe brutto',
    'Summe netto',
  ];

  /// Hängt [row] an eine bestehende (`existingBytes`) oder neue Datei an.
  Uint8List appendRow({
    Uint8List? existingBytes,
    required EinnahmenXlsxRow row,
  }) {
    final excel = existingBytes == null
        ? Excel.createExcel()
        : Excel.decodeBytes(existingBytes);

    final sheet = excel[excel.getDefaultSheet()!];

    if (existingBytes == null) {
      sheet.appendRow([for (final header in headers) TextCellValue(header)]);
    }

    sheet.appendRow([
      TextCellValue(_date(row.datum)),
      TextCellValue(row.kundenname),
      TextCellValue(row.adresse),
      TextCellValue(row.auftragstitel),
      TextCellValue(row.rechnungsnummer),
      TextCellValue(_euro(row.summeBruttoCents)),
      TextCellValue(_euro(row.summeNettoCents)),
    ]);

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('Excel.save() hat keine Bytes erzeugt.');
    }
    return Uint8List.fromList(bytes);
  }

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';

  static String _euro(int cents) {
    final whole = cents ~/ 100;
    final frac = (cents % 100).toString().padLeft(2, '0');
    return '$whole,$frac';
  }
}