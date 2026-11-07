/// Betriebsausgabe (Material/Fremdleistung/Personal), Datenklasse 1:1 zum
/// Schema `expenses`. Belege liegen als Datei im Dateisystem (`filePath`).
class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.netCents,
    required this.vatRateBp,
    required this.grossCents,
    required this.bookedAt,
    this.orderId,
    this.colleagueId,
    this.filePath,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        category: json['category'] as String? ?? 'material',
        netCents: json['net_cents'] as int? ?? 0,
        vatRateBp: json['vat_rate_bp'] as int? ?? 0,
        grossCents: json['gross_cents'] as int? ?? 0,
        bookedAt: DateTime.parse(json['booked_at'] as String),
        orderId: json['order_id'] as String?,
        colleagueId: json['colleague_id'] as String?,
        filePath: json['file_path'] as String?,
      );

  final String id;
  final String category;
  final int netCents;
  final int vatRateBp;
  final int grossCents;
  final DateTime bookedAt;
  final String? orderId;
  final String? colleagueId;
  final String? filePath;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'net_cents': netCents,
        'vat_rate_bp': vatRateBp,
        'gross_cents': grossCents,
        'booked_at': bookedAt.toIso8601String(),
        'order_id': orderId,
        'colleague_id': colleagueId,
        'file_path': filePath,
      };
}
