import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  // 🔥 Reemplaza estas 2 constantes con tus datos reales
  static final String supabaseUrl = dotenv.env["SUPABASE_URL"]!;
  static final String supabaseAnonKey = dotenv.env["SUPABASE_ANON_KEY"]!;

  static final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  static final String STORAGE_BUCKET = dotenv.env["STORAGE_BUCKET"]!;
  static final String STORAGE_FOLDER = dotenv.env["STORAGE_FOLDER"]!;
  // ====================================================
  // 🔥 Ejemplo de función de sincronización con STORAGE
  // ====================================================
  static Future<String?> uploadImage(String ruta) async {
    try {
      final file = File(ruta);
      if (!file.existsSync()) return null;

      final fileName =
          "${STORAGE_FOLDER}/foto_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final response = await supabase.storage
          .from(STORAGE_BUCKET)
          .upload(fileName, file);

      final publicUrl = supabase.storage
          .from(STORAGE_BUCKET)
          .getPublicUrl(fileName);

      return publicUrl; // 🔥 Si salió bien, retorno la URL
    } catch (e) {
      print("ERROR al subir imagen: $e");
      return null; // 🔥 Si falló, retorno null
    }
  }
}
