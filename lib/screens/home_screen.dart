import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shortcut.dart';
import '../models/category.dart';
import '../database/database_helper.dart';
import '../screens/webview_screen.dart';
import '../screens/edit_shortcut_screen.dart';
import '../widgets/shortcut_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Shortcut> shortcuts = [];
  List<Category> categories = [];
  bool isAdminMode = false;
  final String adminPassword = "admin123";
  late TabController _tabController;
  bool isLoading = true;
  
  // Variables para auto-logout
  Timer? _adminSessionTimer;
  static const Duration _adminSessionTimeout = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkAdminSession();
  }

  Future<void> _checkAdminSession() async {
    try {
      final adminSession = await _dbHelper.getSessionData('admin_mode');
      if (adminSession == 'true') {
        setState(() {
          isAdminMode = true;
        });
        // Iniciar timer de auto-logout
        _startAdminSessionTimer();
      }
    } catch (e) {
      debugPrint('Error checking admin session: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminSessionTimer?.cancel();
    super.dispose();
  }

  // Método para iniciar el timer de auto-logout
  void _startAdminSessionTimer() {
    _adminSessionTimer?.cancel();
    _adminSessionTimer = Timer(_adminSessionTimeout, () {
      if (mounted && isAdminMode) {
        _autoLogout();
      }
    });
  }

  // Método para reiniciar el timer (llamado en cada acción administrativa)
  void _resetAdminSessionTimer() {
    if (isAdminMode) {
      _startAdminSessionTimer();
    }
  }

  // Método para auto-logout
  void _autoLogout() {
    setState(() {
      isAdminMode = false;
    });
    
    // Limpiar sesión de administrador
    _dbHelper.saveSessionData('admin_mode', 'false', isTemporary: true);
    
    // Mostrar notificación
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Sesión de administrador cerrada por inactividad'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Cargar categorías
      final categoriesData = await _dbHelper.getAllCategories();
      categories = categoriesData.map((map) => Category.fromMap(map)).toList();

      // Cargar shortcuts
      final shortcutsData = await _dbHelper.getAllShortcuts();
      shortcuts = shortcutsData.map((map) => Shortcut.fromMap(map)).toList();

      // Inicializar TabController
      _tabController = TabController(length: categories.length + 1, vsync: this);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método eliminado por no ser utilizado

  List<Shortcut> _getShortcutsByCategory(int? categoryId) {
    if (categoryId == null) {
      return shortcuts;
    }
    return shortcuts.where((shortcut) => shortcut.categoryId == categoryId).toList();
  }

  void _showAdminDialog() {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acceso de Administrador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa la clave de administrador para poder editar los accesos directos:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Clave de Administrador',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigatorContext = context;
              if (passwordController.text == adminPassword) {
                setState(() {
                  isAdminMode = true;
                });
                
                // Iniciar timer de auto-logout
                _startAdminSessionTimer();
                
                // Guardar sesión de administrador como temporal
                await _dbHelper.saveSessionData('admin_mode', 'true', isTemporary: true);
                
                if (mounted) {
                  Navigator.pop(navigatorContext);
                  ScaffoldMessenger.of(navigatorContext).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Modo administrador activado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(navigatorContext).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Clave incorrecta'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Acceder'),
          ),
        ],
      ),
    );
  }

  Future<void> _setDefault(int shortcutId) async {
    if (!isAdminMode) {
      _showAdminDialog();
      return;
    }
    
    // Reiniciar timer de sesión administrativa
    _resetAdminSessionTimer();
    
    final navigatorContext = context;
    try {
      await _dbHelper.setDefaultShortcut(shortcutId);
      await _loadData(); // Recargar datos
      if (mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(
            content: Text('✅ Sistema predeterminado actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editShortcut(Shortcut? shortcut) async {
    if (!isAdminMode) {
      _showAdminDialog();
      return;
    }
    
    // Reiniciar timer de sesión administrativa
    _resetAdminSessionTimer();
    
    final navigatorContext = context;
    final result = await Navigator.push(
      navigatorContext,
      MaterialPageRoute(
        builder: (context) => EditShortcutScreen(
          shortcut: shortcut,
          categories: categories,
        ),
      ),
    );

    if (result != null) {
      try {
        if (shortcut != null) {
          // Actualizar shortcut existente
          await _dbHelper.updateShortcut(
            shortcut.id!,
            result.name,
            result.url,
            result.categoryId,
            isDefault: result.isDefault,
          );
        } else {
          // Crear nuevo shortcut
          await _dbHelper.insertShortcut(
            result.name,
            result.url,
            result.categoryId,
            isDefault: result.isDefault,
          );
        }
        
        await _loadData(); // Recargar datos
        if (mounted) {
          ScaffoldMessenger.of(navigatorContext).showSnackBar(
            SnackBar(
              content: Text(shortcut != null ? '✅ Sistema actualizado' : '✅ Sistema creado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(navigatorContext).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteShortcut(int shortcutId, String shortcutName) async {
    if (!isAdminMode) {
      _showAdminDialog();
      return;
    }
    
    // Reiniciar timer de sesión administrativa
    _resetAdminSessionTimer();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Sistema'),
        content: Text('¿Estás seguro de que quieres eliminar "$shortcutName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dialogContext = context;
              try {
                await _dbHelper.deleteShortcut(shortcutId);
                await _loadData(); // Recargar datos
                Navigator.pop(dialogContext);
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Sistema eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _openWebView(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url),
      ),
    );
  }

  void _showAdminMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Expanded(
              child: const Text('Panel de Administrador'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecciona la acción que deseas realizar:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
            
            // Gestión de Sistemas
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_business, color: Colors.white, size: 20),
              ),
              title: const Text('Gestión de Sistemas'),
              subtitle: const Text('Agregar, editar o eliminar sistemas'),
              onTap: () {
                Navigator.pop(context);
                _showSystemsMenu();
              },
            ),
            
            // Gestión de Categorías
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.category, color: Colors.white, size: 20),
              ),
              title: const Text('Gestión de Categorías'),
              subtitle: const Text('Crear, editar o eliminar categorías'),
              onTap: () {
                Navigator.pop(context);
                _manageCategories();
              },
            ),
            
            // Restablecer Enlaces por Defecto
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restore, color: Colors.white, size: 20),
              ),
              title: const Text('Restablecer Enlaces por Defecto'),
              subtitle: const Text('Restaurar todos los enlaces originales'),
              onTap: () {
                Navigator.pop(context);
                _resetToDefaultShortcuts();
              },
            ),
            
            const Divider(),
            
            // Salir del modo administrador
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: Colors.orange.shade700, size: 20),
              ),
              title: const Text('Salir del Modo Administrador'),
              subtitle: const Text('Desactivar privilegios de administrador'),
              onTap: () {
                Navigator.pop(context);
                _logoutAdmin();
              },
            ),
          ],
        ),
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showSystemsMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_business, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Expanded(
              child: const Text('Gestión de Sistemas'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Qué acción deseas realizar?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // Agregar nuevo sistema
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              title: const Text('Agregar Nuevo Sistema'),
              subtitle: const Text('Crear un nuevo sistema de supply chain'),
              onTap: () {
                Navigator.pop(context);
                _editShortcut(null);
              },
            ),
            
            // Ver todos los sistemas
            ListTile(
              title: const Text('Ver Todos los Sistemas'),
              subtitle: Text('${shortcuts.length} sistemas disponibles'),
              onTap: () {
                Navigator.pop(context);
                _showAllSystems();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showShortcutDetails(Shortcut shortcut) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                shortcut.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Categoría', shortcut.categoryName, Icons.category),
            const SizedBox(height: 12),
            _buildDetailRow('URL', shortcut.url, Icons.link),
            if (shortcut.isDefault) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Sistema Predeterminado',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
                      ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openWebView(shortcut.url);
              },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAllSystems() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Todos los Sistemas'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total: ${shortcuts.length} sistemas',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 16),
              ...shortcuts.map((shortcut) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  child: ListTile(
                    title: Text(
                      shortcut.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoría: ${shortcut.categoryName}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        if (shortcut.isDefault) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Sistema Predeterminado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            Navigator.pop(context);
                            _showShortcutDetails(shortcut);
                            break;
                          case 'edit':
                            Navigator.pop(context);
                            _editShortcut(shortcut);
                            break;
                          case 'delete':
                            Navigator.pop(context);
                            _deleteShortcut(shortcut.id!, shortcut.name);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 18),
                              SizedBox(width: 8),
                              Text('Ver detalles'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logoutAdmin() async {
    // Cancelar timer de auto-logout
    _adminSessionTimer?.cancel();
    
    setState(() {
      isAdminMode = false;
    });
    
    // Limpiar sesión de administrador
    await _dbHelper.saveSessionData('admin_mode', 'false', isTemporary: true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Modo administrador desactivado'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _closeApplication() async {
    // Mostrar diálogo de confirmación
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Cerrar Aplicación'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar la aplicación?\n\n'
          'Se limpiarán todas las credenciales y datos de sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (shouldClose == true) {
      try {
        // Limpiar todos los datos de sesión
        await _dbHelper.clearAllSessionData();
        
        // Limpiar datos de autenticación de portales
        await _dbHelper.clearPortalAuthenticationData();
        
        // Limpiar todos los datos de navegación
        await _dbHelper.clearAllNavigationData();
        
        // Cancelar timer de admin si está activo
        _adminSessionTimer?.cancel();
        
        // Mostrar mensaje de confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔒 Aplicación cerrada - Credenciales limpiadas'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Cerrar la aplicación después de un breve delay
        Future.delayed(const Duration(seconds: 2), () {
          SystemNavigator.pop();
        });
        
      } catch (e) {
        debugPrint('❌ Error cerrando aplicación: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _resetToDefaultShortcuts() async {
    // Reiniciar timer de sesión administrativa
    _resetAdminSessionTimer();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Enlaces por Defecto'),
        content: const Text(
          '¿Estás seguro de que quieres restablecer todos los enlaces a los valores por defecto?\n\n'
          'Esta acción eliminará todos los enlaces personalizados y restaurará los enlaces originales de FIFCO.\n\n'
          '⚠️ Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final dialogContext = context;
              try {
                await _dbHelper.resetToDefaultShortcuts();
                await _loadData(); // Recargar datos
                Navigator.pop(dialogContext);
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Enlaces por defecto restablecidos'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  Future<void> _manageCategories() async {
    // Reiniciar timer de sesión administrativa
    _resetAdminSessionTimer();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestionar Categorías'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Categorías actuales:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 16),
              ...categories.map((category) {
                final systemCount = shortcuts.where((s) => s.categoryId == category.id).length;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.category, color: Color(0xFF1E3A8A)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$systemCount ${systemCount == 1 ? 'sistema' : 'sistemas'}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _editCategory(category),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: const Size(0, 32),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: systemCount > 0 
                                ? null 
                                : () => _deleteCategory(category),
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Eliminar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: systemCount > 0 ? Colors.grey : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: const Size(0, 32),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Categoría'),
              ),
            ],
          ),
        ),
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory() async {
    // Reiniciar timer de sesión administrativa
    _resetAdminSessionTimer();
    
    final categoryController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el nombre de la nueva categoría:'),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCategory = categoryController.text.trim();
              if (newCategory.isNotEmpty) {
                try {
                  await _dbHelper.insertCategory(newCategory);
                  await _loadData(); // Recargar datos
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Categoría "$newCategory" agregada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editCategory(Category category) async {
    // Reiniciar timer de sesión administrativa
    _resetAdminSessionTimer();
    
    final categoryController = TextEditingController(text: category.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Modifica el nombre de la categoría:'),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCategory = categoryController.text.trim();
              if (newCategory.isNotEmpty && newCategory != category.name) {
                try {
                  await _dbHelper.updateCategory(category.id!, newCategory);
                  await _loadData(); // Recargar datos
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Categoría actualizada a "$newCategory"'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    // Reiniciar timer de sesión administrativa
    _resetAdminSessionTimer();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text('¿Estás seguro de que quieres eliminar la categoría "${category.name}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _dbHelper.deleteCategory(category.id!);
                await _loadData(); // Recargar datos
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Categoría "${category.name}" eliminada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
                  'Supply Chain Hub',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos...'),
            ],
          ),
        ),
      );
    }

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
              child: const Text(
                'Supply Chain Hub',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Todos'),
            ...categories.map((category) => Tab(text: category.name)),
          ],
        ),
        actions: [
          if (isAdminMode)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: _showAdminMenu,
              tooltip: 'Menú de administrador',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _closeApplication,
            tooltip: 'Cerrar aplicación y limpiar credenciales',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
                               onPressed: () {
                     showDialog(
                       context: context,
                       builder: (context) => AlertDialog(
                         title: const Text('Acerca de'),
                         content: SizedBox(
                           width: double.maxFinite,
                           height: MediaQuery.of(context).size.height * 0.6,
                           child: SingleChildScrollView(
                             child: Column(
                               mainAxisSize: MainAxisSize.min,
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                                                   const Text(
                                    'FIFCO Hub - Portal de Supply Chain\n\n'
                                    'Esta aplicación centraliza todos los accesos y herramientas de la cadena de suministro de FIFCO:\n\n'
                                    '🔒 **Modo Administrador:**\n'
                                    'Para editar, agregar o eliminar sistemas y categorías, necesitas activar el modo administrador.\n\n'
                                    '⚙️ **Panel de Administrador:**\n'
                                    '• Usa el botón de administrador para acceder al panel completo\n'
                                    '• **Gestión de Sistemas:** Agregar, editar o eliminar sistemas\n'
                                    '• **Gestión de Categorías:** Crear, editar o eliminar categorías\n'
                                    '• Solo se pueden eliminar categorías vacías\n'
                                    '• Al editar una categoría, se actualizan todos los sistemas asociados\n\n'
                                    '🧹 **Limpieza Automática:**\n'
                                    '• Los datos de login se limpian automáticamente al cerrar la aplicación\n'
                                    '• El cache se limpia para optimizar el rendimiento\n'
                                    '• Los enlaces por defecto se preservan siempre\n'
                                    '• La seguridad se mantiene entre sesiones\n\n'
                                    '💾 **Base de Datos SQLite:**\n'
                                    'Los datos se almacenan localmente y persisten entre sesiones.',
                                  ),
                                 if (!isAdminMode) ...[
                                   const SizedBox(height: 16),
                                   Container(
                                     padding: const EdgeInsets.all(12),
                                     decoration: BoxDecoration(
                                       color: Colors.orange.shade100,
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(color: Colors.orange.shade300),
                                     ),
                                     child: Row(
                                       children: [
                                         Icon(Icons.security, color: Colors.orange.shade700),
                                         const SizedBox(width: 8),
                                         Expanded(
                                           child: Text(
                                             'Modo administrador desactivado',
                                             style: TextStyle(
                                               color: Colors.orange.shade700,
                                               fontWeight: FontWeight.w500,
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ],
                               ],
                             ),
                           ),
                         ),
                         actions: [
                           ElevatedButton(
                             onPressed: () => Navigator.pop(context),
                             child: const Text('Entendido'),
                           ),
                         ],
                       ),
                     );
                   },
            tooltip: 'Información',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab "Todos"
          _buildShortcutsList(null),
          // Tabs de categorías
                      ...categories.map((category) => _buildShortcutsList(category.id)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editShortcut(null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Sistema'),
        backgroundColor: const Color(0xFF0EA5E9),
        foregroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }

  Widget _buildShortcutsList(int? categoryId) {
    final categoryShortcuts = _getShortcutsByCategory(categoryId);
    final categoryName = categoryId == null ? 'Todos' : 
      categories.firstWhere((c) => c.id == categoryId).name;
    
    return categoryShortcuts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay sistemas en "$categoryName"',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega nuevos sistemas de supply chain a esta categoría',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isAdminMode) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E3A8A),
                          Color(0xFF0EA5E9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E3A8A)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.security, color: Colors.white),
                        const SizedBox(height: 8),
                        const Text(
                          'Modo Administrador Requerido',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Necesitas activar el modo administrador para agregar sistemas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${categoryShortcuts.length} ${categoryShortcuts.length == 1 ? 'sistema' : 'sistemas'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (!isAdminMode) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E3A8A),
                          Color(0xFF0EA5E9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E3A8A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Modo administrador desactivado - Solo lectura',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Indicador de scroll cuando hay muchos elementos
                if (categoryShortcuts.length > 8)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swipe_up, color: Colors.blue.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Desliza para ver más sistemas (${categoryShortcuts.length} total)',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categoryShortcuts.length,
                    itemBuilder: (context, index) {
                      final shortcut = categoryShortcuts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ShortcutTile(
                          shortcut: shortcut,
                          onEdit: () => _editShortcut(shortcut),
                          onDelete: () => _deleteShortcut(shortcut.id!, shortcut.name),
                          onOpen: () => _openWebView(shortcut.url),
                          onSetDefault: () => _setDefault(shortcut.id!),
                          isAdminMode: isAdminMode,
                        ),
                      );
                    },
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                  ),
                ),
              ],
            ),
          );
  }
}