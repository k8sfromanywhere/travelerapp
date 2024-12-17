import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelerapp/features/authentication/bloc/bloc/auth_bloc.dart';
import 'package:travelerapp/features/authentication/presentation/widgets/email_input_field.dart';
import 'package:travelerapp/features/authentication/presentation/widgets/password_input_field.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
          if (state is AuthSuccess) {
            emailController.clear();
            passwordController.clear();
            nameController.clear();
            Navigator.pushNamed(
              context,
              '/profile',
              arguments: state.userId,
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
                TextField(
                  controller: nameController,
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 20),
                EmailInputField(controller: emailController),
                const SizedBox(height: 20),
                PasswordInputField(controller: passwordController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните все поля')),
                      );
                      return;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(emailController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Введите корректный email')),
                      );
                      return;
                    }
                    if (passwordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Пароль должен быть не менее 6 символов')),
                      );
                      return;
                    }

                    context.read<AuthBloc>().add(
                          RegisterEvent(
                            email: emailController.text,
                            password: passwordController.text,
                            name: nameController.text,
                          ),
                        );
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
