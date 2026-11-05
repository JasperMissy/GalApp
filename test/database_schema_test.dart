import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertClient({String id = 'k-1'}) => db.into(db.clients).insert(
        ClientsCompanion.insert(
          id: id,
          name: 'Max Mustermann',
          createdAt: DateTime(2026, 11, 5, 10, 30),
        ),
      );

  test('Client einfügen und lesen', () async {
    await insertClient();

    final loaded = await db.select(db.clients).getSingle();
    expect(loaded.name, 'Max Mustermann');
    expect(loaded.createdAt, DateTime(2026, 11, 5, 10, 30));
  });

  test('Rechnungsnummer ist eindeutig (UNIQUE)', () async {
    await insertClient();

    Future<void> insertInvoice(String number) => db.into(db.invoices).insert(
          InvoicesCompanion.insert(
            id: number,
            number: Value(number),
            clientId: 'k-1',
            createdAt: DateTime(2026),
          ),
        );

    await insertInvoice('RE-2026-0001');
    await expectLater(
      insertInvoice('RE-2026-0001'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('Nummernfolge: Primärschlüssel (Jahr, Typ)', () async {
    Future<void> insert(int year, String type) =>
        db.into(db.invoiceSequences).insert(
              InvoiceSequencesCompanion.insert(year: year, type: type),
            );

    await insert(2026, 'invoice');
    await insert(2026, 'offer');
    await insert(2027, 'invoice');
    expect(await db.select(db.invoiceSequences).get(), hasLength(3));

    await expectLater(
      insert(2026, 'invoice'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('Einstellungen speichern und lesen', () async {
    await db.into(db.settings).insert(
          SettingsCompanion.insert(key: 'akzentfarbe', value: '#4CAF50'),
        );

    final loaded = await db.select(db.settings).getSingle();
    expect(loaded.value, '#4CAF50');
  });
}