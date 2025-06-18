import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/location/location_bloc.dart';
import '../blocs/location/location_event.dart';
import '../blocs/location/location_state.dart';

class AddressAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final Function(String)? onAddressSelected;

  const AddressAutocomplete({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.onAddressSelected,
  }) : super(key: key);

  @override
  AddressAutocompleteState createState() => AddressAutocompleteState();
}

class AddressAutocompleteState extends State<AddressAutocomplete> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      context.read<LocationBloc>().add(ShowAddressSuggestions());
    } else {
      context.read<LocationBloc>().add(HideAddressSuggestions());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final showSuggestions = state is LocationLoaded && state.showAddressSuggestions;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(),
            if (showSuggestions && state is LocationLoaded && state.placePredictions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
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
                          widget.controller.text = address;
                          widget.onAddressSelected?.call(address);
                          context.read<LocationBloc>().add(const ClearPlacePredictions());
                          context.read<LocationBloc>().add(HideAddressSuggestions());
                          _focusNode.unfocus();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.location_on),
        hintText: 'Start typing to search...',
      ),
      validator: widget.validator,
      onChanged: (value) {
        if (value.length >= 3) {
          context.read<LocationBloc>().add(GetPlacePredictions(value));
          context.read<LocationBloc>().add(ShowAddressSuggestions());
        } else {
          context.read<LocationBloc>().add(HideAddressSuggestions());
        }
      },
      onTap: () {
        context.read<LocationBloc>().add(ShowAddressSuggestions());
      },
    );
  }
} 