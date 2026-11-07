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
  int get schemaVersion => 7;

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
        },
      );
}