import 'package:flutter/material.dart';
import 'package:myapp/models/ingredient.dart';

class IngredientsTable extends StatelessWidget {
  final List<Ingredient> ingredients;
  final Function(Ingredient)? onEdit; 
  final Function(Ingredient)? onDisable; 

  const IngredientsTable({
    super.key,
    required this.ingredients,
    this.onEdit, 
    this.onDisable, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFe5e7eb)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFe5e7eb))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Insumos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Acción de agregar manejada en CatalogPage
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd67628),
                  ),
                  child: const Text('+ Agregar'),
                ),
              ],
            ),
          ),

          // Tabla
          Expanded(
            child: ingredients.isEmpty
                ? const Center(
                    child: Text(
                      'No hay insumos para mostrar.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFf9fafb)),
                      columns: const [
                        DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Stock Min', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Stock Max', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Proveedor', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Lote', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('F. Producción', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('F. Vencimiento', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Precio Unit.', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Costo Total', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Refrigeración', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Alérgenos', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: ingredients.map((ingredient) {
                        return DataRow(cells: [
                          DataCell(Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(ingredient.category ?? 'N/A')),
                          DataCell(Text('${ingredient.quantity} ${ingredient.unit ?? ''}')),
                          DataCell(Text(ingredient.minStock?.toString() ?? 'N/A')),
                          DataCell(Text(ingredient.maxStock?.toString() ?? 'N/A')),
                          DataCell(Text(ingredient.supplier ?? 'N/A')),
                          DataCell(Text(ingredient.lotNumber ?? 'N/A')),
                          DataCell(Text(ingredient.productionDate ?? 'N/A')),
                          DataCell(Text(ingredient.expirationDate ?? 'N/A')),
                          DataCell(Text('S/ ${ingredient.unitPrice?.toStringAsFixed(2) ?? '0.00'}')),
                          DataCell(Text(
                            'S/ ${ingredient.totalCost?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ingredient.requiresRefrigeration == true 
                                    ? const Color(0xFFecfdf5) 
                                    : const Color(0xFFfff1f0),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                ingredient.requiresRefrigeration == true ? 'Sí' : 'No',
                                style: TextStyle(
                                  color: ingredient.requiresRefrigeration == true 
                                      ? const Color(0xFF0f9d58) 
                                      : const Color(0xFFdc2626),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ingredient.hasAllergens == true 
                                    ? const Color(0xFFecfdf5) 
                                    : const Color(0xFFfff1f0),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                ingredient.hasAllergens == true ? 'Sí' : 'No',
                                style: TextStyle(
                                  color: ingredient.hasAllergens == true 
                                      ? const Color(0xFF0f9d58) 
                                      : const Color(0xFFdc2626),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ingredient.state 
                                    ? const Color(0xFFecfdf5) 
                                    : const Color(0xFFfff1f0),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                ingredient.state ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  color: ingredient.state 
                                      ? const Color(0xFF0f9d58) 
                                      : const Color(0xFFdc2626),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  onPressed: onEdit != null ? () => onEdit!(ingredient) : null, 
                                  icon: Image.asset('assets/icons/boton-editar.png', width: 16, height: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  onPressed: onDisable != null ? () => onDisable!(ingredient) : null,
                                  icon: Image.asset('assets/icons/delete.png', width: 16, height: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
