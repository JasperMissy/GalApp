import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/settings/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() async => db.close());

  test('loadAll ist anfangs leer', () async {
    expect(await repo.loadAll(), isEmpty);
  });

  test('save und loadAll', () async {
    await repo.save('firmenname', 'Grünes GaLaBau');
    final Map<String, String> all = await repo.loadAll();
    expect(all['firmenname'], 'Grünes GaLaBau');
  });

  test('saveAll überschreibt vorhandene Werte (Upsert)', () async {
    await repo.save('akzentfarbe', '#000000');
    await repo.saveAll({'akzentfarbe': '#2E7D32', 'iban': 'DE00'});
    final Map<String, String> all = await repo.loadAll();
    expect(all['akzentfarbe'], '#2E7D32');
    expect(all['iban'], 'DE00');
  });
}