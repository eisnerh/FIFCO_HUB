import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DatabaseHelper _dbHelper = DatabaseHelper();

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
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused) {
      // La aplicación se pausa (va a segundo plano)
      _cleanupOnAppPause();
    } else if (state == AppLifecycleState.detached) {
      // La aplicación se está cerrando completamente
      _cleanupOnAppClose();
    }
  }

  Future<void> _cleanupOnAppPause() async {
    try {
      // Limpiar datos temporales pero mantener enlaces por defecto
      await _dbHelper.cleanupTemporaryData();
      
      print('⏸️ Limpieza de datos temporales al pausar la aplicación');
    } catch (e) {
      print('❌ Error durante la limpieza al pausar: $e');
    }
  }

  Future<void> _cleanupOnAppClose() async {
    try {
      // Limpiar datos de login (modo administrador)
      await _dbHelper.clearLoginData();
      
      // Limpiar cache de WebView
      await _dbHelper.clearWebViewCache();
      
      print('🧹 Limpieza de datos completada al cerrar la aplicación');
    } catch (e) {
      print('❌ Error durante la limpieza: $e');
    }
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
                 surface: const Color(0xFFF8FAFC), // Gris muy claro
                 background: const Color(0xFFFFFFFF), // Blanco
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