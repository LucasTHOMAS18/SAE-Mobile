import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:baratie/config/provider.dart';
import 'package:baratie/models/restaurant.dart';
import 'package:baratie/views/widgets/restaurant_listing.dart';
import 'package:baratie/views/widgets/search_bar.dart';
import 'package:baratie/views/profile/user_profile_view.dart';
import 'package:baratie/config/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _restaurantTypes = ['Tous types'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantTypes();
  }

  Future<void> _loadRestaurantTypes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<BaratieProvider>(context, listen: false);
      final types = await provider.getRestaurantTypes();

      setState(() {
        _restaurantTypes = ['Tous types', ...types];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Row(
                children: [
                  if (auth.isLoggedIn && auth.userId != null)
                    IconButton(
                      tooltip: 'Mon profil',
                      icon: const Icon(Icons.account_circle, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserProfileView(userId: auth.userId!),
                          ),
                        );
                      },
                    ),
                  const SizedBox(width: 8),
                  auth.isLoggedIn
                      ? ElevatedButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text('Déconnexion',
                              style: TextStyle(fontSize: 16)),
                        )
                      : Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => context.push('/login'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.black, width: 3),
                                shape: const StadiumBorder(),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Connexion',
                                  style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => context.push('/register'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                elevation: 0,
                              ),
                              child: const Text('Inscription',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: _buildHeader(context),
          ),
          Expanded(
            child: _buildRestaurantsSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: const Color(0xFF6CC5D9),
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
              child: SingleChildScrollView(
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
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RestaurantSearchBar(
                            restaurantTypes: _restaurantTypes,
                            onSearch: (searchTerm, location, type) {},
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsSection(BuildContext context) {
    final future = Provider.of<BaratieProvider>(context).getTopRatedRestaurants();

    return FutureBuilder<List<Restaurant>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final restaurants = snapshot.data ?? [];

        return Column(
          children: [
            Expanded(
              child: RestaurantListing(
                restaurants: restaurants,
                emptyMessage: 'Aucun restaurant à la une',
              ),
            ),
          ],
        );
      },
    );
  }
}
