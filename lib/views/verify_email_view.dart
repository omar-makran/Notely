import 'package:flutter/material.dart';
import 'package:mynote/services/auth/auth_exceptions.dart';
import 'package:mynote/utilities/dialogs/error_dialog.dart';
import 'package:mynote/utilities/dialogs/genereic_dialog.dart';

import '../services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.firebase().logOut();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('A verification email has been sent to your email.'),
            const Text('Please check your email inbox and verify your email.'),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService.firebase().sendEmailVerification();
                  if (!mounted) return;
                  await showGenirecDialog(
                    context: context,
                    title: 'Verification Email Sent',
                    content: 'A verification link has been sent to your email.',
                    optionsBuilder: () => {'OK': null},
                  );
                } on GenericAuthException {
                  if (!mounted) return;
                  await showErrorDialog(context, 'An unexpected error occurred. Please try again.');
                }
              },
              child: const Text('Send verification email'),
            )
          ],
        ),
      ),
    );
  }
}
