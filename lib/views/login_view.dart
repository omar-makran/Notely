import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    // Rebuild the widget when the password text changes to update the icon visibility.
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                // Show the icon only if the password field is not empty.
                suffixIcon: _password.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          // Change the icon based on the obscureText state.
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          // Toggle the password's visibility on press.
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : null, // Otherwise, show no icon.
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () async {
                try {
                  // Sign in the user.
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _email.text,
                    password: _password.text,
                  );
                } on FirebaseAuthException {
                  print(
                      'Invalid email or password. Please check your credentials and try again.');
                } catch (e) {
                  // Handle other potential errors.
                  print('An unexpected error occurred: $e');
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
