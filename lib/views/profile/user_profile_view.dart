import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baratie/config/provider.dart';
import 'package:baratie/models/review.dart';
import 'package:baratie/models/restaurant.dart';
import 'package:baratie/views/details/details_view.dart';

class UserProfileView extends StatelessWidget {
  final int userId;

  const UserProfileView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BaratieProvider>(context);

    return FutureBuilder<String?>(
      future: provider.getUsernameById(userId),
      builder: (context, userSnapshot) {
        final username = userSnapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(username ?? 'Profil utilisateur'),
            backgroundColor: const Color.fromARGB(255, 108, 197, 217),
          ),
          body: FutureBuilder<List<Review>>(
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
          ),
        );
      },
    );
  }
}
