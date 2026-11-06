import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/order_package.dart' as model;
import 'package:galabau_app/services/database/app_database.dart';
import 'package:galabau_app/services/orders/order_package_repository.dart';

void main() {
  late AppDatabase db;
  late OrderPackageRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = OrderPackageRepository(db);
  });

  tearDown(() async => db.close());

  test('insert und watchByOrder', () async {
    await repo.insert(model.OrderPackage(
      id: 'pkg-1',
      orderId: 'a-1',
      colleagueId: 'm-1',
      direction: 'outgoing',
      status: 'sent',
      createdAt: DateTime(2026, 11, 5, 10),
    ));
    await repo.insert(model.OrderPackage(
      id: 'pkg-2',
      orderId: 'a-2',
      colleagueId: 'm-2',
      direction: 'incoming',
      status: 'received',
      createdAt: DateTime(2026, 11, 6, 10),
    ));

    final forOrder = await repo.watchByOrder('a-1').first;
    expect(forOrder, hasLength(1));
    expect(forOrder.single.id, 'pkg-1');
    expect(forOrder.single.colleagueId, 'm-1');
    expect(forOrder.single.direction, 'outgoing');
  });

  test('getByPackageId findet ein Paket', () async {
    await repo.insert(model.OrderPackage(
      id: 'pkg-1',
      orderId: 'a-1',
      colleagueId: 'm-1',
      direction: 'outgoing',
      status: 'sent',
      createdAt: DateTime(2026, 11, 5, 10),
    ));

    final model.OrderPackage? pkg = await repo.getByPackageId('pkg-1');
    expect(pkg, isNotNull);
    expect(pkg!.orderId, 'a-1');

    expect(await repo.getByPackageId('unbekannt'), isNull);
  });
}
