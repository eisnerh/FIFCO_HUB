import 'package:flutter/material.dart';
import '../models/shortcut.dart';
import '../models/category.dart';

class EditShortcutScreen extends StatefulWidget {
  final Shortcut? shortcut;
  final List<Category> categories;
  
  const EditShortcutScreen({
    super.key, 
    this.shortcut,
    required this.categories,
  });

  @override
  State<EditShortcutScreen> createState() => _EditShortcutScreenState();
}

class _EditShortcutScreenState extends State<EditShortcutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late int _selectedCategoryId;
  late String _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shortcut?.name ?? '');
    _urlController = TextEditingController(text: widget.shortcut?.url ?? '');
    
    if (widget.shortcut != null) {
      _selectedCategoryId = widget.shortcut!.categoryId;
      _selectedCategoryName = widget.shortcut!.categoryName;
    } else {
      _selectedCategoryId = widget.categories.first.id!;
      _selectedCategoryName = widget.categories.first.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese una URL';
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'La URL debe comenzar con http:// o https://';
    }
    return null;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final shortcut = Shortcut(
        id: widget.shortcut?.id,
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        isDefault: widget.shortcut?.isDefault ?? false,
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
      );
      Navigator.pop(context, shortcut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.shortcut != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Logo FIFCO simplificado
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'FIF',
                          style: TextStyle(color: Color(0xFF1E3A8A)),
                        ),
                        TextSpan(
                          text: 'CO',
                          style: TextStyle(color: Color(0xFF0EA5E9)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E3A8A),
                          Color(0xFF7C3AED),
                          Color(0xFF0EA5E9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Center(
                      child: Text(
                        '®',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isEditing ? 'Editar Sistema' : 'Nuevo Sistema',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono y título
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit : Icons.add_link,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEditing ? 'Editar Sistema' : 'Agregar Nuevo Sistema',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing 
                          ? 'Modifica los detalles del sistema de supply chain'
                          : 'Agrega un nuevo sistema o herramienta de la cadena de suministro',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Campo Nombre
              Text(
                'Nombre del Sistema',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ej: SAP SCM, WMS System, TMS Platform...',
                  prefixIcon: const Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Ingrese un nombre para el sistema' 
                    : null,
              ),
              const SizedBox(height: 24),
              
              // Campo URL
              Text(
                'URL del Sistema',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://sistema.fifco.com',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: _validateUrl,
              ),
              const SizedBox(height: 24),
              
              // Campo Categoría
              Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: widget.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value!;
                      _selectedCategoryName = widget.categories
                          .firstWhere((c) => c.id == value)
                          .name;
                    });
                  },
                  validator: (value) => value == null 
                      ? 'Selecciona una categoría' 
                      : null,
                ),
              ),
              const SizedBox(height: 32),
              
              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Actualizar Sistema' : 'Crear Sistema'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              if (isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}