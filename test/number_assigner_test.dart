import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/invoicing/number_assigner.dart';

void main() {
  late AppDatabase db;
  late NumberAssigner assigner;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    assigner = NumberAssigner(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Erstvergabe Rechnung: RE-2026-0001', () async {
    final number =
        await assigner.assignNumber(InvoiceDocumentType.invoice,
            date: DateTime(2026));
    expect(number, 'RE-2026-0001');
  });

  test('Folgevergabe: RE-2026-0001, RE-2026-0002', () async {
    await assigner.assignNumber(InvoiceDocumentType.invoice,
        date: DateTime(2026));
    final second = await assigner.assignNumber(InvoiceDocumentType.invoice,
        date: DateTime(2026));
    expect(second, 'RE-2026-0002');
  });

  test('Angebote haben eine eigene Nummernfolge', () async {
    await assigner.assignNumber(InvoiceDocumentType.invoice,
        date: DateTime(2026));
    final offer =
        await assigner.assignNumber(InvoiceDocumentType.offer,
            date: DateTime(2026));
    expect(offer, 'AN-2026-0001');
  });

  test('Jahreswechsel startet bei 0001', () async {
    await assigner.assignNumber(InvoiceDocumentType.invoice,
        date: DateTime(2026));
    await assigner.assignNumber(InvoiceDocumentType.invoice,
        date: DateTime(2026));
    final nextYear = await assigner.assignNumber(InvoiceDocumentType.invoice,
        date: DateTime(2027));
    expect(nextYear, 'RE-2027-0001');
  });

  test('suggestNumber verbucht nichts', () async {
    final suggestion = await assigner.suggestNumber(
        InvoiceDocumentType.invoice, date: DateTime(2026));
    expect(suggestion, 'RE-2026-0001');

    final assigned = await assigner.assignNumber(InvoiceDocumentType.invoice,
        date: DateTime(2026));
    expect(assigned, suggestion);
  });

  test('isNumberAvailable erkennt vergebene Nummern', () async {
    expect(await assigner.isNumberAvailable('RE-2026-0001'), isTrue);

    await db.into(db.invoices).insert(
          InvoicesCompanion.insert(
            id: 'r-1',
            number: const Value('RE-2026-0001'),
            clientId: 'k-1',
            createdAt: DateTime(2026),
          ),
        );

    expect(await assigner.isNumberAvailable('RE-2026-0001'), isFalse);
    expect(await assigner.isNumberAvailable('RE-2026-0002'), isTrue);
  });

  test('Präfix aus Einstellungen überschreibt den Standard', () async {
    await db.into(db.settings).insert(
          SettingsCompanion.insert(key: 'nummern_praefix_rechnung', value: 'RG'),
        );
    final number = await assigner.assignNumber(InvoiceDocumentType.invoice,
        date: DateTime(2026));
    expect(number, 'RG-2026-0001');
  });

  test('Leeres Präfix-Setting fällt auf den Standard zurück', () async {
    await db.into(db.settings).insert(
          SettingsCompanion.insert(key: 'nummern_praefix_angebot', value: '  '),
        );
    final number = await assigner.assignNumber(InvoiceDocumentType.offer,
        date: DateTime(2026));
    expect(number, 'AN-2026-0001');
  });
}