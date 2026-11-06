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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(orders);
          }
        },
      );
}