import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/services/orders/order_repository.dart';

import 'invoice_form_dialog.dart';

/// Auftragsdetails mit Status-Wechsel und Aktion „Rechnung generieren“.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool erledigt = order.status == OrderStatus.erledigt;

    return Scaffold(
      appBar: AppBar(title: Text(order.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (order.description.isNotEmpty) ...<Widget>[
            Text(
              order.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          Card(
            child: ListTile(
              leading: Icon(
                erledigt ? Icons.check_circle : Icons.radio_button_unchecked,
                color: erledigt
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              ),
              title: Text(erledigt ? 'Erledigt' : 'Offen'),
              subtitle: order.recurring ? const Text('wiederkehrend') : null,
            ),
          ),
          if (order.notes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Text('Notizen', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(order.notes),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _generateInvoice(context),
            icon: const Icon(Icons.receipt_long),
            label: const Text('Rechnung generieren'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await ref
                  .read(orderRepositoryProvider)
                  .updateStatus(order.id, erledigt ? OrderStatus.offen : OrderStatus.erledigt);
              ref.invalidate(ordersProvider);
            },
            icon: Icon(erledigt ? Icons.undo : Icons.check),
            label: Text(erledigt ? 'Wieder öffnen' : 'Als erledigt markieren'),
          ),
        ],
      ),
    );
  }

  void _generateInvoice(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) => InvoiceFormDialog(clientId: order.clientId, orderId: order.id),
    );
  }
}