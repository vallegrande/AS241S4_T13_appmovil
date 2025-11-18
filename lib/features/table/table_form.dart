// lib/features/tables/widgets/table_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:as241s4_t13_appmovil/core/models/table/table_model.dart';

class TableForm extends StatefulWidget {
  final TableModel? table;
  final Function(TableModel) onSave;
  final VoidCallback? onCancel;

  const TableForm({
    super.key,
    this.table,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<TableForm> createState() => _TableFormState();
}

class _TableFormState extends State<TableForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _locationController;
  late TextEditingController _currentOccupancyController;

  // State variables
  bool _isOccupied = false;
  bool _state = true;
  bool _isSubmitting = false;

  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _capacityFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _occupancyFocus = FocusNode();

  // Colors
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFF8C42);
  static const Color accentOrange = Color(0xFFFFA556);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.table?.name ?? '');
    _capacityController = TextEditingController(
      text: widget.table?.capacity.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: widget.table?.location ?? '',
    );
    _currentOccupancyController = TextEditingController(
      text: widget.table?.currentOccupancy.toString() ?? '0',
    );

    _isOccupied = widget.table?.isOccupied ?? false;
    _state = widget.table?.state ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    _currentOccupancyController.dispose();
    _nameFocus.dispose();
    _capacityFocus.dispose();
    _locationFocus.dispose();
    _occupancyFocus.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validación adicional de ocupación
    final capacity = int.tryParse(_capacityController.text) ?? 0;
    final currentOccupancy =
        int.tryParse(_currentOccupancyController.text) ?? 0;

    if (_isOccupied && currentOccupancy > capacity) {
      _showErrorDialog(
        'Ocupación inválida',
        'La ocupación actual no puede ser mayor que la capacidad de la mesa.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final table = TableModel(
        idTable: widget.table?.idTable,
        name: _nameController.text.trim(),
        capacity: capacity,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        state: _state,
        isOccupied: _isOccupied,
        currentOccupancy: _isOccupied ? currentOccupancy : 0,
      );

      widget.onSave(table);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isDark),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameField(isDark),
                    const SizedBox(height: 20),
                    _buildCapacityField(isDark),
                    const SizedBox(height: 20),
                    _buildLocationField(isDark),
                    const SizedBox(height: 24),
                    _buildOccupancySection(isDark),
                    if (widget.table != null) ...[
                      const SizedBox(height: 24),
                      _buildStateSwitch(isDark),
                    ],
                    const SizedBox(height: 32),
                    _buildActionButtons(isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryOrange, lightOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.table == null ? Icons.add_rounded : Icons.edit_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.table == null ? 'Nueva Mesa' : 'Editar Mesa',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.table == null
                      ? 'Registra una nueva mesa en el sistema'
                      : 'Actualiza la información de la mesa',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onCancel ?? () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            iconSize: 28,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, duration: 400.ms);
  }

  Widget _buildNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Nombre de la Mesa', true, isDark),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocus,
          textCapitalization: TextCapitalization.words,
          decoration: _buildInputDecoration(
            hintText: 'Ej: Mesa 1, Mesa VIP, Terraza A',
            prefixIcon: Icons.table_bar_rounded,
            isDark: isDark,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            if (value.trim().length < 2) {
              return 'El nombre debe tener al menos 2 caracteres';
            }
            return null;
          },
          onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: -0.1);
  }

  Widget _buildCapacityField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Capacidad', true, isDark),
        const SizedBox(height: 8),
        TextFormField(
          controller: _capacityController,
          focusNode: _capacityFocus,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: _buildInputDecoration(
            hintText: 'Número de personas',
            prefixIcon: Icons.people_rounded,
            isDark: isDark,
            suffixText: 'personas',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La capacidad es requerida';
            }
            final capacity = int.tryParse(value);
            if (capacity == null || capacity <= 0) {
              return 'Ingrese una capacidad válida';
            }
            if (capacity > 100) {
              return 'La capacidad máxima es 100';
            }
            return null;
          },
          onFieldSubmitted: (_) => _locationFocus.requestFocus(),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 150.ms).slideX(begin: -0.1);
  }

  Widget _buildLocationField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Ubicación', false, isDark),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          focusNode: _locationFocus,
          textCapitalization: TextCapitalization.sentences,
          decoration: _buildInputDecoration(
            hintText: 'Ej: Salón principal, Terraza, Piso 2',
            prefixIcon: Icons.location_on_rounded,
            isDark: isDark,
          ),
          onFieldSubmitted: (_) {
            if (_isOccupied) {
              _occupancyFocus.requestFocus();
            }
          },
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(begin: -0.1);
  }

  Widget _buildOccupancySection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOccupied
              ? primaryOrange.withOpacity(0.3)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mesa Ocupada',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Switch(
                value: _isOccupied,
                activeColor: primaryOrange,
                onChanged: (value) {
                  setState(() {
                    _isOccupied = value;
                    if (!value) {
                      _currentOccupancyController.text = '0';
                    }
                  });
                },
              ),
            ],
          ),
          if (_isOccupied) ...[
            const SizedBox(height: 16),
            Text(
              'Ocupación Actual',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentOccupancyController,
              focusNode: _occupancyFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: _buildInputDecoration(
                hintText: 'Número de personas ocupando',
                prefixIcon: Icons.group_rounded,
                isDark: isDark,
                suffixText: 'personas',
              ),
              validator: (value) {
                if (!_isOccupied) return null;

                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese la ocupación actual';
                }
                final occupancy = int.tryParse(value);
                if (occupancy == null || occupancy < 0) {
                  return 'Ingrese un número válido';
                }
                final capacity = int.tryParse(_capacityController.text) ?? 0;
                if (occupancy > capacity) {
                  return 'No puede exceder la capacidad ($capacity)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildOccupancyIndicator(isDark),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideX(begin: -0.1);
  }

  Widget _buildOccupancyIndicator(bool isDark) {
    final capacity = int.tryParse(_capacityController.text) ?? 1;
    final occupancy = int.tryParse(_currentOccupancyController.text) ?? 0;
    final percentage = (occupancy / capacity * 100).clamp(0, 100);

    Color indicatorColor = Colors.green;
    String status = 'Disponible';

    if (occupancy > 0 && occupancy < capacity) {
      indicatorColor = Colors.orange;
      status = 'Parcialmente ocupada';
    } else if (occupancy >= capacity) {
      indicatorColor = Colors.red;
      status = 'Llena';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: indicatorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: indicatorColor,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: indicatorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$occupancy de $capacity personas',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateSwitch(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _state
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _state ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: _state ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de la Mesa',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  _state ? 'Activa' : 'Inactiva',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _state ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _state,
            activeColor: Colors.green,
            inactiveTrackColor: Colors.red.withOpacity(0.3),
            onChanged: (value) => setState(() => _state = value),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideX(begin: -0.1);
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting
                ? null
                : (widget.onCancel ?? () => Navigator.pop(context)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: primaryOrange,
              disabledBackgroundColor: primaryOrange.withOpacity(0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: primaryOrange.withOpacity(0.4),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        widget.table == null ? 'Crear Mesa' : 'Guardar Cambios',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 350.ms).slideY(begin: 0.1);
  }

  Widget _buildFieldLabel(String label, bool required, bool isDark) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: primaryOrange,
        size: 22,
      ),
      suffixText: suffixText,
      suffixStyle: GoogleFonts.inter(
        color: isDark ? Colors.grey[500] : Colors.grey[600],
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primaryOrange,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
