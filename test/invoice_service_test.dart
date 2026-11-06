import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/invoicing/invoice_service.dart';
import 'package:galabau_app/services/invoicing/number_assigner.dart';

void main() {
  late AppDatabase db;
  late InvoiceService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = InvoiceService(db: db, assigner: NumberAssigner(db: db));
  });

  tearDown(() async => db.close());

  Future<void> seedClient() => db.into(db.clients).insert(
        ClientsCompanion.insert(
          id: 'k-1', name: 'Berger', createdAt: DateTime(2026),
        ),
      );

  test('erstellt Rechnung mit automatischer Nummer und korrekten Beträgen',
      () async {
    await seedClient();
    final invoice = await service.createInvoice(
      clientId: 'k-1',
      lines: const <InvoiceLineInput>[
        InvoiceLineInput(position: 1, description: 'Laubentfernung', quantityMilli: 18000, unit: 'Std.', unitPriceCents: 6500),
        InvoiceLineInput(position: 2, description: 'Baumschnitt', quantityMilli: 1500, unit: 'Std.', unitPriceCents: 6500),
      ],
      vatRateBp: 1900,
      issuedDate: DateTime(2026, 11, 5),
    );

    expect(invoice.number, 'RE-2026-0001');
    expect(invoice.status, 'issued');
    expect(invoice.netCents, 126750);
    expect(invoice.vatCents, 24083);
    expect(invoice.grossCents, 150833);

    final items = await db.select(db.invoiceItems).get();
    expect(items, hasLength(2));
    expect(items.first.totalCents, 117000);
  });

  test('überschreibt die Nummer, wenn angegeben', () async {
    await seedClient();
    final invoice = await service.createInvoice(
      clientId: 'k-1',
      lines: const <InvoiceLineInput>[],
      vatRateBp: 1900,
      number: 'RE-2026-0042',
      issuedDate: DateTime(2026),
    );
    expect(invoice.number, 'RE-2026-0042');
  });

  test('doppelte Nummer wird durch UNIQUE verhindert', () async {
    await seedClient();
    await service.createInvoice(
      clientId: 'k-1',
      lines: const <InvoiceLineInput>[],
      vatRateBp: 1900,
      number: 'RE-2026-0001',
      issuedDate: DateTime(2026),
    );

    expect(
      () => service.createInvoice(
        clientId: 'k-1',
        lines: const <InvoiceLineInput>[],
        vatRateBp: 1900,
        number: 'RE-2026-0001',
        issuedDate: DateTime(2026),
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('saveDraft legt einen Draft an und aktualisiert ihn', () async {
    await seedClient();
    final draft = await service.saveDraft(
      clientId: 'k-1',
      orderId: 'a-1',
      lines: const <InvoiceLineInput>[
        InvoiceLineInput(position: 1, description: 'Baumfällung', quantityMilli: 8000, unit: 'Std.', unitPriceCents: 7500),
      ],
      vatRateBp: 1900,
    );
    expect(draft.status, 'draft');
    expect(draft.number, isNull);
    expect(draft.grossCents, 71400);

    final updated = await service.saveDraft(
      draftId: draft.id,
      clientId: 'k-1',
      orderId: 'a-1',
      lines: const <InvoiceLineInput>[
        InvoiceLineInput(position: 1, description: 'Baumfällung', quantityMilli: 8000, unit: 'Std.', unitPriceCents: 7500),
        InvoiceLineInput(position: 2, description: 'Abtransport', quantityMilli: 1500, unit: 'Pauschale', unitPriceCents: 18000),
      ],
      vatRateBp: 1900,
    );
    expect(updated.id, draft.id);
    final items = await service.loadItems(draft.id);
    expect(items, hasLength(2));
  });

  test('draftByOrder findet den offenen Draft', () async {
    await seedClient();
    await service.saveDraft(
        clientId: 'k-1', orderId: 'a-1', lines: const [], vatRateBp: 1900);

    final found = await service.draftByOrder('a-1');
    expect(found, isNotNull);
    expect(found!.orderId, 'a-1');
    expect(await service.draftByOrder('a-999'), isNull);
  });

  test('createInvoice mit type offer vergibt eine AN-Nummer', () async {
    await seedClient();
    final offer = await service.createInvoice(
      clientId: 'k-1',
      lines: const <InvoiceLineInput>[],
      vatRateBp: 1900,
      type: 'offer',
      issuedDate: DateTime(2026),
    );
    expect(offer.type, 'offer');
    expect(offer.number, 'AN-2026-0001');
  });
}