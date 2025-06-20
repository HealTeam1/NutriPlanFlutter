import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class NutritionistRegisterForm extends StatefulWidget {
  const NutritionistRegisterForm({super.key});

  @override
  State<NutritionistRegisterForm> createState() =>
      _NutritionistRegisterFormState();
}

class _NutritionistRegisterFormState extends State<NutritionistRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _lastName = '';
  String _birthDate = '';
  String _numberLicense = '';
  String _specialty = '';
  String _email = '';
  String _password = '';
  bool _isVisible = false;
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              onSaved: (newValue) => _name = newValue ?? '',
              decoration: _inputDecoration('Nombre'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              onSaved: (newValue) => _lastName = newValue ?? '',
              decoration: _inputDecoration('Apellido'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: _birthDate),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _birthDate =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  });
                }
              },
              decoration: _inputDecoration(
                'Fecha de Nacimiento',
              ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              onSaved: (newValue) => _numberLicense = newValue ?? '',
              decoration: _inputDecoration('Número de Licencia'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              onSaved: (newValue) => _specialty = newValue ?? '',
              decoration: _inputDecoration('Especialidad'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              onSaved: (newValue) => _email = newValue ?? '',
              decoration: _inputDecoration('Correo Electrónico'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: !_isVisible,
              onSaved: (newValue) => _password = newValue ?? '',
              decoration: _inputDecoration('Contraseña').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _isVisible ? Icons.visibility : Icons.visibility_off,
                  ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  activeColor: Colors.green,
                  value: _acceptedTerms,
                  onChanged: (val) {
                    setState(() {
                      _acceptedTerms = val ?? false;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 11, color: Colors.black),
                      children: [
                        const TextSpan(text: 'He leído y acepto los '),
                        TextSpan(
                          text: 'Términos y Condiciones',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: abrir términos
                            },
                        ),
                        const TextSpan(text: ' y la '),
                        TextSpan(
                          text: 'Política de Privacidad',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: abrir política
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: procesar datos
                  }
                },
                child: const Text(
                  "Registrarse",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
    );
  }
}
