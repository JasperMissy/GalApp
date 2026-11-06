import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/invoice.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/invoicing/invoice_repository.dart';
import 'package:galabau_app/services/orders/order_repository.dart';
import 'package:galabau_app/views/shared/empty_state.dart';
import 'package:galabau_app/views/shared/error_state.dart';
import 'package:galabau_app/views/theme/app_colors.dart';

import 'invoice_form_dialog.dart';
import 'order_form_dialog.dart';

/// Auftragsordner mit den vier Unterordnern (Vision, Abschnitt 4.3).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(order.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: 'Auftragsdetails'),
              Tab(text: 'Arbeitsdokumentation'),
              Tab(text: 'Assoziierte Rechnungen'),
              Tab(text: 'Rechnungen'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _DetailsTab(order: order),
            const EmptyState(
              icon: Icons.photo_camera_outlined,
              title: 'Arbeitsdokumentation',
              message: 'Nachher-Bilder, Zeiterfassung und Anmerkungen folgen.',
            ),
            const EmptyState(
              icon: Icons.attach_file_outlined,
              title: 'Assoziierte Rechnungen',
              message: 'Material- und Subunternehmer-Rechnungen können hier später importiert werden.',
            ),
            _InvoicesTab(order: order),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final bool? changed = await showDialog<bool>(
      context: context,
      builder: (_) => OrderFormDialog(clientId: order.clientId, order: order),
    );
    if (changed == true) {
      ref.invalidate(ordersProvider);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Auftrag löschen?'),
        content: Text('„${order.title}“ wird gelöscht. Rechnungen bleiben erhalten.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(orderRepositoryProvider).delete(order.id);
      ref.invalidate(ordersProvider);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _DetailsTab extends ConsumerWidget {
  const _DetailsTab({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Client?> client =
        ref.watch(clientByIdProvider(order.clientId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _statusBadge(order),
            if (order.recurring)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusRecurring,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'wiederkehrend',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        client.when(
          data: (Client? c) => c == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      c.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text('${c.street}\n${c.zip} ${c.city}'.trim()),
                  ],
                ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),
        Text('Erfassungsdatum: ${_date(order.createdAt)}'),
        if (order.dueDateStart != null)
          Text('Ausführungsdatum: ${_date(order.dueDateStart!)}'),
        if (order.description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text('Beschreibung',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(order.description),
        ],
        if (order.notes.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text('Notizen',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(order.notes),
        ],
      ],
    );
  }

  Widget _statusBadge(Order order) {
    final bool erledigt = order.status == OrderStatus.erledigt;
    final Color color =
        erledigt ? AppColors.statusDone : AppColors.statusOpen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        erledigt ? 'Erledigt' : 'Offen',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Invoice>> invoices =
        ref.watch(invoicesByOrderProvider(order.id));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generate(context, ref),
        icon: const Icon(Icons.receipt_long),
        label: const Text('Rechnung generieren'),
      ),
      body: invoices.when(
        data: (List<Invoice> all) => all.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Noch keine Rechnungen',
                message: 'Generieren Sie über den Button Ihre erste Rechnung.',
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
          onRetry: () => ref.invalidate(invoicesByOrderProvider(order.id)),
        ),
      ),
    );
  }

  void _generate(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (_) =>
          InvoiceFormDialog(clientId: order.clientId, orderId: order.id),
    ).then((bool? created) {
      if (created == true) {
        ref.invalidate(invoicesByOrderProvider(order.id));
        ref.invalidate(issuedInvoicesProvider);
      }
    });
  }
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