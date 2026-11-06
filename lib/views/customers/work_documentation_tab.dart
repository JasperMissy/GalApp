import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/work_note.dart';
import 'package:galabau_app/models/work_time_entry.dart';
import 'package:galabau_app/services/orders/work_documentation_repository.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Arbeitsdokumentation eines Auftrags: Zeiterfassung (Start/Pause/Ende)
/// und Anmerkung mit Diktierfunktion.
class WorkDocumentationTab extends ConsumerStatefulWidget {
  const WorkDocumentationTab({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<WorkDocumentationTab> createState() =>
      _WorkDocumentationTabState();
}

class _WorkDocumentationTabState extends ConsumerState<WorkDocumentationTab> {
  final TextEditingController _noteController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  bool _listening = false;

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
      ],
    );
  }

  String _time(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}
