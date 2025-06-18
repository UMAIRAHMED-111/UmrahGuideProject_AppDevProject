import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/location.dart';
import '../../services/location_service.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;

  LocationBloc(this._locationService) : super(LocationInitial()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddLocation>(_onAddLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<DeleteLocation>(_onDeleteLocation);
    on<SearchLocations>(_onSearchLocations);
    on<FilterLocationsByCategory>(_onFilterLocationsByCategory);
    on<SortLocationsByDistance>(_onSortLocationsByDistance);
    on<SortLocationsByRating>(_onSortLocationsByRating);
    on<GetPlacePredictions>(_onGetPlacePredictions);
    on<GetPlaceDetails>(_onGetPlaceDetails);
    on<GetNearbyPlaces>(_onGetNearbyPlaces);
    on<GeocodeAddress>(_onGeocodeAddress);
    on<AddLocationComment>(_onAddLocationComment);
    on<ShowAddLocationDialog>(_onShowAddLocationDialog);
    on<ShowEditLocationDialog>(_onShowEditLocationDialog);
    on<ShowLocationDetailsDialog>(_onShowLocationDetailsDialog);
    on<ShowAddCommentDialog>(_onShowAddCommentDialog);
    on<HideDialog>(_onHideDialog);
    on<ClearSearch>(_onClearSearch);
    on<ClearPlacePredictions>(_onClearPlacePredictions);
    on<UpdateSelectedCategory>(_onUpdateSelectedCategory);
    on<ExpandLocation>(_onExpandLocation);
    on<CollapseLocation>(_onCollapseLocation);
    on<ToggleLocationExpansion>(_onToggleLocationExpansion);
    on<ShowAddressSuggestions>(_onShowAddressSuggestions);
    on<HideAddressSuggestions>(_onHideAddressSuggestions);
    on<UpdateCommentRating>(_onUpdateCommentRating);
    on<UpdateCommentText>(_onUpdateCommentText);
    on<ClearCommentForm>(_onClearCommentForm);
  }

  Future<void> _onLoadLocations(
    LoadLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      // For now, we'll use mock data. In a real app, this would fetch from Firebase
      final mockLocations = _getMockLocations();
      
      List<Location> filteredLocations = mockLocations;
      
      if (event.category != null) {
        filteredLocations = _locationService.filterLocationsByCategory(mockLocations, event.category!);
      }

      emit(LocationLoaded(
        locations: mockLocations,
        filteredLocations: filteredLocations,
        selectedCategory: event.category,
      ));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onAddLocation(
    AddLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final updatedLocations = List<Location>.from(currentState.locations)..add(event.location);
        
        emit(currentState.copyWith(
          locations: updatedLocations,
          filteredLocations: _applyFilters(updatedLocations, currentState.selectedCategory, currentState.searchQuery),
          showAddLocationDialog: false,
          editingLocation: null,
        ));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final updatedLocations = currentState.locations.map((location) {
          return location.id == event.location.id ? event.location : location;
        }).toList();
        
        emit(currentState.copyWith(
          locations: updatedLocations,
          filteredLocations: _applyFilters(updatedLocations, currentState.selectedCategory, currentState.searchQuery),
          showEditLocationDialog: false,
          editingLocation: null,
        ));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final updatedLocations = currentState.locations.where((location) => location.id != event.locationId).toList();
        
        emit(currentState.copyWith(
          locations: updatedLocations,
          filteredLocations: _applyFilters(updatedLocations, currentState.selectedCategory, currentState.searchQuery),
        ));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onSearchLocations(
    SearchLocations event,
    Emitter<LocationState> emit,
  ) async {
    try {
      print('🔍 BLOC: SearchLocations called with query: "${event.query}"');
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        print('🔍 BLOC: Total locations available: ${currentState.locations.length}');
        
        // Search across all locations first
        List<Location> searchResults = _locationService.searchLocations(currentState.locations, event.query);
        print('🔍 BLOC: Search results found: ${searchResults.length}');
        print('🔍 BLOC: Results: ${searchResults.map((l) => '${l.name} (${l.address})').toList()}');
        
        // Store the search results but don't apply category filter yet
        // The category filter will be applied by the TabBarView based on the current tab
        emit(currentState.copyWith(
          filteredLocations: searchResults,
          searchQuery: event.query,
          // Don't change selectedCategory here - keep the current one
        ));
        print('🔍 BLOC: State updated with ${searchResults.length} filtered locations');
      } else {
        print('❌ BLOC: State is not LocationLoaded: ${state.runtimeType}');
      }
    } catch (e) {
      print('❌ BLOC: Error in _onSearchLocations: $e');
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onFilterLocationsByCategory(
    FilterLocationsByCategory event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        List<Location> filteredLocations = _locationService.filterLocationsByCategory(currentState.locations, event.category);
        
        if (currentState.searchQuery.isNotEmpty) {
          filteredLocations = _locationService.searchLocations(filteredLocations, currentState.searchQuery);
        }
        
        emit(currentState.copyWith(
          filteredLocations: filteredLocations,
          selectedCategory: event.category,
        ));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onSortLocationsByDistance(
    SortLocationsByDistance event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final sortedLocations = _locationService.sortLocationsByDistance(
          currentState.filteredLocations,
          event.latitude,
          event.longitude,
        );
        
        emit(currentState.copyWith(filteredLocations: sortedLocations));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onSortLocationsByRating(
    SortLocationsByRating event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final sortedLocations = _locationService.sortLocationsByRating(currentState.filteredLocations);
        
        emit(currentState.copyWith(filteredLocations: sortedLocations));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onGetPlacePredictions(
    GetPlacePredictions event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final predictions = await _locationService.getPlacePredictions(event.input);
        
        emit(currentState.copyWith(placePredictions: predictions));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onGetPlaceDetails(
    GetPlaceDetails event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final placeDetails = await _locationService.getPlaceDetails(event.placeId);
        
        emit(currentState.copyWith(selectedPlaceDetails: placeDetails));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onGetNearbyPlaces(
    GetNearbyPlaces event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final nearbyPlaces = await _locationService.getNearbyPlaces(
        latitude: event.latitude,
        longitude: event.longitude,
        type: event.type,
        radius: event.radius,
      );
      
      // Convert to Location objects and add to state
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final newLocations = nearbyPlaces.map((place) => _convertPlaceToLocation(place)).toList();
        final updatedLocations = List<Location>.from(currentState.locations)..addAll(newLocations);
        
        emit(currentState.copyWith(
          locations: updatedLocations,
          filteredLocations: _applyFilters(updatedLocations, currentState.selectedCategory, currentState.searchQuery),
        ));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onGeocodeAddress(
    GeocodeAddress event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final coordinates = await _locationService.geocodeAddress(event.address);
      // Handle geocoding result
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onAddLocationComment(
    AddLocationComment event,
    Emitter<LocationState> emit,
  ) async {
    try {
      if (state is LocationLoaded) {
        final currentState = state as LocationLoaded;
        final updatedLocations = currentState.locations.map((location) {
          if (location.id == event.locationId) {
            final updatedComments = List<LocationComment>.from(location.comments)..add(event.comment);
            final averageRating = updatedComments.isNotEmpty
                ? updatedComments.map((c) => c.rating).reduce((a, b) => a + b) / updatedComments.length
                : 0.0;
            return location.copyWith(
              comments: updatedComments,
              averageRating: averageRating,
            );
          }
          return location;
        }).toList();
        
        emit(currentState.copyWith(
          locations: updatedLocations,
          filteredLocations: _applyFilters(updatedLocations, currentState.selectedCategory, currentState.searchQuery),
          showAddCommentDialog: false,
          selectedLocation: null,
        ));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  void _onShowAddLocationDialog(
    ShowAddLocationDialog event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(showAddLocationDialog: true));
    }
  }

  void _onShowEditLocationDialog(
    ShowEditLocationDialog event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(
        showEditLocationDialog: true,
        editingLocation: event.location,
      ));
    }
  }

  void _onShowLocationDetailsDialog(
    ShowLocationDetailsDialog event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(
        showLocationDetailsDialog: true,
        selectedLocation: event.location,
      ));
    }
  }

  void _onShowAddCommentDialog(
    ShowAddCommentDialog event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(
        showAddCommentDialog: true,
        selectedLocation: event.location,
      ));
    }
  }

  void _onHideDialog(
    HideDialog event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(
        showAddLocationDialog: false,
        showEditLocationDialog: false,
        showLocationDetailsDialog: false,
        showAddCommentDialog: false,
        editingLocation: null,
        selectedLocation: null,
      ));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(
        searchQuery: '',
        filteredLocations: _applyFilters(currentState.locations, currentState.selectedCategory, ''),
      ));
    }
  }

  void _onClearPlacePredictions(
    ClearPlacePredictions event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(
        placePredictions: [],
      ));
    }
  }

  void _onUpdateSelectedCategory(
    UpdateSelectedCategory event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(
        selectedCategory: event.category,
      ));
    }
  }

  void _onExpandLocation(ExpandLocation event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final updated = Set<String>.from(currentState.expandedLocationIds)..add(event.locationId);
      emit(currentState.copyWith(expandedLocationIds: updated));
    }
  }

  void _onCollapseLocation(CollapseLocation event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final updated = Set<String>.from(currentState.expandedLocationIds)..remove(event.locationId);
      emit(currentState.copyWith(expandedLocationIds: updated));
    }
  }

  void _onToggleLocationExpansion(ToggleLocationExpansion event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final updated = Set<String>.from(currentState.expandedLocationIds);
      if (updated.contains(event.locationId)) {
        updated.remove(event.locationId);
      } else {
        updated.add(event.locationId);
      }
      emit(currentState.copyWith(expandedLocationIds: updated));
    }
  }

  void _onShowAddressSuggestions(ShowAddressSuggestions event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(showAddressSuggestions: true));
    }
  }

  void _onHideAddressSuggestions(HideAddressSuggestions event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(showAddressSuggestions: false));
    }
  }

  void _onUpdateCommentRating(UpdateCommentRating event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final updated = Map<String, double>.from(currentState.commentRatings);
      updated[event.locationId] = event.rating;
      emit(currentState.copyWith(commentRatings: updated));
    }
  }

  void _onUpdateCommentText(UpdateCommentText event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final updated = Map<String, String>.from(currentState.commentTexts);
      updated[event.locationId] = event.text;
      emit(currentState.copyWith(commentTexts: updated));
    }
  }

  void _onClearCommentForm(ClearCommentForm event, Emitter<LocationState> emit) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final updatedRatings = Map<String, double>.from(currentState.commentRatings);
      final updatedTexts = Map<String, String>.from(currentState.commentTexts);
      updatedRatings.remove(event.locationId);
      updatedTexts.remove(event.locationId);
      emit(currentState.copyWith(commentRatings: updatedRatings, commentTexts: updatedTexts));
    }
  }

  List<Location> _applyFilters(List<Location> locations, LocationCategory? category, String searchQuery) {
    List<Location> filtered = locations;
    
    if (category != null) {
      filtered = _locationService.filterLocationsByCategory(filtered, category);
    }
    
    if (searchQuery.isNotEmpty) {
      filtered = _locationService.searchLocations(filtered, searchQuery);
    }
    
    return filtered;
  }

  Location _convertPlaceToLocation(Map<String, dynamic> place) {
    final geometry = place['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;
    
    return Location(
      id: place['place_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: place['name'] ?? 'Unknown Place',
      address: place['formatted_address'] ?? 'No address available',
      description: place['types']?.join(', ') ?? 'No description available',
      category: LocationCategory.other,
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<Location> _getMockLocations() {
    return [
      Location(
        id: '1',
        name: 'Masjid al-Haram',
        address: 'Al Haram, Mecca 24231, Saudi Arabia',
        description: 'The Great Mosque of Mecca, also known as the Sacred Mosque, is the largest mosque in the world.',
        category: LocationCategory.spiritualPlaces,
        latitude: 21.4225,
        longitude: 39.8262,
        tags: ['mosque', 'holy', 'prayer'],
        averageRating: 4.9,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
      ),
      Location(
        id: '2',
        name: 'Masjid an-Nabawi',
        address: 'Al Haram, Medina 42311, Saudi Arabia',
        description: 'The Prophet\'s Mosque is the second holiest site in Islam.',
        category: LocationCategory.spiritualPlaces,
        latitude: 24.4672,
        longitude: 39.6112,
        tags: ['mosque', 'holy', 'prophet'],
        averageRating: 4.8,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
      ),
      Location(
        id: '3',
        name: 'Jabal al-Nour',
        address: 'Mecca, Saudi Arabia',
        description: 'The Mountain of Light where Prophet Muhammad received his first revelation.',
        category: LocationCategory.historicPlaces,
        latitude: 21.4575,
        longitude: 39.8597,
        tags: ['mountain', 'historic', 'revelation'],
        averageRating: 4.7,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
      ),
      Location(
        id: '4',
        name: 'Al Baik Restaurant',
        address: 'King Abdulaziz Road, Mecca, Saudi Arabia',
        description: 'Famous fast food restaurant chain in Saudi Arabia.',
        category: LocationCategory.food,
        latitude: 21.4225,
        longitude: 39.8262,
        tags: ['restaurant', 'fast food', 'chicken'],
        averageRating: 4.5,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
      ),
    ];
  }
} 