import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baratie/config/auth_service.dart';
import 'package:baratie/config/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(Provider.of<BaratieProvider>(context, listen: false).database);

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      bool success = await authService.loginUser(
                        _usernameController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      if (success) {
                        // Connexion réussie 
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _error = 'Nom d\'utilisateur ou mot de passe incorrect.';
                        });
                      }
                    },
                    child: const Text('Se connecter'),
                  ),
          ],
        ),
      ),
    );
  }
}
