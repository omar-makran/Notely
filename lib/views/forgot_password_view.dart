import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';
import 'package:mynote/utilities/dialogs/error_dialog.dart';
import 'package:mynote/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:mynote/widgets/auth_hero_section.dart';
import 'package:mynote/widgets/styled_text_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _email;
  Timer? _cooldownTimer;
  int _secondsRemaining = 0;
  bool _canSend = true;

  @override
  void initState() {
    _email = TextEditingController();
    _email.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void _startCooldown() {
    setState(() {
      _canSend = false;
      _secondsRemaining = 30;
    });
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });
      if (_secondsRemaining <= 0) {
        timer.cancel();
        setState(() {
          _canSend = true;
        });
      }
    });
  }

  Widget _buildForgotSheet(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -30),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.60 + 30,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reset Password',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Enter your email to receive a reset link.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 40),
            StyledTextField(
              controller: _email,
              icon: Icons.email_outlined,
              hint: 'Email',
            ),
            SizedBox(height: 24),
            FilledButton(
              onPressed: (_canSend && _email.text.isNotEmpty)
                  ? () {
                      context.read<AuthBloc>().add(
                        AuthEventForgotPassword(email: _email.text),
                      );
                    }
                  : null,
              child: Text(
                _canSend ? 'Send Reset Link' : 'Resend in $_secondsRemaining s',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Remember your password? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _startCooldown();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          child: Column(
            children: [
              AuthHeroSection(
                tagline: 'Forgot your\npassword?',
                imagePath: 'assets/icon/girl_2.png',
                positionSize: 3,
                imageHeight: 0.35,
              ),
              _buildForgotSheet(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
