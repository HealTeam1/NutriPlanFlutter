import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget _buildProgressBar(BuildContext context, String title, double value, double maxValue, Color color) {
    final percent = (value / maxValue).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${value.toInt()} / ${maxValue.toInt()}',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          color: color,
          backgroundColor: color.withOpacity(0.3),
          minHeight: 8,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFoodRecommendation(String imageAsset, String foodName, String description) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.asset(
              imageAsset,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(foodName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF02C79D))),
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bienvenido a NutriPlan',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: const Color(0xFFB0EFC6),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  Icon(Icons.local_florist,
                      size: 48, color: Color(0xFF02C79D)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Tip del día: Bebe al menos 8 vasos de agua para mantener tu cuerpo hidratado.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Objetivos diarios',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          _buildProgressBar(context, 'Agua (ml)', 1400, 2000, const Color(0xFF02C79D)),
          _buildProgressBar(context, 'Pasos', 6500, 10000, Colors.orange),
          _buildProgressBar(context, 'Calorías consumidas', 1800, 2200, Colors.redAccent),

          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Peso', '72.5 kg', Icons.monitor_weight, Colors.green),
                  _buildSummaryItem('IMC', '23.4', Icons.fitness_center, Colors.blue),
                  _buildSummaryItem('Meta semanal', '−0.5 kg', Icons.flag, Colors.deepPurple),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Recomendaciones saludables',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          _buildFoodRecommendation(
            'assets/images/spinach.png',
            'Espinaca',
            'Rica en hierro, fibra y antioxidantes, perfecta para ensaladas y batidos verdes.',
          ),
          _buildFoodRecommendation(
            'assets/images/quinoa.png',
            'Quinoa',
            'Excelente fuente de proteína completa y carbohidratos saludables para energía sostenida.',
          ),
          _buildFoodRecommendation(
            'assets/images/almonds.jpg',
            'Almendras',
            'Fuente de grasas saludables y vitamina E para cuidar tu corazón y piel.',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
