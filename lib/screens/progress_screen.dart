import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProgressScreen extends StatefulWidget {
  final String email;

  const ProgressScreen({super.key, required this.email});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final String baseUrl = 'http://192.168.100.26:3000';

  final Map<String, int> caloriasPorAlimento = {
      // Plan Básico
      '🥛 1 vaso de leche': 150,
      '🥣 1 taza de avena': 250,
      '🍌 1 banana': 100,
      '🍗 Pechuga de pollo': 200,
      '🍚 Arroz integral': 180,
      '🥗 Ensalada': 50,
      '🥕 Sopa de verduras': 80,
      '🍞 Pan integral': 100,
      '🍎 1 manzana': 95,
      '🍳 Huevo duro': 70,

      // Plan Vegetariano
      '🍌 Smoothie de plátano': 120,
      '🥜 Mantequilla de maní': 180,
      '🍲 Quinoa con garbanzos': 220,
      '🍅 Tomate y pepino': 60,
      '🍱 Tofu con vegetales': 190,
      '🍚 Arroz blanco': 160,
      '🥦 Brócoli al vapor': 55,
      '🥗 Ensalada de lentejas': 170,
      '🍠 Puré de camote': 140,
      '🍎 Fruta mixta': 100,

      // Plan Keto
      '🥑 Aguacate con limón': 160,
      '🍳 Omelette con espinacas': 200,
      '🧀 Queso curado': 110,
      '🥓 Tiras de tocino': 180,
      '🐟 Salmón a la plancha': 210,
      '🥬 Ensalada con aceite de oliva': 130,
      '🥜 Nueces mixtas': 170,
      '🍗 Alitas de pollo al horno': 220,
      '🍄 Champiñones salteados': 90,
      '☕ Café con crema': 50,

      // Plan Energético
      '🥣 Avena con frutos secos': 270,
      '🍌 Banana': 100,
      '🥩 Carne magra': 250,
      '🥗 Ensalada con quinua': 180,
      '🍠 Camote al horno': 160,
      '🥤 Batido de proteínas': 200,
      '🥜 Mix de semillas': 150,
      '🥚 Huevos cocidos': 70,
      '🍞 Pan de centeno': 110,

      // Plan Ligero
      '🍵 Té verde': 5,
      '🍊 Mandarina': 45,
      '🥗 Ensalada verde': 40,
      '🍅 Sopa de tomate': 60,
      '🐟 Pescado al vapor': 140,
      '🥒 Bastones de pepino': 20,
      '🍎 Manzana verde': 80,
      '🥬 Wrap de lechuga con hummus': 100,
      '🥕 Zanahorias baby': 30,
      '🍓 Frutos rojos': 60,

      // Plan Mediterráneo
      '🥗 Ensalada griega': 150,
      '🐟 Sardinas en aceite de oliva': 200,
      '🍅 Tomates cherry con queso feta': 110,
      '🥖 Pan integral con hummus': 130,
      '🥒 Tabulé de pepino y perejil': 120,
      '🫒 Aceitunas negras': 90,
      '🍊 Naranja fresca': 70,
      '🥣 Yogur natural con miel': 140,
      '🌰 Almendras crudas': 160,
      '🍆 Berenjenas al horno': 85,

      // Plan Alto en Fibra
      '🥣 Avena con linaza': 260,
      '🍐 Pera con cáscara': 100,
      '🥬 Ensalada de espinaca y remolacha': 80,
      '🍞 Pan integral con aguacate': 180,
      '🍛 Lentejas guisadas': 220,
      '🥕 Zanahoria cruda': 35,
      '🍎 Manzana roja': 95,
      '🌽 Mazorca cocida': 120,
      '🍓 Mix de frutos del bosque': 70,
      '🌰 Nueces y semillas': 170,
  };

  Future<Map<String, dynamic>> _fetchResumenConCalorias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/meals?email=${widget.email}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        int totalCalorias = 0;

        List<Map<String, dynamic>> items = data.map((item) {
          String meal = item['meal'];
          int cantidad = item['cantidad'] ?? 0;
          int calorias = caloriasPorAlimento[meal] ?? 0;
          int subtotal = cantidad * calorias;
          totalCalorias += subtotal;

          return {
            'meal': meal,
            'cantidad': cantidad,
            'calorias': calorias,
            'subtotal': subtotal,
          };
        }).toList();

        return {
          'items': items,
          'total': totalCalorias,
        };
      }
    } catch (e) {
      debugPrint('❌ Error al cargar resumen: $e');
    }

    return {
      'items': [],
      'total': 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi progreso',
          style: TextStyle(
            color: Colors.black, // ✅ Texto oscuro visible sobre fondo blanco
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black), // Íconos oscuros también
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchResumenConCalorias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['items'].isEmpty) {
            return const Center(
              child: Text(
                "Aún no has consumido alimentos 🍽",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final items = snapshot.data!['items'] as List<Map<String, dynamic>>;
          final totalCalorias = snapshot.data!['total'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Progreso de comidas consumidas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 20),

                // Lista de alimentos en tarjetas estilizadas
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.green,
                          ),
                          title: Text(
                            item['meal'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Cantidad: ${item['cantidad']}  |  Cal x unidad: ${item['calorias']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Text(
                            '${item['subtotal']} cal',
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(height: 30, thickness: 2),

                // Total de calorías en estilo destacado
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🔥 Total de calorías consumidas: $totalCalorias cal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
