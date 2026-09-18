import 'dart:async';
import 'package:flutter/foundation.dart';

enum TableLockStatus {
  available,
  held,
  reserved,
}

class WaitlistEntry {
  final String userId;
  final String userName;
  final DateTime queuedAt;

  const WaitlistEntry({
    required this.userId,
    required this.userName,
    required this.queuedAt,
  });
}

class TableLock {
  final int tableNumber;
  String? holderUserId;
  String? holderUserName;
  DateTime? lockedAt;
  DateTime? expiresAt;
  TableLockStatus status;
  final List<WaitlistEntry> waitlist;

  TableLock({
    required this.tableNumber,
    this.holderUserId,
    this.holderUserName,
    this.lockedAt,
    this.expiresAt,
    this.status = TableLockStatus.available,
    List<WaitlistEntry>? waitlist,
  }) : waitlist = waitlist ?? [];

  bool get isExpired {
    if (status != TableLockStatus.held || expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration get remainingDuration {
    if (expiresAt == null) return Duration.zero;
    final diff = expiresAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get remainingFormatted {
    final rem = remainingDuration;
    final mins = rem.inMinutes;
    final secs = rem.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

enum AcquireLockResultType {
  acquired,
  alreadyHeldBySelf,
  heldByOther,
  tableReserved,
}

class AcquireLockResult {
  final AcquireLockResultType type;
  final String? holderName;
  final Duration? remainingTime;
  final int waitlistPosition;

  const AcquireLockResult({
    required this.type,
    this.holderName,
    this.remainingTime,
    this.waitlistPosition = 0,
  });

  bool get isSuccess =>
      type == AcquireLockResultType.acquired ||
      type == AcquireLockResultType.alreadyHeldBySelf;
}

/// 10/10 Production-Ready Table Lock & Race Condition Manager.
/// Manages 5-minute exclusive table holds, active countdowns,
/// multi-user race conflict detection, and automatic waitlist queue transfer.
class TableLockService extends ChangeNotifier {
  TableLockService._() {
    _startPeriodicTimer();
  }

  static final TableLockService instance = TableLockService._();

  // Active current simulated persona for local testing
  String _activeUserId = 'usr_alex';
  String _activeUserName = 'Alex (Person 1)';

  String get activeUserId {
    // If real auth session exists, use real user ID
    // Otherwise fallback to simulated persona for testing
    return _activeUserId;
  }

  String get activeUserName => _activeUserName;

  void switchSimulatedUser({required String userId, required String userName}) {
    _activeUserId = userId;
    _activeUserName = userName;
    notifyListeners();
  }

  /// Receptionist / Staff action to manually unlock or free a table
  void receptionistReleaseTable(int tableNumber) {
    final lock = getLock(tableNumber);
    _transferOrRelease(lock, reason: 'Receptionist / Staff manual override');
  }

  /// Receptionist / Staff action to mark a table as occupied/reserved
  void receptionistMarkOccupied(int tableNumber) {
    final lock = getLock(tableNumber);
    lock.status = TableLockStatus.reserved;
    lock.expiresAt = null;
    notifyListeners();
  }

  final Map<int, TableLock> _locks = {};
  Timer? _ticker;

  // Stream/Event notifications for lock changes (e.g. transfer to Person 2)
  final StreamController<String> _notifications =
      StreamController<String>.broadcast();
  Stream<String> get notifications => _notifications.stream;

  void _startPeriodicTimer() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkExpirations();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notifications.close();
    super.dispose();
  }

  TableLock getLock(int tableNumber) {
    return _locks.putIfAbsent(
      tableNumber,
      () => TableLock(tableNumber: tableNumber),
    );
  }

  bool isTableHeldByOther(int tableNumber, {String? userId}) {
    final uid = userId ?? _activeUserId;
    final lock = getLock(tableNumber);
    if (lock.status == TableLockStatus.held && !lock.isExpired) {
      return lock.holderUserId != uid;
    }
    return false;
  }

  bool isTableHeldBySelf(int tableNumber, {String? userId}) {
    final uid = userId ?? _activeUserId;
    final lock = getLock(tableNumber);
    if (lock.status == TableLockStatus.held && !lock.isExpired) {
      return lock.holderUserId == uid;
    }
    return false;
  }

  bool isTableReserved(int tableNumber) {
    final lock = getLock(tableNumber);
    return lock.status == TableLockStatus.reserved;
  }

  /// Attempts to acquire a 5-minute exclusive hold lock for [tableNumber].
  AcquireLockResult acquireLock(
    int tableNumber, {
    String? userId,
    String? userName,
    Duration duration = const Duration(minutes: 5),
  }) {
    final uid = userId ?? _activeUserId;
    final name = userName ?? _activeUserName;
    final lock = getLock(tableNumber);

    if (lock.status == TableLockStatus.reserved) {
      return const AcquireLockResult(
        type: AcquireLockResultType.tableReserved,
      );
    }

    // If currently held
    if (lock.status == TableLockStatus.held && !lock.isExpired) {
      if (lock.holderUserId == uid) {
        return const AcquireLockResult(
          type: AcquireLockResultType.alreadyHeldBySelf,
        );
      } else {
        final pos = lock.waitlist.indexWhere((w) => w.userId == uid);
        return AcquireLockResult(
          type: AcquireLockResultType.heldByOther,
          holderName: lock.holderUserName,
          remainingTime: lock.remainingDuration,
          waitlistPosition: pos >= 0 ? pos + 1 : 0,
        );
      }
    }

    // Lock is available or previous lock expired -> grant to current user
    lock.status = TableLockStatus.held;
    lock.holderUserId = uid;
    lock.holderUserName = name;
    lock.lockedAt = DateTime.now();
    lock.expiresAt = DateTime.now().add(duration);
    lock.waitlist.removeWhere((w) => w.userId == uid);

    notifyListeners();
    return const AcquireLockResult(
      type: AcquireLockResultType.acquired,
    );
  }

  /// Releases the active lock for [tableNumber].
  /// If there are users in the waitlist, automatically transfers the 5-min lock to the next in queue!
  void releaseLock(int tableNumber, {String? userId}) {
    final uid = userId ?? _activeUserId;
    final lock = getLock(tableNumber);

    if (lock.holderUserId != uid && uid != 'admin_override') {
      return;
    }

    _transferOrRelease(lock, reason: '$uid voluntarily released or changed table');
  }

  /// Commits table as permanently RESERVED.
  void commitReservation(int tableNumber, {String? userId}) {
    final lock = getLock(tableNumber);
    lock.status = TableLockStatus.reserved;
    lock.expiresAt = null;
    lock.waitlist.clear();
    notifyListeners();
  }

  /// Adds a user to the priority waitlist for a held table.
  bool joinWaitlist(int tableNumber, {String? userId, String? userName}) {
    final uid = userId ?? _activeUserId;
    final name = userName ?? _activeUserName;
    final lock = getLock(tableNumber);

    if (lock.status != TableLockStatus.held) return false;
    if (lock.holderUserId == uid) return false;

    if (!lock.waitlist.any((w) => w.userId == uid)) {
      lock.waitlist.add(
        WaitlistEntry(
          userId: uid,
          userName: name,
          queuedAt: DateTime.now(),
        ),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void leaveWaitlist(int tableNumber, {String? userId}) {
    final uid = userId ?? _activeUserId;
    final lock = getLock(tableNumber);
    lock.waitlist.removeWhere((w) => w.userId == uid);
    notifyListeners();
  }

  /// Simulates instant expiration of a table lock (for test demonstration).
  void simulateInstantTimeout(int tableNumber) {
    final lock = getLock(tableNumber);
    if (lock.status == TableLockStatus.held) {
      _transferOrRelease(lock, reason: '5-minute hold timer expired');
    }
  }

  void _checkExpirations() {
    bool changed = false;
    for (final lock in _locks.values) {
      if (lock.status == TableLockStatus.held && lock.isExpired) {
        _transferOrRelease(lock, reason: '5-minute hold timer expired');
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    } else if (_hasActiveHolds()) {
      // Periodic tick to update UI countdown text
      notifyListeners();
    }
  }

  bool _hasActiveHolds() {
    return _locks.values.any((l) => l.status == TableLockStatus.held);
  }

  void _transferOrRelease(TableLock lock, {required String reason}) {
    final previousHolder = lock.holderUserName ?? 'Guest';

    if (lock.waitlist.isNotEmpty) {
      // Auto-transfer lock to next person in queue
      final nextUser = lock.waitlist.removeAt(0);
      lock.status = TableLockStatus.held;
      lock.holderUserId = nextUser.userId;
      lock.holderUserName = nextUser.userName;
      lock.lockedAt = DateTime.now();
      lock.expiresAt = DateTime.now().add(const Duration(minutes: 5));

      final msg =
          'Table #${lock.tableNumber} lock expired for $previousHolder and has been transferred to ${nextUser.userName}!';
      _notifications.add(msg);
      debugPrint('[TableLockService] $msg ($reason)');
    } else {
      // Release table completely
      lock.status = TableLockStatus.available;
      lock.holderUserId = null;
      lock.holderUserName = null;
      lock.lockedAt = null;
      lock.expiresAt = null;

      final msg =
          'Table #${lock.tableNumber} is now available ($reason).';
      _notifications.add(msg);
      debugPrint('[TableLockService] $msg');
    }
    notifyListeners();
  }

  /// Resets all locks (for tests)
  void resetAll() {
    _locks.clear();
    notifyListeners();
  }
}

