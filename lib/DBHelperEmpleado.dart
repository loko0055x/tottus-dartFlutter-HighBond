import 'package:path/path.dart';
import 'employee_model.dart';
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
    foto TEXT
          )
        ''');
      },
    );
  }

  // 🔥 INSERT EMPLEADO
  static Future<int> insertEmployee(Employee emp) async {
    final database = await db;
    return await database.insert('empleados', emp.toMap());
  }

  static Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      final database = await db;
      return await database.rawQuery("SELECT * FROM empleados");
    } catch (e) {
      print("Error es de  : ${e}");
      return List.empty();
    }
  }

  static Future<void> deleteEmployeeTable() async {
    final database = await db;
    await database.execute("DROP TABLE IF EXISTS empleados");
  }
}
