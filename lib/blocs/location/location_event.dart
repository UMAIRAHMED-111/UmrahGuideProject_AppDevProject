import 'package:equatable/equatable.dart';
import '../../models/location.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocations extends LocationEvent {
  final String userId;
  final LocationCategory? category;

  const LoadLocations(this.userId, {this.category});

  @override
  List<Object?> get props => [userId, category];
}

class AddLocation extends LocationEvent {
  final String userId;
  final Location location;

  const AddLocation(this.userId, this.location);

  @override
  List<Object?> get props => [userId, location];
}

class UpdateLocation extends LocationEvent {
  final String userId;
  final Location location;

  const UpdateLocation(this.userId, this.location);

  @override
  List<Object?> get props => [userId, location];
}

class DeleteLocation extends LocationEvent {
  final String userId;
  final String locationId;

  const DeleteLocation(this.userId, this.locationId);

  @override
  List<Object?> get props => [userId, locationId];
}

class SearchLocations extends LocationEvent {
  final String query;
  final LocationCategory? category;

  const SearchLocations(this.query, {this.category});

  @override
  List<Object?> get props => [query, category];
}

class FilterLocationsByCategory extends LocationEvent {
  final LocationCategory category;

  const FilterLocationsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SortLocationsByDistance extends LocationEvent {
  final double latitude;
  final double longitude;

  const SortLocationsByDistance(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class SortLocationsByRating extends LocationEvent {
  const SortLocationsByRating();
}

class GetPlacePredictions extends LocationEvent {
  final String input;

  const GetPlacePredictions(this.input);

  @override
  List<Object?> get props => [input];
}

class GetPlaceDetails extends LocationEvent {
  final String placeId;

  const GetPlaceDetails(this.placeId);

  @override
  List<Object?> get props => [placeId];
}

class GetNearbyPlaces extends LocationEvent {
  final double latitude;
  final double longitude;
  final String type;
  final int radius;

  const GetNearbyPlaces({
    required this.latitude,
    required this.longitude,
    required this.type,
    this.radius = 5000,
  });

  @override
  List<Object?> get props => [latitude, longitude, type, radius];
}

class GeocodeAddress extends LocationEvent {
  final String address;

  const GeocodeAddress(this.address);

  @override
  List<Object?> get props => [address];
}

class AddLocationComment extends LocationEvent {
  final String userId;
  final String locationId;
  final LocationComment comment;

  const AddLocationComment(this.userId, this.locationId, this.comment);

  @override
  List<Object?> get props => [userId, locationId, comment];
}

class ShowAddLocationDialog extends LocationEvent {
  const ShowAddLocationDialog();
}

class ShowEditLocationDialog extends LocationEvent {
  final Location location;

  const ShowEditLocationDialog(this.location);

  @override
  List<Object?> get props => [location];
}

class ShowLocationDetailsDialog extends LocationEvent {
  final Location location;

  const ShowLocationDetailsDialog(this.location);

  @override
  List<Object?> get props => [location];
}

class ShowAddCommentDialog extends LocationEvent {
  final Location location;

  const ShowAddCommentDialog(this.location);

  @override
  List<Object?> get props => [location];
}

class HideDialog extends LocationEvent {
  const HideDialog();
}

class ClearSearch extends LocationEvent {
  const ClearSearch();
}

class ClearPlacePredictions extends LocationEvent {
  const ClearPlacePredictions();
}

class UpdateSelectedCategory extends LocationEvent {
  final LocationCategory category;

  const UpdateSelectedCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ExpandLocation extends LocationEvent {
  final String locationId;
  const ExpandLocation(this.locationId);
  @override
  List<Object?> get props => [locationId];
}

class CollapseLocation extends LocationEvent {
  final String locationId;
  const CollapseLocation(this.locationId);
  @override
  List<Object?> get props => [locationId];
}

class ToggleLocationExpansion extends LocationEvent {
  final String locationId;
  const ToggleLocationExpansion(this.locationId);
  @override
  List<Object?> get props => [locationId];
}

class ShowAddressSuggestions extends LocationEvent {
  const ShowAddressSuggestions();
}

class HideAddressSuggestions extends LocationEvent {
  const HideAddressSuggestions();
}

class UpdateCommentRating extends LocationEvent {
  final String locationId;
  final double rating;
  const UpdateCommentRating(this.locationId, this.rating);
  @override
  List<Object?> get props => [locationId, rating];
}

class UpdateCommentText extends LocationEvent {
  final String locationId;
  final String text;
  const UpdateCommentText(this.locationId, this.text);
  @override
  List<Object?> get props => [locationId, text];
}

class ClearCommentForm extends LocationEvent {
  final String locationId;
  const ClearCommentForm(this.locationId);
  @override
  List<Object?> get props => [locationId];
} 