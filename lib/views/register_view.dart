import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final Future<FirebaseApp> _initialization;
  bool _obscureText = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _initialization = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
        title: const Text('Register'),
      ),
      body: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
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
                          // Create a new user with the provided email and password.
                          final userCredential =
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: _email.text,
                            password: _password.text,
                          );
                          // Consider showing a success message to the user.
                          print('Successfully registered: ${userCredential.user?.uid}');
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            print('The account already exists for that email.');
                          } else if (e.code == 'invalid-email') {
                            print('The email address is badly formatted.');
                          } else {
                            print('Error registering: ${e.message}');
                            print(e.code);
                          }
                        }
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
