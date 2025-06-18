import 'package:equatable/equatable.dart';
import '../../models/location.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final List<Location> locations;
  final List<Location> filteredLocations;
  final List<Map<String, dynamic>> placePredictions;
  final Map<String, dynamic>? selectedPlaceDetails;
  final LocationCategory? selectedCategory;
  final String searchQuery;
  final bool showAddLocationDialog;
  final bool showEditLocationDialog;
  final bool showLocationDetailsDialog;
  final bool showAddCommentDialog;
  final Location? editingLocation;
  final Location? selectedLocation;
  final String? errorMessage;
  final Set<String> expandedLocationIds;
  final bool showAddressSuggestions;
  final Map<String, double> commentRatings;
  final Map<String, String> commentTexts;

  const LocationLoaded({
    required this.locations,
    required this.filteredLocations,
    this.placePredictions = const [],
    this.selectedPlaceDetails,
    this.selectedCategory,
    this.searchQuery = '',
    this.showAddLocationDialog = false,
    this.showEditLocationDialog = false,
    this.showLocationDetailsDialog = false,
    this.showAddCommentDialog = false,
    this.editingLocation,
    this.selectedLocation,
    this.errorMessage,
    this.expandedLocationIds = const {},
    this.showAddressSuggestions = false,
    this.commentRatings = const {},
    this.commentTexts = const {},
  });

  LocationLoaded copyWith({
    List<Location>? locations,
    List<Location>? filteredLocations,
    List<Map<String, dynamic>>? placePredictions,
    Map<String, dynamic>? selectedPlaceDetails,
    LocationCategory? selectedCategory,
    String? searchQuery,
    bool? showAddLocationDialog,
    bool? showEditLocationDialog,
    bool? showLocationDetailsDialog,
    bool? showAddCommentDialog,
    Location? editingLocation,
    Location? selectedLocation,
    String? errorMessage,
    Set<String>? expandedLocationIds,
    bool? showAddressSuggestions,
    Map<String, double>? commentRatings,
    Map<String, String>? commentTexts,
  }) {
    return LocationLoaded(
      locations: locations ?? this.locations,
      filteredLocations: filteredLocations ?? this.filteredLocations,
      placePredictions: placePredictions ?? this.placePredictions,
      selectedPlaceDetails: selectedPlaceDetails ?? this.selectedPlaceDetails,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      showAddLocationDialog: showAddLocationDialog ?? this.showAddLocationDialog,
      showEditLocationDialog: showEditLocationDialog ?? this.showEditLocationDialog,
      showLocationDetailsDialog: showLocationDetailsDialog ?? this.showLocationDetailsDialog,
      showAddCommentDialog: showAddCommentDialog ?? this.showAddCommentDialog,
      editingLocation: editingLocation ?? this.editingLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      errorMessage: errorMessage ?? this.errorMessage,
      expandedLocationIds: expandedLocationIds ?? this.expandedLocationIds,
      showAddressSuggestions: showAddressSuggestions ?? this.showAddressSuggestions,
      commentRatings: commentRatings ?? this.commentRatings,
      commentTexts: commentTexts ?? this.commentTexts,
    );
  }

  @override
  List<Object?> get props => [
    locations,
    filteredLocations,
    placePredictions,
    selectedPlaceDetails,
    selectedCategory,
    searchQuery,
    showAddLocationDialog,
    showEditLocationDialog,
    showLocationDetailsDialog,
    showAddCommentDialog,
    editingLocation,
    selectedLocation,
    errorMessage,
    expandedLocationIds,
    showAddressSuggestions,
    commentRatings,
    commentTexts,
  ];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
} 