// Archivo: lib/Dishes/Forms/presentation_form.dart
import 'package:flutter/material.dart';
import 'package:myapp/services/presentation_service.dart';
import 'package:myapp/models/presentation.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/department_service.dart'; // Importa NotFoundException

class PresentationForm extends StatefulWidget {
  final Presentation? presentation;
  final Product product;
  final VoidCallback onClose;
  final Function(Presentation) onSaved;

  const PresentationForm({
    super.key,
    this.presentation,
    required this.product,
    required this.onClose,
    required this.onSaved,
  });

  @override
  _PresentationFormState createState() => _PresentationFormState();
}

class _PresentationFormState extends State<PresentationForm> {
  final _formKey = GlobalKey<FormState>();
  final _presentationService = PresentationService();
  
  late String _name;
  late String _description;
  late double _price;
  late double? _deliveryPrice;
  late double? _takeoutPrice;
  late double? _promoPrice;
  late int? _preparationTime;
  late bool _state;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.presentation;
    _name = p?.name ?? '';
    _description = p?.description ?? '';
    _price = p?.price ?? 0.0;
    _deliveryPrice = p?.deliveryPrice;
    _takeoutPrice = p?.takeoutPrice;
    _promoPrice = p?.promoPrice;
    _preparationTime = p?.preparationTime;
    _state = p?.state ?? true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final presentationData = Presentation(
        idPresentation: widget.presentation?.idPresentation,
        name: _name,
        description: _description,
        price: _price,
        deliveryPrice: _deliveryPrice, // Envía null si es null
        takeoutPrice: _takeoutPrice, // Envía null si es null
        promoPrice: _promoPrice, // Envía null si es null
        preparationTime: _preparationTime, // Envía null si es null
        state: _state,
        product: widget.product,
      );

      Presentation savedPresentation;
      if (widget.presentation?.idPresentation != null) {
        savedPresentation = await _presentationService.update(
          widget.presentation!.idPresentation!, 
          presentationData
        );
      } else {
        savedPresentation = await _presentationService.create(presentationData);
      }

      widget.onSaved(savedPresentation);
      _showSuccess('Presentación ${widget.presentation != null ? 'actualizada' : 'creada'} correctamente');
    } catch (e) {
      _showError('Error al guardar presentación: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.presentation != null;

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.3))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Editar Presentación' : 'Nueva Presentación',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Producto: ${widget.product.name}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Nombre
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de Presentación *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                      onChanged: (value) => _name = value,
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es requerido';
                        }
                        return null;
                      },
                      onChanged: (value) => _description = value,
                    ),
                    const SizedBox(height: 16),

                    // Precios en fila
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _price.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Precio en mesa (Base) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              final num = double.tryParse(value);
                              if (num == null || num < 0.01) {
                                return 'El precio debe ser mayor a 0';
                              }
                              return null;
                            },
                            onChanged: (value) => _price = double.tryParse(value) ?? 0.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _takeoutPrice?.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Precio para llevar',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _takeoutPrice = double.tryParse(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Más precios
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _deliveryPrice?.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Precio de Envío',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _deliveryPrice = double.tryParse(value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _promoPrice?.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Precio de Promoción',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _promoPrice = double.tryParse(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tiempo de preparación
                    TextFormField(
                      initialValue: _preparationTime?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Tiempo de Preparación (minutos)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _preparationTime = int.tryParse(value),
                    ),
                    const SizedBox(height: 16),

                    // Estado (solo en edición)
                    if (isEdit) 
                      CheckboxListTile(
                        title: const Text('Presentación activa'),
                        value: _state,
                        onChanged: (value) => setState(() => _state = value ?? true),
                      ),

                    const SizedBox(height: 20),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loading ? null : widget.onClose,
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF28a745),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(isEdit ? 'Actualizar' : 'Crear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}