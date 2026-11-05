import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/pdf/invoice_pdf_builder.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('PDF-Smoke: Rechnung mit Inter-TTF, Umlauten und € erzeugen', () async {
    final regularBytes =
        File('assets/fonts/Inter-Regular.ttf').readAsBytesSync();
    final boldBytes = File('assets/fonts/Inter-Bold.ttf').readAsBytesSync();

    final builder = InvoicePdfBuilder(
      regularFont: pw.Font.ttf(ByteData.sublistView(regularBytes)),
      boldFont: pw.Font.ttf(ByteData.sublistView(boldBytes)),
    );

    final data = InvoicePdfData(
      companyName: 'Grünes GaLaBau & Baumpflege',
      companyStreet: 'Musterstraße 12',
      companyZipCity: '34123 Kassel',
      companyPhone: '0561 123456',
      companyEmail: 'info@gruen-gaertner.de',
      taxNumber: '025/123/45678',
      ustId: 'DE 123 456 789',
      iban: 'DE02 1234 5678 9000 1234 56',
      accentColorHex: '#4CAF50',
      clientName: 'Familie Möller',
      clientStreet: 'Am Wiesengrund 5',
      clientZipCity: '34123 Kassel',
      number: 'RE-2026-0001',
      issueDate: DateTime(2026, 11, 5),
      lines: const [
        InvoicePdfLine(
          position: 1,
          description: 'Laubentfernung im Vorgarten – inkl. Abtransport',
          quantityMilli: 18000,
          unit: 'Std.',
          unitPriceCents: 6500,
          totalCents: 117000,
        ),
        InvoicePdfLine(
          position: 2,
          description: 'Baumschnitt: Totholzentfernung (Kranplätze)',
          quantityMilli: 1500,
          unit: 'Std.',
          unitPriceCents: 6500,
          totalCents: 9750,
        ),
      ],
      netCents: 126750,
      vatRateBp: 1900,
      vatCents: 24083,
      grossCents: 150833,
      footerText: 'Vielen Dank für Ihren Auftrag!',
    );

    // Unkomprimiert für den bytegenauen Font-Nachweis.
    final bytes = await builder.build(data, compress: false);

    // Gültiger PDF-Rahmen: Header und EOF-Trailer.
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final tail = String.fromCharCodes(bytes.sublist(bytes.length - 64));
    expect(tail, contains('%%EOF'));

    // Inter ist als TrueType eingebettet: das pdf-Paket bettet TTF
    // als Composite-Font (CIDFontType2) mit FontFile2-Stream ein.
    final asText = latin1.decode(bytes, allowInvalid: true);
    expect(asText, contains('/FontFile2'));
    expect(asText, contains('/Subtype/CIDFontType2'));
    expect(asText, contains('/BaseFont/Inter-'));

    // Mindestgröße: eingebettete Schrift + Inhalt.
    expect(bytes.length, greaterThan(20000));

    // Beispiel-PDF zur Sichtprüfung ablegen (build/ ist nicht versioniert).
    final dir = Directory('build/pdf-smoke');
    dir.createSync(recursive: true);
    final file = File('build/pdf-smoke/beispielrechnung.pdf');
    // Produktionsvariante (komprimiert) zur Sichtprüfung ablegen.
    final productionBytes = await builder.build(data);
    file.writeAsBytesSync(productionBytes);
    expect(file.lengthSync(), productionBytes.length);
  });
}