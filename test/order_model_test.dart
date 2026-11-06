import 'package:flutter_test/flutter_test.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_package.dart';
import 'package:galabau_app/models/order_status.dart';

void main() {
  test('Order: fromJson/toJson Roundtrip', () {
    final order = Order(
      id: 'a-1',
      clientId: 'k-1',
      title: 'Laubentfernung',
      description: 'Vorgarten inkl. Abtransport',
      createdAt: DateTime(2026, 11, 5, 9),
      dueDateStart: DateTime(2026, 11, 20, 8),
      dueDateEnd: DateTime(2026, 11, 20, 12),
      status: OrderStatus.offen,
      recurring: true,
      notes: 'Wichtig: Tor offen lassen',
      origin: 'erhalten',
      packageId: 'pkg-1',
      externalAddress: 'Musterweg 1, 34123 Kassel',
      senderName: 'Chef GmbH',
    );

    final restored = Order.fromJson(order.toJson());
    expect(restored.id, 'a-1');
    expect(restored.clientId, 'k-1');
    expect(restored.title, 'Laubentfernung');
    expect(restored.dueDateStart, DateTime(2026, 11, 20, 8));
    expect(restored.dueDateEnd, DateTime(2026, 11, 20, 12));
    expect(restored.status, OrderStatus.offen);
    expect(restored.recurring, isTrue);
    expect(restored.notes, 'Wichtig: Tor offen lassen');
    expect(restored.origin, 'erhalten');
    expect(restored.packageId, 'pkg-1');
    expect(restored.externalAddress, 'Musterweg 1, 34123 Kassel');
    expect(restored.senderName, 'Chef GmbH');
  });

  test('Order: Defaults und nullable Felder', () {
    final order = Order.fromJson(const {
      'id': 'a-2',
      'client_id': 'k-1',
      'title': 'Baumschnitt',
      'created_at': '2026-11-05T09:00:00.000',
    });

    expect(order.description, '');
    expect(order.dueDateStart, isNull);
    expect(order.status, OrderStatus.offen);
    expect(order.recurring, isFalse);
    expect(order.notes, '');
    expect(order.origin, 'eigen');
    expect(order.packageId, isNull);
    expect(order.senderName, isNull);
  });

  test('Order: externer Auftrag ohne Kunde (clientId null)', () {
    final order = Order.fromJson(const {
      'id': 'a-3',
      'title': 'Externer Auftrag',
      'created_at': '2026-11-05T09:00:00.000',
      'origin': 'erhalten',
      'sender_name': 'Chef GmbH',
    });

    expect(order.clientId, isNull);
    expect(order.origin, 'erhalten');
    expect(order.senderName, 'Chef GmbH');
  });

  test('OrderPackage: fromJson/toJson Roundtrip', () {
    final pkg = OrderPackage(
      id: 'pkg-1',
      orderId: 'a-1',
      colleagueId: 'm-1',
      direction: 'outgoing',
      status: 'sent',
      createdAt: DateTime(2026, 11, 5, 10),
    );

    final restored = OrderPackage.fromJson(pkg.toJson());
    expect(restored.id, 'pkg-1');
    expect(restored.orderId, 'a-1');
    expect(restored.colleagueId, 'm-1');
    expect(restored.direction, 'outgoing');
    expect(restored.status, 'sent');
    expect(restored.createdAt, DateTime(2026, 11, 5, 10));
  });
}