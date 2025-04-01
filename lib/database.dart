import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Database> initDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'baratie.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      String sqlScript = await rootBundle.loadString('./data/bd.sql');
      List<String> queries = sqlScript.split(';');

      for (String query in queries) {
        if (query.trim().isNotEmpty) {
          await db.execute(query.trim() + ';');
        }
      }
    },
  );
}

Future<Database> populateDatabase() async {
  final Database db = await initDatabase();

  String jsonString = await rootBundle.loadString('./data/restaurants.json');
  List<dynamic> jsonData = jsonDecode(jsonString);

  for (var item in jsonData) {
    await insertRestaurant(db, item);
  }
  return db;
}

Future<void> insertRestaurant(
    Database db, Map<String, dynamic> restaurant) async {
  await db.insert(
    'RESTAURANT',
    {
      'nameR': restaurant['name'],
      'city': restaurant['commune'],
      'schedule': restaurant['opening_hours'],
      'website': restaurant['website'],
      'phone': restaurant['phone'],
      'typeR': restaurant['type'],
      'latitude': restaurant['geo_point_2d']?['lat']?.toString(),
      'longitude': restaurant['geo_point_2d']?['lon']?.toString(),
      'accessibl': restaurant['wheelchair'] == 'yes' ? 1 : 0,
      'delivery': restaurant['delivery'] == 'yes' ? 1 : 0,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
