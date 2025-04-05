import 'package:baratie/views/details/details_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:baratie/config/database.dart';
import 'package:baratie/config/provider.dart';
import 'package:baratie/views/home/home_view.dart';
import 'package:baratie/views/search/search_results_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final database = await populateDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BaratieProvider(database),
        ),
      ],
      child: BaratieApp(database),
    ),
  );
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
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/search-results',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            if (extra == null) {
              return const SearchResultsView(query: '');
            }
            
            final query = extra['query'] as String? ?? '';
            final city = extra['city'] as String?;
            final type = extra['type'] as String?;
            
            return SearchResultsView(query: query, city: city, type: type);
          },
        ),

        GoRoute(
          path: '/restaurant/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const Scaffold(body: Center(child: Text('ID invalide')));
            }
            return DetailsView(idRestaurant: id);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Le Baratie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6CC5D9)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}