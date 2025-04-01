import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import 'package:baratie/models/restaurant.dart';
import 'package:baratie/models/restaurant_list.dart';

class RestaurantViewModel extends ChangeNotifier {
  late ListRestaurants listeRestaux;

  RestaurantViewModel(Database db) {
    listeRestaux = ListRestaurants();
    init(db);
  }

  void generateRestaurant() {
    listeRestaux.generateRestaurant(50);
    notifyListeners();
  }

  Future<void> init(Database db) async {
    await listeRestaux.fromDatabase(db);
    notifyListeners();
  }

  Restaurant? getRestaurantByName(String restaurantName) {
    return listeRestaux.getRestaurantByName(restaurantName);
  }

  List<Restaurant> getRestaurants() {
    return listeRestaux.currentRestaurants;
  }

  void setRestaurantFiltre(
      String? nomRestau, String? categorie, List<String>? options) {
    listeRestaux.setRestaurantFiltre(nomRestau, categorie, options);
    notifyListeners();
  }
}
