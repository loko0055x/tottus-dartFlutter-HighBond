import 'package:flutter/material.dart';
import 'package:totus_auditoria/data/services/mysql_service.dart';
import '../../data/services/supabase_service.dart';
import 'add_employee_page.dart';
import '../../data/services/sync_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio CRUD")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AGREGAR EMPLEADO
            ElevatedButton(
              child: const Text("Agregar Empleado"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEmployeePage()),
                );
              },
            ),

            const SizedBox(height: 20),

            // SINCRONIZAR
            ElevatedButton(
              child: const Text("Sincronizar Datos"),
              onPressed: () async {
                await SyncService.sincronizarEmpleados;
              },
            ),

            const SizedBox(height: 20),

            // MYSQL
            ElevatedButton(
              child: const Text("Probar conexión a MySQL"),
              onPressed: () async {
                await MySQLService.testConnection();
              },
            ),
          ],
        ),
      ),
    );
  }
}
