import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/work_time_entry.dart' as wt;
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/orders/work_documentation_repository.dart';

void main() {
  late AppDatabase db;
  late WorkDocumentationRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = WorkDocumentationRepository(db);
    // Fremdschlüssel: Arbeitsdaten brauchen einen existierenden Auftrag.
    await db.into(db.orders).insert(
          OrdersCompanion.insert(
            id: 'a-1',
            title: 'Heckenschnitt',
            createdAt: DateTime(2026, 11, 1),
          ),
        );
  });

  tearDown(() async => db.close());

  test('startTime/finishTime erfasst einen Eintrag', () async {
    await repo.startTime('a-1');
    await repo.finishTime('a-1');

    final times = await repo.watchTimes('a-1').first;
    expect(times, hasLength(1));
    expect(times.single.startedAt, isNotNull);
    expect(times.single.endedAt, isNotNull);
  });

  test('startTime legt bei offenem Eintrag keinen zweiten an', () async {
    final String first = await repo.startTime('a-1');
    final String second = await repo.startTime('a-1');
    expect(first, second);

    final times = await repo.watchTimes('a-1').first;
    expect(times, hasLength(1));
  });

  test('pauseTime/resumeTime setzen den Pause-Zustand', () async {
    await repo.startTime('a-1');
    await repo.pauseTime('a-1');
    var times = await repo.watchTimes('a-1').first;
    expect(times.single.pausedAt, isNotNull);

    await repo.resumeTime('a-1');
    times = await repo.watchTimes('a-1').first;
    expect(times.single.pausedAt, isNull);
  });

  test('resumeTime summiert die Pausenzeit', () async {
    await repo.startTime('a-1');
    await repo.pauseTime('a-1');

    // Pause künstlich in die Vergangenheit verschieben, um deterministisch zu
    // prüfen, dass die verstrichene Zeit übernommen wird.
    final open = await (db.select(db.workTimeEntries)
          ..where((t) => t.pausedAt.isNotNull()))
        .getSingle();
    await (db.update(db.workTimeEntries)..where((t) => t.id.equals(open.id)))
        .write(WorkTimeEntriesCompanion(
          pausedAt: Value(DateTime.now().subtract(const Duration(seconds: 4))),
        ));

    await repo.resumeTime('a-1');

    final times = await repo.watchTimes('a-1').first;
    expect(times.single.pausedAt, isNull);
    expect(times.single.pausedMilliseconds, greaterThanOrEqualTo(4000));
  });

  test('duration zieht Pausen ab', () async {
    await repo.startTime('a-1');
    await repo.finishTime('a-1');
    final entry = (await repo.watchTimes('a-1').first).single;
    // Ohne Pause entspricht die Dauer der Zeitspanne zwischen Start und Ende.
    final raw = entry.endedAt!.difference(entry.startedAt);
    expect(entry.duration(), raw);
    // Mit 10 Minuten Pause wird sie abgezogen.
    final withPause = wt.WorkTimeEntry(
      id: entry.id,
      orderId: entry.orderId,
      startedAt: entry.startedAt,
      endedAt: entry.endedAt,
      pausedAt: null,
      pausedMilliseconds: const Duration(minutes: 10).inMilliseconds,
      createdAt: entry.createdAt,
    );
    expect(withPause.duration(), raw - const Duration(minutes: 10));
  });

  test('saveNote/loadNote Roundtrip', () async {
    expect(await repo.loadNote('a-1'), isNull);

    await repo.saveNote('a-1', 'Alles erledigt');
    final note = await repo.loadNote('a-1');
    expect(note!.text, 'Alles erledigt');

    await repo.saveNote('a-1', 'Geändert');
    final updated = await repo.loadNote('a-1');
    expect(updated!.text, 'Geändert');
  });
}
