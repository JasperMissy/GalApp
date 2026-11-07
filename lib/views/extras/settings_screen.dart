import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/services/settings/settings_keys.dart';
import 'package:galabau_app/services/settings/settings_repository.dart';
import 'package:galabau_app/views/shared/error_state.dart';

/// Stammdaten & Rechnungs-Design (Firmendaten, Steuer, IBAN, Akzentfarbe).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = <String, TextEditingController>{
    SettingsKeys.firmenname: TextEditingController(),
    SettingsKeys.strasse: TextEditingController(),
    SettingsKeys.plz: TextEditingController(),
    SettingsKeys.ort: TextEditingController(),
    SettingsKeys.telefon: TextEditingController(),
    SettingsKeys.email: TextEditingController(),
    SettingsKeys.steuernummer: TextEditingController(),
    SettingsKeys.ustId: TextEditingController(),
    SettingsKeys.iban: TextEditingController(),
    SettingsKeys.akzentfarbe: TextEditingController(),
  };
  bool _loaded = false;
  bool _saving = false;
  bool _isKleinunternehmer = false;

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final Map<String, String> entries = <String, String>{};
    for (final MapEntry<String, TextEditingController> e in _controllers.entries) {
      entries[e.key] = e.value.text.trim();
    }
    entries[SettingsKeys.kleinunternehmer] = _isKleinunternehmer ? 'ja' : 'nein';
    await ref.read(settingsRepositoryProvider).saveAll(entries);
    ref.invalidate(settingsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map<String, String>> settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stammdaten & Rechnungsdesign')),
      body: settings.when(
        data: (Map<String, String> values) {
          if (!_loaded) {
            for (final String key in _controllers.keys) {
              _controllers[key]!.text = values[key] ?? '';
            }
            _isKleinunternehmer =
                values[SettingsKeys.kleinunternehmer] == 'ja';
            _loaded = true;
          }
          return _form();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(onRetry: () => ref.invalidate(settingsProvider)),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const _SectionLabel('Firmendaten'),
          TextFormField(
            controller: _controllers[SettingsKeys.firmenname],
            decoration: const InputDecoration(labelText: 'Firmenname'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[SettingsKeys.strasse],
            decoration: const InputDecoration(labelText: 'Straße'),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _controllers[SettingsKeys.plz],
                  decoration: const InputDecoration(labelText: 'PLZ'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _controllers[SettingsKeys.ort],
                  decoration: const InputDecoration(labelText: 'Ort'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Kontakt'),
          TextFormField(
            controller: _controllers[SettingsKeys.telefon],
            decoration: const InputDecoration(labelText: 'Telefon'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[SettingsKeys.email],
            decoration: const InputDecoration(labelText: 'E-Mail'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Steuer & Zahlung'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Kleinunternehmer (§19 UStG)'),
            subtitle: const Text(
                'Rechnungen ohne MwSt-Ausweis, kein Vorsteuerabzug.'),
            value: _isKleinunternehmer,
            onChanged: (bool value) =>
                setState(() => _isKleinunternehmer = value),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[SettingsKeys.steuernummer],
            decoration: const InputDecoration(labelText: 'Steuernummer'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[SettingsKeys.ustId],
            decoration: const InputDecoration(labelText: 'USt-IdNr.'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[SettingsKeys.iban],
            decoration: const InputDecoration(labelText: 'IBAN'),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Design'),
          TextFormField(
            controller: _controllers[SettingsKeys.akzentfarbe],
            decoration: const InputDecoration(
              labelText: 'Akzentfarbe (Hex)',
              hintText: '#2E7D32',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
