import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlansScreen extends StatefulWidget {
  final String email;
  const PlansScreen({super.key, required this.email});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late String userEmail;
  final String baseUrl = 'http://192.168.100.26:3000';

  @override
  void initState() {
    super.initState();
    userEmail = widget.email;
  }

  void _openPlanDetailDialog(Map<String, dynamic> plan) async {
    final planTitle = plan['title'];
    final meals = List<String>.from(plan['meals']);
    Map<String, int> quantityMap = { for (var m in meals) m: 0 };

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/meals?email=$userEmail&plan=$planTitle'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var item in data) {
          quantityMap[item['meal']] = item['cantidad'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint('❌ Error al obtener meals existentes: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Selecciona cantidades - ${plan['title']}'),
              content: SingleChildScrollView(
                child: Column(
                  children: meals.map((meal) {
                    return Row(
                      children: [
                        Expanded(child: Text(meal)),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setModalState(() {
                              if (quantityMap[meal]! > 0) quantityMap[meal] = quantityMap[meal]! - 1;
                            });
                          },
                        ),
                        Text(quantityMap[meal].toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setModalState(() {
                              quantityMap[meal] = quantityMap[meal]! + 1;
                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final selected = quantityMap.entries
                        .where((e) => e.value > 0)
                        .map((e) => {
                              'meal': e.key,
                              'cantidad': e.value,
                              'consumed': true,
                            })
                        .toList();

                    if (selected.isEmpty) return;

                    final payload = {
                      'email': userEmail,
                      'plan': planTitle,
                      'meals': selected,
                    };

                    try {
                      final response = await http.put(
                        Uri.parse('$baseUrl/api/meals'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(payload),
                      );

                      if (!context.mounted) return;

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comidas guardadas correctamente.')),
                        );
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al guardar: ${response.statusCode}')),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error de red al guardar.')),
                      );
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final List<Map<String, dynamic>> plans = [
    {
      'title': 'Plan Básico',
      'description': 'Desayuno, almuerzo y cena con enfoque saludable.',
      'icon': Icons.local_dining,
      'color': Colors.green[100],
      'meals': [
        '🥛 1 vaso de leche', '🥣 1 taza de avena', '🍌 1 banana',
        '🍗 Pechuga de pollo', '🍚 Arroz integral', '🥗 Ensalada',
        '🥕 Sopa de verduras', '🍞 Pan integral', '🍎 1 manzana',
        '🍳 Huevo duro'
      ],
    },
    {
      'title': 'Plan Vegetariano',
      'description': 'Rico en proteínas vegetales y sin carne.',
      'icon': Icons.eco,
      'color': Colors.orange[100],
      'meals': [
        '🍌 Smoothie de plátano', '🥜 Mantequilla de maní',
        '🍲 Quinoa con garbanzos', '🍅 Tomate y pepino',
        '🍱 Tofu con vegetales', '🍚 Arroz blanco', '🥦 Brócoli al vapor',
        '🥗 Ensalada de lentejas', '🍠 Puré de camote',  '🍎 Fruta mixta'
      ],
    },
    {
      'title': 'Plan Keto',
      'description': 'Alto en grasas saludables y bajo en carbohidratos.',
      'icon': Icons.local_fire_department,
      'color': Colors.blue[100],
      'meals': [
        '🥑 Aguacate con limón', '🍳 Omelette con espinacas', '🧀 Queso curado',
        '🥓 Tiras de tocino', '🐟 Salmón a la plancha','🥬 Ensalada con aceite de oliva',
        '🥜 Nueces mixtas', '🍗 Alitas de pollo al horno','🍄 Champiñones salteados',
        '☕ Café con crema'
      ],
    },
    {
      'title': 'Plan Energético',
      'description': 'Ideal para deportistas, alto en carbohidratos y proteínas.',
      'icon': Icons.flash_on,
      'color': Colors.red[100],
      'meals': [
        '🥣 Avena con frutos secos', '🍌 Banana', '🥩 Carne magra', '🍚 Arroz integral',
        '🥗 Ensalada con quinua', '🍠 Camote al horno', '🥤 Batido de proteínas',
        '🥜 Mix de semillas', '🥚 Huevos cocidos', '🍞 Pan de centeno'
      ],
    },
    {
      'title': 'Plan Ligero',
      'description': 'Ideal para perder peso, bajo en calorías.',
      'icon': Icons.air,
      'color': Colors.purple[100],
      'meals': [
        '🍵 Té verde', '🍊 Mandarina', '🥗 Ensalada verde', '🍅 Sopa de tomate',
        '🐟 Pescado al vapor', '🥒 Bastones de pepino', '🍎 Manzana verde',
        '🥬 Wrap de lechuga con hummus', '🥕 Zanahorias baby', '🍓 Frutos rojos'
      ],
    },
    {
      'title': 'Plan Mediterráneo',
      'description': 'Basado en la dieta mediterránea, rica en vegetales, pescado y aceite de oliva.',
      'icon': Icons.spa,
      'color': Colors.teal[100],
      'meals': [
        '🥗 Ensalada griega', '🐟 Sardinas en aceite de oliva', '🍅 Tomates cherry con queso feta',
        '🥖 Pan integral con hummus', '🥒 Tabulé de pepino y perejil', '🫒 Aceitunas negras',
        '🍊 Naranja fresca', '🥣 Yogur natural con miel', '🌰 Almendras crudas', '🍆 Berenjenas al horno'
      ],
    },
    {
      'title': 'Plan Alto en Fibra',
      'description': 'Favorece la digestión y regula el apetito con alimentos ricos en fibra.',
      'icon': Icons.grass,
      'color': Colors.brown[100],
      'meals': [
        '🥣 Avena con linaza', '🍐 Pera con cáscara', '🥬 Ensalada de espinaca y remolacha',
        '🍞 Pan integral con aguacate', '🍛 Lentejas guisadas', '🥕 Zanahoria cruda',
        '🍎 Manzana roja', '🌽 Mazorca cocida', '🍓 Mix de frutos del bosque', '🌰 Nueces y semillas'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          color: plan['color'],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            leading: Icon(plan['icon'], size: 36, color: Colors.green[700]),
            title: Text(plan['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(plan['description']),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openPlanDetailDialog(plan),
          ),
        );
      },
    );
  }
}

