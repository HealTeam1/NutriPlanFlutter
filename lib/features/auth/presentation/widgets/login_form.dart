import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: !_isVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isVisible = !_isVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              activeColor: Colors.green,
              value: true,
              onChanged: (val) {},
            ),
            const Text('Remember me'),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.green,
          ),
          onPressed: () {},
          child: Text("Iniciar sesión", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: () {}, child: const Text('Olvidé mi contraseña')),
      ],
    );
  }
}
