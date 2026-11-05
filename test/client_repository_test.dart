import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/client.dart' as model;
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/database/app_database.dart';

void main() {
  late AppDatabase db;
  late ClientRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ClientRepository(db);
  });

  tearDown(() async => db.close());

  test('insert und watchAll (alphabetisch sortiert)', () async {
    await repo.insert(model.Client(
      id: 'k-2', name: 'Müller', street: '', zip: '', city: '', phone: '',
      email: '', createdAt: DateTime(2026),
    ));
    await repo.insert(model.Client(
      id: 'k-1', name: 'Berger', street: '', zip: '', city: '', phone: '',
      email: '', createdAt: DateTime(2026),
    ));

    final clients = await repo.watchAll().first;
    expect(clients.map((c) => c.name).toList(), ['Berger', 'Müller']);
  });
}