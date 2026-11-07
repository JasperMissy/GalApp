import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Daten einer hinzugefügten assoziierten Rechnung (Material/Personal).
class AssociatedInvoiceData {
  const AssociatedInvoiceData({
    required this.category,
    required this.fileName,
    required this.bytes,
  });

  final String category;
  final String fileName;
  final Uint8List bytes;
}

/// Dialog zum Hinzufügen einer assoziierten Rechnung (Datei + Kategorie).
class AssociatedInvoiceDialog extends StatefulWidget {
  const AssociatedInvoiceDialog({super.key});

  @override
  State<AssociatedInvoiceDialog> createState() =>
      _AssociatedInvoiceDialogState();
}

class _AssociatedInvoiceDialogState extends State<AssociatedInvoiceDialog> {
  String _category = 'material';
  String? _fileName;
  Uint8List? _bytes;

  Future<void> _pickFile() async {
    final List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.any,
      allowedExtensions: const <String>['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (files.isEmpty) return;
    final Uint8List bytes = await files.single.readAsBytes();
    setState(() {
      _fileName = files.single.name;
      _bytes = bytes;
    });
  }

  void _save() {
    if (_fileName == null || _bytes == null) return;
    Navigator.of(context).pop(AssociatedInvoiceData(
      category: _category,
      fileName: _fileName!,
      bytes: _bytes!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assoziierte Rechnung hinzufügen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Kategorie'),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'material', child: Text('Materialkosten')),
              DropdownMenuItem(
                  value: 'personal', child: Text('Personal (Subunternehmer)')),
            ],
            onChanged: (String? v) =>
                setState(() => _category = v ?? 'material'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.attach_file),
            label: Text(
                _fileName == null ? 'Datei auswählen (PDF/Foto)' : _fileName!),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(onPressed: _save, child: const Text('Hinzufügen')),
      ],
    );
  }
}
