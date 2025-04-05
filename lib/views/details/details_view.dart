import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:baratie/config/provider.dart';
import 'package:baratie/models/restaurant.dart';

class DetailsView extends StatelessWidget {
  final int idRestaurant;

  const DetailsView({
    super.key,
    required this.idRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BaratieProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du restaurant'),
        backgroundColor: Color.fromARGB(255, 108, 197, 217),
      ),
      body: FutureBuilder<Restaurant?>(
        future: provider.getRestaurantById(idRestaurant),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final restaurant = snapshot.data;

          if (restaurant == null) {
            return const Center(child: Text('Aucun restaurant trouvé avec cet ID.'));
          }

          final isOpen = restaurant.isCurrentlyOpen();
          final willClose = restaurant.whenWillClose();
          final willOpen = restaurant.whenWillOpen();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image principale
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/baratie.jpg',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom
                      Text(
                        restaurant.nameR,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Adresse
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                  '${restaurant.address ?? ''}${restaurant.address != null && restaurant.city != null ? ', ' : ''}${restaurant.city ?? ''}',
                                  style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Statut ouvert / fermé
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.schedule, size: 20, color: Colors.black),
                          const SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: isOpen ? 'Ouvert' : 'Fermé',
                                    style: TextStyle(
                                      color: isOpen ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: isOpen ? ' – Ferme à $willClose' : ' – Ouvre à $willOpen',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Informations de contact
                      if (restaurant.website != null)
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse(restaurant.website!)),
                          child: Row(
                            children: [
                              const Icon(Icons.language, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                restaurant.website!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      if (restaurant.phone != null)
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse('tel:${restaurant.phone}')),
                          child: Row(
                            children: [
                              const Icon(Icons.phone, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                restaurant.phone!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Accessibilité et livraison
                      Wrap(
                        spacing: 10,
                        children: [
                          if (restaurant.accessibl)
                            _buildBadge(context, 'Accessible', Colors.green),
                          if (restaurant.delivery)
                            _buildBadge(context, 'Livraison', Colors.blue),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Horaires
                      if (restaurant.schedule != null) ...[
                        Text(
                          'Horaires',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...Restaurant.days.map((day) {
                          final hours = restaurant.schedule![day];
                          final label = Restaurant.dayLabels[day] ?? day;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: Text('$label:')),
                                Expanded(
                                  child: Text(
                                    hours != null && hours.isNotEmpty
                                        ? hours.join(', ')
                                        : 'Fermé',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
