import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/id_generator.dart';
import 'package:galabau_app/services/orders/order_repository.dart';
import 'package:galabau_app/services/work/work_media_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Formular zum Anlegen eines Auftrags (Kunde, Titel, Beschreibung,
/// Ausführungsdatum, wiederkehrend, Notizen).
class OrderFormDialog extends ConsumerStatefulWidget {
  const OrderFormDialog({super.key, this.clientId, this.order});

  /// Optionaler Start-Kunde (Edit-Modus).
  final String? clientId;

  /// Im Edit-Modus der zu bearbeitende Auftrag.
  final Order? order;

  @override
  ConsumerState<OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends ConsumerState<OrderFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final SpeechToText _speech = SpeechToText();
  final List<_MediaDraft> _media = <_MediaDraft>[];
  String? _clientId;
  bool _listening = false;
  bool _recording = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final Order? order = widget.order;
    if (order != null) {
      _clientId = order.clientId;
      _title.text = order.title;
      _description.text = order.description;
      _notes.text = order.notes;
    } else if (widget.clientId != null) {
      _clientId = widget.clientId;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _notes.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final String? clientId = _clientId;
    if (clientId == null) return;
    setState(() => _saving = true);

    try {
      final Order? existing = widget.order;
      final Order order = Order(
        id: existing?.id ?? newId(),
        clientId: clientId,
        title: _title.text.trim(),
        description: _description.text.trim(),
        createdAt: existing?.createdAt ?? DateTime.now(),
        dueDateStart: existing?.dueDateStart,
        dueDateEnd: existing?.dueDateEnd,
        status: existing?.status ?? OrderStatus.offen,
        recurring: existing?.recurring ?? false,
        notes: _notes.text.trim(),
        origin: existing?.origin ?? 'eigen',
        packageId: existing?.packageId,
        externalAddress: existing?.externalAddress,
        senderName: existing?.senderName,
      );

      if (existing == null) {
        await ref.read(orderRepositoryProvider).insert(order);
      } else {
        await ref.read(orderRepositoryProvider).update(order);
      }

      await _saveMedia(order.title);

      ref.invalidate(ordersProvider);
      if (mounted) Navigator.of(context).pop(order);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auftrag konnte nicht gespeichert werden: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveMedia(String orderTitle) async {
    if (_media.isEmpty) return;
    try {
      final Directory base = await getApplicationDocumentsDirectory();
      final WorkMediaService service = WorkMediaService(baseDirectory: base);
      for (final _MediaDraft media in _media) {
        try {
          final int slash = media.name.indexOf('/');
          final String subfolder =
              slash >= 0 ? media.name.substring(0, slash) : '';
          final String fileName =
              slash >= 0 ? media.name.substring(slash + 1) : media.name;
          await service.saveMedia(
            orderTitle: orderTitle,
            subfolder: subfolder,
            fileName: fileName,
            bytes: media.bytes,
          );
        } catch (_) {
          // Ein Fehler beim Medien-Speichern verhindert das Speichern nicht.
        }
      }
    } catch (_) {
      // Basisverzeichnis nicht ermittelbar – Auftrag wird trotzdem gespeichert.
    }
  }

  String _sanitize(String name) {
    final String cleaned = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return cleaned.isEmpty
        ? 'datei_${DateTime.now().millisecondsSinceEpoch}'
        : cleaned;
  }

  Future<void> _toggleDictation() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final bool available = await _speech.initialize(
      onStatus: (String status) {
        if (mounted && status == 'done') setState(() => _listening = false);
      },
      onError: (Object error) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!available) return;
    setState(() => _listening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'de_DE'),
      onResult: (result) {
        if (mounted) {
          setState(() => _description.text = result.recognizedWords);
        }
      },
    );
  }

  Future<void> _showMediaSheet() async {
    final String? choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Foto (Kamera)'),
              onTap: () => Navigator.pop(context, 'foto'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Foto (Galerie)'),
              onTap: () => Navigator.pop(context, 'galerie'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Sprachmemo'),
              onTap: () => Navigator.pop(context, 'memo'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    switch (choice) {
      case 'foto':
        await _takePhoto(ImageSource.camera);
        break;
      case 'galerie':
        await _takePhoto(ImageSource.gallery);
        break;
      case 'video':
        await _takeVideo();
        break;
      case 'memo':
        await _toggleVoiceMemo();
        break;
      case 'pdf':
        await _pickPdf();
        break;
    }
  }

  Future<void> _takePhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;
    final Uint8List bytes = await image.readAsBytes();
    setState(() => _media.add(_MediaDraft('fotos/${_sanitize(image.name)}', bytes)));
  }

  Future<void> _takeVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video == null) return;
    final Uint8List bytes = await video.readAsBytes();
    setState(
        () => _media.add(_MediaDraft('videos/${_sanitize(video.name)}', bytes)));
  }

  Future<void> _pickPdf() async {
    final List<PlatformFile> files = await FilePicker.pickFiles(
      type: FileType.any,
      allowedExtensions: const <String>['pdf'],
    );
    if (files.isEmpty) return;
    final Uint8List bytes = await files.single.readAsBytes();
    setState(
      () => _media.add(_MediaDraft('pdf/${_sanitize(files.single.name)}', bytes)),
    );
  }

  Future<void> _toggleVoiceMemo() async {
    if (_recording) {
      final String? path = await _recorder.stop();
      setState(() => _recording = false);
      if (path != null) {
        final File file = File(path);
        final Uint8List bytes = await file.readAsBytes();
        setState(() => _media.add(_MediaDraft(
              'sprachmemos/memo_${DateTime.now().millisecondsSinceEpoch}.m4a',
              bytes,
            )));
        await file.delete();
      }
      return;
    }
    if (!await _recorder.hasPermission()) return;
    final Directory tmp = await getTemporaryDirectory();
    final String path =
        '${tmp.path}/memo_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() => _recording = true);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Client>> clients = ref.watch(clientsProvider);

    return AlertDialog(
      title: Text(widget.order == null ? 'Auftrag anlegen' : 'Auftrag bearbeiten'),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _description,
                              decoration: const InputDecoration(
                                  labelText: 'Auftragsbeschreibung'),
                              maxLines: 3,
                            ),
                          ),
                          IconButton(
                            icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                            color: _listening
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            tooltip: 'Diktieren',
                            onPressed: _toggleDictation,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _showMediaSheet,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text(
                            'Fotos, Videos, Sprachmemos oder PDF hinzufügen'),
                      ),
                      for (int i = 0; i < _media.length; i++)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.attach_file),
                          title: Text(_media[i].name),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Entfernen',
                            onPressed: () =>
                                setState(() => _media.removeAt(i)),
                          ),
                        ),
                      const SizedBox(height: 8),
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
          onPressed: () => Navigator.of(context).pop(),
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

class _MediaDraft {
  _MediaDraft(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}