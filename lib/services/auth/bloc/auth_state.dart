import 'package:equatable/equatable.dart';
import 'package:mynote/services/auth/auth_user.dart';

abstract class AuthState {
  final bool isLoading;
  final String? loadingText;

  const AuthState({this.isLoading = false, this.loadingText});
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({super.isLoading, super.loadingText});
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    this.exception,
    super.isLoading,
    super.loadingText,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser? user;

  const AuthStateLoggedIn({
    required this.user,
    super.isLoading = false,
    super.loadingText,
  });
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({
    super.isLoading = false,
    super.loadingText,
  });
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    this.exception,
    super.isLoading = false,
    super.loadingText,
  });
}
