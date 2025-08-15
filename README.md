# FIFCO Supply Chain Hub

Aplicación móvil para centralizar todos los accesos y herramientas de la cadena de suministro de FIFCO.

## Características

- **Centralización de Enlaces**: Acceso rápido a todos los sistemas de supply chain
- **Categorización**: Organización por categorías (Gestión de Inventarios, Logística, Almacén, etc.)
- **Modo Administrador**: Gestión completa de enlaces y categorías
- **Enlaces por Defecto**: Sistema preconfigurado con enlaces oficiales de FIFCO
- **Interfaz Moderna**: Diseño Material 3 con colores corporativos de FIFCO

## Enlaces por Defecto

La aplicación incluye los siguientes enlaces preconfigurados:

### Sistemas Internos
- **Incidencias**: Formulario de reporte de incidencias
- **Reportes Preventivos**: Sistema de reportes preventivos
- **10 Pasos**: Documentación de procesos
- **Actualizar OC Moderno**: Actualización de órdenes de compra

### Calidad
- **Muestreo de Envase**: Sistema de muestreo de envases

### Transporte
- **Lavado de Camiones**: Aplicación de PowerApps para lavado de camiones

## Funcionalidades del Administrador

### Acceso
- Contraseña: `admin123`
- Acceso desde el botón de administrador en la barra superior

### Gestión de Sistemas
- Agregar nuevos sistemas
- Editar sistemas existentes
- Eliminar sistemas
- Establecer sistema predeterminado
- Ver todos los sistemas

### Gestión de Categorías
- Crear nuevas categorías
- Editar categorías existentes
- Eliminar categorías (solo si están vacías)

### Restablecimiento
- Restablecer enlaces por defecto
- Elimina todos los enlaces personalizados
- Restaura los enlaces oficiales de FIFCO

## Tecnologías

- **Flutter**: Framework de desarrollo móvil
- **SQLite**: Base de datos local
- **Material Design 3**: Sistema de diseño
- **WebView**: Visualización de enlaces web

## Instalación

1. Clonar el repositorio
2. Ejecutar `flutter pub get`
3. Ejecutar `flutter run`

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── database/
│   └── database_helper.dart  # Gestión de base de datos SQLite
├── models/
│   ├── category.dart         # Modelo de categoría
│   └── shortcut.dart         # Modelo de enlace directo
├── screens/
│   ├── home_screen.dart      # Pantalla principal
│   ├── edit_shortcut_screen.dart # Editor de enlaces
│   └── webview_screen.dart   # Visualizador web
└── widgets/
    └── shortcut_tile.dart    # Widget de tarjeta de enlace
```

## Base de Datos

La aplicación utiliza SQLite para almacenar:
- Categorías de sistemas
- Enlaces directos
- Configuraciones de usuario

Los datos persisten entre sesiones y se almacenan localmente en el dispositivo.

## Colores Corporativos FIFCO

- **Azul Oscuro**: `#1E3A8A` (FIF)
- **Azul Claro**: `#0EA5E9` (CO)
- **Púrpura**: `#7C3AED` (Elemento gráfico)

## Licencia

Desarrollado para uso interno de FIFCO.
