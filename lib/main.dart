import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:baratie/database.dart';
import 'package:baratie/viewmodels/restaurant_view_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _sectionANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionANav');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final database = await populateDatabase();

  runApp(ChangeNotifierProvider(
    create: (context) => RestaurantViewModel(database),
    child: MyApp(database),
  ));
}

class MyApp extends StatelessWidget {
  final Database? database;

  const MyApp(this.database, {super.key});

  @override
  Widget build(BuildContext context) {
    RestaurantViewModel restaurantViewModel = RestaurantViewModel(database!);
    return MultiProvider(
      providers: [],
      child: Consumer<RestaurantViewModel>(
        builder: (context, restaurantViewModel, child) {
          return MaterialApp.router(
            title: 'Le Baratie',
          );
        },
      ),
    );
  }
}
