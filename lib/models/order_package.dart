/// Geteiltes/empfangenes Auftrags-Paket (Subunternehmer-Workflow).
class OrderPackage {
  const OrderPackage({
    required this.id,
    required this.orderId,
    required this.colleagueId,
    required this.direction,
    required this.status,
    required this.createdAt,
  });

  factory OrderPackage.fromJson(Map<String, dynamic> json) => OrderPackage(
        id: json['id'] as String,
        orderId: json['order_id'] as String?,
        colleagueId: json['colleague_id'] as String?,
        direction: json['direction'] as String? ?? 'outgoing',
        status: json['status'] as String? ?? 'sent',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String? orderId;
  final String? colleagueId;
  final String direction;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'colleague_id': colleagueId,
        'direction': direction,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}
