import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelerapp/features/authentication/bloc/bloc/auth_bloc.dart';
import 'package:travelerapp/features/authentication/presentation/widgets/auth_button.dart';
import 'package:travelerapp/features/authentication/presentation/widgets/email_input_field.dart';
import 'package:travelerapp/features/authentication/presentation/widgets/password_input_field.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
          if (state is AuthSuccess) {
            Navigator.pushNamed(
              context,
              '/profile',
              arguments: state.userId, // Передаем userId в профиль
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                EmailInputField(controller: emailController),
                const SizedBox(height: 10),
                PasswordInputField(controller: passwordController),
                const SizedBox(height: 20),
                AuthButton(
                  label: 'Войти',
                  onPressed: () {
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Введите email и пароль')),
                      );
                      return;
                    }
                    context.read<AuthBloc>().add(
                          LoginEvent(
                            email: emailController.text,
                            password: passwordController.text,
                          ),
                        );
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Зарегистрироваться'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
