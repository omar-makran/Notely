import 'dart:async';

import 'package:mynote/services/auth/auth_provider.dart';
import 'package:mynote/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  late MockAuthProvider provider;

  setUp(() {
    provider = MockAuthProvider();
  });

  group('Mock Authentication', () {
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(
        () async => await provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to initialize', () async {
      await provider.initializer();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () async {
      await provider.initializer();
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in less than 3 seconds', () async {
      await provider.initializer();
      expect(provider.isInitialized, true);
    },
        timeout: const Timeout(Duration(seconds: 3))
    );

    test('Create user should delegate to logIn and handle exceptions', () async {
      await provider.initializer();
      expect(
          provider.createUser(
            email: 'omarmakran@gmail.com',
            password: 'anypassword',
          ),
          throwsA(const TypeMatcher<InvalidCredentialAuthException>()));

      final user = await provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () async {
      await provider.initializer();
      await provider.logIn(
        email: 'foo@bar.com',
        password: 'anypassword',
      );
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and then login again', () async {
      await provider.initializer();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      expect(provider.currentUser, isNotNull);

      await provider.logOut();
      expect(provider.currentUser, isNull);

      final user = await provider.logIn(
        email: 'email',
        password: 'password',
      );
      expect(user, isNotNull);
      expect(provider.currentUser, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class InvalidCredentialAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  AuthUser? _user;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initializer() async {
    await Future.delayed(const Duration(seconds: 2));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'omarmakran@gmail.com' && password == 'anypassword') {
      throw InvalidCredentialAuthException();
    }
    const user = AuthUser(isEmailVerified: false, email: 'omarmakran@gmail.com');
    _user = user;
    _authStateController.add(user);
    return user;
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUserValid = AuthUser(isEmailVerified: true, email: 'omarmakran@gmail.com');
    _user = newUserValid;
    _authStateController.add(newUserValid);
  }
}
