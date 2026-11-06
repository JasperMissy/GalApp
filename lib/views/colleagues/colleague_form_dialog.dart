import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/colleague.dart';
import 'package:galabau_app/services/colleagues/colleague_repository.dart';
import 'package:galabau_app/services/id_generator.dart';

/// Vorauswahl an Qualifikationen (Vision, Abschnitt 3.4).
const List<String> kPresetQualifications = <String>[
  'SKT-A',
  'SKT-B',
  'Anhängerführerschein',
  'eigener Anhänger',
];

/// Formular zum Anlegen eines Kollegen (Kontaktdaten, Qualifikationen, Notiz).
class ColleagueFormDialog extends ConsumerStatefulWidget {
  const ColleagueFormDialog({super.key});

  @override
  ConsumerState<ColleagueFormDialog> createState() =>
      _ColleagueFormDialogState();
}

class _ColleagueFormDialogState extends ConsumerState<ColleagueFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _zip = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _customQualification = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final Set<String> _qualifications = <String>{};
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _street.dispose();
    _zip.dispose();
    _city.dispose();
    _phone.dispose();
    _email.dispose();
    _customQualification.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await ref.read(colleagueRepositoryProvider).insert(
          Colleague(
            id: newId(),
            name: _name.text.trim(),
            street: _street.text.trim(),
            zip: _zip.text.trim(),
            city: _city.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            qualifications: _qualifications.toList()..sort(),
            notes: _notes.text.trim(),
            createdAt: DateTime.now(),
          ),
        );
    ref.invalidate(colleaguesProvider);
    if (mounted) Navigator.of(context).pop(true);
  }

  void _addCustomQualification() {
    final String value = _customQualification.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _qualifications.add(value);
      _customQualification.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> custom = _qualifications
        .where((String q) => !kPresetQualifications.contains(q))
        .toList()
      ..sort();

    return AlertDialog(
      title: const Text('Kollege hinzufügen'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Name erforderlich' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _street,
                decoration:
                    const InputDecoration(labelText: 'Straße + Hausnr.'),
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
              const SizedBox(height: 16),
              Text('Qualifikationen',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final String q in kPresetQualifications)
                    FilterChip(
                      label: Text(q),
                      selected: _qualifications.contains(q),
                      onSelected: (bool selected) => setState(() {
                        selected
                            ? _qualifications.add(q)
                            : _qualifications.remove(q);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _customQualification,
                      decoration: const InputDecoration(
                        labelText: 'Eigene Qualifikation',
                      ),
                      onSubmitted: (_) => _addCustomQualification(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Hinzufügen',
                    onPressed: _addCustomQualification,
                  ),
                ],
              ),
              if (custom.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final String q in custom)
                      InputChip(
                        label: Text(q),
                        onDeleted: () =>
                            setState(() => _qualifications.remove(q)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notiz / Kommentar',
                ),
                maxLines: 3,
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
