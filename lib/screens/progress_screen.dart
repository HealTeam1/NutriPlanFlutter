import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<double> _weightEntries = [];
  List<double> _caloriesEntries = [];
  List<String> _dates = [];

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  String _lastUpdate = '';

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final weights = prefs.getStringList('weights') ?? [];
    final calories = prefs.getStringList('calories') ?? [];
    final dates = prefs.getStringList('dates') ?? [];

    if (weights.isEmpty || calories.isEmpty || dates.isEmpty) {
      // Datos base para 6 días anteriores
      final now = DateTime.now();
      List<String> baseDates = List.generate(6, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      });

      List<double> baseWeights = [70.0, 69.8, 69.6, 69.7, 69.5, 69.4];
      List<double> baseCalories = [2200, 2100, 2300, 2250, 2150, 2200];

      await prefs.setStringList('weights', baseWeights.map((e) => e.toString()).toList());
      await prefs.setStringList('calories', baseCalories.map((e) => e.toString()).toList());
      await prefs.setStringList('dates', baseDates);

      setState(() {
        _weightEntries = baseWeights;
        _caloriesEntries = baseCalories;
        _dates = baseDates;
        _lastUpdate = baseDates.last;
      });
    } else {
      setState(() {
        _weightEntries = weights.map((e) => double.tryParse(e) ?? 0.0).toList();
        _caloriesEntries = calories.map((e) => double.tryParse(e) ?? 0.0).toList();
        _dates = dates;
        if (_dates.isNotEmpty) {
          _lastUpdate = _dates.last;
        }
      });
    }
  }

  Future<void> _saveProgressData(double weight, double calories) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (_dates.isNotEmpty && _dates.last == dateStr) {
      _weightEntries[_weightEntries.length - 1] = weight;
      _caloriesEntries[_caloriesEntries.length - 1] += calories;
    } else {
      _weightEntries.add(weight);
      _caloriesEntries.add(calories);
      _dates.add(dateStr);
    }

    if (_weightEntries.length > 7) {
      _weightEntries.removeAt(0);
      _caloriesEntries.removeAt(0);
      _dates.removeAt(0);
    }

    await prefs.setStringList('weights', _weightEntries.map((e) => e.toString()).toList());
    await prefs.setStringList('calories', _caloriesEntries.map((e) => e.toString()).toList());
    await prefs.setStringList('dates', _dates);

    setState(() {
      _lastUpdate = dateStr;
    });
  }

  double _average(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Widget _buildChart() {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < _dates.length) {
                    final parts = _dates[index].split('-');
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${parts[2]}/${parts[1]}'),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 5),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: _weightEntries
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              barWidth: 3,
              color: Colors.green,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.3),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = _dates[spot.spotIndex];
                  return LineTooltipItem(
                    'Fecha: $date\nPeso: ${spot.y.toStringAsFixed(1)} kg',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dates.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final date = _dates[index];
        final weight = _weightEntries[index];
        final calories = _caloriesEntries[index];
        return ListTile(
          leading: const Icon(Icons.calendar_today, color: Color(0xFF02C79D)),
          title: Text('Fecha: $date'),
          subtitle: Text('Peso: ${weight.toStringAsFixed(1)} kg\nCalorías: ${calories.toStringAsFixed(0)} kcal'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double avgWeight = _average(_weightEntries);
    final double avgCalories = _average(_caloriesEntries);
    final double todayCalories = _caloriesEntries.isNotEmpty ? _caloriesEntries.last : 0.0;
    final double currentWeight = _weightEntries.isNotEmpty ? _weightEntries.last : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso del Usuario'),
        backgroundColor: const Color(0xFF02C79D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peso actual: ${currentWeight.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.titleLarge),
            Text('Última actualización: $_lastUpdate',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text('Promedio de peso (últimos 7 días): ${avgWeight.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.titleLarge),
            Text('Promedio de calorías (últimos 7 días): ${avgCalories.toStringAsFixed(0)} kcal',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Calorías consumidas hoy: ${todayCalories.toStringAsFixed(0)} kcal',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildChart(),
            const SizedBox(height: 24),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ingrese peso actual (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ingrese calorías consumidas hoy',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final double? weight = double.tryParse(_weightController.text);
                final double? calories = double.tryParse(_caloriesController.text);
                if (weight != null && calories != null) {
                  _saveProgressData(weight, calories);
                  _weightController.clear();
                  _caloriesController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese valores válidos')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02C79D),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Guardar progreso',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Historial de progreso',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }
}
