import 'package:flutter/material.dart';
import 'package:nutrihealth_app/features/auth/presentation/widgets/login_form.dart';
import 'package:nutrihealth_app/features/auth/presentation/widgets/register_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Bienvenidos a NutriPlan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Para usar la aplicacion, por favor inicia sesión o regístrate.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 24),
                const TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  indicatorWeight: 2,
                  tabs: [
                    Tab(text: "Iniciar Sesión"),
                    Tab(text: "Registrarse"),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 360,
                  child: TabBarView(
                    children: [const LoginForm(), const RegisterForm()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
