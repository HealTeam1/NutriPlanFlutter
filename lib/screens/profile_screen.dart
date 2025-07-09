import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController photoUrlController = TextEditingController();

  final String memberSince = 'Julio 2025';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final url = Uri.parse('http://192.168.100.26:3000/api/profile?email=${widget.email}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        nameController.text = data['name'] ?? '';
        ageController.text = (data['age'] ?? '').toString();
        weightController.text = (data['weight'] ?? '').toString();
        heightController.text = (data['height'] ?? '').toString();
        photoUrlController.text = data['photoUrl'] ?? '';
      } else {
        debugPrint('Error al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Excepción al obtener perfil: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    final updatedName = nameController.text;
    final age = ageController.text;
    final weight = weightController.text;
    final height = heightController.text;
    final photoUrl = photoUrlController.text;

    final url = Uri.parse('http://192.168.100.26:3000/api/profile');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'name': updatedName,
        'age': int.tryParse(age) ?? 0,
        'weight': double.tryParse(weight) ?? 0.0,
        'height': double.tryParse(height) ?? 0.0,
        'photoUrl': photoUrl,
      }),
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } else {
      final data = jsonDecode(response.body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${data['message']}')),
      );
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Color(0xFF4CAF50)) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final String imageUrl = photoUrlController.text.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFF4CAF50),
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Perfil del Usuario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 16),
          buildTextField(
            label: 'Nombre de usuario',
            controller: nameController,
            icon: Icons.person,
          ),
          buildTextField(
            label: 'Edad',
            controller: ageController,
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
          ),
          buildTextField(
            label: 'Peso (kg)',
            controller: weightController,
            icon: Icons.monitor_weight,
            keyboardType: TextInputType.number,
          ),
          buildTextField(
            label: 'Altura (cm)',
            controller: heightController,
            icon: Icons.height,
            keyboardType: TextInputType.number,
          ),
          buildTextField(
            label: 'URL de la foto de perfil',
            controller: photoUrlController,
            icon: Icons.image,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 8),
          Text(
            'Correo electrónico: ${widget.email}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            'Miembro desde: $memberSince',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.save),
              label: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }
}
