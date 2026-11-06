import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/order.dart' as model;
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/orders/order_repository.dart';

void main() {
  late AppDatabase db;
  late OrderRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = OrderRepository(db);
  });

  tearDown(() async => db.close());

  Future<void> seedClient(String id, String name) => db.into(db.clients).insert(
        ClientsCompanion.insert(
          id: id, name: name, createdAt: DateTime(2026),
        ),
      );

  model.Order makeOrder({String id = 'a-1', String clientId = 'k-1'}) =>
      model.Order(
        id: id,
        clientId: clientId,
        title: 'Laubentfernung',
        description: '',
        createdAt: DateTime(2026, 11, 5),
        dueDateStart: null,
        dueDateEnd: null,
        status: OrderStatus.offen,
        recurring: false,
        notes: '',
      );

  test('insert und watchAll', () async {
    await seedClient('k-1', 'Berger');
    await repo.insert(makeOrder());

    final orders = await repo.watchAll().first;
    expect(orders, hasLength(1));
    expect(orders.single.title, 'Laubentfernung');
  });

  test('watchByClient filtert nach Kunde', () async {
    await seedClient('k-1', 'Berger');
    await seedClient('k-2', 'Müller');
    await repo.insert(makeOrder(id: 'a-1', clientId: 'k-1'));
    await repo.insert(makeOrder(id: 'a-2', clientId: 'k-2'));

    final forK1 = await repo.watchByClient('k-1').first;
    expect(forK1.map((o) => o.id).toList(), ['a-1']);
  });

  test('updateStatus wechselt den Status', () async {
    await seedClient('k-1', 'Berger');
    await repo.insert(makeOrder());
    await repo.updateStatus('a-1', OrderStatus.erledigt);

    final orders = await repo.watchAll().first;
    expect(orders.single.status, OrderStatus.erledigt);
  });

  test('update ändert Titel, Notizen und wiederkehrend', () async {
    await seedClient('k-1', 'Berger');
    await repo.insert(makeOrder());
    final existing = (await repo.watchAll().first).single;

    await repo.update(model.Order(
      id: existing.id,
      clientId: existing.clientId,
      title: 'Neuer Titel',
      description: 'Neue Beschreibung',
      createdAt: existing.createdAt,
      dueDateStart: existing.dueDateStart,
      dueDateEnd: existing.dueDateEnd,
      status: existing.status,
      recurring: true,
      notes: 'Neue Notiz',
    ));

    final reloaded = (await repo.watchAll().first).single;
    expect(reloaded.title, 'Neuer Titel');
    expect(reloaded.notes, 'Neue Notiz');
    expect(reloaded.recurring, isTrue);
  });

  test('delete entfernt den Auftrag', () async {
    await seedClient('k-1', 'Berger');
    await repo.insert(makeOrder());
    await repo.delete('a-1');

    final orders = await repo.watchAll().first;
    expect(orders, isEmpty);
  });
}