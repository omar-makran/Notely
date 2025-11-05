import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/services/auth/auth_service.dart';
import 'package:mynote/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _obscureText = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    _password.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _email,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _password,
              autocorrect: false,
              obscureText: _obscureText,
              enableSuggestions: false,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Password',
                suffixIcon: _password.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService.firebase().logIn(
                    email: _email.text,
                    password: _password.text,
                  );
                  if (!mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } on InvalidCredentialAuthException {
                  if (!mounted) return;
                    await showErrorDialog(
                        context,
                        'User not found or wrong password.',
                    );
                } on GenericAuthException {
                  if (!mounted) return;
                  await showErrorDialog(
                    context,
                    'An unexpected error occurred. Please try again.',
                  );
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/register/');
              },
              child: const Text('Not registered yet? Register here!'),
            )
          ],
        ),
      ),
    );
  }
}
