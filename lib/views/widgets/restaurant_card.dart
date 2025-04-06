import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:baratie/config/auth_provider.dart';
import 'package:baratie/models/restaurant.dart';
import 'package:baratie/services/favorite_service.dart';
import 'package:baratie/views/details/details_view.dart';

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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(
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
                  padding: const EdgeInsets.all(6.0), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.nameR,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2), 
                      Text(
                        widget.restaurant.city ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12, 
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 2, 
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