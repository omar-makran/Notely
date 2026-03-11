import 'package:equatable/equatable.dart';
import 'package:mynote/services/auth/auth_user.dart';

abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateLoggedOut({this.exception, this.isLoading = false});

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser? user;

  const AuthStateLoggedIn({required this.user});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({this.exception});
}
