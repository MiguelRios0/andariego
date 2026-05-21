import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get _base {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }

  // ── USUARIOS ────────────────────────────────────────────

  static Future<Map<String, dynamic>> registrarUsuario(
    Map<String, dynamic> datos,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/usuarios/registro/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> loginUsuario(
    String alias,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/usuarios/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'alias_usuario': alias, 'password': password}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<void> inactivarUsuario(int idUsuario) async {
    await http.post(
      Uri.parse('$_base/usuarios/$idUsuario/inactivar/'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<Map<String, dynamic>> editarUsuario(
    int idUsuario,
    Map<String, dynamic> datosModificados,
  ) async {
    final res = await http.patch(
      Uri.parse('$_base/usuarios/$idUsuario/editar/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datosModificados),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ── CARACTERIZACIÓN ──────────────────────────────────────

  static Future<Map<String, dynamic>> guardarCaracterizacion(
    Map<String, dynamic> datos,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/caracterizacion/guardar/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>?> getCaracterizacionUsuario(
    int idUsuario,
  ) async {
    final res = await http.get(
      Uri.parse('$_base/caracterizacion/?id_usuario=$idUsuario'),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is List && data.isNotEmpty) return data.first;
    return null;
  }

  // ── HOBBIES ─────────────────────────────────────────────

  static Future<void> guardarHobbiesUsuario(
    int idUsuario,
    List<int> hobbieIds,
  ) async {
    for (final id in hobbieIds) {
      await http.post(
        Uri.parse('$_base/hobbies-usuario/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_usuario': idUsuario, 'id_hobbie': id}),
      );
    }
  }

  static Future<void> reemplazarHobbiesUsuario(
    int idUsuario,
    List<int> nuevosHobbieIds,
  ) async {
    final actuales = await getHobbiesDeUsuario(idUsuario);

    for (final h in actuales) {
      final idHobbie = h['id_hobbie'];
      if (!nuevosHobbieIds.contains(idHobbie)) {
        await http.delete(
          Uri.parse(
            '$_base/hobbies-usuario/eliminar/?id_usuario=$idUsuario&id_hobbie=$idHobbie',
          ),
          headers: {'Content-Type': 'application/json'},
        );
      }
    }

    final idsActuales = actuales.map((h) => h['id_hobbie']).toList();
    for (final id in nuevosHobbieIds) {
      if (!idsActuales.contains(id)) {
        await http.post(
          Uri.parse('$_base/hobbies-usuario/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id_usuario': idUsuario, 'id_hobbie': id}),
        );
      }
    }
  }

  static Future<List<dynamic>> getHobbiesDeUsuario(int idUsuario) async {
    final res = await http.get(
      Uri.parse('$_base/hobbies-usuario/con_nombre/?id_usuario=$idUsuario'),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) return data['results'];
    return [];
  }

  // ── LUGARES ─────────────────────────────────────────────

  static Future<List<dynamic>> getLugares() async {
    final res = await http.get(Uri.parse('$_base/lugares/'));
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) return data['results'];
    return [];
  }

  // ── FAVORITOS ────────────────────────────────────────────

  static Future<List<dynamic>> getFavoritos(int idUsuario) async {
    final res = await http.get(
      Uri.parse('$_base/favoritos/con_lugar/?id_usuario=$idUsuario'),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> agregarFavorito(
    int idUsuario,
    int idLugar,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/favoritos/agregar/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_usuario': idUsuario, 'id_lugar': idLugar}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<void> eliminarFavorito(int idUsuario, int idLugar) async {
    await http.delete(
      Uri.parse(
        '$_base/favoritos/eliminar/?id_usuario=$idUsuario&id_lugar=$idLugar',
      ),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // ── COMENTARIOS ──────────────────────────────────────────

  static Future<List<dynamic>> getComentariosDeLugar(int idLugar) async {
    final res = await http.get(
      Uri.parse('$_base/comentarios/de_lugar/?id_lugar=$idLugar'),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> agregarComentario(
    int idUsuario,
    int idLugar,
    String textoComentario,
    int puntuacion,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/comentarios/agregar/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_usuario': idUsuario,
        'id_lugar': idLugar,
        'comentarios': textoComentario,
        'puntuacion': puntuacion,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ── RUTAS ────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getMiRuta(int idUsuario) async {
    final res = await http.get(
      Uri.parse('$_base/rutas/mi_ruta/?id_usuario=$idUsuario'),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> agregarLugarARuta(
    int idUsuario,
    int idLugar,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/rutas/agregar_lugar/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_usuario': idUsuario, 'id_lugar': idLugar}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<Map<String, dynamic>> eliminarLugarDeRuta(
    int idUsuario,
    int idLugar,
  ) async {
    final res = await http.delete(
      Uri.parse(
        '$_base/rutas/eliminar_lugar/?id_usuario=$idUsuario&id_lugar=$idLugar',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  // ── CATÁLOGOS ────────────────────────────────────────────

  static Future<List<dynamic>> getHorariosPreferidos() async {
    final res = await http.get(Uri.parse('$_base/horarios-preferidos/'));
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) return data['results'];
    return [];
  }

  static Future<List<dynamic>> getPresupuestos() async {
    final res = await http.get(Uri.parse('$_base/presupuestos/'));
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) return data['results'];
    return [];
  }

  static Future<List<dynamic>> getTipoTurismo() async {
    final res = await http.get(Uri.parse('$_base/tipo-turismo/'));
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) return data['results'];
    return [];
  }
}
