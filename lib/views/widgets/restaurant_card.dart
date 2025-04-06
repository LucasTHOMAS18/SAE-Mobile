import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:baratie/config/auth_provider.dart';
import 'package:baratie/models/restaurant.dart';
import 'package:baratie/services/favorite_service.dart';
import 'package:baratie/views/details/details_view.dart';

import '../../config/provider.dart';

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantCard({
    super.key,
    required this.restaurant
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      setState(() => _isLoadingFavorite = true);
      _isFavorite = await FavoriteService.isFavorite(
        authProvider.userId!,
        widget.restaurant.id,
      );
      setState(() => _isLoadingFavorite = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) return;

    setState(() => _isLoadingFavorite = true);
    
    if (_isFavorite) {
      await FavoriteService.removeFavorite(
        authProvider.userId!,
        widget.restaurant.id,
      );
    } else {
      await FavoriteService.addFavorite(
        authProvider.userId!,
        widget.restaurant.id,
      );
    }

    setState(() {
      _isFavorite = !_isFavorite;
      _isLoadingFavorite = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsView(idRestaurant: widget.restaurant.id),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16), // arrondi partout
                  child: Image.asset(
                    'assets/images/baratie.jpg',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isLoggedIn)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _isLoadingFavorite
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 2,
                    )
                        : IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    widget.restaurant.nameR,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Adresse
                  Text(
                    widget.restaurant.getAddress(),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Note + avis
                  FutureBuilder<double>(
                    future: Provider.of<BaratieProvider>(context, listen: false)
                        .getAverageRatingForRestaurant(widget.restaurant.id),
                    builder: (context, snapshot) {
                      final avg = (snapshot.data ?? 0).toStringAsFixed(1);
                      return Text(
                        '★ $avg',
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),

                  const SizedBox(height: 4),

                  // Ouvert / fermé
                  Builder(builder: (context) {
                    final isOpen = widget.restaurant.isCurrentlyOpen();
                    final statusText = isOpen
                        ? 'Ouvert • Ferme à ${widget.restaurant.whenWillClose()}'
                        : 'Fermé • Ouvre à ${widget.restaurant.whenWillOpen()}';

                    return Text(
                      statusText,
                      style: TextStyle(
                        color: isOpen ? Colors.green : Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Badges
                  Wrap(
                    spacing: 6,
                    children: [
                      if (widget.restaurant.accessibl)
                        _buildBadge('Accessible', Colors.green),
                      if (widget.restaurant.delivery)
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), 
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10, 
        ),
      ),
    );
  }
}