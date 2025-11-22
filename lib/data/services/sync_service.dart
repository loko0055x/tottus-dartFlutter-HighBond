import 'dart:io';
import '../db/sqlite_helper.dart';
import 'supabase_service.dart';
import 'mysql_service.dart';

class SyncService {
  static Future<void> sincronizarEmpleados() async {
    print("🔄 Iniciando sincronización...");

    final pendientes = await DBHelper.getPendientes();
    print("📌 Pendientes: ${pendientes.length}");

    for (var emp in pendientes) {
      /*try {
        print("➡️ Procesando empleado ID ${emp['id']}...");

        final File foto = File(emp['foto']);

        if (!foto.existsSync()) {
          print("❌ Foto no encontrada: ${emp['foto']}");
          continue;
        }

        // 1) SUBIR FOTO A SUPABASE
        final urlFoto = await SupabaseService.uploadImage(emp['foto']);

        if (urlFoto == null) {
          print("❌ Error subiendo foto para id ${emp['id']}");
          continue;
        }

        // 2) INSERTAR EN MYSQL
        final ok = await MySQLService.insertarEmpleadoMYSQL(
          nombre: emp['nombre'],
          apellido: emp['apellido'],
          edad: emp['edad'],
          fotoUrl: urlFoto,
        );

        if (!ok) {
          print("❌ Error insertando en MySQL id ${emp['id']}");
          continue;
        }

        // 3) MARCAR COMO SINCRONIZADO
        await DBHelper.updateSincronizado(emp['id']);
        print("✔ ID ${emp['id']} sincronizado exitosamente");
      } catch (e) {
        print("❌ Error inesperado con ID ${emp['id']}: $e");
      }*/
    }

    print("🎉 Sincronización finalizada");
  }
}
