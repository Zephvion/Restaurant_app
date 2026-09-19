import 'restaurant.dart';

/// A confirmed table reservation made by the user.
class Reservation {
  const Reservation({
    required this.id,
    this.userId = '',
    required this.restaurant,
    required this.date,
    required this.timeSlot,
    required this.seats,
    required this.tableNumber,
    this.tableNumbers = const [],
    this.status = 'confirmed',
    this.cancellationReason,
    this.cancelledAt,
  });

  final String id;
  final String userId;
  final Restaurant restaurant;
  final DateTime date;
  final String timeSlot; // e.g. "7:00PM"
  final int seats;
  final int tableNumber;
  final List<int> tableNumbers;
  final String status;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  /// All table numbers (including combined tables)
  List<int> get allTableNumbers =>
      tableNumbers.isNotEmpty ? tableNumbers : [tableNumber];

  /// Display string for tables, e.g. "Table #5 & #6" or "Table #5"
  String get tableDisplay {
    if (tableNumbers.length > 1) {
      return tableNumbers.map((n) => '#$n').join(' & ');
    }
    return '#$tableNumber';
  }

  /// Short human-readable date, e.g. "January 2, 2023"
  String get formattedDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day} , ${date.year}';
  }

  /// Formatted arrival time matching user selection
  String get arrivalTime => timeSlot;

  /// Time until which the table is reserved (90-minute dining duration)
  String get reservedUntil {
    final tod = _parseTimeSlot();
    if (tod == null) return '$timeSlot + 90m';
    final totalMins = tod.hour * 60 + tod.minute + 90;
    final endH = (totalMins ~/ 60) % 24;
    final endM = totalMins % 60;
    return _formatTime(endH, endM);
  }

  /// Waiting / arrival grace window (15 minutes from scheduled arrival)
  String get waitingUntil {
    final tod = _parseTimeSlot();
    if (tod == null) return '$timeSlot + 15m';
    final totalMins = tod.hour * 60 + tod.minute + 15;
    final waitH = (totalMins ~/ 60) % 24;
    final waitM = totalMins % 60;
    return _formatTime(waitH, waitM);
  }

  bool get isCompleted =>
      status.toLowerCase() == 'completed' ||
      status.toLowerCase() == 'released' ||
      status.toLowerCase() == 'freed';

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get canBeCancelled => !isCancelled && !isCompleted;

  ({int hour, int minute})? _parseTimeSlot() {
    final cleaned = timeSlot.replaceAll(' ', '').toUpperCase();
    final isPm = cleaned.contains('PM');
    final isAm = cleaned.contains('AM');
    final numPart = cleaned.replaceAll('AM', '').replaceAll('PM', '');
    final parts = numPart.split(':');
    if (parts.isEmpty) return null;
    int hour = int.tryParse(parts[0]) ?? 19;
    int min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;
    return (hour: hour, minute: min);
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  Reservation copyWith({
    String? id,
    String? userId,
    Restaurant? restaurant,
    DateTime? date,
    String? timeSlot,
    int? seats,
    int? tableNumber,
    List<int>? tableNumbers,
    String? status,
    String? cancellationReason,
    DateTime? cancelledAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurant: restaurant ?? this.restaurant,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      seats: seats ?? this.seats,
      tableNumber: tableNumber ?? this.tableNumber,
      tableNumbers: tableNumbers ?? this.tableNumbers,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'restaurant': restaurant.toMap(),
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'seats': seats,
        'tableNumber': tableNumber,
        'tableNumbers': tableNumbers,
        'status': status,
        if (cancellationReason != null)
          'cancellationReason': cancellationReason,
        if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      };

  factory Reservation.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawTableNumbers = map['tableNumbers'] as List?;
    final tableNumbers = rawTableNumbers != null
        ? rawTableNumbers.map((e) => (e as num).toInt()).toList()
        : <int>[];
    final tableNumber = (map['tableNumber'] as num?)?.toInt() ??
        (tableNumbers.isNotEmpty ? tableNumbers.first : 1);

    return Reservation(
      id: id ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      restaurant: map['restaurant'] != null
          ? Restaurant.fromMap(Map<String, dynamic>.from(map['restaurant'] as Map))
          : const Restaurant(
              id: 'rest_1',
              name: 'Paragon Restaurant',
              address: 'Kannur Road, Near CH Flyover',
              city: 'Calicut',
            ),
      date: map['date'] != null
          ? (DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      timeSlot: map['timeSlot'] as String? ?? '7:00PM',
      seats: (map['seats'] as num?)?.toInt() ?? 2,
      tableNumber: tableNumber,
      tableNumbers: tableNumbers.isNotEmpty ? tableNumbers : [tableNumber],
      status: map['status'] as String? ?? 'confirmed',
      cancellationReason: map['cancellationReason'] as String?,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.tryParse(map['cancelledAt'].toString())
          : null,
    );
  }
}
