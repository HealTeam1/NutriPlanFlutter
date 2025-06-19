import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

const Color kPrimaryColor = Color(0xFF02C79D);
const Color kSecondaryColor = Color(0xFFB0EFC6);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = '';
  String email = '';
  DateTime birthDate = DateTime(1990, 5, 20);
  String gender = 'Masculino';
  double weight = 0.0;
  double height = 0.0;

  File? _profileImageFile;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _birthDateController;
  String? _genderValue;
  late DateTime _selectedDate;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      fullName = prefs.getString('fullName') ?? '';
      email = prefs.getString('email') ?? '';
      final birthDateString = prefs.getString('birthDate');
      birthDate = birthDateString != null
          ? DateTime.tryParse(birthDateString) ?? DateTime(1990, 5, 20)
          : DateTime(1990, 5, 20);
      gender = prefs.getString('gender') ?? 'Masculino';
      weight = prefs.getDouble('weight') ?? 0.0;
      height = prefs.getDouble('height') ?? 0.0;
      final profileImagePath = prefs.getString('profileImagePath');

      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        _profileImageFile = File(profileImagePath);
      }

      _nameController = TextEditingController(text: fullName);
      _emailController = TextEditingController(text: email);
      _weightController = TextEditingController(text: weight > 0 ? weight.toString() : '');
      _heightController = TextEditingController(text: height > 0 ? height.toString() : '');
      _genderValue = gender;
      _selectedDate = birthDate;
      _birthDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate));
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('fullName', _nameController.text.trim());
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('birthDate', _birthDateController.text);
    await prefs.setString('gender', _genderValue ?? 'Masculino');
    await prefs.setDouble('weight', double.parse(_weightController.text));
    await prefs.setDouble('height', double.parse(_heightController.text));
    if (_profileImageFile != null) {
      await prefs.setString('profileImagePath', _profileImageFile!.path);
    }

    setState(() {
      fullName = _nameController.text.trim();
      email = _emailController.text.trim();
      birthDate = _selectedDate;
      gender = _genderValue ?? 'Masculino';
      weight = double.parse(_weightController.text);
      height = double.parse(_heightController.text);
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil guardado correctamente'),
        backgroundColor: kPrimaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final String savedPath = path.join(directory.path, fileName);
      final File savedImage = await File(pickedFile.path).copy(savedPath);

      setState(() {
        _profileImageFile = savedImage;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar perfil', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: _profileImageFile != null
                          ? FileImage(_profileImageFile!)
                          : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                      backgroundColor: kSecondaryColor.withOpacity(0.4),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nombre completo',
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Correo electrónico',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese su correo';
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) return 'Correo no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _birthDateController,
                        label: 'Fecha de nacimiento',
                        readOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _genderValue,
                    decoration: InputDecoration(
                      labelText: 'Género',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _genderValue = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty ? 'Seleccione género' : null,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _weightController,
                    label: 'Peso actual (kg)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese su peso';
                      final w = double.tryParse(value);
                      if (w == null || w <= 0) return 'Peso no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _heightController,
                    label: 'Altura (cm)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese su altura';
                      final h = double.tryParse(value);
                      if (h == null || h <= 0) return 'Altura no válida';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryColor,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(100, 40),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _saveProfile,
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  Widget _buildProfileDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundImage: _profileImageFile != null
            ? FileImage(_profileImageFile!)
            : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
        backgroundColor: kSecondaryColor.withOpacity(0.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: kPrimaryColor,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showEditDialog,
              child: _buildProfilePhoto(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kSecondaryColor.withOpacity(0.3),
                border: Border.all(color: kPrimaryColor, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileDataRow('Nombre completo', fullName.isEmpty ? '-' : fullName),
                  _buildProfileDataRow('Correo electrónico', email.isEmpty ? '-' : email),
                  _buildProfileDataRow('Fecha de nacimiento', DateFormat('yyyy-MM-dd').format(birthDate)),
                  _buildProfileDataRow('Género', gender),
                  _buildProfileDataRow('Peso actual (kg)', weight > 0 ? weight.toStringAsFixed(1) : '-'),
                  _buildProfileDataRow('Altura (cm)', height > 0 ? height.toStringAsFixed(1) : '-'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 24, color: Colors.white),
                label: const Text(
                  'Editar perfil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showEditDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
