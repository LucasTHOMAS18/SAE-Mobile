import 'package:flutter/material.dart';

class RestaurantSearchBar extends StatelessWidget {
  final List<String> restaurantTypes;
  final Function(String, String, String)? onSearch;

  const RestaurantSearchBar({
    super.key,
    required this.restaurantTypes,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final locationController = TextEditingController();
    String selectedType = restaurantTypes.first;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Mots clés',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const Divider(height: 1),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              hintText: 'Où ?',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const Divider(height: 1),
          DropdownButtonFormField<String>(
            value: selectedType,
            items: restaurantTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              selectedType = value!;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () {
                if (onSearch != null) {
                  onSearch!(
                    searchController.text,
                    locationController.text,
                    selectedType,
                  );
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Rechercher', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}