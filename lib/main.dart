import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:baratie/database.dart';
import 'package:baratie/viewmodels/restaurant_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final database = await populateDatabase();

  runApp(ChangeNotifierProvider(
    create: (context) => RestaurantViewModel(database),
    child: BaratieApp(database),
  ));
}

class BaratieApp extends StatelessWidget {
  final Database? database;

  const BaratieApp(this.database, {super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Le Baratie',
      routerConfig: router,
    );
  }
}
