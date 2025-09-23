// lib/Dishes/Products/panel_products.dart
import 'package:flutter/material.dart';
import 'package:myapp/Dishes/Products/form_products.dart';

class PanelProducts extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final String? selectedProduct;
  final Function(String) onSelect;

  const PanelProducts({
    super.key,
    required this.products,
    this.selectedProduct,
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
              'Productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormProducts()),
                );
              },
              child: const Text('+ Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        ...products.map((prod) => GestureDetector(
              onTap: () => onSelect(prod['name']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: selectedProduct == prod['name'] ? Colors.pink[100] : Colors.white,
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
                    Image.asset(prod['image'], width: 50, height: 50, fit: BoxFit.cover),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prod['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(prod['description'], style: const TextStyle(color: Colors.grey)),
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
                        '${prod['presentations']} presentaciones',
                        style: const TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: prod['active'] ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        prod['active'] ? 'Horno' : 'Inactivo',
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