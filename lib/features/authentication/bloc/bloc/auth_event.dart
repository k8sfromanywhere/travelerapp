part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Событие для входа в систему
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// Событие для выхода из системы
class LogoutEvent extends AuthEvent {}

// Событие для регистрации нового пользователя
class RegisterEvent extends AuthEvent {
  final String name; // Добавлено поле для имени пользователя
  final String email;
  final String password;

  RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}
