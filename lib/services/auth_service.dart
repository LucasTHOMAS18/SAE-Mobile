import 'package:sqflite/sqflite.dart';

class AuthService {
  final Database database;
  AuthService(this.database);


  Future<int?> registerUser(String username, String password) async {
    final result = await database.query(
      'USER',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return null;
    }

    final id = await database.insert(
      'USER',
      {
        'username': username,
        'password': password,
      },
    );

    return id > 0 ? id : null;
  }



  Future<int?> loginUser(String username, String password) async {
    final result = await database.query(
      'USER',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return result.first['idUser'] as int;
    }
    return null;
  }

}
