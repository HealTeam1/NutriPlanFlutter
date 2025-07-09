import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_screen.dart';
import 'plans_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late String userEmail;
  late String userName;
  late String dailyTip;
  final String baseUrl = 'http://192.168.100.26:3000';

  final List<String> tipList = [
    '🥦 Come al menos 5 porciones de frutas y verduras al día.',
    '💧 Bebe 8 vasos de agua diariamente para mantenerte hidratado.',
    '🕒 Haz pausas activas durante el día para moverte un poco.',
    '🌿 Elige alimentos frescos y evita los ultraprocesados.',
    '🥗 Incluye proteína en cada comida, como huevos, legumbres, pescado o tofu.',
    '🌾 Prefiere granos enteros, como arroz integral, avena o pan de centeno.',
    '🍽️ Come despacio y con atención, así ayudas a tu digestión y te sientes más satisfecho.',
    '🍋 Empieza el día con algo ligero y nutritivo, como fruta, yogur o un batido natural.',
    '🚫 Reduce el consumo de azúcares añadidos, revisando las etiquetas de los productos.',
    '🧂 Modera el uso de sal, y prueba sazonar con hierbas y especias naturales.',
    '🥜 Incluye grasas saludables, como las del aguacate, aceite de oliva o nueces.',
    '📏 Escucha a tu cuerpo: come cuando tengas hambre y para cuando estés satisfecho.',
    '☕ Modera el consumo de café y bebidas energéticas, y evita tomarlas en la noche.',
    '💤 Una buena alimentación también depende de un buen descanso nocturno.'  
  ];

  final List<Map<String, dynamic>> dailyGoals = [
    {
      'text': '🚶‍♂️ Caminar al menos 15 minutos al aire libre o dentro de casa',
      'completed': false,
    },
    {
      'text': '🍽 Preparar o elegir al menos una comida con verduras',
      'completed': false,
    },
    {
      'text': '💧 Beber al menos 5 vasos de agua',
      'completed': false,
    },
    {
      'text': '🍎 Comer una fruta como snack en vez de algo ultraprocesado',
      'completed': false,
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final email = ModalRoute.of(context)?.settings.arguments as String?;
    if (email == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    userEmail = email;
    userName = email.contains('@') ? email.split('@')[0] : email;
    dailyTip = tipList[Random().nextInt(tipList.length)];
  }

  void toggleGoalCompletion(int index) {
    setState(() {
      dailyGoals[index]['completed'] = !dailyGoals[index]['completed'];
    });
  }

  Future<List<Map<String, dynamic>>> _fetchResumenComidas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/meals?email=$userEmail'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      debugPrint('❌ Error al cargar resumen: $e');
    }
    return [];
  }

  Widget _buildResumenComidas() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchResumenComidas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Aún no has marcado comidas 🍽"),
          );
        }

        final comidas = snapshot.data!;
        return Card(
          color: const Color(0xFFF1F8E9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(top: 20),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Resumen de comidas consumidas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF388E3C)),
                ),
                const SizedBox(height: 12),
                ...comidas.map((item) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(item['meal'] ?? '')),
                        Text('x${item['cantidad'] ?? 0}'),
                      ],
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInicio() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            'Hola, $userName!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 12),
          Text(
            'Tu camino hacia una vida saludable empieza hoy 🌱',
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFE8F5E9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                children: [
                  const Text(
                    '📝 Tip diario',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF388E3C)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dailyTip,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 Objetivos del día',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(dailyGoals.length, (index) {
                    final goal = dailyGoals[index];
                    return CheckboxListTile(
                      title: Text(goal['text']),
                      value: goal['completed'],
                      activeColor: const Color(0xFF4CAF50),
                      onChanged: (_) => toggleGoalCompletion(index),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }),
                ],
              ),
            ),
          ),
          _buildResumenComidas(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> sections = [
      _buildInicio(),
      PlansScreen(email: userEmail),
      ProfileScreen(email: userEmail),
      ProgressScreen(email: userEmail),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        centerTitle: true,
        title: Image.asset('assets/logo11.png', height: 40),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            tooltip: 'Recetas',
            onPressed: () {
              Navigator.pushNamed(context, '/recipes');
            },
          ),          
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: SafeArea(child: sections[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Planes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progreso'),
        ],
      ),
    );
  }
}
