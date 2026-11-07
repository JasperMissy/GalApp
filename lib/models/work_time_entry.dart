/// Zeiterfassungs-Eintrag zur Arbeitsdokumentation eines Auftrags.
class WorkTimeEntry {
  const WorkTimeEntry({
    required this.id,
    required this.orderId,
    required this.startedAt,
    required this.endedAt,
    required this.pausedAt,
    required this.pausedMilliseconds,
    required this.createdAt,
  });

  factory WorkTimeEntry.fromJson(Map<String, dynamic> json) => WorkTimeEntry(
        id: json['id'] as String,
        orderId: json['order_id'] as String,
        startedAt: DateTime.parse(json['started_at'] as String),
        endedAt: json['ended_at'] == null
            ? null
            : DateTime.parse(json['ended_at'] as String),
        pausedAt: json['paused_at'] == null
            ? null
            : DateTime.parse(json['paused_at'] as String),
        pausedMilliseconds: json['paused_milliseconds'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String orderId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? pausedAt;
  final int pausedMilliseconds;
  final DateTime createdAt;

  /// Effektive Arbeitsdauer ohne Pausen. Läuft der Eintrag noch, wird [now]
  /// (standardmäßig die aktuelle Zeit) als Ende verwendet.
  Duration duration({DateTime? now}) {
    final DateTime end = endedAt ?? now ?? DateTime.now();
    return end.difference(startedAt) -
        Duration(milliseconds: pausedMilliseconds);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'paused_at': pausedAt?.toIso8601String(),
        'paused_milliseconds': pausedMilliseconds,
        'created_at': createdAt.toIso8601String(),
      };
}
