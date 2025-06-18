import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String userId;
  final Map<String, bool> completedRituals;
  final DateTime lastUpdated;

  UserProgress({
    required this.userId,
    required this.completedRituals,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'completedRituals': completedRituals,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    DateTime lastUpdated;
    final raw = map['lastUpdated'];
    if (raw is Timestamp) {
      lastUpdated = raw.toDate();
    } else if (raw is String) {
      lastUpdated = DateTime.parse(raw);
    } else {
      lastUpdated = DateTime.now();
    }
    return UserProgress(
      userId: map['userId'] as String,
      completedRituals: Map<String, bool>.from(map['completedRituals'] as Map),
      lastUpdated: lastUpdated,
    );
  }
} 