// lib/pages/employees_table_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'DBHelperEmpleado.dart'; // ajusta la ruta si tu DBHelper está en otro lugar

class EmployeesTablePage extends StatefulWidget {
  const EmployeesTablePage({super.key});

  @override
  State<EmployeesTablePage> createState() => _EmployeesTablePageState();
}

class _EmployeesTablePageState extends State<EmployeesTablePage> {
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;

  // Ruta de ejemplo (archivo subido). Se usa como placeholder si no hay imagen.
  // Path local del archivo subido: /mnt/data/aaea6a95-0446-4113-bd42-c3da4c69d41f.png
  static const String _exampleImagePath =
      '/mnt/data/aaea6a95-0446-4113-bd42-c3da4c69d41f.png';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loading = true);
    final list = await DBHelper.getAllEmployees();
    setState(() {
      _employees = list;
      _loading = false;
    });
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: const [
          SizedBox(
            width: 140,
            child: Text('FOTO', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              'NOMBRE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              'APELLIDO',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text('EDAD', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> emp) {
    final String? fotoPath =
        (emp['foto'] != null && emp['foto'].toString().isNotEmpty)
        ? emp['foto'].toString()
        : null;

    Widget imageWidget;
    if (fotoPath != null && File(fotoPath).existsSync()) {
      imageWidget = Image.file(
        File(fotoPath),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    } else if (File(_exampleImagePath).existsSync()) {
      imageWidget = Image.file(
        File(_exampleImagePath),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    } else {
      imageWidget = Container(
        width: 120,
        height: 120,
        color: Colors.grey[300],
        child: const Icon(Icons.person, size: 48, color: Colors.white70),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 140, // fila grande para que la foto se vea bien
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 120, height: 120, child: imageWidget),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      emp['nombre']?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      emp['apellido']?.toString() ?? '-',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      emp['edad']?.toString() ?? '-',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No hay empleados', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: const Text('Refrescar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: _employees.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader();
          final emp = _employees[index - 1];
          return _buildRow(emp);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados (tabla)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // si quieres navegar a la pantalla de agregar, descomenta y ajusta la ruta
          // final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEmployeePage()));
          // if (r == true) _loadEmployees();
          await _loadEmployees();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
