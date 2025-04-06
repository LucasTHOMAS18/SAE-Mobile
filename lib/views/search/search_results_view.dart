import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:baratie/config/provider.dart';
import 'package:baratie/models/restaurant.dart';
import 'package:baratie/views/widgets/restaurant_card.dart';

class SearchResultsView extends StatelessWidget {
  final String query;
  final String? city;
  final String? type;

  const SearchResultsView({
    Key? key,
    required this.query,
    this.city,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BaratieProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats de recherche'),
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: provider.searchRestaurants(query, city: city, type: type),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }
          
          final restaurants = snapshot.data ?? [];
          
          if (restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun restaurant trouvé',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Essayez avec d\'autres critères de recherche',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${restaurants.length} résultat${restaurants.length > 1 ? 's' : ''} trouvé${restaurants.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}