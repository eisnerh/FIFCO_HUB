# Documentación Técnica - FIFCO Supply Chain Hub

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Base de Datos](#base-de-datos)
4. [Funcionalidades Principales](#funcionalidades-principales)
5. [Sistema de Limpieza Automática](#sistema-de-limpieza-automática)
6. [API y Métodos](#api-y-métodos)
7. [Configuración y Despliegue](#configuración-y-despliegue)
8. [Troubleshooting](#troubleshooting)

## 🎯 Descripción General

**FIFCO Supply Chain Hub** es una aplicación móvil desarrollada en Flutter que centraliza todos los accesos y herramientas de la cadena de suministro de FIFCO. La aplicación proporciona una interfaz unificada para acceder a sistemas internos, formularios y aplicaciones web de la empresa.

### Características Principales
- ✅ Centralización de enlaces de sistemas FIFCO
- ✅ Categorización inteligente de herramientas
- ✅ Modo administrador con gestión completa
- ✅ Enlaces por defecto preconfigurados
- ✅ Limpieza automática de datos de sesión
- ✅ **Navegador web en modo incógnito**
- ✅ **Advertencias de seguridad para conexiones HTTP**
- ✅ Interfaz Material Design 3
- ✅ Base de datos SQLite local

## 🏗️ Arquitectura del Sistema

### Estructura del Proyecto
```
lib/
├── main.dart                    # Punto de entrada y ciclo de vida
├── database/
│   └── database_helper.dart     # Gestión de base de datos SQLite
├── models/
│   ├── category.dart           # Modelo de categoría
│   └── shortcut.dart           # Modelo de enlace directo
├── screens/
│   ├── home_screen.dart        # Pantalla principal con tabs
│   ├── edit_shortcut_screen.dart # Editor de enlaces
│   └── webview_screen.dart     # Visualizador web integrado
└── widgets/
    └── shortcut_tile.dart      # Widget de tarjeta de enlace
```

### Patrones de Diseño Utilizados
- **Singleton Pattern**: DatabaseHelper
- **Observer Pattern**: WidgetsBindingObserver para ciclo de vida
- **Factory Pattern**: Modelos de datos
- **Repository Pattern**: Acceso a datos

## 🗄️ Base de Datos

### Esquema de Base de Datos

#### Tabla: `categories`
```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Tabla: `shortcuts`
```sql
CREATE TABLE shortcuts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  url TEXT NOT NULL,
  category_id INTEGER NOT NULL,
  is_default BOOLEAN DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
);
```

#### Tabla: `session_data`
```sql
CREATE TABLE session_data (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT UNIQUE NOT NULL,
  value TEXT,
  is_temporary BOOLEAN DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Datos por Defecto

#### Categorías Predefinidas
- Gestión de Inventarios
- Logística
- Almacén
- Transporte
- Sistemas Internos
- Proveedores
- Calidad

#### Enlaces por Defecto
| Nombre | URL | Categoría |
|--------|-----|-----------|
| Incidencias | forms.office.com/... | Sistemas Internos |
| Reportes Preventivos | forms.office.com/... | Sistemas Internos |
| Muestreo de Envase | forms.office.com/... | Calidad |
| 10 Pasos | florida1.sharepoint.com/... | Sistemas Internos |
| Lavado de Camiones | apps.powerapps.com/... | Transporte |
| Actualizar OC Moderno | forms.office.com/... | Sistemas Internos |

## ⚙️ Funcionalidades Principales

### 1. Gestión de Enlaces
- **Crear**: Agregar nuevos enlaces con nombre, URL y categoría
- **Editar**: Modificar enlaces existentes
- **Eliminar**: Remover enlaces no deseados
- **Establecer Predeterminado**: Marcar un enlace como favorito

### 2. Gestión de Categorías
- **Crear**: Agregar nuevas categorías
- **Editar**: Modificar nombres de categorías
- **Eliminar**: Solo categorías vacías (integridad referencial)

### 3. Modo Administrador
- **Contraseña**: `admin123`
- **Funciones**: Gestión completa de enlaces y categorías
- **Sesión Temporal**: Se limpia automáticamente al cerrar

### 4. Interfaz de Usuario
- **Tabs Dinámicos**: Una pestaña por categoría + "Todos"
- **Material Design 3**: Colores corporativos FIFCO
- **Responsive**: Adaptable a diferentes tamaños de pantalla

## 🧹 Sistema de Limpieza Automática

### Ciclo de Vida de la Aplicación

#### Estados del Ciclo de Vida
1. **resumed**: Aplicación activa y visible
2. **inactive**: Aplicación en transición
3. **paused**: Aplicación en segundo plano
4. **detached**: Aplicación cerrada completamente

#### Acciones de Limpieza

##### Al Pausar (paused)
```dart
Future<void> _cleanupOnAppPause() async {
  await _dbHelper.cleanupTemporaryData();
}
```
- Limpia datos temporales de sesión
- Preserva enlaces por defecto
- Optimiza memoria

##### Al Cerrar (detached)
```dart
Future<void> _cleanupOnAppClose() async {
  await _dbHelper.clearLoginData();
  await _dbHelper.clearWebViewCache();
}
```
- Limpia datos de login
- Limpia cache de WebView
- Elimina sesiones temporales

### Implementación de Limpieza

#### Método: `cleanupTemporaryData()`
```dart
Future<void> cleanupTemporaryData() async {
  final db = await database;
  
  // Limpiar datos temporales de sesión
  await db.delete('session_data', where: 'is_temporary = 1');
  
  // Asegurar que los enlaces por defecto estén presentes
  final shortcuts = await db.query('shortcuts');
  if (shortcuts.isEmpty) {
    await _insertDefaultShortcuts(db);
  }
}
```

#### Método: `clearLoginData()`
```dart
Future<void> clearLoginData() async {
  final db = await database;
  
  // Limpiar datos de sesión temporales
  await db.delete('session_data', where: 'is_temporary = 1');
}
```

## 🔌 API y Métodos

### DatabaseHelper - Métodos Principales

#### Gestión de Categorías
```dart
// Obtener todas las categorías
Future<List<Map<String, dynamic>>> getAllCategories()

// Insertar nueva categoría
Future<int> insertCategory(String name)

// Actualizar categoría
Future<int> updateCategory(int id, String name)

// Eliminar categoría
Future<int> deleteCategory(int id)

// Verificar si categoría está vacía
Future<bool> isCategoryEmpty(int categoryId)
```

#### Gestión de Enlaces
```dart
// Obtener todos los enlaces
Future<List<Map<String, dynamic>>> getAllShortcuts()

// Obtener enlaces por categoría
Future<List<Map<String, dynamic>>> getShortcutsByCategory(int categoryId)

// Insertar nuevo enlace
Future<int> insertShortcut(String name, String url, int categoryId, {bool isDefault = false})

// Actualizar enlace
Future<int> updateShortcut(int id, String name, String url, int categoryId, {bool isDefault = false})

// Eliminar enlace
Future<int> deleteShortcut(int id)

// Establecer enlace predeterminado
Future<int> setDefaultShortcut(int id)
```

#### Gestión de Sesión
```dart
// Guardar datos de sesión
Future<void> saveSessionData(String key, String value, {bool isTemporary = true})

// Obtener datos de sesión
Future<String?> getSessionData(String key)

// Limpiar datos de login
Future<void> clearLoginData()

// Limpiar cache de WebView
Future<void> clearWebViewCache()

// Limpiar datos temporales
Future<void> cleanupTemporaryData()

### WebView - Navegador Integrado

#### Características del WebView
- **Modo Incógnito Automático**: Navegación privada por defecto
- **Advertencias de Seguridad**: Alertas para conexiones HTTP no seguras
- **Limpieza Automática**: Eliminación automática de datos al cerrar
- **Zoom Deshabilitado**: Mejor experiencia de navegación
- **Barra de Progreso**: Indicador visual de carga

#### Configuración de Seguridad
```dart
// Prevenir navegación a sitios no seguros
onNavigationRequest: (NavigationRequest request) {
  if (request.url.startsWith('http://') && !request.url.startsWith('https://')) {
    _showSecurityWarning(request.url);
    return NavigationDecision.prevent;
  }
  return NavigationDecision.navigate;
}
```

#### Limpieza de Datos
```dart
// Limpiar datos de formularios y sesión
await controller.runJavaScript('''
  // Limpiar formularios
  var forms = document.getElementsByTagName('form');
  for (var i = 0; i < forms.length; i++) {
    forms[i].reset();
  }
  // Limpiar campos de entrada
  var inputs = document.querySelectorAll('input, textarea, select');
  for (var i = 0; i < inputs.length; i++) {
    inputs[i].value = '';
    inputs[i].checked = false;
  }
  // Limpiar sessionStorage
  if (window.sessionStorage) {
    sessionStorage.clear();
  }
''');
```
```

### Modelos de Datos

#### Category Model
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
}
```

#### Shortcut Model
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
}
```

## 🚀 Configuración y Despliegue

### Requisitos del Sistema
- **Flutter**: 3.0.0 o superior
- **Dart**: 2.17.0 o superior
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.2
  path: ^1.8.3
  webview_flutter: ^4.4.7
  url_launcher: ^6.2.5
  shared_preferences: ^2.2.2
  logger: ^2.0.2+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

### Pasos de Instalación

#### 1. Clonar Repositorio
```bash
git clone <repository-url>
cd fifco-supply-chain-hub
```

#### 2. Instalar Dependencias
```bash
flutter pub get
```

#### 3. Configurar Base de Datos
La base de datos se crea automáticamente en la primera ejecución con:
- Categorías por defecto
- Enlaces por defecto
- Tabla de sesión

#### 4. Compilar APK
```bash
# Versión de desarrollo
flutter build apk --debug

# Versión de producción
flutter build apk --release
```

### Configuración de Entorno

#### Variables de Entorno
```dart
// Configuración de colores FIFCO
const Color FIFCO_BLUE_DARK = Color(0xFF1E3A8A);
const Color FIFCO_BLUE_LIGHT = Color(0xFF0EA5E9);
const Color FIFCO_PURPLE = Color(0xFF7C3AED);

// Configuración de administrador
const String ADMIN_PASSWORD = "admin123";

// Configuración de base de datos
const String DATABASE_NAME = "fifco_hub.db";
const int DATABASE_VERSION = 1;
```

## 🔧 Troubleshooting

### Problemas Comunes

#### 1. Error de Base de Datos
**Síntoma**: Error al abrir la aplicación
**Solución**: 
```bash
# Limpiar cache de Flutter
flutter clean
flutter pub get

# Reinstalar aplicación
flutter install
```

#### 2. Enlaces por Defecto No Aparecen
**Síntoma**: Aplicación sin enlaces iniciales
**Solución**:
```dart
// Verificar en DatabaseHelper
await _insertDefaultShortcuts(db);
```

#### 3. Modo Administrador No Funciona
**Síntoma**: No se puede acceder al panel de administrador
**Solución**:
- Verificar contraseña: `admin123`
- Revisar logs de sesión
- Limpiar datos de aplicación

#### 4. Problemas de Rendimiento
**Síntoma**: Aplicación lenta o con lag
**Solución**:
- Verificar limpieza automática
- Revisar tamaño de base de datos
- Optimizar consultas SQL

### Logs y Debugging

#### Habilitar Logs Detallados
```dart
// En main.dart
void main() {
  // Habilitar logs de limpieza
  debugPrint('🧹 Iniciando aplicación FIFCO Hub');
  runApp(const MyApp());
}
```

#### Logs de Limpieza Automática
```
⏸️ Limpieza de datos temporales al pausar la aplicación
🧹 Datos temporales limpiados
✅ Limpieza completada - Enlaces por defecto preservados
🔒 Datos de login y sesión limpiados
🗑️ Cache de WebView limpiado
```

### Mantenimiento

#### Limpieza Manual de Base de Datos
```dart
// Método para limpieza completa
Future<void> performFullCleanup() async {
  await clearLoginData();
  await clearWebViewCache();
  await cleanupTemporaryData();
  await resetToDefaultShortcuts();
}
```

#### Backup de Datos
```dart
// Exportar configuración actual
Future<Map<String, dynamic>> exportConfiguration() async {
  final categories = await getAllCategories();
  final shortcuts = await getAllShortcuts();
  
  return {
    'categories': categories,
    'shortcuts': shortcuts,
    'exported_at': DateTime.now().toIso8601String(),
  };
}
```

## 📞 Soporte Técnico

### Contacto
- **Desarrollador**: Eisner López Acevedo
- **Email**: elopez21334@fifco.com
- **Documentación**: Este archivo

### Recursos Adicionales
- [README.md](./README.md) - Documentación de usuario
- [CHANGELOG.md](./CHANGELOG.md) - Historial de cambios
- [API_REFERENCE.md](./API_REFERENCE.md) - Referencia de API

---

**Versión**: 1.2.3  
**Última Actualización**: Agosto 2024  
**Compatibilidad**: Flutter 3.0+  
**Licencia**: Uso interno FIFCO

