import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class UserForm extends StatefulWidget {
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? nombres;
  final String? apellidos;
  final String? genero;
  final String? gmail;
  final String? contrasena;
  final String? rol;
  final String? telefono;
  final String? direccion;
  final String? imagePath;

  const UserForm({
    super.key,
    this.tipoDocumento,
    this.numeroDocumento,
    this.nombres,
    this.apellidos,
    this.genero,
    this.gmail,
    this.contrasena,
    this.rol,
    this.telefono,
    this.direccion,
    this.imagePath,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _isSidebarOpen = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _numeroDocumentoController;
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _gmailController;
  late TextEditingController _contrasenaController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  String? _selectedTipoDocumento;
  String? _selectedGenero;
  String? _selectedRol;

  @override
  void initState() {
    super.initState();
    _selectedTipoDocumento = widget.tipoDocumento;
    _selectedGenero = widget.genero;
    _selectedRol = widget.rol;
    _selectedImage = widget.imagePath != null ? File(widget.imagePath!) : null;

    _numeroDocumentoController = TextEditingController(
      text: widget.numeroDocumento ?? '',
    );
    _nombresController = TextEditingController(text: widget.nombres ?? '');
    _apellidosController = TextEditingController(text: widget.apellidos ?? '');
    _gmailController = TextEditingController(text: widget.gmail ?? '');
    _contrasenaController = TextEditingController(
      text: widget.contrasena ?? '',
    );
    _telefonoController = TextEditingController(text: widget.telefono ?? '');
    _direccionController = TextEditingController(text: widget.direccion ?? '');
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _numeroDocumentoController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _gmailController.dispose();
    _contrasenaController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.numeroDocumento != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppHeader(
            onMenuTap: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
          ),
          Expanded(
            child: Row(
              children: [
                AppSidebar(isOpen: _isSidebarOpen, onItemTap: (_) {}),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? "Editar usuario" : "Crear nuevo usuario",
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 38,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : const AssetImage(
                                            "assets/formUser/defaultUser.png",
                                          )
                                          as ImageProvider,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickImage,
                                  child: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Dropdowns e Inputs unificados
                        _buildDropdown(
                          "Tipo de documento",
                          ["DNI", "CNE"],
                          _selectedTipoDocumento,
                          (val) => setState(() => _selectedTipoDocumento = val),
                        ),
                        _buildTextField(
                          "Número de documento",
                          controller: _numeroDocumentoController,
                        ),
                        _buildTextField(
                          "Nombres",
                          controller: _nombresController,
                        ),
                        _buildTextField(
                          "Apellidos",
                          controller: _apellidosController,
                        ),
                        _buildDropdown(
                          "Género",
                          ["Masculino", "Femenino", "Otros"],
                          _selectedGenero,
                          (val) => setState(() => _selectedGenero = val),
                        ),
                        _buildTextField("Gmail", controller: _gmailController),
                        _buildTextField(
                          "Contraseña",
                          obscure: true,
                          controller: _contrasenaController,
                        ),
                        _buildDropdown(
                          "Rol asignado",
                          ["Admin", "Cocinero", "Mozo"],
                          _selectedRol,
                          (val) => setState(() => _selectedRol = val),
                        ),
                        _buildTextField(
                          "Teléfono",
                          controller: _telefonoController,
                        ),
                        _buildTextField(
                          "Dirección",
                          controller: _direccionController,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, {
                                  "tipoDocumento": _selectedTipoDocumento,
                                  "numeroDocumento":
                                      _numeroDocumentoController.text,
                                  "nombres": _nombresController.text,
                                  "apellidos": _apellidosController.text,
                                  "genero": _selectedGenero,
                                  "gmail": _gmailController.text,
                                  "contrasena": _contrasenaController.text,
                                  "rol": _selectedRol,
                                  "telefono": _telefonoController.text,
                                  "direccion": _direccionController.text,
                                  "imagePath": _selectedImage?.path,
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: const Text(
                                "Guardar",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    bool obscure = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
          hintText: "Ingrese $label",
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selected,
    void Function(String?) onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: selected,
            hint: Text(
              "Seleccione $label",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                )
                .toList(),
            onChanged: onChange,
            buttonStyleData: ButtonStyleData(
              height: 48,
              padding: EdgeInsets.zero,
              decoration: null,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              elevation: 4,
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(8),
                thickness: MaterialStateProperty.all(6),
                thumbColor: MaterialStateProperty.all(Colors.grey.shade400),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(height: 40),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down_circle_outlined,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
