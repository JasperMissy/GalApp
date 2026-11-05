import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generatorenspezifische Datenstruktur für das Rechnungs-PDF.
/// (Mapper aus DB-Models folgt in M3.)
class InvoicePdfData {
  const InvoicePdfData({
    required this.companyName,
    required this.companyStreet,
    required this.companyZipCity,
    required this.companyPhone,
    required this.companyEmail,
    required this.taxNumber,
    required this.ustId,
    required this.iban,
    required this.accentColorHex,
    required this.clientName,
    required this.clientStreet,
    required this.clientZipCity,
    required this.number,
    required this.issueDate,
    required this.lines,
    required this.netCents,
    required this.vatRateBp,
    required this.vatCents,
    required this.grossCents,
    this.logoBytes,
    this.footerText,
  });

  final String companyName;
  final String companyStreet;
  final String companyZipCity;
  final String companyPhone;
  final String companyEmail;
  final String taxNumber;
  final String ustId;
  final String iban;
  final String accentColorHex;
  final String clientName;
  final String clientStreet;
  final String clientZipCity;
  final String number;
  final DateTime issueDate;
  final List<InvoicePdfLine> lines;
  final int netCents;
  final int vatRateBp;
  final int vatCents;
  final int grossCents;
  final Uint8List? logoBytes;
  final String? footerText;
}

/// Eine Positionstabelle-Zeile im Rechnungs-PDF.
class InvoicePdfLine {
  const InvoicePdfLine({
    required this.position,
    required this.description,
    required this.quantityMilli,
    required this.unit,
    required this.unitPriceCents,
    required this.totalCents,
  });

  final int position;
  final String description;
  final int quantityMilli;
  final String unit;
  final int unitPriceCents;
  final int totalCents;
}

/// Erzeugt das Rechnungs-PDF deterministisch mit `dart:pdf`.
///
/// Grund-Layout laut `docs/Architektur-Rechnungswesen.md`, Abschnitt 6:
/// Kopf (Logo links, Firmen-Stammdaten rechts) -> Akzentlinie -> Adressblock
/// -> Metadaten -> Positionstabelle -> Summenblock -> Zahlungsinformation
/// -> Fußzeile.
class InvoicePdfBuilder {
  const InvoicePdfBuilder({required this.regularFont, required this.boldFont});

  /// Eingebettete Inter-TTF (siehe `assets/fonts/`).
  final pw.Font regularFont;
  final pw.Font boldFont;

  /// [compress] steuert die Objekt-Komprimierung der PDF;
  /// Tests nutzen false, um eingebettete Schriften bytegenau zu prüfen.
  Future<Uint8List> build(
    InvoicePdfData data, {
    bool compress = true,
  }) async {
    final document = pw.Document(compress: compress);
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => _content(data),
      ),
    );
    return document.save();
  }

  List<pw.Widget> _content(InvoicePdfData data) {
    final accent = _accentColor(data.accentColorHex);
    return [
      _header(data),
      pw.SizedBox(height: 12),
      pw.Divider(color: accent, thickness: 1),
      pw.SizedBox(height: 24),
      _clientBlock(data),
      pw.SizedBox(height: 24),
      _metaBlock(data),
      pw.SizedBox(height: 24),
      _itemsTable(data),
      pw.SizedBox(height: 16),
      _summaryBlock(data, accent),
      pw.SizedBox(height: 24),
      pw.Text('Zahlung bitte an: IBAN ${data.iban}',
          style: pw.TextStyle(font: regularFont, fontSize: 10)),
      pw.SizedBox(height: 12),
      pw.Divider(color: accent, thickness: 0.5),
      pw.SizedBox(height: 8),
      pw.Text(
        'Steuernummer: ${data.taxNumber}  ·  USt-IdNr.: ${data.ustId}',
        style: pw.TextStyle(font: regularFont, fontSize: 8),
      ),
      if (data.footerText != null && data.footerText!.isNotEmpty)
        pw.Text(data.footerText!,
            style: pw.TextStyle(font: regularFont, fontSize: 8)),
    ];
  }

  pw.Widget _header(InvoicePdfData data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (data.logoBytes != null)
          pw.SizedBox(
            width: 120,
            height: 60,
            child: pw.Image(
              pw.MemoryImage(data.logoBytes!),
              fit: pw.BoxFit.contain,
            ),
          )
        else
          pw.SizedBox(width: 120),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(data.companyName,
                  style: pw.TextStyle(font: boldFont, fontSize: 16)),
              pw.Text(data.companyStreet,
                  style: pw.TextStyle(font: regularFont, fontSize: 10)),
              pw.Text(data.companyZipCity,
                  style: pw.TextStyle(font: regularFont, fontSize: 10)),
              pw.Text('Tel.: ${data.companyPhone}',
                  style: pw.TextStyle(font: regularFont, fontSize: 10)),
              pw.Text(data.companyEmail,
                  style: pw.TextStyle(font: regularFont, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _clientBlock(InvoicePdfData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(data.clientName,
            style: pw.TextStyle(font: boldFont, fontSize: 11)),
        pw.Text(data.clientStreet,
            style: pw.TextStyle(font: regularFont, fontSize: 10)),
        pw.Text(data.clientZipCity,
            style: pw.TextStyle(font: regularFont, fontSize: 10)),
      ],
    );
  }

  pw.Widget _metaBlock(InvoicePdfData data) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('Rechnung Nr. ${data.number}',
              style: pw.TextStyle(font: boldFont, fontSize: 11)),
          pw.Text('Datum: ${_date(data.issueDate)}',
              style: pw.TextStyle(font: regularFont, fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _itemsTable(InvoicePdfData data) {
    return pw.TableHelper.fromTextArray(
      headers: ['Pos.', 'Bezeichnung', 'Menge', 'Einheit', 'EP', 'Gesamt'],
      data: data.lines
          .map((line) => [
                line.position.toString(),
                line.description,
                _quantity(line.quantityMilli),
                line.unit,
                _euro(line.unitPriceCents),
                _euro(line.totalCents),
              ])
          .toList(),
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 9),
      cellStyle: pw.TextStyle(font: regularFont, fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(26),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(42),
        3: const pw.FixedColumnWidth(48),
        4: const pw.FixedColumnWidth(58),
        5: const pw.FixedColumnWidth(68),
      },
    );
  }

  pw.Widget _summaryBlock(InvoicePdfData data, PdfColor accent) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.SizedBox(
            width: 220,
            child: _summaryRow('Netto', _euro(data.netCents)),
          ),
          pw.SizedBox(
            width: 220,
            child: _summaryRow(
                'MwSt ${_vatPercent(data.vatRateBp)}', _euro(data.vatCents)),
          ),
          pw.SizedBox(width: 220, child: pw.Divider(color: accent)),
          pw.SizedBox(
            width: 220,
            child: _summaryRow('TOTAL', _euro(data.grossCents), bold: true),
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryRow(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(
      font: bold ? boldFont : regularFont,
      fontSize: bold ? 11 : 10,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(label, style: style), pw.Text(value, style: style)],
    );
  }

  PdfColor _accentColor(String hex) {
    var value = hex.trim().replaceFirst('#', '');
    if (value.length == 3) {
      value = value.split('').map((c) => '$c$c').join();
    }
    final intValue = int.parse(value, radix: 16);
    return PdfColor(
      ((intValue >> 16) & 0xFF) / 255,
      ((intValue >> 8) & 0xFF) / 255,
      (intValue & 0xFF) / 255,
    );
  }

  /// 12345 -> '123,45'
  static String _euro(int cents) {
    final whole = cents ~/ 100;
    final frac = (cents % 100).toString().padLeft(2, '0');
    return '$whole,$frac';
  }

  /// 1500 -> '1,5', 18000 -> '18', 1234 -> '1,234'
  static String _quantity(int milli) {
    final whole = milli ~/ 1000;
    final frac = milli % 1000;
    if (frac == 0) return '$whole';
    var digits = frac.toString().padLeft(3, '0');
    digits = digits.replaceAll(RegExp(r'0+$'), '');
    return '$whole,$digits';
  }

  /// 1900 -> '19 %', 700 -> '7 %', 1070 -> '10,7 %'
  static String _vatPercent(int bp) =>
      bp % 100 == 0 ? '${bp ~/ 100} %' : '${(bp / 100).toStringAsFixed(1)} %';

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}