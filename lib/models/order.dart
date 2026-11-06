import 'order_status.dart';

/// Auftrag (Datenklasse, Felder laut Vision, Abschnitt 10).
///
/// Medien (Fotos, Videos, Sprachmemos, PDFs) liegen im Auftragsordner im
/// Dateisystem und werden hier bewusst nicht gespeichert.
class Order {
  const Order({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDateStart,
    required this.dueDateEnd,
    required this.status,
    required this.recurring,
    required this.notes,
    this.origin = 'eigen',
    this.packageId,
    this.externalAddress,
    this.senderName,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        clientId: json['client_id'] as String?,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        dueDateStart: json['due_date_start'] == null
            ? null
            : DateTime.parse(json['due_date_start'] as String),
        dueDateEnd: json['due_date_end'] == null
            ? null
            : DateTime.parse(json['due_date_end'] as String),
        status: OrderStatus.values.byName(json['status'] as String? ?? 'offen'),
        recurring: json['recurring'] as bool? ?? false,
        notes: json['notes'] as String? ?? '',
        origin: json['origin'] as String? ?? 'eigen',
        packageId: json['package_id'] as String?,
        externalAddress: json['external_address'] as String?,
        senderName: json['sender_name'] as String?,
      );

  final String id;
  final String? clientId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDateStart;
  final DateTime? dueDateEnd;
  final OrderStatus status;
  final bool recurring;
  final String notes;
  final String origin;
  final String? packageId;
  final String? externalAddress;
  final String? senderName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'title': title,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'due_date_start': dueDateStart?.toIso8601String(),
        'due_date_end': dueDateEnd?.toIso8601String(),
        'status': status.name,
        'recurring': recurring,
        'notes': notes,
        'origin': origin,
        'package_id': packageId,
        'external_address': externalAddress,
        'sender_name': senderName,
      };
}