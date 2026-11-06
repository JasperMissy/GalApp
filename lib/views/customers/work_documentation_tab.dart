import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/work_note.dart';
import 'package:galabau_app/models/work_time_entry.dart';
import 'package:galabau_app/services/orders/work_documentation_repository.dart';
import 'package:galabau_app/services/work/work_media_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Arbeitsdokumentation eines Auftrags: Zeiterfassung (Start/Pause/Ende)
/// und Anmerkung mit Diktierfunktion.
class WorkDocumentationTab extends ConsumerStatefulWidget {
  const WorkDocumentationTab({
    super.key,
    required this.orderId,
    required this.orderTitle,
  });

  final String orderId;
  final String orderTitle;

  @override
  ConsumerState<WorkDocumentationTab> createState() =>
      _WorkDocumentationTabState();
}

class _WorkDocumentationTabState extends ConsumerState<WorkDocumentationTab> {
  final TextEditingController _noteController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  bool _listening = false;
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final WorkNote? note = await ref
        .read(workDocumentationRepositoryProvider)
        .loadNote(widget.orderId);
    if (mounted) {
      setState(() => _noteController.text = note?.text ?? '');
    }
  }

  Future<void> _saveNote() async {
    await ref
        .read(workDocumentationRepositoryProvider)
        .saveNote(widget.orderId, _noteController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anmerkung gespeichert')),
      );
    }
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
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spracherkennung nicht verfügbar.')),
        );
      }
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'de_DE'),
      onResult: (result) {
        if (mounted) {
          setState(() => _noteController.text = result.recognizedWords);
        }
      },
    );
  }

  void _startTime() {
    ref.read(workDocumentationRepositoryProvider).startTime(widget.orderId);
  }

  void _finishTime() {
    ref.read(workDocumentationRepositoryProvider).finishTime(widget.orderId);
  }

  Future<WorkMediaService> _mediaService() async {
    final Directory base = await getApplicationDocumentsDirectory();
    return WorkMediaService(baseDirectory: base);
  }

  Future<void> _takePhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;
    final Uint8List bytes = await image.readAsBytes();
    final WorkMediaService service = await _mediaService();
    await service.saveMedia(
      orderTitle: widget.orderTitle,
      subfolder: 'fotos',
      fileName: image.name,
      bytes: bytes,
    );
    _showSaved('Foto gespeichert');
  }

  Future<void> _takeVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video == null) return;
    final Uint8List bytes = await video.readAsBytes();
    final WorkMediaService service = await _mediaService();
    await service.saveMedia(
      orderTitle: widget.orderTitle,
      subfolder: 'videos',
      fileName: video.name,
      bytes: bytes,
    );
    _showSaved('Video gespeichert');
  }

  Future<void> _toggleVoiceMemo() async {
    if (_recording) {
      final String? path = await _recorder.stop();
      setState(() => _recording = false);
      if (path != null) {
        final File file = File(path);
        final Uint8List bytes = await file.readAsBytes();
        final WorkMediaService service = await _mediaService();
        await service.saveMedia(
          orderTitle: widget.orderTitle,
          subfolder: 'sprachmemos',
          fileName: 'memo_${DateTime.now().millisecondsSinceEpoch}.m4a',
          bytes: bytes,
        );
        await file.delete();
        _showSaved('Sprachmemo gespeichert');
      }
      return;
    }
    if (!await _recorder.hasPermission()) {
      _showSaved('Keine Mikrofon-Berechtigung.');
      return;
    }
    final Directory tmp = await getTemporaryDirectory();
    final String path =
        '${tmp.path}/memo_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() => _recording = true);
  }

  void _showSaved(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<WorkTimeEntry>> times =
        ref.watch(workTimesProvider(widget.orderId));
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Zeiterfassung',
            style:
                textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilledButton.icon(
              onPressed: _startTime,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
            OutlinedButton.icon(
              onPressed: _finishTime,
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),
            OutlinedButton.icon(
              onPressed: _finishTime,
              icon: const Icon(Icons.stop),
              label: const Text('Ende'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        times.when(
          data: (List<WorkTimeEntry> entries) => entries.isEmpty
              ? const Text('Noch keine Zeiten erfasst.')
              : Column(
                  children: <Widget>[
                    for (final WorkTimeEntry e in entries)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.schedule),
                        title: Text(
                          '${_time(e.startedAt)} – '
                          '${e.endedAt == null ? 'läuft' : _time(e.endedAt!)}',
                        ),
                      ),
                  ],
                ),
          loading: () => const Text('Lädt …'),
          error: (_, _) => const Text('Zeiten konnten nicht geladen werden.'),
        ),
        const Divider(height: 32),
        Text('Anmerkung',
            style:
                textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Anmerkung zur Arbeit …',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_listening ? Icons.mic : Icons.mic_none),
              color: _listening ? Theme.of(context).colorScheme.primary : null,
              tooltip: 'Diktieren',
              onPressed: _toggleDictation,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _saveNote,
            child: const Text('Speichern'),
          ),
        ),
        const Divider(height: 32),
        Text('Medien',
            style:
                textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: () => _takePhoto(ImageSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Foto'),
            ),
            OutlinedButton.icon(
              onPressed: () => _takePhoto(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galerie'),
            ),
            OutlinedButton.icon(
              onPressed: _takeVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('Video'),
            ),
            OutlinedButton.icon(
              onPressed: _toggleVoiceMemo,
              icon: Icon(_recording ? Icons.stop : Icons.mic),
              label: Text(_recording ? 'Aufnahme stoppen' : 'Sprachmemo'),
            ),
          ],
        ),
      ],
    );
  }

  String _time(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}
