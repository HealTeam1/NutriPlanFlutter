import 'package:flutter/material.dart';
import 'package:nutrihealth_app/features/auth/presentation/widgets/nutritionist_register_form.dart';
import 'package:nutrihealth_app/features/auth/presentation/widgets/person_register_form.dart';

class RegisterDialogForm extends StatelessWidget {
  const RegisterDialogForm({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    if (role == 'nutricionista') {
      return NutritionistRegisterForm();
    } else if (role == 'persona') {
      return PersonRegisterForm();
    }
    return Center(
      child: Text(
        'Rol no reconocido: $role',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }
}
