import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // DatabaseHelper para la política de seguridad
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isAppInBackground = false;

  // Política de Seguridad de la Empresa:
  // - La limpieza de credenciales se maneja automáticamente al salir de la app
  // - Se preservan los accesos directos almacenados en la base de datos
  // - Los usuarios deben volver a autenticarse en los portales de la empresa
  // - Los datos de navegación se limpian al cerrar la aplicación

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // La aplicación está en segundo plano
      _isAppInBackground = true;
      _clearSessionData();
    } else if (state == AppLifecycleState.resumed && _isAppInBackground) {
      // La aplicación vuelve a primer plano después de estar en segundo plano
      _isAppInBackground = false;
      // Mostrar diálogo de sesión expirada
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionExpiredDialog();
      });
    }
  }

  // Método para limpiar datos de sesión
  Future<void> _clearSessionData() async {
    try {
      // Guardar estado de sesión como cerrada
      await _dbHelper.saveSessionData('session_active', 'false', isTemporary: true);
      await _dbHelper.saveSessionData('admin_mode', 'false', isTemporary: true);
      debugPrint('🔒 Datos de sesión limpiados al salir de la aplicación');
    } catch (e) {
      debugPrint('❌ Error al limpiar datos de sesión: $e');
    }
  }

  // Mostrar diálogo de sesión expirada
  void _showSessionExpiredDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: const Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            const Text('Sesión cerrada'),
          ],
        ),
        content: const Text(
          'Por seguridad, tu sesión ha sido cerrada al salir de la aplicación. '
          'Los datos de navegación han sido eliminados.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
         return MaterialApp(
       title: 'FIFCO Supply Chain Hub',
                   theme: ThemeData(
               useMaterial3: true,
               colorScheme: ColorScheme.fromSeed(
                 seedColor: const Color(0xFF1E3A8A), // Azul oscuro FIFCO
                 brightness: Brightness.light,
                 primary: const Color(0xFF1E3A8A), // Azul oscuro FIFCO (FIF)
                 secondary: const Color(0xFF0EA5E9), // Azul claro FIFCO (CO)
                 tertiary: const Color(0xFF7C3AED), // Púrpura medio FIFCO (elemento gráfico)
                 surface: const Color(0xFFFFFFFF), // Blanco (reemplaza background)
                 onPrimary: Colors.white,
                 onSecondary: Colors.white,
                 onTertiary: Colors.white,
               ),
                       appBarTheme: const AppBarTheme(
                 elevation: 0,
                 centerTitle: false,
                 backgroundColor: Color(0xFF1E3A8A), // Azul oscuro FIFCO
                 foregroundColor: Colors.white,
                 titleTextStyle: TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.w600,
                   color: Colors.white,
                 ),
               ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color(0xFFFFFFFF),
        ),
                       elevatedButtonTheme: ElevatedButtonThemeData(
                 style: ElevatedButton.styleFrom(
                   elevation: 2,
                   backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro FIFCO
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(8),
                   ),
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                 ),
               ),
                       inputDecorationTheme: InputDecorationTheme(
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8),
                   borderSide: const BorderSide(color: Color(0xFF1E3A8A)), // Azul oscuro FIFCO
                 ),
                 focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8),
                   borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2), // Azul claro FIFCO
                 ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC), // Gris muy claro
        ),
                       floatingActionButtonTheme: const FloatingActionButtonThemeData(
                 backgroundColor: Color(0xFF0EA5E9), // Azul claro FIFCO
                 foregroundColor: Colors.white,
                 elevation: 4,
               ),
                       tabBarTheme: const TabBarThemeData(
                 labelColor: Colors.white,
                 unselectedLabelColor: Color(0xFFCBD5E1),
                 indicatorColor: Color(0xFF0EA5E9), // Azul claro FIFCO
               ),
                       chipTheme: const ChipThemeData(
                 backgroundColor: Color(0xFFE0F2FE), // Azul muy claro
                 selectedColor: Color(0xFF0EA5E9), // Azul claro FIFCO
                 labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Azul oscuro FIFCO
               ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}