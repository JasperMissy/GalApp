import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/orders/work_documentation_repository.dart';

void main() {
  late AppDatabase db;
  late WorkDocumentationRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = WorkDocumentationRepository(db);
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

  test('finishTime beendet nur den letzten offenen Eintrag', () async {
    await repo.startTime('a-1');
    await repo.startTime('a-1');
    await repo.finishTime('a-1');

    final times = await repo.watchTimes('a-1').first;
    expect(times, hasLength(2));
    expect(times.first.endedAt, isNull);
    expect(times.last.endedAt, isNotNull);
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
