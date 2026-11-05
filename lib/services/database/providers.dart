import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// App-weite lokale SQLite-Datenbank.
///
/// Wird in Tests durch eine In-Memory-Datenbank ersetzt
/// (`AppDatabase.forTesting(NativeDatabase.memory())`).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});