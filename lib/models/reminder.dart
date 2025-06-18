import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime reminderTime;
  final bool isSystemGenerated;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.reminderTime,
    this.isSystemGenerated = false,
    this.isEnabled = true,
    required this.createdAt,
    this.lastTriggeredAt,
  });

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      reminderTime: data['reminderTime'] is Timestamp
          ? (data['reminderTime'] as Timestamp).toDate()
          : DateTime.parse(data['reminderTime']),
      isSystemGenerated: data['isSystemGenerated'] ?? false,
      isEnabled: data['isEnabled'] ?? true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      lastTriggeredAt: data['lastTriggeredAt'] != null
          ? (data['lastTriggeredAt'] is Timestamp
              ? (data['lastTriggeredAt'] as Timestamp).toDate()
              : DateTime.parse(data['lastTriggeredAt']))
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'reminderTime': Timestamp.fromDate(reminderTime),
      'isSystemGenerated': isSystemGenerated,
      'isEnabled': isEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastTriggeredAt': lastTriggeredAt != null ? Timestamp.fromDate(lastTriggeredAt!) : null,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? reminderTime,
    bool? isSystemGenerated,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastTriggeredAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      isSystemGenerated: isSystemGenerated ?? this.isSystemGenerated,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reminderTime': reminderTime.toIso8601String(),
      'isSystemGenerated': isSystemGenerated,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      reminderTime: DateTime.parse(json['reminderTime']),
      isSystemGenerated: json['isSystemGenerated'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggeredAt: json['lastTriggeredAt'] != null ? DateTime.parse(json['lastTriggeredAt']) : null,
    );
  }
} 