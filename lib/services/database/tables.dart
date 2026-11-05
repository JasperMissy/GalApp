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

/// Kunden (Quelle: Kundenverwaltung der App).
class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get street => text().withDefault(const Constant(''))();
  TextColumn get zip => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
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
  TextColumn get clientId => text().references(Clients, #id)();
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

  @override
  Set<Column> get primaryKey => {id};
}