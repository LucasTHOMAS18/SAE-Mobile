import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:baratie/config/provider.dart';
import 'package:baratie/models/restaurant.dart';
import 'package:baratie/views/widgets/restaurant_card.dart';
import 'package:baratie/views/widgets/search_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantTypes = [
      'Tous types',
      'Fast-food',
    ];

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, restaurantTypes),
          Expanded(
            child: _buildRestaurantsSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<String> restaurantTypes) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: const Color(0xFF6CC5D9),
      height: isMobile 
          ? MediaQuery.of(context).size.height * 0.35
          : MediaQuery.of(context).size.height * 0.42,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/burger.png',
              width: MediaQuery.of(context).size.width * (isMobile ? 0.4 : 0.3),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/plat.png',
              width: MediaQuery.of(context).size.width * (isMobile ? 0.4 : 0.3),
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SizedBox(
              width: isMobile
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Où allez vous manger ?',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RestaurantSearchBar(
                    restaurantTypes: restaurantTypes,
                    onSearch: (searchTerm, location, type) {
                      // Handle search here
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsSection(BuildContext context) {
    final restaurants = Provider.of<BaratieProvider>(context).getTopRatedRestaurants();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Restaurants à la une',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Restaurant>>(
            future: restaurants,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucun restaurant trouvé'));
              }
              
              return Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final restaurant = snapshot.data![index];
                    return RestaurantCard(
                      restaurant: restaurant,
                      onTap: () {
                        // Navigate to restaurant details
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}