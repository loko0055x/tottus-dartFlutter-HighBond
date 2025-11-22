import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../data/models/empleado.dart';
import '../../data/db/sqlite_helper.dart';
import 'empleados_table_page.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController apellidoCtrl = TextEditingController();
  final TextEditingController edadCtrl = TextEditingController();

  String? fotoPath; // aquí guardamos la ruta de la foto

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      // Copiar la imagen a carpeta interna segura
      final internalPath = await copyImageToInternalFolder(imagen.path);

      setState(() {
        fotoPath = internalPath; // ahora la ruta es PRIVADA y segura
      });
    }
  }

  Future<String> copyImageToInternalFolder(String originalPath) async {
    // Obtener carpeta interna del sistema
    final directory = await getApplicationDocumentsDirectory();

    // Crear carpeta /fotos si no existe
    final fotosDir = Directory('${directory.path}/fotos');
    if (!fotosDir.existsSync()) {
      fotosDir.createSync(recursive: true);
    }

    // Nuevo nombre de archivo único
    final newFilePath =
        '${fotosDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Copiar
    final newImage = await File(originalPath).copy(newFilePath);

    return newImage.path; // ESTA es la ruta que se guardará en SQLite
  }

  Future<void> guardarEmpleado() async {
    if (nombreCtrl.text.isEmpty ||
        apellidoCtrl.text.isEmpty ||
        edadCtrl.text.isEmpty ||
        fotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete todos los campos")),
      );
      return;
    }

    Employee emp = Employee(
      nombre: nombreCtrl.text,
      apellido: apellidoCtrl.text,
      edad: int.parse(edadCtrl.text),
      foto: fotoPath!, // guardamos la ruta
    );

    await DBHelper.insertEmployee(emp);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Empleado guardado")));

    Navigator.pop(context);
  }

  Future<void> verificarCantidad() async {
    final lista = await DBHelper.getAllEmployees();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Hay ${lista.length} empleados")));

    var nelementos = lista.length;
    print("Nelementos es ${nelementos}");

    for (int i = 0; i < nelementos; i++) {
      print(lista[i]);
    }
  }

  Future<void> redicerttable() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmployeesTablePage()),
    );
  }

  Future<void> elimintarTabla() async {
    try {
      await DBHelper.deleteEmployeeTable();
      print("Se elimino Correctamente");
    } catch (e) {
      print("Hubo error al eliminar");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text("Agregar Empleado"),
        backgroundColor: Colors.blueAccent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---- FOTO ----
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: fotoPath == null
                    ? const Center(
                        child: Text(
                          "Seleccionar foto",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(fotoPath!), fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // ---- NOMBRE ----
            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ---- APELLIDO ----
            TextField(
              controller: apellidoCtrl,
              decoration: InputDecoration(
                labelText: "Apellido",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ---- EDAD ----
            TextField(
              controller: edadCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Edad",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---- BOTONES ----
            ElevatedButton(
              onPressed: guardarEmpleado,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Guardar",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: verificarCantidad,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Ver cuántos hay",
                style: TextStyle(fontSize: 16),
              ),
            ),

            ElevatedButton(
              onPressed: redicerttable,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Ver empleados",
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: elimintarTabla,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "BORRAR TABLA EMPLEADO",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
