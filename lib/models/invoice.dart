/// Rechnung oder Angebot (Datenklasse, 1:1 zum Schema `invoices`).
class Invoice {
  const Invoice({
    required this.id,
    required this.number,
    required this.type,
    required this.clientId,
    required this.orderId,
    required this.status,
    required this.issuedDate,
    required this.netCents,
    required this.vatRateBp,
    required this.vatCents,
    required this.grossCents,
    required this.createdAt,
    this.colleagueId,
    this.stornoOfId,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        number: json['number'] as String?,
        type: json['type'] as String? ?? 'invoice',
        clientId: json['client_id'] as String,
        orderId: json['order_id'] as String?,
        status: json['status'] as String? ?? 'draft',
        issuedDate: json['issued_date'] == null
            ? null
            : DateTime.parse(json['issued_date'] as String),
        netCents: json['net_cents'] as int? ?? 0,
        vatRateBp: json['vat_rate_bp'] as int? ?? 1900,
        vatCents: json['vat_cents'] as int? ?? 0,
        grossCents: json['gross_cents'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
        colleagueId: json['colleague_id'] as String?,
        stornoOfId: json['storno_of_id'] as String?,
      );

  final String id;
  final String? number;
  final String type;
  final String clientId;
  final String? orderId;
  final String status;
  final DateTime? issuedDate;
  final int netCents;
  final int vatRateBp;
  final int vatCents;
  final int grossCents;
  final DateTime createdAt;
  final String? colleagueId;
  final String? stornoOfId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'type': type,
        'client_id': clientId,
        'order_id': orderId,
        'status': status,
        'issued_date': issuedDate?.toIso8601String(),
        'net_cents': netCents,
        'vat_rate_bp': vatRateBp,
        'vat_cents': vatCents,
        'gross_cents': grossCents,
        'created_at': createdAt.toIso8601String(),
        'colleague_id': colleagueId,
        'storno_of_id': stornoOfId,
      };
}