import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:baratie/config/provider.dart';

class RestaurantSearchBar extends StatefulWidget {
  final List<String> restaurantTypes;
  final Function(String, String, String) onSearch;

  const RestaurantSearchBar({
    Key? key,
    required this.restaurantTypes,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<RestaurantSearchBar> createState() => _RestaurantSearchBarState();
}

class _RestaurantSearchBarState extends State<RestaurantSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedType = 'Tous types';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.restaurantTypes.first;
    _loadRestaurantTypes();
  }

  Future<void> _loadRestaurantTypes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<BaratieProvider>(context, listen: false);
      await provider.getRestaurantTypes(); // Load types for provider cache
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    final location = _locationController.text.trim();
    final type = _selectedType == 'Tous types' ? '' : _selectedType;

    // Call the callback
    widget.onSearch(query, location, type);

    // Navigate to search results
    context.push('/search-results', extra: {
      'query': query,
      'city': location.isEmpty ? null : location,
      'type': type.isEmpty ? null : type,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search keywords field
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Mots clés',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const Divider(),
          
          // Location field
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: 'Où ?',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const Divider(),
          
          // Type dropdown
          if (_isLoading) 
            const Center(child: CircularProgressIndicator())
          else 
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              underline: const SizedBox(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
              items: widget.restaurantTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
          
          const SizedBox(height: 8),
          
          // Search button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6CC5D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Rechercher',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}