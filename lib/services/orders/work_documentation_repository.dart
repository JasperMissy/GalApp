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

  /// Startet einen neuen Zeiteintrag. Läuft für den Auftrag bereits einer,
  /// wird dessen Id zurückgegeben, statt einen zweiten anzulegen.
  Future<String> startTime(String orderId) async {
    final WorkTimeEntry? open = await (db.select(db.workTimeEntries)
          ..where((t) => t.orderId.equals(orderId) & t.endedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (open != null) return open.id;

    final String id = newId();
    await db.into(db.workTimeEntries).insert(
          WorkTimeEntriesCompanion.insert(
            id: id,
            orderId: orderId,
            startedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  /// Beendet den letzten offenen Zeiteintrag. Eine noch laufende Pause wird
  /// dabei in [WorkTimeEntries.pausedMilliseconds] übernommen.
  Future<void> finishTime(String orderId) async {
    final WorkTimeEntry? row = await (db.select(db.workTimeEntries)
          ..where((t) => t.orderId.equals(orderId) & t.endedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return;

    final DateTime now = DateTime.now();
    final int pendingPause =
        row.pausedAt == null ? 0 : now.difference(row.pausedAt!).inMilliseconds;
    await (db.update(db.workTimeEntries)..where((t) => t.id.equals(row.id)))
        .write(WorkTimeEntriesCompanion(
          endedAt: Value(now),
          pausedAt: Value<DateTime?>(null),
          pausedMilliseconds: Value(row.pausedMilliseconds + pendingPause),
        ));
  }

  /// Pausiert den letzten laufenden Zeiteintrag.
  Future<void> pauseTime(String orderId) async {
    final row = await (db.select(db.workTimeEntries)
          ..where((t) =>
              t.orderId.equals(orderId) &
              t.endedAt.isNull() &
              t.pausedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return;
    await (db.update(db.workTimeEntries)..where((t) => t.id.equals(row.id)))
        .write(WorkTimeEntriesCompanion(pausedAt: Value(DateTime.now())));
  }

  /// Setzt den letzten pausierten Zeiteintrag fort und übernimmt die bislang
  /// aufgelaufene Pause in [WorkTimeEntries.pausedMilliseconds].
  Future<void> resumeTime(String orderId) async {
    final WorkTimeEntry? row = await (db.select(db.workTimeEntries)
          ..where((t) =>
              t.orderId.equals(orderId) &
              t.endedAt.isNull() &
              t.pausedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return;

    final Duration paused = DateTime.now().difference(row.pausedAt!);
    await (db.update(db.workTimeEntries)..where((t) => t.id.equals(row.id)))
        .write(WorkTimeEntriesCompanion(
          pausedAt: Value<DateTime?>(null),
          pausedMilliseconds: Value(row.pausedMilliseconds + paused.inMilliseconds),
        ));
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
        pausedAt: row.pausedAt,
        pausedMilliseconds: row.pausedMilliseconds,
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
