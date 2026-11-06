import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:galabau_app/models/invoice.dart';
import 'package:galabau_app/services/invoicing/invoice_repository.dart';
import 'package:galabau_app/views/shared/empty_state.dart';
import 'package:galabau_app/views/shared/error_state.dart';

/// Rechnungsordner eines Kunden: alle gestellten Rechnungen als Querverweis.
class ClientInvoicesScreen extends ConsumerWidget {
  const ClientInvoicesScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Invoice>> invoices =
        ref.watch(invoicesByClientProvider(clientId));

    return Scaffold(
      appBar: AppBar(title: const Text('Rechnungsordner')),
      body: invoices.when(
        data: (List<Invoice> all) => all.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Keine Rechnungen',
                message: 'An diesen Kunden wurden noch keine Rechnungen gestellt.',
              )
            : ListView.builder(
                itemCount: all.length,
                itemBuilder: (BuildContext context, int index) {
                  final Invoice invoice = all[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(invoice.number ?? ''),
                      subtitle: Text(invoice.issuedDate == null
                          ? ''
                          : _date(invoice.issuedDate!)),
                      trailing: Text('${_euro(invoice.grossCents)} €'),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(
          onRetry: () => ref.invalidate(invoicesByClientProvider(clientId)),
        ),
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';

  String _euro(int cents) {
    final int whole = cents ~/ 100;
    final String frac = (cents % 100).toString().padLeft(2, '0');
    return '$whole,$frac';
  }
}