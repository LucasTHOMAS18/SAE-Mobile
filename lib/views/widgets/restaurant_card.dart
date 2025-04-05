import 'package:baratie/views/details/details_view.dart';
import 'package:flutter/material.dart';
import 'package:baratie/models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsView(idRestaurant: restaurant.id),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                'assets/images/baratie.jpg',
                height: 120, 
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0), // Réduit le padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.nameR,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Taille réduite
                    ),
                  ),
                  const SizedBox(height: 2), // Espace réduit
                  Text(
                    restaurant.city ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12, // Taille réduite
                    ),
                  ),
                  const SizedBox(height: 4), // Espace réduit
                  Wrap(
                    spacing: 6, // Espacement réduit
                    runSpacing: 2, // Espacement réduit
                    children: [
                      if (restaurant.accessibl)
                        _buildBadge('Accessible', Colors.green),
                      if (restaurant.delivery)
                        _buildBadge('Livraison', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Padding vertical réduit
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10, // Taille de police réduite
        ),
      ),
    );
  }
}