import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Inicializar bindings y factory para Windows (o para ejecución en desktop)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar la DB (se crea en el directorio actual del ejecutable)
  final db = await DatabaseHelper.instance.database;

  runApp(MyApp(database: db));
}

class MyApp extends StatelessWidget {
  final Database database;
  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD SQFLite Demo',
      debugShowCheckedModeBanner: false,
      home: HomePage(db: database),
    );
  }
}

class HomePage extends StatefulWidget {
  final Database db;
  const HomePage({super.key, required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final list = await DatabaseHelper.instance.getAllTasks();
    setState(() => _tasks = list);
  }

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate()) return;
    await DatabaseHelper.instance.insertTask({'title': _titleCtrl.text});
    _titleCtrl.clear();
    await _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD SQFLite - Tareas')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Título tarea',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('No hay tareas'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, i) {
                        final t = _tasks[i];
                        return ListTile(
                          title: Text(t['title'] ?? ''),
                          subtitle: Text('id: ${t['id']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTask(t['id'] as int),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------
/// Database Helper (singleton)
/// ---------------------------
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // Usamos el directorio actual del proceso para guardar la DB en Windows/desktop.
    // En Android esto será diferente; sqflite usará su propia ruta si se usa getDatabasesPath().
    final dbDir = Directory.current.path;
    final pathDb = join(dbDir, 'crud_demo.db');

    return await databaseFactory.openDatabase(
      pathDb,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL
          )
        ''');
        },
      ),
    );
  }

  Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('tasks', row);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'id DESC');
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  
}
