import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/services/contacts/contact_import.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/id_generator.dart';

/// Formular zum Anlegen eines Kunden (Name, Adresse, Telefon, E-Mail).
class ClientFormDialog extends ConsumerStatefulWidget {
  const ClientFormDialog({super.key});

  @override
  ConsumerState<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends ConsumerState<ClientFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _zip = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _street.dispose();
    _zip.dispose();
    _city.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await ref.read(clientRepositoryProvider).insert(
          Client(
            id: newId(),
            name: _name.text.trim(),
            street: _street.text.trim(),
            zip: _zip.text.trim(),
            city: _city.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            createdAt: DateTime.now(),
          ),
        );
    ref.invalidate(clientsProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _importContact() async {
    final ImportedContact? contact = await pickContact(context);
    if (contact == null) return;
    setState(() {
      _name.text = contact.name;
      _phone.text = contact.phone;
      _email.text = contact.email;
      _street.text = contact.street;
      _zip.text = contact.zip;
      _city.text = contact.city;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kunde hinzufügen'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _importContact,
                icon: const Icon(Icons.contacts_outlined),
                label: const Text('Aus Kontakten importieren'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Name erforderlich' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _street,
                decoration: const InputDecoration(labelText: 'Straße'),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _zip,
                      decoration: const InputDecoration(labelText: 'PLZ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _city,
                      decoration: const InputDecoration(labelText: 'Ort'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
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