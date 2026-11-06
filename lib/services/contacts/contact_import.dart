import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// Importierte Kontaktdaten aus dem Geräte-Adressbuch.
class ImportedContact {
  const ImportedContact({
    required this.name,
    required this.phone,
    required this.email,
    required this.street,
    required this.zip,
    required this.city,
  });

  final String name;
  final String phone;
  final String email;
  final String street;
  final String zip;
  final String city;
}

/// Öffnet einen Kontakt-Picker aus dem Adressbuch und liefert die Auswahl.
///
/// Fragt die Berechtigung ab, zeigt die alphabetisch sortierte Kontaktliste
/// und mappt die Auswahl auf die Felder für Kunde/Kollege.
Future<ImportedContact?> pickContact(BuildContext context) async {
  final PermissionStatus status =
      await FlutterContacts.permissions.request(PermissionType.read);
  final bool granted =
      status == PermissionStatus.granted || status == PermissionStatus.limited;
  if (!granted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine Berechtigung für das Adressbuch.'),
        ),
      );
    }
    return null;
  }

  final List<Contact> contacts = await FlutterContacts.getAll(
    properties: ContactProperties.allProperties,
  );
  if (!context.mounted) return null;

  if (contacts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Keine Kontakte im Adressbuch gefunden.')),
    );
    return null;
  }

  final List<Contact> sorted = List<Contact>.of(contacts)
    ..sort((Contact a, Contact b) =>
        (a.displayName ?? '').compareTo(b.displayName ?? ''));

  final Contact? selected = await showModalBottomSheet<Contact>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) => _ContactPicker(contacts: sorted),
  );
  if (selected == null) return null;

  return ImportedContact(
    name: selected.displayName ?? '',
    phone: selected.phones.isNotEmpty ? selected.phones.first.number : '',
    email: selected.emails.isNotEmpty ? selected.emails.first.address : '',
    street: selected.addresses.isNotEmpty
        ? (selected.addresses.first.street ?? '')
        : '',
    zip: selected.addresses.isNotEmpty
        ? (selected.addresses.first.postalCode ?? '')
        : '',
    city: selected.addresses.isNotEmpty
        ? (selected.addresses.first.city ?? '')
        : '',
  );
}

class _ContactPicker extends StatelessWidget {
  const _ContactPicker({required this.contacts});

  final List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (BuildContext context, int index) {
        final Contact contact = contacts[index];
        final String subtitle = <String>[
          if (contact.phones.isNotEmpty) contact.phones.first.number,
          if (contact.emails.isNotEmpty) contact.emails.first.address,
        ].join(' · ');
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(contact.displayName ?? '(ohne Name)'),
          subtitle: subtitle.isEmpty ? null : Text(subtitle),
          onTap: () => Navigator.of(context).pop(contact),
        );
      },
    );
  }
}
