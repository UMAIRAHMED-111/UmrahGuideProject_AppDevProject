import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistItem {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime? completedAt;

  ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.isCustom = false,
    required this.createdAt,
    this.completedAt,
  });

  factory ChecklistItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChecklistItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      isDone: data['isDone'] ?? false,
      isCustom: data['isCustom'] ?? false,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] is Timestamp
              ? (data['completedAt'] as Timestamp).toDate()
              : DateTime.parse(data['completedAt']))
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'isCustom': isCustom,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      isDone: json['isDone'] ?? false,
      isCustom: json['isCustom'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }
} 