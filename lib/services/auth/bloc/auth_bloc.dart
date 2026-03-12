import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynote/services/auth/auth_provider.dart';
import 'package:mynote/services/auth/bloc/auth_event.dart';
import 'package:mynote/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider provider;
  AuthBloc(this.provider) : super(const AuthStateUninitialized()) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initializer();
      final currentUser = provider.currentUser;
      if (currentUser == null) {
        emit(const AuthStateLoggedOut());
      } else if (!currentUser.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user: currentUser));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(AuthStateLoggedOut(isLoading: true));
      try {
        await provider.logIn(email: event.email, password: event.password);
        final currentUser = provider.currentUser;
        if (currentUser == null) {
          emit(AuthStateLoggedOut());
        } else if (currentUser.isEmailVerified) {
          emit(AuthStateLoggedOut(isLoading: false));
          emit(AuthStateLoggedIn(user: currentUser));
        } else {
          emit(AuthStateNeedsVerification());
        }
      } catch (e) {
        emit(AuthStateLoggedOut(isLoading: false, exception: e as Exception));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(AuthStateLoggedOut());
      } catch (e) {
        emit(AuthStateLoggedOut(exception: e as Exception));
      }
    });

    on<AuthEventRegister>((event, emit) async {
      try {
        await provider.createUser(email: event.email, password: event.password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification());
      } catch (e) {
        emit(AuthStateRegistering(exception: e as Exception));
      }
    });

    on<AuthEventSendEmailVerification>((event, emit) async {
      try {
        await provider.sendEmailVerification();
        emit(state);
      } catch (e) {
        emit(AuthStateLoggedOut(exception: e as Exception));
      }
    });

    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering());
    });
  }
}
