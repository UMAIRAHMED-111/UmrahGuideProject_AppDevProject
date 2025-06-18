import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/location.dart';

class LocationService {
  static const String _apiKey = 'AIzaSyD4d3kMBN7pbvfHS0zKGrRJr-X2NAex9zo';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  // Get place predictions for autocomplete
  Future<List<Map<String, dynamic>>> getPlacePredictions(String input) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/autocomplete/json?input=$input&key=$_apiKey&types=establishment|geocode',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = List<Map<String, dynamic>>.from(data['predictions']);
          return predictions;
        }
      }
      return [];
    } catch (e) {
      print('Error getting place predictions: $e');
      return [];
    }
  }

  // Get place details by place_id
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/details/json?place_id=$placeId&fields=name,formatted_address,geometry,formatted_phone_number,website,photos&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  // Get nearby places
  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
    int radius = 5000,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        }
      }
      return [];
    } catch (e) {
      print('Error getting nearby places: $e');
      return [];
    }
  }

  // Geocode address to coordinates
  Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'latitude': location['lat'].toDouble(),
            'longitude': location['lng'].toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }

  // Reverse geocode coordinates to address
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/geocode/json?latlng=$latitude,$longitude&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  // Calculate distance between two points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get places by category
  List<Location> filterLocationsByCategory(List<Location> locations, LocationCategory category) {
    return locations.where((location) => location.category == category).toList();
  }

  // Search locations by name or address
  List<Location> searchLocations(List<Location> locations, String query) {
    final lowercaseQuery = query.toLowerCase().trim();
    if (lowercaseQuery.isEmpty) return locations;
    
    final queryWords = lowercaseQuery.split(' ').where((word) => word.isNotEmpty).toList();
    
    return locations.where((location) {
      final name = location.name.toLowerCase();
      final address = location.address.toLowerCase();
      final description = location.description.toLowerCase();
      final tags = location.tags.map((tag) => tag.toLowerCase()).toList();
      // AND logic: every query word must match at least one field
      return queryWords.every((queryWord) =>
        name.contains(queryWord) ||
        address.contains(queryWord) ||
        description.contains(queryWord) ||
        tags.any((tag) => tag.contains(queryWord))
      );
    }).toList();
  }

  // Sort locations by distance from a point
  List<Location> sortLocationsByDistance(List<Location> locations, double lat, double lon) {
    final sortedLocations = List<Location>.from(locations);
    sortedLocations.sort((a, b) {
      final distanceA = calculateDistance(lat, lon, a.latitude, a.longitude);
      final distanceB = calculateDistance(lat, lon, b.latitude, b.longitude);
      return distanceA.compareTo(distanceB);
    });
    return sortedLocations;
  }

  // Sort locations by rating
  List<Location> sortLocationsByRating(List<Location> locations) {
    final sortedLocations = List<Location>.from(locations);
    sortedLocations.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sortedLocations;
  }
} 