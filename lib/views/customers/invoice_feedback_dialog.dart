import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:galabau_app/services/packages/order_feedback_service.dart';

/// Dialog zum Erfassen der Rechnungsdaten für das Zurücksenden.
class InvoiceFeedbackDialog extends StatefulWidget {
  const InvoiceFeedbackDialog({super.key});

  @override
  State<InvoiceFeedbackDialog> createState() => _InvoiceFeedbackDialogState();
}

class _InvoiceFeedbackDialogState extends State<InvoiceFeedbackDialog> {
  final TextEditingController _number = TextEditingController();
  final TextEditingController _net = TextEditingController();
  final TextEditingController _gross = TextEditingController();
  Uint8List? _pdfBytes;
  String? _pdfName;

  @override
  void dispose() {
    _number.dispose();
    _net.dispose();
    _gross.dispose();
    super.dispose();
  }

  int? _parseEuro(String value) {
    final double? parsed = double.tryParse(value.replaceAll(',', '.'));
    return parsed == null ? null : (parsed * 100).round();
  }

  Future<void> _pickPdf() async {
    final List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.any,
      allowedExtensions: const <String>['pdf'],
    );
    if (files.isEmpty) return;
    final Uint8List bytes = await files.single.readAsBytes();
    setState(() {
      _pdfBytes = bytes;
      _pdfName = files.single.name;
    });
  }

  void _send() {
    final int? net = _parseEuro(_net.text);
    final int? gross = _parseEuro(_gross.text);
    if (_number.text.trim().isEmpty || net == null || gross == null) return;
    Navigator.of(context).pop(InvoiceFeedbackData(
      number: _number.text.trim(),
      netCents: net,
      grossCents: gross,
      pdfBytes: _pdfBytes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rechnung senden'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _number,
              decoration: const InputDecoration(labelText: 'Rechnungsnummer *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _net,
              decoration: const InputDecoration(labelText: 'Netto (€) *'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _gross,
              decoration: const InputDecoration(labelText: 'Brutto (€) *'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.attach_file),
              label: Text(_pdfName == null ? 'PDF anhängen (optional)' : _pdfName!),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(onPressed: _send, child: const Text('Senden')),
      ],
    );
  }
}
