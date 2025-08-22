# API Reference - FIFCO Supply Chain Hub

## 📋 Índice

1. [DatabaseHelper](#databasehelper)
2. [Modelos de Datos](#modelos-de-datos)
3. [Pantallas](#pantallas)
4. [Widgets](#widgets)
5. [Constantes](#constantes)
6. [Ejemplos de Uso](#ejemplos-de-uso)

---

## DatabaseHelper

### Clase Principal
```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
}
```

### Inicialización
```dart
Future<Database> get database async {
  if (_database != null) return _database!;
  _database = await _initDatabase();
  return _database!;
}
```

### Métodos de Categorías

#### getAllCategories()
```dart
Future<List<Map<String, dynamic>>> getAllCategories() async
```
**Descripción**: Obtiene todas las categorías ordenadas alfabéticamente.

**Retorna**: Lista de mapas con datos de categorías.

**Ejemplo**:
```dart
final categories = await dbHelper.getAllCategories();
// Retorna: [{'id': 1, 'name': 'Sistemas Internos', 'created_at': '2024-08-XX'}]
```

#### insertCategory(String name)
```dart
Future<int> insertCategory(String name) async
```
**Descripción**: Inserta una nueva categoría.

**Parámetros**:
- `name` (String): Nombre de la categoría

**Retorna**: ID de la categoría insertada.

**Ejemplo**:
```dart
final categoryId = await dbHelper.insertCategory('Nueva Categoría');
```

#### updateCategory(int id, String name)
```dart
Future<int> updateCategory(int id, String name) async
```
**Descripción**: Actualiza el nombre de una categoría existente.

**Parámetros**:
- `id` (int): ID de la categoría
- `name` (String): Nuevo nombre

**Retorna**: Número de filas afectadas.

#### deleteCategory(int id)
```dart
Future<int> deleteCategory(int id) async
```
**Descripción**: Elimina una categoría (solo si está vacía).

**Parámetros**:
- `id` (int): ID de la categoría

**Retorna**: Número de filas afectadas.

#### isCategoryEmpty(int categoryId)
```dart
Future<bool> isCategoryEmpty(int categoryId) async
```
**Descripción**: Verifica si una categoría no tiene enlaces asociados.

**Parámetros**:
- `categoryId` (int): ID de la categoría

**Retorna**: `true` si está vacía, `false` si tiene enlaces.

### Métodos de Enlaces

#### getAllShortcuts()
```dart
Future<List<Map<String, dynamic>>> getAllShortcuts() async
```
**Descripción**: Obtiene todos los enlaces con información de categoría.

**Retorna**: Lista de mapas con datos completos de enlaces.

**Ejemplo**:
```dart
final shortcuts = await dbHelper.getAllShortcuts();
// Retorna: [{'id': 1, 'name': 'Incidencias', 'url': '...', 'category_name': 'Sistemas Internos'}]
```

#### getShortcutsByCategory(int categoryId)
```dart
Future<List<Map<String, dynamic>>> getShortcutsByCategory(int categoryId) async
```
**Descripción**: Obtiene enlaces filtrados por categoría.

**Parámetros**:
- `categoryId` (int): ID de la categoría

**Retorna**: Lista de enlaces de la categoría especificada.

#### insertShortcut(String name, String url, int categoryId, {bool isDefault = false})
```dart
Future<int> insertShortcut(String name, String url, int categoryId, {bool isDefault = false}) async
```
**Descripción**: Inserta un nuevo enlace.

**Parámetros**:
- `name` (String): Nombre del enlace
- `url` (String): URL del enlace
- `categoryId` (int): ID de la categoría
- `isDefault` (bool, opcional): Si es enlace predeterminado

**Retorna**: ID del enlace insertado.

#### updateShortcut(int id, String name, String url, int categoryId, {bool isDefault = false})
```dart
Future<int> updateShortcut(int id, String name, String url, int categoryId, {bool isDefault = false}) async
```
**Descripción**: Actualiza un enlace existente.

**Parámetros**:
- `id` (int): ID del enlace
- `name` (String): Nuevo nombre
- `url` (String): Nueva URL
- `categoryId` (int): Nueva categoría
- `isDefault` (bool, opcional): Si es predeterminado

**Retorna**: Número de filas afectadas.

#### deleteShortcut(int id)
```dart
Future<int> deleteShortcut(int id) async
```
**Descripción**: Elimina un enlace.

**Parámetros**:
- `id` (int): ID del enlace

**Retorna**: Número de filas afectadas.

#### setDefaultShortcut(int id)
```dart
Future<int> setDefaultShortcut(int id) async
```
**Descripción**: Establece un enlace como predeterminado.

**Parámetros**:
- `id` (int): ID del enlace

**Retorna**: Número de filas afectadas.

### Métodos de Sesión

#### saveSessionData(String key, String value, {bool isTemporary = true})
```dart
Future<void> saveSessionData(String key, String value, {bool isTemporary = true}) async
```
**Descripción**: Guarda datos de sesión temporales o permanentes.

**Parámetros**:
- `key` (String): Clave del dato
- `value` (String): Valor del dato
- `isTemporary` (bool, opcional): Si es temporal (se limpia automáticamente)

#### getSessionData(String key)
```dart
Future<String?> getSessionData(String key) async
```
**Descripción**: Obtiene datos de sesión por clave.

**Parámetros**:
- `key` (String): Clave del dato

**Retorna**: Valor del dato o `null` si no existe.

### Métodos de Limpieza

#### clearLoginData()
```dart
Future<void> clearLoginData() async
```
**Descripción**: Limpia datos de login y sesión temporales.

#### clearWebViewCache()
```dart
Future<void> clearWebViewCache() async
```
**Descripción**: Limpia cache del WebView.

#### cleanupTemporaryData()
```dart
Future<void> cleanupTemporaryData() async
```
**Descripción**: Limpia datos temporales preservando enlaces por defecto.

#### resetToDefaultShortcuts()
```dart
Future<void> resetToDefaultShortcuts() async
```
**Descripción**: Restablece todos los enlaces a los valores por defecto.

---

## Modelos de Datos

### Category Model
```dart
class Category {
  final int? id;
  final String name;
  final DateTime? createdAt;
  
  Category({
    this.id,
    required this.name,
    this.createdAt,
  });
  
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      createdAt: map['created_at'] != null 
        ? DateTime.parse(map['created_at']) 
        : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
```

### Shortcut Model
```dart
class Shortcut {
  final int? id;
  final String name;
  final String url;
  final int categoryId;
  final bool isDefault;
  final String categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  Shortcut({
    this.id,
    required this.name,
    required this.url,
    required this.categoryId,
    this.isDefault = false,
    required this.categoryName,
    this.createdAt,
    this.updatedAt,
  });
  
  factory Shortcut.fromMap(Map<String, dynamic> map) {
    return Shortcut(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      categoryId: map['category_id'],
      isDefault: map['is_default'] == 1,
      categoryName: map['category_name'],
      createdAt: map['created_at'] != null 
        ? DateTime.parse(map['created_at']) 
        : null,
      updatedAt: map['updated_at'] != null 
        ? DateTime.parse(map['updated_at']) 
        : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'category_id': categoryId,
      'is_default': isDefault ? 1 : 0,
      'category_name': categoryName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
```

---

## Pantallas

### HomeScreen
```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

**Propiedades**:
- `shortcuts`: Lista de enlaces
- `categories`: Lista de categorías
- `isAdminMode`: Estado del modo administrador
- `isLoading`: Estado de carga

**Métodos Principales**:
- `_loadData()`: Carga datos de la base de datos
- `_showAdminDialog()`: Muestra diálogo de login
- `_editShortcut(Shortcut?)`: Edita o crea enlace
- `_deleteShortcut(int, String)`: Elimina enlace
- `_setDefault(int)`: Establece enlace predeterminado

### EditShortcutScreen
```dart
class EditShortcutScreen extends StatefulWidget {
  final Shortcut? shortcut;
  final List<Category> categories;
  
  const EditShortcutScreen({
    Key? key,
    this.shortcut,
    required this.categories,
  }) : super(key: key);
}
```

**Propiedades**:
- `shortcut`: Enlace a editar (null para crear nuevo)
- `categories`: Lista de categorías disponibles

### WebViewScreen
```dart
class WebViewScreen extends StatefulWidget {
  final String url;
  
  const WebViewScreen({Key? key, required this.url}) : super(key: key);
}
```

**Propiedades**:
- `url`: URL a mostrar en el WebView

---

## Widgets

### ShortcutTile
```dart
class ShortcutTile extends StatelessWidget {
  final Shortcut shortcut;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  final VoidCallback onSetDefault;
  final bool isAdminMode;
  
  const ShortcutTile({
    Key? key,
    required this.shortcut,
    required this.onEdit,
    required this.onDelete,
    required this.onOpen,
    required this.onSetDefault,
    required this.isAdminMode,
  }) : super(key: key);
}
```

**Propiedades**:
- `shortcut`: Enlace a mostrar
- `onEdit`: Callback para editar
- `onDelete`: Callback para eliminar
- `onOpen`: Callback para abrir
- `onSetDefault`: Callback para establecer predeterminado
- `isAdminMode`: Si está en modo administrador

---

## Constantes

### Colores FIFCO
```dart
// Colores corporativos FIFCO
const Color FIFCO_BLUE_DARK = Color(0xFF1E3A8A);
const Color FIFCO_BLUE_LIGHT = Color(0xFF0EA5E9);
const Color FIFCO_PURPLE = Color(0xFF7C3AED);

// Colores de fondo
const Color FIFCO_SURFACE = Color(0xFFF8FAFC);
const Color FIFCO_BACKGROUND = Color(0xFFFFFFFF);
```

### Configuración
```dart
// Contraseña de administrador
const String ADMIN_PASSWORD = "admin123";

// Configuración de base de datos
const String DATABASE_NAME = "fifco_hub.db";
const int DATABASE_VERSION = 1;
```

### Enlaces por Defecto
```dart
const Map<String, String> DEFAULT_SHORTCUTS = {
  'Incidencias': 'https://forms.office.com/Pages/ResponsePage.aspx?id=Y6S5GQ0RP0KXWJzTBYcEaYDu70xkywhMslL9GXJ1eX9UN1VNMUlQNEdYN1pETVE1MzZWR1QzQ0tPTiQlQCN0PWcu',
  'Reportes Preventivos': 'https://forms.office.com/Pages/ResponsePage.aspx?id=Y6S5GQ0RP0KXWJzTBYcEaeUZyy766PJPm3R17RbagC9UM1hYVTlBWVpCMFk4OEdUTlZVVjRaSFZUSSQlQCN0PWcu',
  'Muestreo de Envase': 'https://forms.office.com/pages/responsepage.aspx?id=Y6S5GQ0RP0KXWJzTBYcEaUa6rTODswZBikoR1jmc1adUOElZWUVONEZOTEo0SkJFN1IyMTYyM1M2MC4u&origin=lprLink&route=shorturl',
  '10 Pasos': 'https://florida1.sharepoint.com/sites/Distribucinpas/_layouts/15/listforms.aspx?cid=NjJmMDI5NTctYzJlZi00YjIzLTgzYzgtNTVlZGM1NmU5ODA5&nav=MDQyNzFiN2UtOWI0ZC00YTFkLWFjZTItODAxODQ2YjU2ZjBk',
  'Lavado de Camiones': 'https://apps.powerapps.com/play/e/default-19b9a463-110d-423f-9758-9cd305870469/a/e930a865-c082-4ee5-8309-422f099ee24e?tenantId=19b9a463-110d-423f-9758-9cd305870469&hint=01fca6c4-a224-4cc1-99f8-200f0984968f&sourcetime=1718583516237&source=portal&skipMobileRedirect=1',
  'Actualizar OC Moderno': 'https://forms.office.com/pages/responsepage.aspx?id=Y6S5GQ0RP0KXWJzTBYcEafToAM31LeNLrDTTJ5DRcApUNTRXQVdONjVGV0pTUkJLSzlGTDRWSDRHSC4u',
};
```

---

## Ejemplos de Uso

### Inicializar DatabaseHelper
```dart
final dbHelper = DatabaseHelper();

// Inicializar base de datos
await dbHelper.database;
```

### Cargar Datos
```dart
// Cargar categorías
final categories = await dbHelper.getAllCategories();
final categoryList = categories.map((map) => Category.fromMap(map)).toList();

// Cargar enlaces
final shortcuts = await dbHelper.getAllShortcuts();
final shortcutList = shortcuts.map((map) => Shortcut.fromMap(map)).toList();
```

### Crear Nuevo Enlace
```dart
// Obtener ID de categoría
final categories = await dbHelper.getAllCategories();
final categoryId = categories.firstWhere((c) => c['name'] == 'Sistemas Internos')['id'];

// Crear enlace
final shortcutId = await dbHelper.insertShortcut(
  'Nuevo Sistema',
  'https://ejemplo.com',
  categoryId,
  isDefault: false,
);
```

### Editar Enlace
```dart
await dbHelper.updateShortcut(
  shortcutId,
  'Sistema Actualizado',
  'https://nuevo-ejemplo.com',
  categoryId,
  isDefault: true,
);
```

### Eliminar Enlace
```dart
await dbHelper.deleteShortcut(shortcutId);
```

### Gestión de Sesión
```dart
// Guardar sesión de administrador
await dbHelper.saveSessionData('admin_mode', 'true', isTemporary: true);

// Verificar sesión
final isAdmin = await dbHelper.getSessionData('admin_mode') == 'true';

// Limpiar sesión
await dbHelper.clearLoginData();
```

### Limpieza Automática
```dart
// Limpiar datos temporales
await dbHelper.cleanupTemporaryData();

// Restablecer enlaces por defecto
await dbHelper.resetToDefaultShortcuts();
```

### Obtener Estadísticas
```dart
final stats = await dbHelper.getStatistics();
print('Total enlaces: ${stats['total_shortcuts']}');
print('Total categorías: ${stats['total_categories']}');
print('Tiene predeterminado: ${stats['has_default']}');
```

### Manejo de Errores
```dart
try {
  await dbHelper.insertCategory('Nueva Categoría');
} catch (e) {
  if (e.toString().contains('UNIQUE constraint failed')) {
    print('La categoría ya existe');
  } else {
    print('Error: $e');
  }
}
```

### Validaciones
```dart
// Verificar si categoría está vacía antes de eliminar
final isEmpty = await dbHelper.isCategoryEmpty(categoryId);
if (isEmpty) {
  await dbHelper.deleteCategory(categoryId);
} else {
  print('No se puede eliminar categoría con enlaces');
}
```

---

## Patrones de Diseño

### Singleton Pattern
```dart
// DatabaseHelper implementa Singleton
final dbHelper1 = DatabaseHelper();
final dbHelper2 = DatabaseHelper();
print(dbHelper1 == dbHelper2); // true
```

### Factory Pattern
```dart
// Modelos usan Factory Pattern
final category = Category.fromMap({'id': 1, 'name': 'Test'});
final shortcut = Shortcut.fromMap({'id': 1, 'name': 'Test', 'url': '...'});
```

### Observer Pattern
```dart
// WidgetsBindingObserver para ciclo de vida
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Manejar cambios de estado
  }
}
```

---

## Mejores Prácticas

### Manejo de Base de Datos
```dart
// Siempre usar try-catch
try {
  await dbHelper.insertShortcut(name, url, categoryId);
} catch (e) {
  // Manejar error apropiadamente
}

// Cerrar conexión cuando sea necesario
await dbHelper.close();
```

### Gestión de Estado
```dart
// Usar setState para actualizar UI
setState(() {
  shortcuts = newShortcuts;
  isLoading = false;
});
```

### Validación de Datos
```dart
// Validar antes de insertar
if (name.trim().isEmpty) {
  throw Exception('El nombre no puede estar vacío');
}

if (!Uri.tryParse(url)?.hasAbsolutePath ?? false) {
  throw Exception('URL inválida');
}
```

---

## Troubleshooting

### Errores Comunes

#### Error de Base de Datos
```dart
// Verificar que la base de datos esté inicializada
if (dbHelper.database == null) {
  await dbHelper.database; // Inicializar
}
```

#### Error de Sesión
```dart
// Limpiar datos de sesión corruptos
await dbHelper.clearLoginData();
```

#### Error de Memoria
```dart
// Ejecutar limpieza manual
await dbHelper.cleanupTemporaryData();
```

---

**Versión**: 1.0.0  
**Última Actualización**: Agosto 2024  
**Compatibilidad**: Flutter 3.0+  
**Documentación**: [DOCUMENTACION.md](./DOCUMENTACION.md)
