import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:baratie/config/auth_provider.dart';
import 'package:baratie/config/provider.dart';
import 'package:baratie/models/review.dart';
import 'package:baratie/models/restaurant.dart';
import 'package:baratie/views/details/details_view.dart';
import 'package:baratie/views/widgets/restaurant_card.dart';
import 'package:baratie/services/favorite_service.dart';

class UserProfileView extends StatelessWidget {
  final int userId;

  const UserProfileView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BaratieProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isCurrentUser = authProvider.isLoggedIn && authProvider.userId == userId;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<String?>(
            future: provider.getUsernameById(userId),
            builder: (context, snapshot) {
              return Text(snapshot.data ?? 'Profil utilisateur');
            },
          ),
          backgroundColor: const Color.fromARGB(255, 108, 197, 217),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.reviews), text: 'Avis'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoris'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReviewsTab(context, provider),
            _buildFavoritesTab(context, provider, isCurrentUser),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context, BaratieProvider provider) {
    return FutureBuilder<List<Review>>(
      future: provider.getReviewsByUser(userId),
      builder: (context, reviewSnapshot) {
        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = reviewSnapshot.data ?? [];

        if (reviews.isEmpty) {
          return const Center(child: Text('Aucun avis pour cet utilisateur.'));
        }

        return ListView.separated(
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return FutureBuilder<Restaurant?>(
              future: provider.getRestaurantById(review.idRestau),
              builder: (context, restauSnapshot) {
                final restaurant = restauSnapshot.data;
                return ListTile(
                  leading: const Icon(Icons.restaurant),
                  title: Text(restaurant?.nameR ?? 'Restaurant inconnu'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Note : ${review.note}/5'),
                      const SizedBox(height: 4),
                      Text(review.comment),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsView(idRestaurant: review.idRestau),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab(BuildContext context, BaratieProvider provider, bool isCurrentUser) {
    if (!isCurrentUser) {
      return const Center(
        child: Text('Connectez-vous pour voir vos favoris'),
      );
    }

    return FutureBuilder<Set<int>>(
      future: FavoriteService.getFavorites(userId),
      builder: (context, favoritesSnapshot) {
        if (favoritesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final favoriteIds = favoritesSnapshot.data ?? {};
        
        if (favoriteIds.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucun restaurant favori'),
              ],
            ),
          );
        }

        return FutureBuilder<List<Restaurant>>(
          future: provider.getRestaurantsByIds(favoriteIds.toList()),
          builder: (context, restaurantsSnapshot) {
            if (restaurantsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final restaurants = restaurantsSnapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return RestaurantCard(
                    restaurant: restaurants[index],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}