import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynote/utilities/show_error_dialog.dart';
import 'package:mynote/utilities/show_generic_dialog.dart';

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
              await FirebaseAuth.instance.signOut();
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
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();
                  if (!mounted) return;
                  await showGenericDialog(
                    context: context,
                    title: 'Verification Email Sent',
                    content: 'A verification link has been sent to your email.',
                    buttonText: 'OK',
                  );
                } on FirebaseException catch (e) {
                  if (!mounted) return;
                  await showErrorDialog(context, 'Error: ${e.message}');
                } catch (e) {
                  if (!mounted) return;
                  await showErrorDialog(
                    context,
                    'An unexpected error occurred. Please try again.',
                  );
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
