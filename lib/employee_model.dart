class Employee {
  int? id;
  String nombre;
  String apellido;
  int edad;
  String foto;

  Employee({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.edad,
    required this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'Foto': foto,
    };
  }
}
