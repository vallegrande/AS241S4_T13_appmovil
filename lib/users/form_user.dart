import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final String? imagePath; // <-- agregar aquí

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
    return Scaffold(
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
                        const Text(
                          "Crear/Editar perfil de usuario",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                          as ImageProvider
                                    : const AssetImage(
                                        "assets/formUser/defaultUser.png",
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickImage,
                                  child: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          "Tipo de documento",
                          ["DNI", "CNE"],
                          _selectedTipoDocumento,
                          (val) => setState(() => _selectedTipoDocumento = val),
                        ),
                        _buildTextField(
                          "Numero de documento",
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
                          "Genero",
                          ["Masculino", "Femenino", "Otros"],
                          _selectedGenero,
                          (val) => setState(() => _selectedGenero = val),
                        ),
                        _buildTextField("Gmail", controller: _gmailController),
                        _buildTextField(
                          "Contrasena",
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
                          "Telefono",
                          controller: _telefonoController,
                        ),
                        _buildTextField(
                          "Direccion",
                          controller: _direccionController,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Cancelar"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                // Retornar datos al panel
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
                              ),
                              child: const Text("Guardar"),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: "Ingrese $label",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selected,
    void Function(String?) onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 3),
        DropdownButtonFormField<String>(
          value: selected,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChange,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
