import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../models/order_status.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Lokale SQLite-Datenbank der App (Rechnungswesen + Kunden/Aufträge).
@DriftDatabase(
  tables: [
    Clients,
    Invoices,
    InvoiceItems,
    Settings,
    InvoiceSequences,
    Orders,
    OrderPackages,
    Colleagues,
    WorkTimeEntries,
    WorkNotes,
    Expenses,
    AuditLog,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Produktive Datenbank im lokalen Datenverzeichnis der App.
  AppDatabase()
      : super(driftDatabase(
          name: 'galabau',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));

  /// In-Memory- bzw. Test-Datenbank.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(orders);
          }
          if (from < 3) {
            await m.addColumn(clients, clients.lat);
            await m.addColumn(clients, clients.lon);
          }
          if (from < 4) {
            await m.createTable(colleagues);
          }
          if (from < 5) {
            // `orders` neu aufbauen: `clientId` wird nullable, neue Felder.
            await customStatement(
              'ALTER TABLE `orders` RENAME TO `orders_old`',
            );
            await m.createTable(orders);
            await customStatement(
              'INSERT INTO `orders` '
              '(id, client_id, title, description, created_at, due_date_start, '
              'due_date_end, status, recurring, notes) '
              'SELECT id, client_id, title, description, created_at, '
              'due_date_start, due_date_end, status, recurring, notes '
              'FROM `orders_old`',
            );
            await customStatement('DROP TABLE `orders_old`');

            await m.createTable(orderPackages);

            await m.addColumn(invoices, invoices.colleagueId);
          }
          if (from < 6) {
            await m.createTable(workTimeEntries);
            await m.createTable(workNotes);
          }
          if (from < 7) {
            await m.addColumn(workTimeEntries, workTimeEntries.pausedAt);
          }
          if (from < 8) {
            await _migrateToV8(m);
          }
          if (from < 9) {
            await m.createTable(expenses);
          }
          if (from < 10) {
            await m.addColumn(invoices, invoices.stornoOfId);
            await m.createTable(auditLog);
          }
        },
        beforeOpen: (details) async {
          // SQLite erzwingt Fremdschlüssel nur, wenn sie aktiviert sind.
          await customStatement('PRAGMA foreign_keys = ON');
          await _createGoBdTriggers();
        },
      );

  /// v8: Fremdschlüssel mit Cascade für Arbeitsdaten und Pakete, Bereinigung
  /// verwaister Zeilen und fehlende Indizes nachziehen.
  Future<void> _migrateToV8(Migrator m) async {
    await customStatement(
      'DELETE FROM `work_time_entries` '
      'WHERE `order_id` NOT IN (SELECT `id` FROM `orders`)',
    );
    await customStatement(
      'DELETE FROM `work_notes` '
      'WHERE `order_id` NOT IN (SELECT `id` FROM `orders`)',
    );
    await customStatement(
      'DELETE FROM `order_packages` WHERE `order_id` IS NOT NULL '
      'AND `order_id` NOT IN (SELECT `id` FROM `orders`)',
    );

    // Pausen-Spalte vor dem Umbau ergänzen, damit der Neuaufbau sie kopiert.
    await m.addColumn(workTimeEntries, workTimeEntries.pausedMilliseconds);

    await m.alterTable(TableMigration(workTimeEntries));
    await m.alterTable(TableMigration(workNotes));
    await m.alterTable(TableMigration(orderPackages));

    await customStatement(
      'CREATE INDEX IF NOT EXISTS `idx_orders_client` '
      'ON `orders` (`client_id`)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS `idx_invoices_client` '
      'ON `invoices` (`client_id`)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS `idx_invoices_order` '
      'ON `invoices` (`order_id`)',
    );
  }

  /// GoBD: gestellte Rechnungen und deren Positionen sind nach dem Stellen
  /// unveränderlich. Die Trigger greifen zusätzlich zur Repository-Logik.
  Future<void> _createGoBdTriggers() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_invoices_immutable_update
      BEFORE UPDATE ON invoices
      WHEN OLD.status = 'issued'
      BEGIN
        SELECT RAISE(ABORT, 'gestellte Rechnungen sind unveränderlich');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_invoices_immutable_delete
      BEFORE DELETE ON invoices
      WHEN OLD.status = 'issued'
      BEGIN
        SELECT RAISE(ABORT, 'gestellte Rechnungen können nicht gelöscht werden');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_invoice_items_immutable_update
      BEFORE UPDATE ON invoice_items
      WHEN EXISTS (
        SELECT 1 FROM invoices
        WHERE id = OLD.invoice_id AND status = 'issued'
      )
      BEGIN
        SELECT RAISE(ABORT, 'Positionen gestellter Rechnungen sind unveränderlich');
      END;
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_invoice_items_immutable_delete
      BEFORE DELETE ON invoice_items
      WHEN EXISTS (
        SELECT 1 FROM invoices
        WHERE id = OLD.invoice_id AND status = 'issued'
      )
      BEGIN
        SELECT RAISE(ABORT, 'Positionen gestellter Rechnungen können nicht gelöscht werden');
      END;
    ''');
  }
}