import 'package:mynote/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initializer();

  AuthUser? get currentUser;

  Future<void> reloadUser();

  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset({required String toEmail});
}
