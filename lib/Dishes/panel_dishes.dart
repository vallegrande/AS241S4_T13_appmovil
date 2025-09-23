// lib/Dishes/panel_dishes.dart
import 'package:flutter/material.dart';
import 'package:myapp/Dishes/Categories/panel_categories.dart';
import 'package:myapp/Dishes/Products/panel_products.dart';
import 'package:myapp/Dishes/Presentations/panel_presentations.dart';

class PanelDishes extends StatefulWidget {
  const PanelDishes({super.key});

  @override
  State<PanelDishes> createState() => _PanelDishesState();
}

class _PanelDishesState extends State<PanelDishes> {
  String selectedMain = 'Platos y Bebidas';
  String? selectedCategory;
  String? selectedProduct;

  final Map<String, Color> mainColors = {
    'Platos y Bebidas': Colors.green,
    'Combos': Colors.blue,
    'Ofertas': Colors.purple,
    'Insumos': Colors.orange,
  };

  final Map<String, List<Map<String, dynamic>>> mainToCategories = {
    'Platos y Bebidas': [
      {'name': 'Pollos', 'description': 'Especialidades de pollo', 'products': 5, 'active': true},
      {'name': 'Bebidas', 'description': 'Refrescos y jugos', 'products': 3, 'active': true},
    ],
    'Combos': [
      {'name': 'Combos Especiales', 'description': 'Ofertas combinadas', 'products': 2, 'active': true},
    ],
    'Ofertas': [
      {'name': 'Promociones', 'description': 'Descuentos del día', 'products': 1, 'active': false},
    ],
    'Insumos': [
      {'name': 'Ingredientes', 'description': 'Materiales crudos', 'products': 4, 'active': true},
    ],
  };

  final Map<String, List<Map<String, dynamic>>> categoryToProducts = {
    'Pollos': [
      {'name': 'Pollo a la Brasa', 'description': 'Con especias', 'presentations': 3, 'active': true, 'image': 'assets/card_user/perfil1.png'},
      {'name': 'Pollo Frito', 'description': 'Crocante', 'presentations': 2, 'active': true, 'image': 'assets/card_user/perfil2.png'},
    ],
    'Bebidas': [
      {'name': 'Coca Cola', 'description': '500ml', 'presentations': 2, 'active': true, 'image': 'assets/card_user/perfil3.png'},
      {'name': 'Jugo Natural', 'description': 'Fresco', 'presentations': 1, 'active': true, 'image': 'assets/card_user/perfil1.png'},
    ],
    'Combos Especiales': [
      {'name': 'Combo Familiar', 'description': 'Pollo + Bebida', 'presentations': 1, 'active': true, 'image': 'assets/card_user/perfil2.png'},
    ],
  };

  final Map<String, List<Map<String, dynamic>>> productToPresentations = {
    'Pollo a la Brasa': [
      {'name': '1/4 Pollo', 'price': 15.00, 'time': 20, 'popularity': 85, 'active': true, 'image': 'assets/card_user/perfil1.png'},
      {'name': '1/2 Pollo', 'price': 25.00, 'time': 25, 'popularity': 90, 'active': true, 'image': 'assets/card_user/perfil2.png'},
    ],
    'Pollo Frito': [
      {'name': '6 Piezas', 'price': 20.00, 'time': 15, 'popularity': 80, 'active': true, 'image': 'assets/card_user/perfil3.png'},
    ],
    'Coca Cola': [
      {'name': '500ml', 'price': 2.50, 'time': 0, 'popularity': 95, 'active': true, 'image': 'assets/card_user/perfil1.png'},
    ],
    'Jugo Natural': [
      {'name': '300ml', 'price': 3.00, 'time': 5, 'popularity': 70, 'active': true, 'image': 'assets/card_user/perfil2.png'},
    ],
    'Combo Familiar': [
      {'name': 'Standard', 'price': 25.00, 'time': 25, 'popularity': 85, 'active': true, 'image': 'assets/card_user/perfil3.png'},
    ],
  };

  List<Map<String, dynamic>> _getCategories() => mainToCategories[selectedMain] ?? [];
  List<Map<String, dynamic>> _getProducts() => categoryToProducts[selectedCategory] ?? [];
  List<Map<String, dynamic>> _getPresentations() => productToPresentations[selectedProduct] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Menú'),
        backgroundColor: Colors.red,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formal header like "Panel de usuarios"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Text(
                'Panel de Platos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Vertical single-column layout for main categories
            Expanded(
              child: ListView.builder(
                itemCount: mainColors.keys.length,
                itemBuilder: (context, index) {
                  final main = mainColors.keys.elementAt(index);
                  return Card(
                    color: selectedMain == main ? mainColors[main]!.withOpacity(0.8) : mainColors[main],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedMain = main;
                          selectedCategory = null;
                          selectedProduct = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fastfood, color: Colors.white, size: 30),
                            const SizedBox(width: 8),
                            Text(
                              main,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PanelCategories(categories: _getCategories(), selectedCategory: selectedCategory, onSelect: (cat) {
                      setState(() {
                        selectedCategory = cat;
                        selectedProduct = null;
                      });
                    }),
                    if (selectedCategory != null) ...[
                      const SizedBox(height: 20),
                      PanelProducts(products: _getProducts(), selectedProduct: selectedProduct, onSelect: (prod) {
                        setState(() {
                          selectedProduct = prod;
                        });
                      }),
                    ],
                    if (selectedProduct != null) ...[
                      const SizedBox(height: 20),
                      PanelPresentations(presentations: _getPresentations()),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}