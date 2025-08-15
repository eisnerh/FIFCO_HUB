import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fifco_hub.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de categorías
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla de shortcuts
    await db.execute('''
      CREATE TABLE shortcuts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        is_default BOOLEAN DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Insertar categorías por defecto
    await _insertDefaultCategories(db);
    
    // Insertar shortcuts por defecto
    await _insertDefaultShortcuts(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      'Gestión de Inventarios',
      'Logística',
      'Almacén',
      'Transporte',
      'Sistemas Internos',
      'Proveedores',
      'Calidad',
    ];

    for (String category in defaultCategories) {
      await db.insert('categories', {'name': category});
    }
  }

  Future<void> _insertDefaultShortcuts(Database db) async {
    // Obtener las categorías para asignar los shortcuts
    final categories = await db.query('categories');
    
    // Mapeo de nombres de categorías a IDs
    final categoryMap = <String, int>{};
    for (var category in categories) {
      categoryMap[category['name'] as String] = category['id'] as int;
    }

    // Lista de shortcuts por defecto
    final defaultShortcuts = [
      {
        'name': 'Incidencias',
        'url': 'https://forms.office.com/Pages/ResponsePage.aspx?id=Y6S5GQ0RP0KXWJzTBYcEaYDu70xkywhMslL9GXJ1eX9UN1VNMUlQNEdYN1pETVE1MzZWR1QzQ0tPTiQlQCN0PWcu',
        'category': 'Sistemas Internos',
        'is_default': false,
      },
      {
        'name': 'Reportes Preventivos',
        'url': 'https://forms.office.com/Pages/ResponsePage.aspx?id=Y6S5GQ0RP0KXWJzTBYcEaeUZyy766PJPm3R17RbagC9UM1hYVTlBWVpCMFk4OEdUTlZVVjRaSFZUSSQlQCN0PWcu',
        'category': 'Sistemas Internos',
        'is_default': false,
      },
      {
        'name': 'Muestreo de Envase',
        'url': 'https://forms.office.com/pages/responsepage.aspx?id=Y6S5GQ0RP0KXWJzTBYcEaUa6rTODswZBikoR1jmc1adUOElZWUVONEZOTEo0SkJFN1IyMTYyM1M2MC4u&origin=lprLink&route=shorturl',
        'category': 'Calidad',
        'is_default': false,
      },
      {
        'name': '10 Pasos',
        'url': 'https://florida1.sharepoint.com/sites/Distribucinpas/_layouts/15/listforms.aspx?cid=NjJmMDI5NTctYzJlZi00YjIzLTgzYzgtNTVlZGM1NmU5ODA5&nav=MDQyNzFiN2UtOWI0ZC00YTFkLWFjZTItODAxODQ2YjU2ZjBk',
        'category': 'Sistemas Internos',
        'is_default': false,
      },
      {
        'name': 'Lavado de Camiones',
        'url': 'https://apps.powerapps.com/play/e/default-19b9a463-110d-423f-9758-9cd305870469/a/e930a865-c082-4ee5-8309-422f099ee24e?tenantId=19b9a463-110d-423f-9758-9cd305870469&hint=01fca6c4-a224-4cc1-99f8-200f0984968f&sourcetime=1718583516237&source=portal&skipMobileRedirect=1',
        'category': 'Transporte',
        'is_default': false,
      },
      {
        'name': 'Actualizar OC Moderno',
        'url': 'https://forms.office.com/pages/responsepage.aspx?id=Y6S5GQ0RP0KXWJzTBYcEafToAM31LeNLrDTTJ5DRcApUNTRXQVdONjVGV0pTUkJLSzlGTDRWSDRHSC4u',
        'category': 'Sistemas Internos',
        'is_default': false,
      },
    ];

    // Insertar cada shortcut
    for (var shortcut in defaultShortcuts) {
      final categoryId = categoryMap[shortcut['category'] as String];
      if (categoryId != null) {
        await db.insert('shortcuts', {
          'name': shortcut['name'] as String,
          'url': shortcut['url'] as String,
          'category_id': categoryId,
          'is_default': (shortcut['is_default'] as bool) ? 1 : 0,
        });
      }
    }
  }

  // Métodos para categorías
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  Future<int> insertCategory(String name) async {
    final db = await database;
    return await db.insert('categories', {'name': name});
  }

  Future<int> updateCategory(int id, String name) async {
    final db = await database;
    return await db.update(
      'categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isCategoryEmpty(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'shortcuts',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    return result.isEmpty;
  }

  // Métodos para shortcuts
  Future<List<Map<String, dynamic>>> getAllShortcuts() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        s.id,
        s.name,
        s.url,
        s.is_default,
        s.category_id,
        c.name as category_name
      FROM shortcuts s
      INNER JOIN categories c ON s.category_id = c.id
      ORDER BY s.name ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getShortcutsByCategory(int categoryId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        s.id,
        s.name,
        s.url,
        s.is_default,
        s.category_id,
        c.name as category_name
      FROM shortcuts s
      INNER JOIN categories c ON s.category_id = c.id
      WHERE s.category_id = ?
      ORDER BY s.name ASC
    ''', [categoryId]);
  }

  Future<int> insertShortcut(String name, String url, int categoryId, {bool isDefault = false}) async {
    final db = await database;
    
    // Si es default, quitar el default de otros shortcuts
    if (isDefault) {
      await db.update(
        'shortcuts',
        {'is_default': 0},
        where: 'is_default = 1',
      );
    }

    return await db.insert('shortcuts', {
      'name': name,
      'url': url,
      'category_id': categoryId,
      'is_default': isDefault ? 1 : 0,
    });
  }

  Future<int> updateShortcut(int id, String name, String url, int categoryId, {bool isDefault = false}) async {
    final db = await database;
    
    // Si es default, quitar el default de otros shortcuts
    if (isDefault) {
      await db.update(
        'shortcuts',
        {'is_default': 0},
        where: 'is_default = 1',
      );
    }

    return await db.update(
      'shortcuts',
      {
        'name': name,
        'url': url,
        'category_id': categoryId,
        'is_default': isDefault ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteShortcut(int id) async {
    final db = await database;
    return await db.delete(
      'shortcuts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> setDefaultShortcut(int id) async {
    final db = await database;
    
    // Quitar default de todos los shortcuts
    await db.update(
      'shortcuts',
      {'is_default': 0},
    );
    
    // Establecer el nuevo default
    return await db.update(
      'shortcuts',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para obtener estadísticas
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final totalShortcuts = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM shortcuts')
    ) ?? 0;
    
    final totalCategories = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories')
    ) ?? 0;
    
    final defaultShortcut = await db.query(
      'shortcuts',
      where: 'is_default = 1',
      limit: 1,
    );
    
    return {
      'total_shortcuts': totalShortcuts,
      'total_categories': totalCategories,
      'has_default': defaultShortcut.isNotEmpty,
    };
  }

  // Método para restablecer shortcuts por defecto
  Future<void> resetToDefaultShortcuts() async {
    final db = await database;
    
    // Eliminar todos los shortcuts existentes
    await db.delete('shortcuts');
    
    // Insertar los shortcuts por defecto nuevamente
    await _insertDefaultShortcuts(db);
  }

  // Método para cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
} 