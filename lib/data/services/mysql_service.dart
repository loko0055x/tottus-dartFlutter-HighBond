import 'package:mysql1/mysql1.dart';

class MySQLService {
  static Future<MySqlConnection> connect() async {
    final settings = ConnectionSettings(
      host: '127.0.0.1',
      port: 3306,
      user: 'root',
      password: '1234',
      db: 'Tottus_mysql',
    );

    return await MySqlConnection.connect(settings);
  }

  static Future<void> testConnection() async {
    try {
      final conn = await connect();
      print("✔ Conexión MySQL exitosa.");

      var results = await conn.query("SELECT NOW() as fecha");
      for (var row in results) {
        print("Fecha servidor MySQL: ${row['fecha']}");
      }

      await conn.close();
    } catch (e) {
      print("❌ Error en conexión MySQL: $e");
    }
  }

  static Future<bool> insertarEmpleadoMYSQL({
    required String nombre,
    required String apellido,
    required int edad,
    required String fotoUrl,
  }) async {
    try {
      final conn = await connect();

      await conn.query(
        '''
      INSERT INTO empleados (nombre, apellido, edad, foto_url)
      VALUES (?, ?, ?, ?)
      ''',
        [nombre, apellido, edad, fotoUrl],
      );

      await conn.close();
      return true;
    } catch (e) {
      print("Error MySQL: $e");
      return false;
    }
  }
}
