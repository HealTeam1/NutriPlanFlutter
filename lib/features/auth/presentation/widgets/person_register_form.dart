import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class PersonRegisterForm extends StatefulWidget {
  const PersonRegisterForm({super.key});

  @override
  State<PersonRegisterForm> createState() => _PersonRegisterFormState();
}

class _PersonRegisterFormState extends State<PersonRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _lastName = '';
  String _birthDate = '';
  String _weight = '';
  String _height = '';
  String _email = '';
  String _password = '';
  bool _isVisible = false;
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            onSaved: (newValue) => _name = newValue ?? '',
            decoration: InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            onSaved: (newValue) => _lastName = newValue ?? '',
            decoration: InputDecoration(
              labelText: 'Apellido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
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
            decoration: InputDecoration(
              labelText: 'Fecha de Nacimiento',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            onSaved: (newValue) => _weight = newValue ?? '',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Peso (kg)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            onSaved: (newValue) => _height = newValue ?? '',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Altura (cm)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            onSaved: (newValue) => _email = newValue ?? '',
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: !_isVisible,
            onSaved: (newValue) => _password = newValue ?? '',
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
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
                value: _acceptedTerms,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() {
                    _acceptedTerms = val ?? false;
                  });
                },
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black),
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
                            // TODO: Abrir términos
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
                            // TODO: Abrir política
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
                'Registrarse',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
