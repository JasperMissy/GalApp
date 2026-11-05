import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/providers.dart';

/// Lese-/Schreibzugriff auf die Einstellungen (`settings`-Tabelle).
class SettingsRepository {
  const SettingsRepository(this.db);

  final AppDatabase db;

  /// Alle Einstellungen als Schlüssel-Wert-Zuordnung.
  Future<Map<String, String>> loadAll() async {
    final rows = await db.select(db.settings).get();
    return {for (final row in rows) row.key: row.value};
  }

  /// Legt einen Wert an oder ersetzt ihn (Upsert).
  Future<void> save(String key, String value) => db.into(db.settings).insert(
        SettingsCompanion.insert(key: key, value: value),
        mode: InsertMode.insertOrReplace,
      );

  /// Schreibt mehrere Werte (Upsert).
  Future<void> saveAll(Map<String, String> entries) async {
    for (final MapEntry<String, String> entry in entries.entries) {
      await save(entry.key, entry.value);
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

final settingsProvider = FutureProvider<Map<String, String>>((ref) {
  return ref.watch(settingsRepositoryProvider).loadAll();
});