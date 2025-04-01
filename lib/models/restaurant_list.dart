import 'package:sqflite/sqflite.dart';
import 'package:baratie/models/restaurant.dart';

class ListRestaurants {
  List<Restaurant> _currentRestaurants;
  List<Restaurant> _lesRestaurants;

  ListRestaurants()
      : _lesRestaurants = [],
        _currentRestaurants = [];

  List<Restaurant> get lesRestaurants => _lesRestaurants;
  List<Restaurant> get currentRestaurants => _currentRestaurants;

  Future<List<Restaurant>> fromDatabase(Database db) async {
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT * FROM RESTAURANT;');

    List<Restaurant> restaurants =
        result.map((row) => Restaurant.fromMap(row)).toList();
    _lesRestaurants = restaurants;
    _currentRestaurants = restaurants;
    return restaurants;
  }

  List<Restaurant> generateRestaurant(int i) {
    List<Restaurant> restaurants = List.generate(
        i,
        (n) => Restaurant(
              nameR: "Restaurant Exemple",
              city: "Ville Exemple",
              schedule: "09:00 - 22:00",
              website: "https://www.restaurantexemple.com",
              phone: "0102030405",
              typeR: "Restaurant",
              latitude: 48.8566,
              longitude: 2.3522,
              accessibl: true,
              delivery: true,
            ));
    _lesRestaurants = restaurants;
    _currentRestaurants = restaurants;
    return restaurants;
  }

  Restaurant? getRestaurantByName(String name) {
    return lesRestaurants.firstWhere((restaurant) => restaurant.nameR == name);
  }

  void setRestaurantFiltre(
      String? nomRestau, String? categorie, List<String>? options) {
    _currentRestaurants = _lesRestaurants.where((restau) {
      return (nomRestau == null ||
              restau.nameR?.toLowerCase().contains(nomRestau.toLowerCase()) ==
                  true) &&
          (categorie == null ||
              restau.typeR?.toLowerCase() == categorie.toLowerCase()) &&
          (options == null || optionPresent(restau, options));
    }).toList();
  }

  bool optionPresent(Restaurant restau, List<String> options) {
    if (options.contains("accessibl") && !restau.accessibl) return false;
    if (options.contains("delivery") && !restau.delivery) return false;
    return true;
  }
}
