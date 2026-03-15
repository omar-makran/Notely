import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';
import 'package:mynote/utilities/dialogs/error_dialog.dart';
import 'package:mynote/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            showPasswordResetEmailSentDialog(
              context,
              'Check your inbox mailbox for a password reset link.',
            );
          } else if (state.exception != null) {
            showErrorDialog(
              context,
              'No account found. Check your email address and try again.',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgot Password')),
        body: Column(
          children: [
            Text('Enter your email to receive a password reset link.'),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(hintText: 'Email address'),
            ),
            TextButton(
              onPressed: () {
                final email = _email.text;
                context.read<AuthBloc>().add(
                  AuthEventForgotPassword(email: email),
                );
              },
              child: Text('Send password reset email'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}
