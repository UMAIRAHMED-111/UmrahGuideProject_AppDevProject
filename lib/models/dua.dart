class Dua {
  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String category;
  final String audioUrl;

  Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.category,
    required this.audioUrl,
  });

  factory Dua.fromMap(Map<String, dynamic> map) {
    return Dua(
      id: map['id'],
      title: map['title'],
      arabic: map['arabic'],
      transliteration: map['transliteration'],
      translation: map['translation'],
      category: map['category'],
      audioUrl: map['audioUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'arabic': arabic,
      'transliteration': transliteration,
      'translation': translation,
      'category': category,
      'audioUrl': audioUrl,
    };
  }
} 