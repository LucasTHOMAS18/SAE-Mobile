import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:baratie/config/provider.dart';
import 'package:baratie/models/restaurant.dart';

import '../../config/auth_provider.dart';
import '../../models/review.dart';

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
            return const Center(
                child: Text('Aucun restaurant trouvé avec cet ID.'));
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                          const Icon(Icons.schedule,
                              size: 20, color: Colors.black),
                          const SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .copyWith(fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: isOpen ? 'Ouvert' : 'Fermé',
                                    style: TextStyle(
                                      color: isOpen ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: isOpen
                                        ? ' – Ferme à $willClose'
                                        : ' – Ouvre à $willOpen',
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
                          onTap: () =>
                              launchUrl(Uri.parse(restaurant.website!)),
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
                          onTap: () =>
                              launchUrl(Uri.parse('tel:${restaurant.phone}')),
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

                      // Ajout d'avis
                      const SizedBox(height: 24),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          if (!auth.isLoggedIn) {
                            return const Text(
                                'Connectez-vous pour laisser un avis.');
                          }

                          final commentController = TextEditingController();
                          double noteValue = 3;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Laisser un avis',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Note : ${noteValue.toInt()}'),
                                  Slider(
                                    value: noteValue,
                                    min: 0,
                                    max: 5,
                                    divisions: 5,
                                    label: '${noteValue.toInt()}',
                                    onChanged: (val) =>
                                        setState(() => noteValue = val),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: commentController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Commentaire',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final success = await provider.addReview(
                                        Review(
                                          idUser: Provider.of<AuthProvider>(
                                                  context,
                                                  listen: false)
                                              .userId!,
                                          idRestau: idRestaurant,
                                          note: noteValue.toInt(),
                                          comment: commentController.text,
                                        ),
                                      );

                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Avis ajouté !')),
                                        );
                                        commentController.clear();
                                        setState(() => noteValue = 3);
                                      }
                                    },
                                    child: const Text('Envoyer mon avis'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),

                      // Affichage des Avis
                      const SizedBox(height: 24),
                      Text(
                        'Avis des clients',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      FutureBuilder<List<Review>>(
                        future: provider.getReviewsForRestaurant(idRestaurant),
                        builder: (context, reviewSnapshot) {
                          if (reviewSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            );
                          }

                          final reviews = reviewSnapshot.data ?? [];

                          if (reviews.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Aucun avis pour ce restaurant.'),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final review = reviews[index];

                              return FutureBuilder<String?>(
                                future: provider.getUsernameById(review.idUser),
                                builder: (context, userSnapshot) {
                                  final username =
                                      userSnapshot.data ?? 'Utilisateur';

                                  return ListTile(
                                    leading: const Icon(Icons.star,
                                        color: Colors.amber),
                                    title: Text(username),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Note : ${review.note}/5'),
                                        const SizedBox(height: 4),
                                        Text(review.comment),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
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
