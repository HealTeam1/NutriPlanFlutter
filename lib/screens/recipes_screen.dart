import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final String baseUrl = 'http://192.168.100.26:3000';

  List<Map<String, dynamic>> _allRecetas = [];
  List<Map<String, dynamic>> _filteredRecetas = [];

  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchRecetas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/recetas'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _allRecetas = List<Map<String, dynamic>>.from(data);
        _filteredRecetas = List.from(_allRecetas);
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error al obtener recetas: $e');
    }
  }

  void _filterRecetas(String query) {
    final filtered = _allRecetas.where((receta) {
      final nombre = receta['nombre']?.toString().toLowerCase() ?? '';
      final input = query.toLowerCase();
      return nombre.contains(input);
    }).toList();

    setState(() {
      _filteredRecetas = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRecetas();
    _searchController.addListener(() {
      _filterRecetas(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Recetas Saludables', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar receta',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _allRecetas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRecetas.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron recetas 🍽️',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredRecetas.length,
                          itemBuilder: (context, index) {
                            final receta = _filteredRecetas[index];
                            return Card(
                              color: const Color(0xFFE8F5E9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (receta['imagen'] != null && receta['imagen'].toString().isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Image.network(
                                        receta['imagen'],
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          receta['nombre'] ?? 'Sin nombre',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF388E3C)),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('🍴 Ingredientes: ${receta['ingredientes']}'),
                                        const SizedBox(height: 6),
                                        Text('👨‍🍳 Preparación:\n${receta['preparacion']}'),
                                        const SizedBox(height: 6),
                                        Text('🔥 Calorías: ${receta['calorias']} kcal'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
