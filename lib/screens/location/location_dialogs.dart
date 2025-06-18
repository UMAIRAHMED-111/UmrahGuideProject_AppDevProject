import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/location/location_bloc.dart';
import '../../blocs/location/location_event.dart';
import '../../blocs/location/location_state.dart';
import '../../models/location.dart';
import '../../services/auth_service.dart';
import '../../widgets/address_autocomplete.dart';

class LocationDialogs {
  static Widget buildAddLocationDialog(BuildContext context, LocationLoaded state) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _addressController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _phoneController = TextEditingController();
    final _websiteController = TextEditingController();
    LocationCategory _selectedCategory = LocationCategory.spiritualPlaces;
    List<String> _tags = [];

    return BlocProvider.value(
      value: context.read<LocationBloc>(),
      child: AlertDialog(
        title: const Text('Add New Location', style: TextStyle(fontFamily: 'Cairo')),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AddressAutocomplete(
                  controller: _addressController,
                  labelText: 'Address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                  onAddressSelected: (address) {
                    // Optionally get place details for coordinates
                    // This could be enhanced to automatically fill coordinates
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<LocationCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: LocationCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(category.icon),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedCategory = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<LocationBloc>().add(const HideDialog());
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final userId = context.read<AuthService>().currentUser?.uid;
                if (userId != null) {
                  final now = DateTime.now();
                  final location = Location(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    address: _addressController.text,
                    description: _descriptionController.text,
                    category: _selectedCategory,
                    latitude: 0.0, // Will be set by geocoding
                    longitude: 0.0, // Will be set by geocoding
                    phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                    website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
                    tags: _tags,
                    createdBy: userId,
                    createdAt: now,
                    updatedAt: now,
                  );

                  context.read<LocationBloc>().add(AddLocation(userId, location));
                }
              }
            },
            child: const Text('Add Location'),
          ),
        ],
      ),
    );
  }

  static Widget buildEditLocationDialog(BuildContext context, LocationLoaded state) {
    final location = state.editingLocation;
    if (location == null) return const SizedBox.shrink();

    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: location.name);
    final _addressController = TextEditingController(text: location.address);
    final _descriptionController = TextEditingController(text: location.description);
    final _phoneController = TextEditingController(text: location.phoneNumber ?? '');
    final _websiteController = TextEditingController(text: location.website ?? '');
    LocationCategory _selectedCategory = location.category;

    return BlocProvider.value(
      value: context.read<LocationBloc>(),
      child: AlertDialog(
        title: const Text('Edit Location', style: TextStyle(fontFamily: 'Cairo')),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AddressAutocomplete(
                  controller: _addressController,
                  labelText: 'Address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                  onAddressSelected: (address) {
                    // Optionally get place details for coordinates
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<LocationCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: LocationCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(category.icon),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedCategory = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<LocationBloc>().add(const HideDialog());
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final userId = context.read<AuthService>().currentUser?.uid;
                if (userId != null) {
                  final updatedLocation = location.copyWith(
                    name: _nameController.text,
                    address: _addressController.text,
                    description: _descriptionController.text,
                    category: _selectedCategory,
                    phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                    website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
                    updatedAt: DateTime.now(),
                  );

                  context.read<LocationBloc>().add(UpdateLocation(userId, updatedLocation));
                }
              }
            },
            child: const Text('Update Location'),
          ),
        ],
      ),
    );
  }

  static Widget buildLocationDetailsDialog(BuildContext context, LocationLoaded state) {
    final location = state.selectedLocation;
    if (location == null) return const SizedBox.shrink();

    return AlertDialog(
      title: Row(
        children: [
          Text(location.category.icon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              location.name,
              style: const TextStyle(fontFamily: 'Cairo'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (location.isVerified)
            const Icon(Icons.verified, color: Color(0xFF32D27F)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Address', location.address, Icons.location_on),
            const SizedBox(height: 12),
            _buildDetailRow('Description', location.description, Icons.description),
            const SizedBox(height: 12),
            _buildDetailRow('Category', location.category.displayName, Icons.category),
            if (location.phoneNumber != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Phone', location.phoneNumber!, Icons.phone),
            ],
            if (location.website != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Website', location.website!, Icons.web),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF32D27F), size: 16),
                const SizedBox(width: 4),
                Text(
                  location.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF32D27F),
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${location.comments.length} reviews)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            if (location.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Tags:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: location.tags.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  backgroundColor: const Color(0xFF32D27F).withOpacity(0.1),
                )).toList(),
              ),
            ],
            if (location.comments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Comments:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              ...location.comments.take(3).map((comment) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const Spacer(),
                        if (comment.rating > 0) ...[
                          const Icon(Icons.star, color: Color(0xFF32D27F), size: 12),
                          Text(
                            comment.rating.toString(),
                            style: const TextStyle(
                              color: Color(0xFF32D27F),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.comment,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<LocationBloc>().add(ShowAddCommentDialog(location));
          },
          child: const Text('Add Comment'),
        ),
        TextButton(
          onPressed: () {
            context.read<LocationBloc>().add(const HideDialog());
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  static Widget buildAddCommentDialog(BuildContext context, LocationLoaded state) {
    final location = state.selectedLocation;
    if (location == null) return const SizedBox.shrink();

    final _formKey = GlobalKey<FormState>();
    final _commentController = TextEditingController();
    double _rating = 0.0;

    return AlertDialog(
      title: Text('Add Comment for ${location.name}', style: const TextStyle(fontFamily: 'Cairo')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Rating: '),
                ...List.generate(5, (index) => IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFF32D27F),
                  ),
                  onPressed: () {
                    _rating = index + 1.0;
                  },
                )),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Your Comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a comment';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<LocationBloc>().add(const HideDialog());
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final userId = context.read<AuthService>().currentUser?.uid;
              final userName = context.read<AuthService>().currentUser?.displayName ?? 'Anonymous';
              if (userId != null) {
                final comment = LocationComment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: userId,
                  userName: userName,
                  comment: _commentController.text,
                  rating: _rating,
                  createdAt: DateTime.now(),
                );

                context.read<LocationBloc>().add(AddLocationComment(userId, location.id, comment));
              }
            }
          },
          child: const Text('Add Comment'),
        ),
      ],
    );
  }

  static Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontFamily: 'Cairo',
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 