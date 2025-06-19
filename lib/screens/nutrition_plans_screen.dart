import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPrimaryColor = Color(0xFF02C79D);
const kSecondaryColor = Color(0xFFB0EFC6);

class NutritionPlansScreen extends StatefulWidget {
  const NutritionPlansScreen({Key? key}) : super(key: key);

  @override
  State<NutritionPlansScreen> createState() => _NutritionPlansScreenState();
}

class _NutritionPlansScreenState extends State<NutritionPlansScreen> {
  final List<String> defaultPlans = [
    'Plan Vegetariano',
    'Plan Bajo en Carbohidratos',
    'Plan Alto en Proteínas',
    'Plan Balanceado',
    'Plan Mediterráneo',
    'Plan Keto',
    'Plan Detox',
  ];

  List<String> customPlans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomPlans();
  }

  Future<void> _loadCustomPlans() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customPlans = prefs.getStringList('customPlans') ?? [];
      isLoading = false;
    });
  }

  Future<List<String>> _getFoodsForPlan(String plan) async {
    if (defaultPlans.contains(plan)) {
      switch (plan) {
        case 'Plan Vegetariano':
          return [
            'Espinaca - 100g',
            'Tofu - 150g',
            'Lentejas - 1 taza',
            'Frutas variadas',
            'Quinoa - 1/2 taza',
            'Nueces mixtas - 30g',
            'Avena - 40g',
          ];
        case 'Plan Bajo en Carbohidratos':
          return [
            'Pechuga de pollo - 150g',
            'Brócoli - 100g',
            'Palta - 1 unidad',
            'Aceite de oliva - 1 cucharada',
            'Huevos - 2 unidades',
            'Espárragos - 80g',
          ];
        case 'Plan Alto en Proteínas':
          return [
            'Claras de huevo - 4',
            'Pechuga de pavo - 200g',
            'Yogurt griego - 1 taza',
            'Salmón - 150g',
            'Almendras - 30g',
            'Requesón - 100g',
          ];
        case 'Plan Balanceado':
          return [
            'Arroz integral - 1/2 taza',
            'Pollo a la plancha - 150g',
            'Ensalada mixta (lechuga, tomate, zanahoria)',
            'Frutas frescas - 1 porción',
            'Lentejas cocidas - 1/2 taza',
          ];
        case 'Plan Mediterráneo':
          return [
            'Aceite de oliva extra virgen - 2 cucharadas',
            'Pescado (merluza o atún) - 150g',
            'Verduras frescas (tomate, pepino, cebolla)',
            'Frutas secas - 30g',
            'Pan integral - 1 rebanada',
            'Vino tinto (opcional) - 1 copa',
          ];
        case 'Plan Keto':
          return [
            'Aguacate - 1 unidad',
            'Queso cheddar - 50g',
            'Nueces - 30g',
            'Carne de res - 200g',
            'Espinaca salteada - 100g',
            'Mantequilla - 1 cucharada',
          ];
        case 'Plan Detox':
          return [
            'Jugo de limón - 1 vaso',
            'Pepino - 100g',
            'Té verde - 1 taza',
            'Apio - 80g',
            'Zanahoria cruda - 100g',
            'Manzana verde - 1 unidad',
          ];
        default:
          return ['Sin alimentos disponibles'];
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('foods_$plan') ?? ['Sin alimentos añadidos'];
    }
  }

  Future<void> _addOrEditPlan({String? existingPlanName}) async {
    final prefs = await SharedPreferences.getInstance();
    final nameController = TextEditingController(text: existingPlanName ?? '');
    List<String> foods = existingPlanName != null
        ? (await prefs.getStringList('foods_$existingPlanName') ?? [])
        : [];

    final planName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existingPlanName == null ? 'Nuevo plan nutricional' : 'Editar plan "$existingPlanName"'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Nombre del plan'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) Navigator.pop(context, name);
            },
            child: const Text('Siguiente', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (planName == null || planName.isEmpty) return;

    await showDialog(
      context: context,
      builder: (context) {
        final foodController = TextEditingController();

        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(existingPlanName == null ? 'Agregar alimentos a "$planName"' : 'Editar alimentos de "$planName"'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: foodController,
                    decoration: const InputDecoration(
                      hintText: 'Nombre alimento',
                      suffixIcon: Icon(Icons.add_circle, color: kPrimaryColor),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setStateDialog(() {
                          foods.add(value.trim());
                          foodController.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      final food = foodController.text.trim();
                      if (food.isNotEmpty) {
                        setStateDialog(() {
                          foods.add(food);
                          foodController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar alimento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: foods.isEmpty
                        ? const Center(child: Text('No hay alimentos añadidos'))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: foods.length,
                            itemBuilder: (_, index) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                title: Text(foods[index]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setStateDialog(() {
                                      foods.removeAt(index);
                                    });
                                  },
                                  tooltip: 'Eliminar alimento',
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: const Text('Guardar plan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );

    if (existingPlanName != null && existingPlanName != planName) {
      customPlans.remove(existingPlanName);
      await prefs.remove('foods_$existingPlanName');
      await prefs.remove('selected_$existingPlanName');
    }

    if (!customPlans.contains(planName)) {
      customPlans.add(planName);
    }

    await prefs.setStringList('customPlans', customPlans);
    await prefs.setStringList('foods_$planName', foods);

    setState(() {});
  }

  Future<void> _deletePlan(String planName) async {
    final prefs = await SharedPreferences.getInstance();
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar el plan "$planName"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      customPlans.remove(planName);
      await prefs.remove('foods_$planName');
      await prefs.remove('selected_$planName');
      await prefs.setStringList('customPlans', customPlans);
      setState(() {});
    }
  }

  Future<void> _showPlanDetails(String planName) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await _getFoodsForPlan(planName);

    final savedSelected = prefs.getStringList('selected_$planName') ?? [];
    final Map<String, bool> selectedItems = {
      for (var item in items) item: savedSelected.contains(item),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 24 + MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    planName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Alimentos sugeridos:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No hay alimentos añadidos', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return CheckboxListTile(
                            title: Text(item),
                            value: selectedItems[item],
                            onChanged: (val) {
                              setModalState(() {
                                selectedItems[item] = val ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Guardar selección', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () async {
                        final selected = selectedItems.entries.where((e) => e.value).map((e) => e.key).toList();
                        await prefs.setStringList('selected_$planName', selected);
                        Navigator.pop(context);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selección guardada')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPlans = [...defaultPlans, ...customPlans];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes Nutricionales'),
        backgroundColor: kPrimaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: allPlans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = allPlans[index];
                final isCustom = customPlans.contains(plan);
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  shadowColor: Colors.black26,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(plan, style: Theme.of(context).textTheme.titleMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.arrow_forward_ios, color: kPrimaryColor),
                          label: const Text('Ver'),
                          onPressed: () => _showPlanDetails(plan),
                          style: TextButton.styleFrom(
                            foregroundColor: kPrimaryColor,
                          ),
                        ),
                        if (isCustom) ...[
                          const SizedBox(width: 4),
                          TextButton.icon(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text('Editar'),
                            onPressed: () => _addOrEditPlan(existingPlanName: plan),
                            style: TextButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text('Eliminar'),
                            onPressed: () => _deletePlan(plan),
                            style: TextButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditPlan(),
        backgroundColor: kPrimaryColor,
        label: const Text('Nuevo plan', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
