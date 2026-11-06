import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/invoice.dart' as model;
import '../database/app_database.dart';
import '../database/providers.dart';

/// Lesezugriff auf Rechnungen für die Rechnungsverwaltung.
class InvoiceRepository {
  const InvoiceRepository(this.db);

  final AppDatabase db;

  /// Schreibt eine (z. B. importierte) Rechnung in die Datenbank.
  Future<void> insert(model.Invoice invoice) => db.into(db.invoices).insert(
        InvoicesCompanion.insert(
          id: invoice.id,
          number: Value(invoice.number),
          type: Value(invoice.type),
          clientId: invoice.clientId,
          orderId: Value(invoice.orderId),
          colleagueId: Value(invoice.colleagueId),
          status: Value(invoice.status),
          issuedDate: Value(invoice.issuedDate),
          netCents: Value(invoice.netCents),
          vatRateBp: Value(invoice.vatRateBp),
          vatCents: Value(invoice.vatCents),
          grossCents: Value(invoice.grossCents),
          createdAt: invoice.createdAt,
        ),
      );

  /// Gestellte Rechnungen (Typ `invoice`, Status `issued`), neueste zuerst.
  Future<List<model.Invoice>> issuedInvoices() async {
    final query = (db.select(db.invoices)
          ..where(
              (t) => t.type.equals('invoice') & t.status.equals('issued')))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  /// Rechnungen zu einem Auftrag, neueste zuerst.
  Future<List<model.Invoice>> invoicesByOrder(String orderId) async {
    final query = (db.select(db.invoices)
          ..where((t) => t.orderId.equals(orderId)))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }
  /// Gestellte Rechnungen eines Kunden, neueste zuerst.
  Future<List<model.Invoice>> invoicesByClient(String clientId) async {
    final query = (db.select(db.invoices)
          ..where((t) =>
              t.clientId.equals(clientId) &
              t.type.equals('invoice') &
              t.status.equals('issued')))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  /// Rechnungen eines Kollegen (Subunternehmer), neueste zuerst.
  Future<List<model.Invoice>> invoicesByColleague(String colleagueId) async {
    final query = (db.select(db.invoices)
          ..where((t) => t.colleagueId.equals(colleagueId)))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  model.Invoice _toModel(Invoice row) => model.Invoice(
        id: row.id,
        number: row.number,
        type: row.type,
        clientId: row.clientId,
        orderId: row.orderId,
        status: row.status,
        issuedDate: row.issuedDate,
        netCents: row.netCents,
        vatRateBp: row.vatRateBp,
        vatCents: row.vatCents,
        grossCents: row.grossCents,
        createdAt: row.createdAt,
        colleagueId: row.colleagueId,
      );
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(ref.watch(databaseProvider));
});

final issuedInvoicesProvider = FutureProvider<List<model.Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).issuedInvoices();
});

final invoicesByOrderProvider =
    FutureProvider.family<List<model.Invoice>, String>((ref, orderId) {
  return ref.watch(invoiceRepositoryProvider).invoicesByOrder(orderId);
});

final invoicesByClientProvider =
    FutureProvider.family<List<model.Invoice>, String>((ref, clientId) {
  return ref.watch(invoiceRepositoryProvider).invoicesByClient(clientId);
});

final invoicesByColleagueProvider =
    FutureProvider.family<List<model.Invoice>, String>((ref, colleagueId) {
  return ref.watch(invoiceRepositoryProvider).invoicesByColleague(colleagueId);
});