import '../datasources/perfil_datasource.dart';
import '../../../auth/data/models/usuario.dart';
import '../models/update_perfil_request.dart';
import '../models/sugerencia.dart';
import '../../../../shared/services/local_database.dart';
import '../../../../shared/services/network_info.dart';

class PerfilRepository {
  final PerfilDataSource _dataSource;
  final LocalDatabase _localDatabase;
  final NetworkInfo _networkInfo;

  PerfilRepository(
    this._dataSource,
    this._localDatabase,
    this._networkInfo,
  );

  /// Online: fetch remoto, cachea localmente y retorna.
  /// Offline: retorna el perfil cacheado en local. Lanza excepción si no hay cache.
  Future<Usuario> getPerfil(int usuarioId) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final usuario = await _dataSource.getPerfil(usuarioId);
        // Cachear en local para uso offline
        await _localDatabase.perfilLocalDataSource.upsert(usuarioId, usuario.toJson());
        return usuario;
      } catch (_) {
        // Si falla el remoto, intentar con cache
        return _getFromCache(usuarioId);
      }
    }

    // Sin conexión: usar cache local
    return _getFromCache(usuarioId);
  }

  Future<Usuario> _getFromCache(int usuarioId) async {
    final cached = await _localDatabase.perfilLocalDataSource.getPerfil(usuarioId);
    if (cached == null) {
      throw Exception('Sin conexión y no hay datos del perfil guardados localmente');
    }
    return _mapToUsuario(cached);
  }

  Future<Usuario> updatePerfil(int usuarioId, UpdatePerfilRequest request) async {
    final usuario = await _dataSource.updatePerfil(usuarioId, request.toJson());
    // Actualizar cache tras edición exitosa
    await _localDatabase.perfilLocalDataSource.upsert(usuarioId, usuario.toJson());
    return usuario;
  }

  Future<void> cambiarCorreo(int usuarioId, String nuevoCorreo, String contrasena) {
    return _dataSource.cambiarCorreo(usuarioId, nuevoCorreo, contrasena);
  }

  Future<void> cambiarContrasena(
      int usuarioId, String contrasenaActual, String nuevaContrasena) {
    return _dataSource.cambiarContrasena(usuarioId, contrasenaActual, nuevaContrasena);
  }

  Future<Sugerencia> crearSugerencia(String comentario) {
    return _dataSource.crearSugerencia(comentario);
  }

  Usuario _mapToUsuario(Map<String, dynamic> row) {
    return Usuario(
      id: row['usuario_id'] as int,
      userName: row['user_name'] as String? ?? '',
      nombreCompleto: row['nombre_completo'] as String? ?? '',
      email: row['email'] as String? ?? '',
      estado: (row['estado'] as int? ?? 1) == 1,
      sancionado: (row['sancionado'] as int? ?? 0) == 1,
      fechaRegistro: row['fecha_registro'] != null
          ? DateTime.tryParse(row['fecha_registro'] as String) ?? DateTime.now()
          : DateTime.now(),
      nombreRol: row['nombre_rol'] as String? ?? 'Usuario',
      rolId: row['rol_id'] as int? ?? 2,
      // La foto no se persiste en SQLite (evita límite de CursorWindow de Android)
      // En modo offline se mostrará la inicial del nombre de usuario
      fotoPerfilBase64: null,
    );
  }
}
