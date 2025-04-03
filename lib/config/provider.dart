import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:baratie/models/restaurant.dart';

class BaratieProvider with ChangeNotifier {
  final Database? _database;

  BaratieProvider(this._database);

  Future<int?> insertData({
    required String tableName,
    required Map<String, dynamic> data,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    try {
      data.removeWhere((key, value) => value == null);

      final id = await _database!.insert(
        tableName,
        data,
        conflictAlgorithm: conflictAlgorithm,
      );

      notifyListeners();
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final restaurants = await _database?.query('RESTAURANT');
      return restaurants?.map((map) => Restaurant.fromMap(map)).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Restaurant>> getTopRatedRestaurants() async {
    try {
      final restaurants = await _database?.rawQuery('''
        SELECT RESTAURANT.*, AVG(REVIEWED.note) as average_rating
        FROM RESTAURANT
        LEFT JOIN REVIEWED ON RESTAURANT.idRestau = REVIEWED.idRestau
        GROUP BY RESTAURANT.idRestau
        ORDER BY average_rating DESC
      ''');

      return restaurants?.map((map) => Restaurant.fromMap(map)).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Restaurant>> searchRestaurants(
    String query, {
    String? city,
    String? type,
  }) async {
    try {
      // Build the query dynamically based on provided filters
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (query.isNotEmpty) {
        whereClause += 'nameR LIKE ?';
        whereArgs.add('%$query%');
      }
      
      if (city != null && city.isNotEmpty) {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause += 'city LIKE ?';
        whereArgs.add('%$city%');
      }
      
      if (type != null && type.isNotEmpty) {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause += 'typeR = ?';
        whereArgs.add(type);
      }
      
      // If no filters provided, return all restaurants
      if (whereClause.isEmpty) {
        return getAllRestaurants();
      }
      
      final restaurants = await _database?.query(
        'RESTAURANT',
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      return restaurants?.map((map) => Restaurant.fromMap(map)).toList() ?? [];
    } catch (e) {
      print('Error searching restaurants: $e');
      return [];
    }
  }

  Future<List<String>> getRestaurantTypes() async {
    try {
      final result = await _database?.rawQuery('''
        SELECT DISTINCT typeR FROM RESTAURANT WHERE typeR IS NOT NULL
      ''');
      
      return result
          ?.map((map) => map['typeR'] as String)
          .where((type) => type.isNotEmpty)
          .toList() ?? [];
    } catch (e) {
      print('Error fetching restaurant types: $e');
      return [];
    }
  }
}