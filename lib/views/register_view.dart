import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_bloc.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';
import 'package:mynote/utilities/dialogs/error_dialog.dart';
import 'package:mynote/utilities/password_strength.dart';
import 'package:mynote/widgets/auth_hero_section.dart';
import 'package:mynote/widgets/password_strength_bar.dart';
import 'package:mynote/widgets/styled_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  bool _obscureText = true;
  bool _obscureTextConfirm = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();

    _password.addListener(() {
      setState(() {});
    });
    _confirmPassword.addListener(() {
      setState(() {});
    });
    _email.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Widget _buildRegisterSheet(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
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
        padding: EdgeInsets.fromLTRB(
          24,
          32,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign Up',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            StyledTextField(
              controller: _email,
              icon: Icons.email_outlined,
              hint: 'Email',
            ),
            const SizedBox(height: 16.0),
            StyledTextField(
              controller: _password,
              icon: Icons.lock_outlined,
              hint: 'Password',
              obscureText: _obscureText,
              suffixIcon: _password.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    )
                  : null,
            ),
            if (_password.text.isNotEmpty)
              PasswordStrengthBar(strength: calculateStrength(_password.text)),
            const SizedBox(height: 16.0),
            StyledTextField(
              controller: _confirmPassword,
              icon: Icons.lock_clock_outlined,
              hint: 'Confirm Password',
              obscureText: _obscureTextConfirm,
              suffixIcon: _confirmPassword.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureTextConfirm = !_obscureTextConfirm;
                        });
                      },
                      icon: Icon(
                        _obscureTextConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    )
                  : null,
            ),
            if (_confirmPassword.text.isNotEmpty &&
                _confirmPassword.text != _password.text)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Password don't match",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24.0),
            FilledButton(
              onPressed:
                  (_email.text.isNotEmpty &&
                      _password.text == _confirmPassword.text &&
                      calculateStrength(_password.text) !=
                          PasswordStrength.weak)
                  ? () {
                      context.read<AuthBloc>().add(
                        AuthEventRegister(
                          email: _email.text,
                          password: _password.text,
                        ),
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
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
        if (state is AuthStateRegistering && state.exception != null) {
          showErrorDialog(
            context,
            'We could not register you. Please make sure you have entered the correct credentials and try again.',
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          child: Column(
            children: [
              AuthHeroSection(
                title: 'Notely',
                tagline: 'Start capturing\nyour ideas.',
                imagePath: 'assets/icon/boy.png',
                size: -33,
              ),
              _buildRegisterSheet(context),
            ],
          ),
        ),
      ),
    );
  }
}
