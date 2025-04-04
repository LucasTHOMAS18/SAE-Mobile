import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baratie/config/auth_service.dart';
import 'package:baratie/config/provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(Provider.of<BaratieProvider>(context, listen: false).database);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
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
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
                        setState(() {
                          _error = 'Les mots de passe ne correspondent pas.';
                        });
                        return;
                      }
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      bool success = await authService.registerUser(
                        _usernameController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      if (success) {
                        // Inscription réussie : retour à la page de connexion
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _error = 'Utilisateur déjà existant.';
                        });
                      }
                    },
                    child: const Text('S\'inscrire'),
                  ),
          ],
        ),
      ),
    );
  }
}
