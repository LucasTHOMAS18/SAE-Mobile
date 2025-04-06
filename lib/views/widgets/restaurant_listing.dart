import 'package:flutter/material.dart';
import 'package:baratie/models/restaurant.dart';
import 'package:baratie/views/widgets/restaurant_card.dart';

class RestaurantListing extends StatelessWidget {
  final List<Restaurant> restaurants;
  final String? emptyMessage;

  const RestaurantListing({
    super.key,
    required this.restaurants,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'Aucun restaurant trouvé',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: restaurants.map((restaurant) {
          final screenWidth = MediaQuery.of(context).size.width;
          final cardWidth = screenWidth < 500
              ? screenWidth
              : screenWidth / 2 - 24;

          return SizedBox(
            width: cardWidth,
            child: RestaurantCard(restaurant: restaurant),
          );
        }).toList(),
      ),
    );
  }
}
