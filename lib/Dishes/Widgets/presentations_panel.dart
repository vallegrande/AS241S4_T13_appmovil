import 'package:flutter/material.dart';
import 'package:myapp/models/presentation.dart';
import 'package:myapp/models/product.dart';

class PresentationsPanel extends StatelessWidget {
  final List<Presentation> presentations;
  final Product? selectedProduct;
  final VoidCallback onAddPresentation;
  final Function(Presentation) onEditPresentation;
  final Function(Presentation) onDeletePresentation;
  final bool isLoading;

  const PresentationsPanel({
    super.key,
    required this.presentations,
    this.selectedProduct,
    required this.onAddPresentation,
    required this.onEditPresentation,
    required this.onDeletePresentation,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFe5e7eb)),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Presentaciones',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (selectedProduct != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'de ${selectedProduct!.name}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              ElevatedButton(
                onPressed: selectedProduct != null ? onAddPresentation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFd67628),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text(
                  '+ Agregar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de presentaciones
          Expanded(
            child: selectedProduct == null
                ? const Center(
                    child: Text(
                      'Selecciona un producto para ver sus presentaciones.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : presentations.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay presentaciones para este producto.',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: presentations.length,
                            itemBuilder: (context, index) {
                              final presentation = presentations[index];
                              return _buildPresentationCard(presentation);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresentationCard(Presentation presentation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFeef2f6), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        presentation.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'S/ ${presentation.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0f1724),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: presentation.state == true ? const Color(0xFF10b981) : const Color(0xFFef4444),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    presentation.state == true ? 'Activo' : 'Inactivo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (presentation.promoPrice != null && presentation.promoPrice! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfef3c7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Promoción',
                            style: TextStyle(
                              color: Color(0xFF92400e),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (presentation.deliveryPrice != null && presentation.deliveryPrice! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf3f4f6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '🚚 S/ ${presentation.deliveryPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF6b7280),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (presentation.takeoutPrice != null && presentation.takeoutPrice! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf3f4f6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '📦 S/ ${presentation.takeoutPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF6b7280),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (presentation.preparationTime != null && presentation.preparationTime! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf3f4f6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '⏱️ ${presentation.preparationTime} min',
                            style: const TextStyle(
                              color: Color(0xFF6b7280),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => onEditPresentation(presentation),
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => onDeletePresentation(presentation),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}