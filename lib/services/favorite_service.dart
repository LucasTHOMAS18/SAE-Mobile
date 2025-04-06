import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _favoritesKey = 'user_favorites';

  static Future<void> addFavorite(int userId, int restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites(userId);
    favorites.add(restaurantId);
    await prefs.setStringList(
      '${_favoritesKey}_$userId', 
      favorites.map((id) => id.toString()).toList()
    );
  }

  static Future<void> removeFavorite(int userId, int restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites(userId);
    favorites.remove(restaurantId);
    await prefs.setStringList(
      '${_favoritesKey}_$userId', 
      favorites.map((id) => id.toString()).toList()
    );
  }

  static Future<Set<int>> getFavorites(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('user_favorites_$userId') ?? [];
    return favorites.map((id) => int.parse(id)).toSet();
  }

  static Future<bool> isFavorite(int userId, int restaurantId) async {
    final favorites = await getFavorites(userId);
    return favorites.contains(restaurantId);
  }
}