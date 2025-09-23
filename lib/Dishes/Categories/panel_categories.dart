// lib/Dishes/Categories/panel_categories.dart
import 'package:flutter/material.dart';
import 'package:myapp/Dishes/Categories/form_categories.dart';

class PanelCategories extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Function(String) onSelect;

  const PanelCategories({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categorías',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormCategories()),
                );
              },
              child: const Text('+ Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        ...categories.map((cat) => GestureDetector(
              onTap: () => onSelect(cat['name']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: selectedCategory == cat['name'] ? Colors.pink[100] : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(cat['description'], style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        '${cat['products']} productos',
                        style: const TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: cat['active'] ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        cat['active'] ? 'Activo' : 'Inactivo',
                        style: const TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}