import 'package:equatable/equatable.dart';

enum LocationCategory {
  historicPlaces,
  spiritualPlaces,
  food,
  accommodation,
  transportation,
  shopping,
  other;

  String get displayName {
    switch (this) {
      case LocationCategory.historicPlaces:
        return 'Historic Places';
      case LocationCategory.spiritualPlaces:
        return 'Spiritual Places';
      case LocationCategory.food:
        return 'Food & Dining';
      case LocationCategory.accommodation:
        return 'Accommodation';
      case LocationCategory.transportation:
        return 'Transportation';
      case LocationCategory.shopping:
        return 'Shopping';
      case LocationCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case LocationCategory.historicPlaces:
        return '🏛️';
      case LocationCategory.spiritualPlaces:
        return '🕌';
      case LocationCategory.food:
        return '🍽️';
      case LocationCategory.accommodation:
        return '🏨';
      case LocationCategory.transportation:
        return '🚗';
      case LocationCategory.shopping:
        return '🛍️';
      case LocationCategory.other:
        return '📍';
    }
  }
}

class LocationComment extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;
  final double rating;

  const LocationComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
    this.rating = 0.0,
  });

  LocationComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? comment,
    DateTime? createdAt,
    double? rating,
  }) {
    return LocationComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
    };
  }

  factory LocationComment.fromMap(Map<String, dynamic> map) {
    return LocationComment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, userId, userName, comment, createdAt, rating];
}

class Location extends Equatable {
  final String id;
  final String name;
  final String address;
  final String description;
  final LocationCategory category;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? phoneNumber;
  final String? website;
  final List<String> tags;
  final List<LocationComment> comments;
  final double averageRating;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;

  const Location({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.phoneNumber,
    this.website,
    this.tags = const [],
    this.comments = const [],
    this.averageRating = 0.0,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
  });

  Location copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    LocationCategory? category,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? phoneNumber,
    String? website,
    List<String>? tags,
    List<LocationComment>? comments,
    double? averageRating,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      averageRating: averageRating ?? this.averageRating,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'category': category.name,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'website': website,
      'tags': tags,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'averageRating': averageRating,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      category: LocationCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => LocationCategory.other,
      ),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      phoneNumber: map['phoneNumber'],
      website: map['website'],
      tags: List<String>.from(map['tags'] ?? []),
      comments: List<LocationComment>.from(
        (map['comments'] ?? []).map((comment) => LocationComment.fromMap(comment)),
      ),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isVerified: map['isVerified'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        description,
        category,
        latitude,
        longitude,
        imageUrl,
        phoneNumber,
        website,
        tags,
        comments,
        averageRating,
        createdBy,
        createdAt,
        updatedAt,
        isVerified,
      ];
} 