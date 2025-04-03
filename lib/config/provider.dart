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

  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final restaurants = await _database?.query(
        'RESTAURANT',
        where: 'nameR LIKE ? OR typeR LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      return restaurants?.map((map) => Restaurant.fromMap(map)).toList() ?? [];
    } catch (e) {
      return [];
    }
  }
}
