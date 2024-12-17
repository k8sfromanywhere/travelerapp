import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordInputField({super.key, required this.controller});

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _isObscured = true;

  void togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите пароль';
        } else if (value.length < 5) {
          return 'Минимум 5 символов';
        }
        return null;
      },
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      controller: widget.controller,
      obscureText: _isObscured, // Используем значение _isObscured
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: togglePasswordVisibility, // Вызываем метод
          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
        ),
        labelText: 'Пароль',
        border: const OutlineInputBorder(),
      ),
    );
  }
}
