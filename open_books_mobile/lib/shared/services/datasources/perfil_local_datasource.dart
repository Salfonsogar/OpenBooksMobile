import 'package:sqflite/sqflite.dart';

class PerfilLocalDataSource {
  final Database _db;

  PerfilLocalDataSource(this._db);

  static const String _tableName = 'perfil_local';

  /// Devuelve el perfil cacheado del usuario, o null si no existe.
  Future<Map<String, dynamic>?> getPerfil(int usuarioId) async {
    final maps = await _db.query(
      _tableName,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Inserta o reemplaza el perfil del usuario en local (sin foto para evitar filas demasiado grandes).
  Future<void> upsert(int usuarioId, Map<String, dynamic> data) async {
    await _db.insert(
      _tableName,
      {
        'usuario_id': usuarioId,
        'user_name': data['userName'] as String? ?? '',
        'nombre_completo': data['nombreCompleto'] as String? ?? '',
        'email': data['email'] as String? ?? '',
        'estado': (data['estado'] as bool? ?? true) ? 1 : 0,
        'sancionado': (data['sancionado'] as bool? ?? false) ? 1 : 0,
        'fecha_registro': data['fechaRegistro'] as String? ?? DateTime.now().toIso8601String(),
        'nombre_rol': data['nombreRol'] as String? ?? 'Usuario',
        'rol_id': data['rolId'] as int? ?? 2,
        // foto_perfil_base64 excluida: puede superar el límite de 2MB de CursorWindow en Android
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
