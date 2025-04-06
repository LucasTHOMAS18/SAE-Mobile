import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  int? _userId;

  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;

  void login(int idUser) {
    _isLoggedIn = true;
    _userId = idUser;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userId = null;
    notifyListeners();
  }
}
