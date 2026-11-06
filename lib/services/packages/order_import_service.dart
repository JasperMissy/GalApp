import '../../models/order.dart';
import '../../models/order_package.dart';
import '../../models/order_status.dart';
import '../../models/package_manifest.dart';

/// Baut aus einem gelesenen Auftrags-Paket einen externen Auftrag
/// (Herkunft `erhalten`, ohne eigenen Kunden).
Order buildImportedOrder({
  required String orderId,
  required PackageManifest manifest,
}) {
  return Order(
    id: orderId,
    clientId: null,
    title: manifest.title,
    description: manifest.description,
    createdAt: DateTime.now(),
    dueDateStart: null,
    dueDateEnd: null,
    status: OrderStatus.offen,
    recurring: false,
    notes: '',
    origin: 'erhalten',
    packageId: manifest.id,
    externalAddress: manifest.address,
    senderName: manifest.senderName,
  );
}

/// Baut den eingehenden Paket-Eintrag zum importierten Auftrag.
OrderPackage buildImportedPackage({
  required String packageId,
  required String orderId,
}) {
  return OrderPackage(
    id: packageId,
    orderId: orderId,
    colleagueId: null,
    direction: 'incoming',
    status: 'received',
    createdAt: DateTime.now(),
  );
}
