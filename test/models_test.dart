import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/invoice.dart';
import 'package:galabau_app/models/invoice_item.dart';
import 'package:galabau_app/models/invoice_sequence.dart';
import 'package:galabau_app/models/setting.dart';

void main() {
  test('Client: fromJson/toJson Roundtrip', () {
    final client = Client(
      id: 'k-1',
      name: 'Max Mustermann',
      street: 'Beispielweg 1',
      zip: '34123',
      city: 'Kassel',
      phone: '0561 123',
      email: 'max@example.de',
      createdAt: DateTime(2026, 11, 5, 10, 30),
    );

    final restored = Client.fromJson(client.toJson());
    expect(restored.id, client.id);
    expect(restored.name, client.name);
    expect(restored.street, client.street);
    expect(restored.zip, client.zip);
    expect(restored.city, client.city);
    expect(restored.phone, client.phone);
    expect(restored.email, client.email);
    expect(restored.createdAt, client.createdAt);
  });

  test('Invoice: fromJson/toJson Roundtrip inkl. nullable Felder', () {
    final invoice = Invoice(
      id: 'r-1',
      number: 'RE-2026-0001',
      type: 'invoice',
      clientId: 'k-1',
      orderId: null,
      status: 'issued',
      issuedDate: DateTime(2026, 11, 5),
      netCents: 12345,
      vatRateBp: 1900,
      vatCents: 2346,
      grossCents: 14691,
      createdAt: DateTime(2026, 11, 5, 9),
    );

    final restored = Invoice.fromJson(invoice.toJson());
    expect(restored.number, 'RE-2026-0001');
    expect(restored.orderId, isNull);
    expect(restored.status, 'issued');
    expect(restored.issuedDate, DateTime(2026, 11, 5));
    expect(restored.netCents, 12345);
    expect(restored.vatRateBp, 1900);
    expect(restored.vatCents, 2346);
    expect(restored.grossCents, 14691);

    final draft = Invoice.fromJson(const {
      'id': 'r-2',
      'client_id': 'k-1',
      'created_at': '2026-11-05T09:00:00.000',
    });
    expect(draft.number, isNull);
    expect(draft.type, 'invoice');
    expect(draft.status, 'draft');
    expect(draft.netCents, 0);
    expect(draft.vatRateBp, 1900);
  });

  test('InvoiceItem: fromJson/toJson Roundtrip', () {
    final item = InvoiceItem(
      id: 'p-1',
      invoiceId: 'r-1',
      position: 1,
      description: 'Laubentfernung',
      quantityMilli: 18000,
      unit: 'Stück',
      unitPriceCents: 6500,
      totalCents: 117000,
    );

    final restored = InvoiceItem.fromJson(item.toJson());
    expect(restored.invoiceId, 'r-1');
    expect(restored.position, 1);
    expect(restored.description, 'Laubentfernung');
    expect(restored.quantityMilli, 18000);
    expect(restored.unit, 'Stück');
    expect(restored.unitPriceCents, 6500);
    expect(restored.totalCents, 117000);
  });

  test('InvoiceSequence: fromJson/toJson Roundtrip', () {
    final sequence = InvoiceSequence(year: 2026, type: 'invoice', lastNumber: 1);
    final restored = InvoiceSequence.fromJson(sequence.toJson());
    expect(restored.year, 2026);
    expect(restored.type, 'invoice');
    expect(restored.lastNumber, 1);
  });

  test('Setting: fromJson/toJson Roundtrip', () {
    final setting = Setting(key: 'akzentfarbe', value: '#4CAF50');
    final restored = Setting.fromJson(setting.toJson());
    expect(restored.key, 'akzentfarbe');
    expect(restored.value, '#4CAF50');
  });
}