import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/order_status.dart';

/// ISO-8601-Text-Konverter für Datumsspalten (Schema: TEXT).
class IsoDateConverter extends TypeConverter<DateTime, String> {
  const IsoDateConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb);

  @override
  String toSql(DateTime value) => value.toIso8601String();
}

/// JSON-Text-Konverter für String-Listen (z. B. Qualifikationen).
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// Kunden (Quelle: Kundenverwaltung der App).
class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get street => text().withDefault(const Constant(''))();
  TextColumn get zip => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  TextColumn get createdAt => text().map(const IsoDateConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Rechnungen und Angebote (eine Tabelle, Typ-Feld).
@TableIndex(name: 'idx_invoices_client', columns: {#clientId})
@TableIndex(name: 'idx_invoices_order', columns: {#orderId})
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get number => text().nullable().unique()();
  TextColumn get type => text().withDefault(const Constant('invoice'))();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get orderId => text().nullable()();
  TextColumn get colleagueId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get issuedDate =>
      text().map(const IsoDateConverter()).nullable()();
  IntColumn get netCents => integer().withDefault(const Constant(0))();
  IntColumn get vatRateBp => integer().withDefault(const Constant(1900))();
  IntColumn get vatCents => integer().withDefault(const Constant(0))();
  IntColumn get grossCents => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text().map(const IsoDateConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Rechnungspositionen.
class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId =>
      text().references(Invoices, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get description => text()();
  IntColumn get quantityMilli => integer()();
  TextColumn get unit => text().withDefault(const Constant(''))();
  IntColumn get unitPriceCents => integer()();
  IntColumn get totalCents => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Einstellungen (Stammdaten & Rechnungs-Design).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Laufende Nummern je Jahr und Dokumenttyp.
class InvoiceSequences extends Table {
  IntColumn get year => integer()();
  TextColumn get type => text()();
  IntColumn get lastNumber => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {year, type};
}

/// Aufträge (Vision, Abschnitt 10).
@TableIndex(name: 'idx_orders_client', columns: {#clientId})
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().nullable().references(Clients, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text().map(const IsoDateConverter())();
  TextColumn get dueDateStart =>
      text().map(const IsoDateConverter()).nullable()();
  TextColumn get dueDateEnd =>
      text().map(const IsoDateConverter()).nullable()();
  TextColumn get status => textEnum<OrderStatus>()
      .withDefault(const Constant('offen'))();
  BoolColumn get recurring => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get origin => text().withDefault(const Constant('eigen'))();
  TextColumn get packageId => text().nullable()();
  TextColumn get externalAddress => text().nullable()();
  TextColumn get senderName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Geteilte/empfangene Auftrags-Pakete (Subunternehmer-Workflow).
class OrderPackages extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().nullable()();
  TextColumn get colleagueId => text().nullable()();
  TextColumn get direction =>
      text().withDefault(const Constant('outgoing'))();
  TextColumn get status => text().withDefault(const Constant('sent'))();
  TextColumn get createdAt => text().map(const IsoDateConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Kollegen (Subunternehmer/Mitarbeiter).
class Colleagues extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get street => text().withDefault(const Constant(''))();
  TextColumn get zip => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get qualifications =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  TextColumn get createdAt => text().map(const IsoDateConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Zeiterfassung zur Arbeitsdokumentation (Subunternehmer-Workflow).
class WorkTimeEntries extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get startedAt => text().map(const IsoDateConverter())();
  TextColumn get endedAt => text().map(const IsoDateConverter()).nullable()();
  TextColumn get createdAt => text().map(const IsoDateConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Anmerkung zur Arbeitsdokumentation (ein Text je Auftrag).
class WorkNotes extends Table {
  TextColumn get orderId => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get updatedAt => text().map(const IsoDateConverter())();

  @override
  Set<Column> get primaryKey => {orderId};
}