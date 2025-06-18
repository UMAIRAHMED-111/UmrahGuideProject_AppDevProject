import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../blocs/location/location_bloc.dart';
import '../../blocs/location/location_event.dart';
import '../../blocs/location/location_state.dart';
import '../../models/location.dart';
import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import 'location_dialogs.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: LocationCategory.values.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          return Column(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  hintText: 'Search locations or addresses...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            context.read<LocationBloc>().add(const ClearSearch());
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  if (value.length >= 3) {
                    // Get place predictions for address search
                    context.read<LocationBloc>().add(GetPlacePredictions(value));
                    // Search existing locations across all categories
                    context.read<LocationBloc>().add(SearchLocations(value));
                  } else if (value.isEmpty) {
                    context.read<LocationBloc>().add(const ClearSearch());
                  } else {
                    // Search existing locations even for short queries across all categories
                    context.read<LocationBloc>().add(SearchLocations(value));
                  }
                },
                onSubmitted: (value) {
                  // When user presses enter, search across all categories
                  if (value.isNotEmpty) {
                    context.read<LocationBloc>().add(GetPlacePredictions(value));
                    context.read<LocationBloc>().add(SearchLocations(value)); // No category filter
                  }
                },
              ),
              // Show place predictions if available
              if (state is LocationLoaded && 
                  state.placePredictions.isNotEmpty && 
                  _searchController.text.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: state.placePredictions.map((prediction) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on, color: Colors.grey),
                          title: Text(
                            prediction['structured_formatting']?['main_text'] ?? prediction['description'] ?? '',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            prediction['structured_formatting']?['secondary_text'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            final address = prediction['description'] ?? '';
                            _searchController.text = address;
                            // Clear place predictions to close dropdown
                            context.read<LocationBloc>().add(const ClearPlacePredictions());
                            // Search for this address in existing locations across all categories
                            context.read<LocationBloc>().add(SearchLocations(address));
                            // Optionally get place details for coordinates
                            if (prediction['place_id'] != null) {
                              context.read<LocationBloc>().add(GetPlaceDetails(prediction['place_id']));
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationCard(Location location, Set<String> expandedLocationIds) {
    final isExpanded = expandedLocationIds.contains(location.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF32D27F).withOpacity(0.2),
              child: Text(
                location.category.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                if (location.isVerified)
                  const Icon(Icons.verified, color: Color(0xFF32D27F), size: 16),
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white70),
                  onPressed: () {
                    context.read<LocationBloc>().add(ToggleLocationExpansion(location.id));
                  },
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  location.address,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: const Color(0xFF32D27F), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      location.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFF32D27F),
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${location.comments.length} reviews)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (location.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: location.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF32D27F).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFF32D27F),
                          fontSize: 10,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    context.read<LocationBloc>().add(ShowEditLocationDialog(location));
                    break;
                  case 'delete':
                    final userId = context.read<AuthService>().currentUser?.uid;
                    if (userId != null) {
                      context.read<LocationBloc>().add(DeleteLocation(userId, location.id));
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Color(0xFF32D27F)),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) _buildExpandedLocationDetails(location),
        ],
      ),
    );
  }

  Widget _buildExpandedLocationDetails(Location location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A6244).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (location.description.isNotEmpty) ...[
            Text('Description', style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 14)),
            const SizedBox(height: 4),
            Text(location.description, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 13)),
            const SizedBox(height: 12),
          ],
          if (location.phoneNumber != null && location.phoneNumber!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.phone, color: Color(0xFF32D27F), size: 16),
                const SizedBox(width: 8),
                Text(location.phoneNumber!, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (location.website != null && location.website!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.link, color: Color(0xFF32D27F), size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(location.website!, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 13, decoration: TextDecoration.underline), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (location.tags.isNotEmpty) ...[
            Text('Tags', style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 14)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: location.tags.map((tag) => Chip(
                label: Text(tag, style: const TextStyle(fontSize: 12, color: Color(0xFF32D27F), fontFamily: 'Cairo')),
                backgroundColor: const Color(0xFF32D27F).withOpacity(0.1),
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],
          _buildCommentsSection(location),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(Location location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Comments', style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 14)),
            const SizedBox(width: 8),
            Icon(Icons.comment, color: Colors.white.withOpacity(0.7), size: 16),
          ],
        ),
        const SizedBox(height: 8),
        if (location.comments.isEmpty)
          Text('No comments yet. Be the first to add one!', style: TextStyle(color: Colors.white.withOpacity(0.7), fontFamily: 'Cairo', fontSize: 12)),
        ...location.comments.map((comment) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF32D27F), fontFamily: 'Cairo', fontSize: 13)),
                  const Spacer(),
                  if (comment.rating > 0) ...[
                    const Icon(Icons.star, color: Color(0xFF32D27F), size: 14),
                    Text(comment.rating.toString(), style: const TextStyle(color: Color(0xFF32D27F), fontSize: 12, fontFamily: 'Cairo')),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.comment, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 13)),
              const SizedBox(height: 2),
              Text(_formatDate(comment.createdAt), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontFamily: 'Cairo')),
            ],
          ),
        )),
        const SizedBox(height: 8),
        _buildAddCommentForm(location),
      ],
    );
  }

  Widget _buildAddCommentForm(Location location) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        double rating = 0.0;
        String commentText = '';
        if (state is LocationLoaded) {
          rating = state.commentRatings[location.id] ?? 0.0;
          commentText = state.commentTexts[location.id] ?? '';
        }
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Your Rating:', style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 12)),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) => IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF32D27F),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      context.read<LocationBloc>().add(UpdateCommentRating(location.id, index + 1.0));
                    },
                  )),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: commentText,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add a comment...'
                      ,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Cairo'),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  context.read<LocationBloc>().add(UpdateCommentText(location.id, value));
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32D27F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final userId = context.read<AuthService>().currentUser?.uid;
                    final userName = context.read<AuthService>().currentUser?.displayName ?? 'Anonymous';
                    if (userId != null && commentText.trim().isNotEmpty) {
                      final comment = LocationComment(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: userId,
                        userName: userName,
                        comment: commentText.trim(),
                        rating: rating,
                        createdAt: DateTime.now(),
                      );
                      context.read<LocationBloc>().add(AddLocationComment(userId, location.id, comment));
                      context.read<LocationBloc>().add(ClearCommentForm(location.id));
                    }
                  },
                  child: const Text('Add Comment', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildEmptyState(LocationCategory category) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final isSearching = state is LocationLoaded && state.searchQuery.isNotEmpty;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isSearching ? '🔍' : category.icon,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                isSearching 
                  ? 'No locations found for "${state.searchQuery}"'
                  : 'No ${category.displayName} found',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isSearching
                  ? 'Try searching with different keywords or check other categories'
                  : 'Add your first ${category.displayName.toLowerCase()} location',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!isSearching)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32D27F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    context.read<LocationBloc>().add(const ShowAddLocationDialog());
                  },
                  child: const Text('Add Location', style: TextStyle(fontFamily: 'Cairo')),
                ),
              if (isSearching)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32D27F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Search across all categories
                    context.read<LocationBloc>().add(SearchLocations(state.searchQuery));
                  },
                  child: const Text('Search All Categories', style: TextStyle(fontFamily: 'Cairo')),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthService>().currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Please sign in to view locations', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')));
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F3D2E), Color(0xFF1A6244)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            // Load locations if not loaded yet
            if (state is LocationInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<LocationBloc>().add(LoadLocations(userId));
              });
              return _buildShimmerLoading();
            }

            // Handle category change when tab changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (state is LocationLoaded) {
                final currentCategory = LocationCategory.values[_tabController.index];
                if (state.selectedCategory != currentCategory) {
                  if (state.searchQuery.isEmpty) {
                    // When not searching, filter by the new category
                    context.read<LocationBloc>().add(FilterLocationsByCategory(currentCategory));
                  } else {
                    // When searching, just update the selected category for display purposes
                    // The TabBarView will filter the search results by the current category
                    context.read<LocationBloc>().add(UpdateSelectedCategory(currentCategory));
                  }
                }
              }
            });

            if (state is LocationLoading) {
              return _buildShimmerLoading();
            }

            if (state is LocationError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                ),
              );
            }

            if (state is LocationLoaded) {
              return Stack(
                children: [
                  Column(
                    children: [
                      // App Bar
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Location Awareness',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<LocationBloc>().add(const ShowAddLocationDialog());
                              },
                              icon: const Icon(
                                Icons.add_location,
                                color: Color(0xFF32D27F),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search Bar
                      _buildSearchBar(),

                      // Search Status Indicator
                      if (state.searchQuery.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF32D27F).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF32D27F).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Color(0xFF32D27F), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Searching for "${state.searchQuery}" ${state.selectedCategory != null ? 'in ${state.selectedCategory!.displayName}' : 'across all categories'}',
                                  style: const TextStyle(
                                    color: Color(0xFF32D27F),
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<LocationBloc>().add(const ClearSearch());
                                },
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: Color(0xFF32D27F),
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Category Tabs
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: const Color(0xFF32D27F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white.withOpacity(0.7),
                          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
                          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
                          isScrollable: true,
                          tabs: LocationCategory.values.map((category) => Tab(
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 80),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(category.icon),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      category.displayName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                      ),

                      // Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: LocationCategory.values.map((category) {
                            // Always filter by the current tab category, whether searching or not
                            final categoryLocations = state.filteredLocations
                                .where((location) => location.category == category)
                                .toList();

                            if (categoryLocations.isEmpty) {
                              return _buildEmptyState(category);
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                              itemCount: categoryLocations.length,
                              itemBuilder: (context, index) {
                                return _buildLocationCard(categoryLocations[index], state.expandedLocationIds);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  // Dialogs
                  if (state.showAddLocationDialog)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: LocationDialogs.buildAddLocationDialog(context, state),
                      ),
                    ),
                  if (state.showEditLocationDialog)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: LocationDialogs.buildEditLocationDialog(context, state),
                      ),
                    ),
                  if (state.showLocationDetailsDialog)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: LocationDialogs.buildLocationDetailsDialog(context, state),
                      ),
                    ),
                  if (state.showAddCommentDialog)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: LocationDialogs.buildAddCommentDialog(context, state),
                      ),
                    ),
                ],
              );
            }

            return const Center(child: Text('Unknown state', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')));
          },
        ),
      ),
    );
  }
} 