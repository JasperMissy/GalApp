import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/invoice.dart';
import 'package:galabau_app/models/invoice_item.dart';
import 'package:galabau_app/services/pdf/invoice_pdf_mapper.dart';

void main() {
  final settings = <String, String>{
    'firmenname': 'Grünes GaLaBau',
    'strasse': 'Musterstraße 12',
    'plz': '34123',
    'ort': 'Kassel',
    'telefon': '0561 123456',
    'email': 'info@gruen.de',
    'steuernummer': '025/123/45678',
    'ust_id': 'DE 123 456 789',
    'iban': 'DE02 1234 5678 9000 1234 56',
    'akzentfarbe': '#8BC34A',
    'layout.fusszeile_text': 'Vielen Dank!',
  };

  final client = Client(
    id: 'k-1',
    name: 'Familie Möller',
    street: 'Am Wiesengrund 5',
    zip: '34123',
    city: 'Kassel',
    phone: '',
    email: '',
    createdAt: DateTime(2026),
  );

  final invoice = Invoice(
    id: 'r-1',
    number: 'RE-2026-0001',
    type: 'invoice',
    clientId: 'k-1',
    orderId: 'a-1',
    status: 'issued',
    issuedDate: DateTime(2026, 11, 5),
    netCents: 126750,
    vatRateBp: 1900,
    vatCents: 24083,
    grossCents: 150833,
    createdAt: DateTime(2026, 11, 5, 9),
  );

  test('Mapper bildet alle Felder korrekt ab', () {
    final items = [
      InvoiceItem(
        id: 'p-2',
        invoiceId: 'r-1',
        position: 2,
        description: 'Baumschnitt',
        quantityMilli: 1500,
        unit: 'Std.',
        unitPriceCents: 6500,
        totalCents: 9750,
      ),
      InvoiceItem(
        id: 'p-1',
        invoiceId: 'r-1',
        position: 1,
        description: 'Laubentfernung',
        quantityMilli: 18000,
        unit: 'Std.',
        unitPriceCents: 6500,
        totalCents: 117000,
      ),
    ];

    final data = InvoicePdfMapper.map(
      invoice: invoice,
      items: items,
      client: client,
      settings: settings,
    );

    expect(data.companyName, 'Grünes GaLaBau');
    expect(data.companyZipCity, '34123 Kassel');
    expect(data.accentColorHex, '#8BC34A');
    expect(data.clientName, 'Familie Möller');
    expect(data.clientZipCity, '34123 Kassel');
    expect(data.number, 'RE-2026-0001');
    expect(data.issueDate, DateTime(2026, 11, 5));
    expect(data.footerText, 'Vielen Dank!');
    expect(data.lines.map((l) => l.position).toList(), [1, 2]);
    expect(data.lines.first.description, 'Laubentfernung');
    expect(data.netCents, 126750);
    expect(data.grossCents, 150833);
  });

  test('Akzentfarbe-Fallback auf Standardgrün', () {
    final data = InvoicePdfMapper.map(
      invoice: invoice,
      items: const [],
      client: client,
      settings: const {},
    );
    expect(data.accentColorHex, '#4CAF50');
  });

  test('Rechnung ohne Nummer wirft ArgumentError', () {
    final draft = Invoice(
      id: 'r-2',
      number: null,
      type: 'invoice',
      clientId: 'k-1',
      orderId: null,
      status: 'draft',
      issuedDate: null,
      netCents: 0,
      vatRateBp: 1900,
      vatCents: 0,
      grossCents: 0,
      createdAt: DateTime(2026),
    );

    expect(
      () => InvoicePdfMapper.map(
        invoice: draft,
        items: const [],
        client: client,
        settings: settings,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}