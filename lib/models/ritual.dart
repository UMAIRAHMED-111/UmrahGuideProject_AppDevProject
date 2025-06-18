class Ritual {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String audioUrl;
  final int order;
  bool isComplete;

  Ritual({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.audioUrl,
    required this.order,
    this.isComplete = false,
  });

  Ritual copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? audioUrl,
    int? order,
    bool? isComplete,
  }) {
    return Ritual(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      order: order ?? this.order,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  factory Ritual.fromMap(Map<String, dynamic> map) {
    return Ritual(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      order: map['order'],
      isComplete: map['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'order': order,
      'isComplete': isComplete,
    };
  }
} 