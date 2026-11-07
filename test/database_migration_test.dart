import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/database/app_database.dart';

/// Prüft die Migration v7 → v8 (Fremdschlüssel, Waisenbereinigung, Cascade).
void main() {
  /// Baut den Stand von Schema 7 (ohne Fremdschlüssel auf Arbeitsdaten) und
  /// füllt ihn mit gültigen Daten sowie mit Waisen. Läuft vor der Migration.
  void buildV7(dynamic raw) {
    raw.execute('''
      CREATE TABLE clients (
        id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
        street TEXT NOT NULL DEFAULT '', zip TEXT NOT NULL DEFAULT '',
        city TEXT NOT NULL DEFAULT '', phone TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL DEFAULT '', lat REAL, lon REAL,
        created_at TEXT NOT NULL
      );
      CREATE TABLE orders (
        id TEXT NOT NULL PRIMARY KEY,
        client_id TEXT REFERENCES clients (id),
        title TEXT NOT NULL, description TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL, due_date_start TEXT, due_date_end TEXT,
        status TEXT NOT NULL DEFAULT 'offen',
        recurring INTEGER NOT NULL DEFAULT 0 CHECK (recurring IN (0, 1)),
        notes TEXT NOT NULL DEFAULT '', origin TEXT NOT NULL DEFAULT 'eigen',
        package_id TEXT, external_address TEXT, sender_name TEXT
      );
      CREATE TABLE invoices (
        id TEXT NOT NULL PRIMARY KEY, number TEXT UNIQUE,
        type TEXT NOT NULL DEFAULT 'invoice',
        client_id TEXT NOT NULL REFERENCES clients (id),
        order_id TEXT, colleague_id TEXT,
        status TEXT NOT NULL DEFAULT 'draft', issued_date TEXT,
        net_cents INTEGER NOT NULL DEFAULT 0,
        vat_rate_bp INTEGER NOT NULL DEFAULT 1900,
        vat_cents INTEGER NOT NULL DEFAULT 0,
        gross_cents INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL
      );
      CREATE TABLE invoice_items (
        id TEXT NOT NULL PRIMARY KEY,
        invoice_id TEXT NOT NULL REFERENCES invoices (id) ON DELETE CASCADE,
        position INTEGER NOT NULL, description TEXT NOT NULL,
        quantity_milli INTEGER NOT NULL, unit TEXT NOT NULL DEFAULT '',
        unit_price_cents INTEGER NOT NULL, total_cents INTEGER NOT NULL
      );
      CREATE TABLE order_packages (
        id TEXT NOT NULL PRIMARY KEY, order_id TEXT, colleague_id TEXT,
        direction TEXT NOT NULL DEFAULT 'outgoing',
        status TEXT NOT NULL DEFAULT 'sent', created_at TEXT NOT NULL
      );
      CREATE TABLE work_time_entries (
        id TEXT NOT NULL PRIMARY KEY, order_id TEXT NOT NULL,
        started_at TEXT NOT NULL, ended_at TEXT, paused_at TEXT,
        created_at TEXT NOT NULL
      );
      CREATE TABLE work_notes (
        order_id TEXT NOT NULL PRIMARY KEY,
        content TEXT NOT NULL DEFAULT '', updated_at TEXT NOT NULL
      );
      INSERT INTO orders (id, title, created_at)
        VALUES ('a-1', 'Hecke', '2026-11-01T10:00:00.000');
      INSERT INTO work_time_entries (id, order_id, started_at, created_at)
        VALUES ('t-1', 'a-1', '2026-11-02T08:00:00.000',
                '2026-11-02T08:00:00.000'),
               ('t-waise', 'a-gelöscht', '2026-11-02T08:00:00.000',
                '2026-11-02T08:00:00.000');
      INSERT INTO work_notes (order_id, content, updated_at)
        VALUES ('a-1', 'ok', '2026-11-02T09:00:00.000'),
               ('a-gelöscht', 'waise', '2026-11-02T09:00:00.000');
      INSERT INTO order_packages (id, order_id, created_at)
        VALUES ('p-1', 'a-1', '2026-11-02T09:00:00.000'),
               ('p-waise', 'a-gelöscht', '2026-11-02T09:00:00.000'),
               ('p-ohne', NULL, '2026-11-02T09:00:00.000');
      PRAGMA user_version = 7;
    ''');
  }

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: buildV7));
  });

  tearDown(() async => db.close());

  test('Migration entfernt Waisen und behält gültige Daten', () async {
    final times = await db.select(db.workTimeEntries).get();
    final notes = await db.select(db.workNotes).get();
    final packages = await db.select(db.orderPackages).get();

    expect(times.map((t) => t.id), <String>['t-1']);
    expect(notes.map((n) => n.orderId), <String>['a-1']);
    expect(
      packages.map((p) => p.id).toSet(),
      <String>{'p-1', 'p-ohne'},
    );
  });

  test('Fremdschlüssel sind aktiv', () async {
    final rows = await db.customSelect('PRAGMA foreign_keys').get();
    expect(rows.single.data.values.single, 1);
  });

  test('Löschen eines Auftrags löscht Zeiten, Notizen und Pakete', () async {
    await db.customStatement("DELETE FROM orders WHERE id = 'a-1'");

    expect(await db.select(db.workTimeEntries).get(), isEmpty);
    expect(await db.select(db.workNotes).get(), isEmpty);
    final packages = await db.select(db.orderPackages).get();
    expect(packages.map((p) => p.id), <String>['p-ohne']);
  });

  test('Zeiteintrag ohne gültigen Auftrag wird abgelehnt', () async {
    await expectLater(
      db.customStatement(
        "INSERT INTO work_time_entries (id, order_id, started_at, created_at) "
        "VALUES ('x', 'gibt-es-nicht', '2026-11-02T08:00:00.000', "
        "'2026-11-02T08:00:00.000')",
      ),
      throwsA(isA<Object>()),
    );
  });

  test('Indizes sind vorhanden', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(names, containsAll(<String>[
      'idx_orders_client',
      'idx_invoices_client',
      'idx_invoices_order',
    ]));
  });
}
