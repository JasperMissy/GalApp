import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/colleague.dart';
import 'package:galabau_app/models/invoice.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_package.dart' as model;
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/models/package_manifest.dart';
import 'package:galabau_app/models/work_note.dart';
import 'package:galabau_app/models/work_time_entry.dart';
import 'package:galabau_app/services/colleagues/colleague_repository.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/id_generator.dart';
import 'package:galabau_app/services/invoicing/invoice_repository.dart';
import 'package:galabau_app/services/orders/order_package_repository.dart';
import 'package:galabau_app/services/orders/order_repository.dart';
import 'package:galabau_app/services/orders/work_documentation_repository.dart';
import 'package:galabau_app/services/packages/order_feedback_service.dart';
import 'package:galabau_app/services/packages/order_share_service.dart';
import 'package:galabau_app/services/packages/package_service.dart';
import 'package:galabau_app/services/work/work_media_service.dart';
import 'package:galabau_app/services/settings/settings_keys.dart';
import 'package:galabau_app/services/settings/settings_repository.dart';
import 'package:galabau_app/views/shared/empty_state.dart';
import 'package:galabau_app/views/shared/error_state.dart';
import 'package:galabau_app/views/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'calculation_screen.dart';
import 'invoice_feedback_dialog.dart';
import 'invoice_form_dialog.dart';
import 'order_form_dialog.dart';
import 'work_documentation_tab.dart';

/// Auftragsordner mit den vier Unterordnern (Vision, Abschnitt 4.3).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(order.title),
          actions: <Widget>[
            if (order.origin == 'erhalten')
              IconButton(
                icon: const Icon(Icons.send),
                tooltip: 'Rückmeldung senden',
                onPressed: () => _sendFeedback(context, ref),
              ),
            if (order.origin == 'erhalten')
              IconButton(
                icon: const Icon(Icons.receipt_long),
                tooltip: 'Rechnung senden',
                onPressed: () => _sendInvoice(context, ref),
              ),
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Auftrag teilen',
              onPressed: () => _share(context, ref),
            ),
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
              Tab(text: 'Kalkulation'),
              Tab(text: 'Auftragsdetails'),
              Tab(text: 'Arbeitsdokumentation'),
              Tab(text: 'Assoziierte Rechnungen'),
              Tab(text: 'Rechnungen'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            CalculationScreen(order: order),
            _DetailsTab(order: order),
            WorkDocumentationTab(orderId: order.id, orderTitle: order.title),
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
    final Order? changed = await showDialog<Order>(
      context: context,
      builder: (_) => OrderFormDialog(clientId: order.clientId, order: order),
    );
    if (changed != null) {
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

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final String? clientId = order.clientId;
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nur eigene Aufträge können geteilt werden.'),
        ),
      );
      return;
    }

    final Colleague? colleague = await showModalBottomSheet<Colleague>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _ColleaguePicker(),
    );
    if (colleague == null || !context.mounted) return;

    final Client? client =
        await ref.read(clientRepositoryProvider).getById(clientId);
    if (client == null) return;

    final Map<String, String> settings =
        await ref.read(settingsRepositoryProvider).loadAll();
    final String senderName = settings[SettingsKeys.firmenname] ?? '';

    final String packageId = newId();
    final PackageManifest manifest = buildShareManifest(
      packageId: packageId,
      order: order,
      client: client,
      senderName: senderName,
    );
    final Uint8List bytes =
        const PackageService().createPackage(manifest: manifest);

    await ref.read(orderPackageRepositoryProvider).insert(
          model.OrderPackage(
            id: packageId,
            orderId: order.id,
            colleagueId: colleague.id,
            direction: 'outgoing',
            status: 'sent',
            createdAt: DateTime.now(),
          ),
        );

    final Directory tmp = await getTemporaryDirectory();
    final File file = File('${tmp.path}/$packageId.galabau');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: 'application/zip')],
        subject: order.title,
        text: 'Auftrag: ${order.title}',
      ),
    );
  }

  Future<void> _sendFeedback(BuildContext context, WidgetRef ref) async {
    final String? packageId = order.packageId;
    if (packageId == null) return;

    final repo = ref.read(workDocumentationRepositoryProvider);
    final List<WorkTimeEntry> times = await repo.watchTimes(order.id).first;
    final WorkNote? note = await repo.loadNote(order.id);

    final Map<String, String> settings =
        await ref.read(settingsRepositoryProvider).loadAll();
    final String senderName = settings[SettingsKeys.firmenname] ?? '';

    final PackageManifest manifest = buildFeedbackManifest(
      packageId: packageId,
      title: order.title,
      senderName: senderName,
    );
    final String docJson = buildWorkDocumentationJson(
      times: times,
      note: note?.text ?? '',
    );

    final Directory base = await getApplicationDocumentsDirectory();
    final WorkMediaService mediaService = WorkMediaService(baseDirectory: base);
    final Map<String, Uint8List> files =
        await mediaService.loadMedia(order.title);
    files['arbeitsdokumentation.json'] =
        Uint8List.fromList(utf8.encode(docJson));

    final Uint8List bytes =
        const PackageService().createPackage(manifest: manifest, files: files);

    final Directory tmp = await getTemporaryDirectory();
    final File file = File('${tmp.path}/$packageId.galabau');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: 'application/zip')],
        subject: order.title,
        text: 'Rückmeldung: ${order.title}',
      ),
    );
  }

  Future<void> _sendInvoice(BuildContext context, WidgetRef ref) async {
    final String? packageId = order.packageId;
    if (packageId == null) return;

    final InvoiceFeedbackData? data = await showDialog<InvoiceFeedbackData>(
      context: context,
      builder: (_) => const InvoiceFeedbackDialog(),
    );
    if (data == null || !context.mounted) return;

    final Map<String, String> settings =
        await ref.read(settingsRepositoryProvider).loadAll();
    final String senderName = settings[SettingsKeys.firmenname] ?? '';

    final PackageManifest manifest = buildInvoiceManifest(
      packageId: packageId,
      data: data,
      senderName: senderName,
    );
    final Map<String, Uint8List> files = <String, Uint8List>{};
    if (data.pdfBytes != null) {
      files['rechnung.pdf'] = data.pdfBytes!;
    }
    final Uint8List bytes =
        const PackageService().createPackage(manifest: manifest, files: files);

    final Directory tmp = await getTemporaryDirectory();
    final File file = File('${tmp.path}/$packageId-rechnung.galabau');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: 'application/zip')],
        subject: 'Rechnung ${data.number}',
        text: 'Rechnung: ${data.number}',
      ),
    );
  }
}

class _ColleaguePicker extends ConsumerWidget {
  const _ColleaguePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Colleague>> colleagues =
        ref.watch(colleaguesProvider);

    return colleagues.when(
      data: (List<Colleague> all) => all.isEmpty
          ? const EmptyState(
              icon: Icons.groups_outlined,
              title: 'Keine Kollegen',
              message: 'Legen Sie zuerst einen Kollegen an.',
            )
          : ListView.builder(
              itemCount: all.length,
              itemBuilder: (BuildContext context, int index) {
                final Colleague colleague = all[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(colleague.name),
                  onTap: () => Navigator.of(context).pop(colleague),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const EmptyState(
        icon: Icons.error_outline,
        title: 'Fehler',
        message: 'Kollegen konnten nicht geladen werden.',
      ),
    );
  }
}

class _DetailsTab extends ConsumerWidget {
  const _DetailsTab({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? clientId = order.clientId;
    final AsyncValue<Client?> client = clientId == null
        ? const AsyncValue.data(null)
        : ref.watch(clientByIdProvider(clientId));

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
    final String? clientId = order.clientId;
    if (clientId == null) return;
    showDialog<bool>(
      context: context,
      builder: (_) =>
          InvoiceFormDialog(clientId: clientId, orderId: order.id),
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