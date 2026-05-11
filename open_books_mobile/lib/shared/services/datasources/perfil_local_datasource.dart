import 'package:sqflite/sqflite.dart';

class PerfilLocalDataSource {
  final Database _db;

  PerfilLocalDataSource(this._db);

  static const String _tableName = 'perfil_local';

  /// Devuelve el perfil cacheado del usuario, o null si no existe.
  Future<Map<String, dynamic>?> getPerfil(String usuarioId) async {
    final maps = await _db.query(
      _tableName,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Inserta o reemplaza el perfil del usuario en local.
  Future<void> upsert(String usuarioId, Map<String, dynamic> data) async {
    await _db.insert(
      _tableName,
      {
        'usuario_id': usuarioId,
        'user_name': data['userName'] as String? ?? '',
        'email': data['email'] as String? ?? '',
        'fecha_registro': data['fechaRegistro'] as String? ?? DateTime.now().toIso8601String(),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
