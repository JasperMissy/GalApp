import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Lokale SQLite-Datenbank der Rechnungs-Engine.
/// Schema siehe `docs/Architektur-Rechnungswesen.md`, Abschnitt 3.
@DriftDatabase(
  tables: [Clients, Invoices, InvoiceItems, Settings, InvoiceSequences],
)
class AppDatabase extends _$AppDatabase {
  /// Produktive Datenbank im lokalen Datenverzeichnis der App.
  AppDatabase() : super(driftDatabase(name: 'galabau'));

  /// In-Memory- bzw. Test-Datenbank.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
      );
}