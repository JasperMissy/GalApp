import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/id_generator.dart';
import 'package:galabau_app/services/orders/order_repository.dart';

/// Formular zum Anlegen eines Auftrags (Kunde, Titel, Beschreibung,
/// Ausführungsdatum, wiederkehrend, Notizen).
class OrderFormDialog extends ConsumerStatefulWidget {
  const OrderFormDialog({super.key});

  @override
  ConsumerState<OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends ConsumerState<OrderFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  String? _clientId;
  DateTime? _dueDate;
  bool _recurring = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final String? clientId = _clientId;
    if (clientId == null) return;
    setState(() => _saving = true);
    await ref.read(orderRepositoryProvider).insert(
          Order(
            id: newId(),
            clientId: clientId,
            title: _title.text.trim(),
            description: _description.text.trim(),
            createdAt: DateTime.now(),
            dueDateStart: _dueDate,
            dueDateEnd: null,
            status: OrderStatus.offen,
            recurring: _recurring,
            notes: _notes.text.trim(),
          ),
        );
    ref.invalidate(ordersProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Client>> clients = ref.watch(clientsProvider);

    return AlertDialog(
      title: const Text('Auftrag anlegen'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: clients.when(
            data: (List<Client> all) => all.isEmpty
                ? const Text('Legen Sie zuerst einen Kunden an.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Kunde *'),
                        initialValue: _clientId,
                        items: <DropdownMenuItem<String>>[
                          for (final Client c in all)
                            DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                        ],
                        onChanged: (String? v) => setState(() => _clientId = v),
                        validator: (String? v) => v == null ? 'Kunde wählen' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _title,
                        decoration: const InputDecoration(labelText: 'Titel *'),
                        validator: (String? v) =>
                            (v == null || v.trim().isEmpty) ? 'Titel erforderlich' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(labelText: 'Beschreibung'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event),
                        title: Text(
                          _dueDate == null
                              ? 'Ausführungsdatum wählen'
                              : _formatDate(_dueDate!),
                        ),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _dueDate = picked);
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Wiederkehrend'),
                        value: _recurring,
                        onChanged: (bool v) => setState(() => _recurring = v),
                      ),
                      TextFormField(
                        controller: _notes,
                        decoration: const InputDecoration(labelText: 'Notizen'),
                        maxLines: 2,
                      ),
                    ],
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, StackTrace _) => Text('Fehler: $e'),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}