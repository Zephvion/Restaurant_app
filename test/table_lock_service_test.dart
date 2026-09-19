import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/services/table_lock_service.dart';

void main() {
  group('TableLockService Race Condition & Lock Management Tests', () {
    late TableLockService lockService;

    setUp(() {
      lockService = TableLockService.instance;
      lockService.resetAll();
    });

    test('TEST 1: Person 1 acquires 5-minute exclusive hold lock on available table', () {
      final res = lockService.acquireLock(
        5,
        userId: 'usr_alex',
        userName: 'Alex',
        duration: const Duration(minutes: 5),
      );

      expect(res.type, equals(AcquireLockResultType.acquired));
      expect(lockService.isTableHeldBySelf(5, userId: 'usr_alex'), isTrue);
      expect(lockService.isTableHeldByOther(5, userId: 'usr_sarah'), isTrue);

      final lock = lockService.getLock(5);
      expect(lock.status, equals(TableLockStatus.held));
      expect(lock.holderUserId, equals('usr_alex'));
      expect(lock.holderUserName, equals('Alex'));
      expect(lock.remainingDuration.inMinutes, inInclusiveRange(4, 5));
    });

    test('TEST 2: Person 2 attempts to acquire held table and gets conflict with remaining countdown', () {
      // Alex holds Table #5
      lockService.acquireLock(
        5,
        userId: 'usr_alex',
        userName: 'Alex',
      );

      // Sarah tries to acquire Table #5
      final resSarah = lockService.acquireLock(
        5,
        userId: 'usr_sarah',
        userName: 'Sarah',
      );

      expect(resSarah.type, equals(AcquireLockResultType.heldByOther));
      expect(resSarah.holderName, equals('Alex'));
      expect(resSarah.remainingTime, isNotNull);
    });

    test('TEST 3: Person 2 joins priority waitlist for held table', () {
      lockService.acquireLock(
        5,
        userId: 'usr_alex',
        userName: 'Alex',
      );

      final joined = lockService.joinWaitlist(
        5,
        userId: 'usr_sarah',
        userName: 'Sarah',
      );

      expect(joined, isTrue);
      final lock = lockService.getLock(5);
      expect(lock.waitlist.length, equals(1));
      expect(lock.waitlist.first.userId, equals('usr_sarah'));
      expect(lock.waitlist.first.userName, equals('Sarah'));
    });

    test('TEST 4: When Person 1 times out or releases lock, table auto-transfers to Person 2', () {
      lockService.acquireLock(
        5,
        userId: 'usr_alex',
        userName: 'Alex',
      );

      lockService.joinWaitlist(
        5,
        userId: 'usr_sarah',
        userName: 'Sarah',
      );

      // Person 1 releases / times out
      lockService.releaseLock(5, userId: 'usr_alex');

      final lock = lockService.getLock(5);
      // Lock has now been automatically granted to Sarah!
      expect(lock.status, equals(TableLockStatus.held));
      expect(lock.holderUserId, equals('usr_sarah'));
      expect(lock.holderUserName, equals('Sarah'));
      expect(lock.waitlist.isEmpty, isTrue);
      expect(lockService.isTableHeldBySelf(5, userId: 'usr_sarah'), isTrue);
    });

    test('TEST 5: Permanent reservation commits lock and clears waitlist', () {
      lockService.acquireLock(
        5,
        userId: 'usr_alex',
        userName: 'Alex',
      );

      lockService.commitReservation(5, userId: 'usr_alex');

      final lock = lockService.getLock(5);
      expect(lock.status, equals(TableLockStatus.reserved));
      expect(lockService.isTableReserved(5), isTrue);

      final nextAttempt = lockService.acquireLock(5, userId: 'usr_sarah');
      expect(nextAttempt.type, equals(AcquireLockResultType.tableReserved));
    });

    test('TEST 6: Owner/Staff manually releases table after guests leave', () {
      // Alex has reserved Table #5
      lockService.acquireLock(5, userId: 'usr_alex', userName: 'Alex');
      lockService.commitReservation(5, userId: 'usr_alex');
      expect(lockService.isTableReserved(5), isTrue);

      // Owner sees guests leave and releases table
      lockService.receptionistReleaseTable(5);

      final lock = lockService.getLock(5);
      expect(lock.status, equals(TableLockStatus.available));
      expect(lock.holderUserId, isNull);
      expect(lock.holderUserName, isNull);
      expect(lockService.isTableReserved(5), isFalse);

      // New guest Sarah can now immediately acquire Table #5
      final resSarah = lockService.acquireLock(5, userId: 'usr_sarah', userName: 'Sarah');
      expect(resSarah.type, equals(AcquireLockResultType.acquired));
    });

    test('TEST 7: Customer reservation cancellation frees table lock immediately', () {
      // Alex reserves Table #5
      lockService.acquireLock(5, userId: 'usr_alex', userName: 'Alex');
      lockService.commitReservation(5, userId: 'usr_alex');
      expect(lockService.isTableReserved(5), isTrue);

      // Alex cancels reservation
      lockService.cancelReservation(5);

      final lock = lockService.getLock(5);
      expect(lock.status, equals(TableLockStatus.available));
      expect(lock.holderUserId, isNull);
      expect(lockService.isTableReserved(5), isFalse);

      // Table is immediately available for someone else
      final res = lockService.acquireLock(5, userId: 'usr_sarah', userName: 'Sarah');
      expect(res.type, equals(AcquireLockResultType.acquired));
    });

    test('TEST 8: Combined tables for odd guest count released together on cancellation', () {
      // 3 guests require combining Table #1 and Table #2 (2-seaters)
      lockService.acquireLock(1, userId: 'usr_alex', userName: 'Alex');
      lockService.acquireLock(2, userId: 'usr_alex', userName: 'Alex');
      lockService.commitReservation(1, userId: 'usr_alex');
      lockService.commitReservation(2, userId: 'usr_alex');

      expect(lockService.isTableReserved(1), isTrue);
      expect(lockService.isTableReserved(2), isTrue);

      // Cancel reservation for all combined tables
      for (final tbl in [1, 2]) {
        lockService.cancelReservation(tbl);
      }

      expect(lockService.isTableReserved(1), isFalse);
      expect(lockService.isTableReserved(2), isFalse);
    });
  });
}

