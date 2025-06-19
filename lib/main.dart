import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'main_menu.dart';
import 'screens/home_screen.dart';
import 'screens/nutrition_plans_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';

// Colores principales
const Color kPrimaryColor = Color(0xFF02C79D);
const Color kSecondaryColor = Color(0xFFB0EFC6);

void main() {
  runApp(NutriPlanApp()); 
}

class NutriPlanApp extends StatelessWidget {
  NutriPlanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        textTheme: ThemeData.light().textTheme.copyWith(
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),       
        '/register': (context) => RegisterPage(),
        '/main_menu': (context) => MainMenu(),
        '/home': (context) => HomeScreen(),
        '/nutrition_plans': (context) => NutritionPlansScreen(),
        '/profile': (context) => ProfileScreen(),
        '/progress': (context) => ProgressScreen(),
      },
    );
  }
}
