import 'package:mynote/services/auth/auth_user.dart';

abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception ;
  const AuthStateLoggedOut({this.exception});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser? user;

  const AuthStateLoggedIn({required this.user});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}
