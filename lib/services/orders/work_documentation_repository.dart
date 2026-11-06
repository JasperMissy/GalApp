import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/work_note.dart' as note_model;
import '../../models/work_time_entry.dart' as time_model;
import '../database/app_database.dart';
import '../database/providers.dart';
import '../id_generator.dart';

/// Zugriff auf die Arbeitsdokumentation (Zeiterfassung + Anmerkung).
class WorkDocumentationRepository {
  const WorkDocumentationRepository(this.db);

  final AppDatabase db;

  /// Zeiterfassung eines Auftrags, älteste zuerst.
  Stream<List<time_model.WorkTimeEntry>> watchTimes(String orderId) {
    final query = (db.select(db.workTimeEntries)
          ..where((t) => t.orderId.equals(orderId)))
      ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]);
    return query.watch().map((rows) => rows.map(_toTime).toList());
  }

  /// Startet einen neuen Zeiteintrag (ohne Ende).
  Future<void> startTime(String orderId) =>
      db.into(db.workTimeEntries).insert(
            WorkTimeEntriesCompanion.insert(
              id: newId(),
              orderId: orderId,
              startedAt: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          );

  /// Beendet den letzten offenen Zeiteintrag.
  Future<void> finishTime(String orderId) async {
    final row = await (db.select(db.workTimeEntries)
          ..where((t) => t.orderId.equals(orderId) & t.endedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return;
    await (db.update(db.workTimeEntries)..where((t) => t.id.equals(row.id)))
        .write(WorkTimeEntriesCompanion(endedAt: Value(DateTime.now())));
  }

  /// Anmerkung eines Auftrags (oder null).
  Future<note_model.WorkNote?> loadNote(String orderId) async {
    final row = await (db.select(db.workNotes)
          ..where((t) => t.orderId.equals(orderId)))
        .getSingleOrNull();
    return row == null ? null : _toNote(row);
  }

  /// Speichert die Anmerkung eines Auftrags (Upsert).
  Future<void> saveNote(String orderId, String text) =>
      db.into(db.workNotes).insert(
            WorkNotesCompanion.insert(
              orderId: orderId,
              content: Value(text),
              updatedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );

  time_model.WorkTimeEntry _toTime(WorkTimeEntry row) =>
      time_model.WorkTimeEntry(
        id: row.id,
        orderId: row.orderId,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        createdAt: row.createdAt,
      );

  note_model.WorkNote _toNote(WorkNote row) => note_model.WorkNote(
        orderId: row.orderId,
        text: row.content,
        updatedAt: row.updatedAt,
      );
}

final workDocumentationRepositoryProvider =
    Provider<WorkDocumentationRepository>((ref) {
  return WorkDocumentationRepository(ref.watch(databaseProvider));
});

final workTimesProvider =
    StreamProvider.family<List<time_model.WorkTimeEntry>, String>(
  (ref, orderId) =>
      ref.watch(workDocumentationRepositoryProvider).watchTimes(orderId),
);
