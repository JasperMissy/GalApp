import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/invoice.dart' as model;
import '../../models/invoice_item.dart' as item;
import '../database/app_database.dart';
import '../database/providers.dart';
import '../id_generator.dart';
import 'invoice_calculator.dart';
import 'number_assigner.dart';

/// Eingabe einer Rechnungsposition; die Zeilensumme wird berechnet.
class InvoiceLineInput {
  const InvoiceLineInput({
    required this.position,
    required this.description,
    required this.quantityMilli,
    required this.unit,
    required this.unitPriceCents,
  });

  final int position;
  final String description;
  final int quantityMilli;
  final String unit;
  final int unitPriceCents;
}

/// Erstellt eine fertige Rechnung: Nummernvergabe, centgenaue Berechnung
/// und Speichern von Rechnung + Positionen in einer Transaktion.
class InvoiceService {
  const InvoiceService({required this.db, required this.assigner});

  final AppDatabase db;
  final NumberAssigner assigner;

  Future<model.Invoice> createInvoice({
    required String clientId,
    String? orderId,
    required List<InvoiceLineInput> lines,
    required int vatRateBp,
    String? number,
    DateTime? issuedDate,
  }) async {
    final DateTime date = issuedDate ?? DateTime.now();
    final String finalNumber = number ??
        await assigner.assignNumber(InvoiceDocumentType.invoice, date: date);

    final List<int> lineTotals = <int>[
      for (final InvoiceLineInput line in lines)
        InvoiceCalculator.lineTotalCents(
          quantityMilli: line.quantityMilli,
          unitPriceCents: line.unitPriceCents,
        ),
    ];
    final InvoiceTotals totals = InvoiceCalculator.totals(
      lineTotalsCents: lineTotals,
      vatRateBp: vatRateBp,
    );

    final model.Invoice invoice = model.Invoice(
      id: newId(),
      number: finalNumber,
      type: 'invoice',
      clientId: clientId,
      orderId: orderId,
      status: 'issued',
      issuedDate: date,
      netCents: totals.netCents,
      vatRateBp: vatRateBp,
      vatCents: totals.vatCents,
      grossCents: totals.grossCents,
      createdAt: DateTime.now(),
    );

    await db.transaction(() async {
      await db.into(db.invoices).insert(
            InvoicesCompanion.insert(
              id: invoice.id,
              number: Value(invoice.number),
              clientId: invoice.clientId,
              orderId: Value(invoice.orderId),
              status: Value(invoice.status),
              issuedDate: Value(invoice.issuedDate),
              netCents: Value(invoice.netCents),
              vatRateBp: Value(invoice.vatRateBp),
              vatCents: Value(invoice.vatCents),
              grossCents: Value(invoice.grossCents),
              createdAt: invoice.createdAt,
            ),
          );

      for (int i = 0; i < lines.length; i++) {
        final InvoiceLineInput line = lines[i];
        await db.into(db.invoiceItems).insert(
              InvoiceItemsCompanion.insert(
                id: newId(),
                invoiceId: invoice.id,
                position: line.position,
                description: line.description,
                quantityMilli: line.quantityMilli,
                unit: Value(line.unit),
                unitPriceCents: line.unitPriceCents,
                totalCents: lineTotals[i],
              ),
            );
      }
    });

    return invoice;
  }

  Future<List<item.InvoiceItem>> loadItems(String invoiceId) async {
    final query = (db.select(db.invoiceItems)
          ..where((t) => t.invoiceId.equals(invoiceId)))
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    final rows = await query.get();
    return rows
        .map((r) => item.InvoiceItem(
              id: r.id,
              invoiceId: r.invoiceId,
              position: r.position,
              description: r.description,
              quantityMilli: r.quantityMilli,
              unit: r.unit,
              unitPriceCents: r.unitPriceCents,
              totalCents: r.totalCents,
            ))
        .toList();
  }
}

final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  return InvoiceService(
    db: ref.watch(databaseProvider),
    assigner: NumberAssigner(db: ref.watch(databaseProvider)),
  );
});