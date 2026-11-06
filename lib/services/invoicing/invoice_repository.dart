import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/invoice.dart' as model;
import '../database/app_database.dart';
import '../database/providers.dart';

/// Lesezugriff auf Rechnungen für die Rechnungsverwaltung.
class InvoiceRepository {
  const InvoiceRepository(this.db);

  final AppDatabase db;

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