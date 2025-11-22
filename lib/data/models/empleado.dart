class Employee {
  int? id;
  String nombre;
  String apellido;
  int edad;
  String foto;
  bool sincronizado; // <- bool en Dart

  Employee({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.foto,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'foto': foto,
      'sincronizado': sincronizado ? 1 : 0, // guardo 1/0 en sqlite
    };
  }

  factory Employee.fromMap(Map<String, dynamic> m) => Employee(
    id: m['id'] as int?,
    nombre: m['nombre'] as String,
    apellido: m['apellido'] as String,
    edad: m['edad'] as int,
    foto: m['foto'] as String,
    sincronizado: (m['sincronizado'] ?? 0) == 1,
  );
}
