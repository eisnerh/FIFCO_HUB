import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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