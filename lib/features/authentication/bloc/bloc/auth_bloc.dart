import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Добавлен импорт Firestore
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc(
      {required FirebaseAuth firebaseAuth,
      required FirebaseFirestore firestore})
      : _firebaseAuth = firebaseAuth,
        super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RegisterEvent>(_onRegister);
  }

  // Логика обработки события LoginEvent
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(userId: userCredential.user?.uid ?? ""));
    } on FirebaseAuthException catch (error) {
      emit(AuthFailure(
          errorMessage: error.message ?? "An error occurred during login."));
    } catch (error) {
      emit(AuthFailure(errorMessage: error.toString()));
    }
  }

  // Логика обработки события LogoutEvent
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(AuthInitial());
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Сохраняем пользователя в Firestore
      final userId = userCredential.user?.uid ?? '';
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('users').doc(userId).set({
        'name': event.name,
        'email': event.email,
      });

      emit(AuthSuccess(userId: userId));
    } on FirebaseAuthException catch (error) {
      emit(AuthFailure(
        errorMessage: error.message ?? "An error occurred during registration.",
      ));
    } catch (error) {
      emit(AuthFailure(errorMessage: error.toString()));
    }
  }
}
