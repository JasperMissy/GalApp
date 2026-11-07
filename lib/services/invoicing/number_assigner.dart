import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Dokumenttypen der Rechnungs-Engine (Spalte `invoices.type`).
enum InvoiceDocumentType { invoice, offer, storno }

/// Vergibt fortlaufende, lückenlose Dokumentnummern
/// (`RE-2026-0001` bzw. `AN-2026-0001`).
///
/// Regeln siehe `docs/Architektur-Rechnungswesen.md`, Abschnitt 4.
class NumberAssigner {
  const NumberAssigner({required this.db});

  final AppDatabase db;

  /// Standard-Präfixe; überschreibbar über die Einstellungen
  /// `nummern_praefix_rechnung` bzw. `nummern_praefix_angebot`.
  static const _defaultPrefixes = {
    InvoiceDocumentType.invoice: 'RE',
    InvoiceDocumentType.offer: 'AN',
    InvoiceDocumentType.storno: 'ST',
  };

  static const _prefixKeys = {
    InvoiceDocumentType.invoice: 'nummern_praefix_rechnung',
    InvoiceDocumentType.offer: 'nummern_praefix_angebot',
    InvoiceDocumentType.storno: 'nummern_praefix_storno',
  };

  /// Vergibt die nächste Nummer innerhalb einer Transaktion:
  /// Sequenz-Zeile anlegen/laden, `last_number + 1`, zurückschreiben.
  ///
  /// Entwürfe erhalten keine Nummer – die Vergabe erfolgt erst beim
  /// „Rechnung stellen“ (Aufrufer). Der UNIQUE-Zwang auf
  /// `invoices.number` fängt Konflikte beim Speichern der Rechnung ab.
  Future<String> assignNumber(
    InvoiceDocumentType type, {
    DateTime? date,
  }) async {
    final year = (date ?? DateTime.now()).year;
    return db.transaction(() async {
      await _insertOrIgnoreSequence(year, type);
      final prefix = await _prefixFor(type);
      final sequence = await _getSequence(year, type);
      final next = sequence.lastNumber + 1;
      await _updateSequence(year, type, next);
      return '$prefix-$year-${next.toString().padLeft(4, '0')}';
    });
  }

  /// Nächste freie Nummer ohne Verbuchung – für den Korrekturschritt,
  /// wenn die App nach einem Nummernkonflikt einen Vorschlag anzeigt.
  Future<String> suggestNumber(
    InvoiceDocumentType type, {
    DateTime? date,
  }) async {
    final year = (date ?? DateTime.now()).year;
    final prefix = await _prefixFor(type);
    final sequence = await (db.select(db.invoiceSequences)
          ..where((t) => t.year.equals(year) & t.type.equals(type.name)))
        .getSingleOrNull();
    final next = (sequence?.lastNumber ?? 0) + 1;
    return '$prefix-$year-${next.toString().padLeft(4, '0')}';
  }
  /// True, wenn die Nummer in `invoices` noch nicht vergeben ist.
  Future<bool> isNumberAvailable(String number) async {
    final matches = await (db.select(db.invoices)
          ..where((t) => t.number.equals(number)))
        .get();
    return matches.isEmpty;
  }

  /// Präfix aus den Einstellungen, sonst Standard (`RE` / `AN`).
  Future<String> prefixFor(InvoiceDocumentType type) => _prefixFor(type);

  Future<String> _prefixFor(InvoiceDocumentType type) async {
    final key = _prefixKeys[type]!;
    final row = await (db.select(db.settings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    final value = row?.value.trim();
    return (value == null || value.isEmpty) ? _defaultPrefixes[type]! : value;
  }

  Future<void> _insertOrIgnoreSequence(int year, InvoiceDocumentType type) =>
      db.into(db.invoiceSequences).insert(
            InvoiceSequencesCompanion.insert(year: year, type: type.name),
            mode: InsertMode.insertOrIgnore,
          );

  Future<InvoiceSequence> _getSequence(int year, InvoiceDocumentType type) =>
      (db.select(db.invoiceSequences)
            ..where((t) => t.year.equals(year) & t.type.equals(type.name)))
          .getSingle();

  Future<void> _updateSequence(int year, InvoiceDocumentType type, int next) =>
      (db.update(db.invoiceSequences)
            ..where((t) => t.year.equals(year) & t.type.equals(type.name)))
          .write(InvoiceSequencesCompanion(lastNumber: Value(next)));
}