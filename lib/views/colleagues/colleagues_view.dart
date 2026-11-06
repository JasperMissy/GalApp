import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/colleague.dart';
import 'package:galabau_app/services/colleagues/colleague_repository.dart';
import 'package:galabau_app/services/map/map_marker_builder.dart';
import 'package:galabau_app/views/colleagues/colleague_detail_sheet.dart';
import 'package:galabau_app/views/colleagues/colleague_form_dialog.dart';
import 'package:galabau_app/views/map/map_screen.dart';
import 'package:galabau_app/views/shared/empty_state.dart';
import 'package:galabau_app/views/shared/error_state.dart';

/// Kollegen-Datenbank: alphabetische Kontaktliste mit Qualifikationen.
class ColleaguesView extends ConsumerWidget {
  const ColleaguesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Colleague>> colleagues =
        ref.watch(colleaguesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kollegen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Karte',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const MapScreen(initialFilter: MapFilter.kollegen),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addColleague(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Kollege'),
      ),
      body: colleagues.when(
        data: (List<Colleague> all) => all.isEmpty
            ? const EmptyState(
                icon: Icons.groups_outlined,
                title: 'Noch keine Kollegen',
                message:
                    'Fügen Sie über „Kollege" Ihren ersten Kollegen hinzu.',
              )
            : ListView.builder(
                itemCount: all.length,
                itemBuilder: (BuildContext context, int index) {
                  final Colleague colleague = all[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(colleague.name),
                      subtitle: Text('${colleague.zip} ${colleague.city}'.trim()),
                      onTap: () => _openColleague(context, colleague),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            ErrorState(onRetry: () => ref.invalidate(colleaguesProvider)),
      ),
    );
  }

  void _openColleague(BuildContext context, Colleague colleague) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ColleagueDetailSheet(colleague: colleague),
    );
  }

  Future<void> _addColleague(BuildContext context) async {
    final bool? created = await showDialog<bool>(
      context: context,
      builder: (_) => const ColleagueFormDialog(),
    );
    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kollege angelegt')),
      );
    }
  }
}
