import 'package:path/path.dart';
import '../models/empleado.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'empleados.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE empleados(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            apellido TEXT,
            edad INTEGER,
            foto TEXT,
            sincronizado INTEGER DEFAULT 0   -- 0 = false, 1 = true
          )
        ''');
      },
    );
  }

  static Future<int> insertEmployee(Employee emp) async {
    print(" -----------------");

    print("DATA  : ${emp}");
    print(" -----------------");
    try {
      final database = await db;
      final result = await database.insert('empleados', emp.toMap());
      return result;
    } catch (e) {
      print('Error al insertar empleado: $e');
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      final database = await db;
      return await database.rawQuery("SELECT * FROM empleados");
    } catch (e) {
      print("❌ Error en getAllEmployees: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPendientes() async {
    try {
      final database = await db;
      return await database.rawQuery(
        "SELECT * FROM empleados WHERE sincronizado = 0",
      );
    } catch (e) {
      print("❌ Error en getPendientes: $e");
      return [];
    }
  }

  static Future<bool> updateSincronizado(int id) async {
    try {
      final database = await db;

      int rows = await database.rawUpdate(
        '''
        UPDATE empleados 
        SET sincronizado = 1 
        WHERE id = ?
      ''',
        [id],
      );

      return rows > 0; // 🔥 retorna true si actualizó correctamente
    } catch (e) {
      print("❌ Error en updateSincronizado: $e");
      return false;
    }
  }

  // =====================================================
  //  ELIMINAR TABLA (solo testing)
  // =====================================================
  static Future<void> deleteEmployeeTable() async {
    final database = await db;
    await database.execute("DROP TABLE IF EXISTS empleados");
  }
}
