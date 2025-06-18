import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart';

class ReminderService {
  final FirebaseFirestore _firestore;
  final String _collection = 'reminders';

  ReminderService(this._firestore);

  Stream<List<Reminder>> getReminders(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('reminderTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reminder.fromFirestore(doc))
            .toList());
  }

  Future<void> addReminder(String userId, Reminder reminder) async {
    final docRef = _firestore.collection(_collection).doc();
    await docRef.set({
      ...reminder.toFirestore(),
      'userId': userId,
    });
  }

  Future<void> updateReminder(String userId, Reminder reminder) async {
    await _firestore
        .collection(_collection)
        .doc(reminder.id)
        .update(reminder.toFirestore());
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    await _firestore.collection(_collection).doc(reminderId).delete();
  }

  Future<void> initializePrayerTimeReminders(String userId) async {
    final now = DateTime.now();
    final prayerTimes = [
      {
        'title': 'Fajr Prayer',
        'description': 'Time for Fajr prayer',
        'hour': 5,
        'minute': 0,
      },
      {
        'title': 'Dhuhr Prayer',
        'description': 'Time for Dhuhr prayer',
        'hour': 12,
        'minute': 30,
      },
      {
        'title': 'Asr Prayer',
        'description': 'Time for Asr prayer',
        'hour': 15,
        'minute': 30,
      },
      {
        'title': 'Maghrib Prayer',
        'description': 'Time for Maghrib prayer',
        'hour': 18,
        'minute': 0,
      },
      {
        'title': 'Isha Prayer',
        'description': 'Time for Isha prayer',
        'hour': 20,
        'minute': 0,
      },
    ];

    for (final prayer in prayerTimes) {
      final reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayer['hour'] as int,
        prayer['minute'] as int,
      );

      final reminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: prayer['title'] as String,
        description: prayer['description'] as String,
        reminderTime: reminderTime,
        isSystemGenerated: true,
        createdAt: DateTime.now(),
      );

      await addReminder(userId, reminder);
    }
  }
} 