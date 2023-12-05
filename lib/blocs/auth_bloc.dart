import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating }

class AuthBloc extends Cubit<AuthStatus> {
  AuthBloc() : super(AuthStatus.unauthenticated);

  void setUser(User? user) {
    if (user != null) {
      emit(AuthStatus.authenticated);
    } else {
      emit(AuthStatus.unauthenticated);
    }
  }

  void setAuthStatus(AuthStatus status) => emit(status);
}
