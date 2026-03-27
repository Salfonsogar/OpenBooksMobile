import '../models/rol.dart';
import '../../../../shared/core/network/api_client.dart';

class RolesDataSource {
  final ApiClient _apiClient;

  RolesDataSource(this._apiClient);

  Future<Rol?> getRol(int rolId) async {
    try {
      final response = await _apiClient.get('/api/Rols/$rolId');
      
      if (response.statusCode == 200 && response.data != null) {
        return Rol.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Rol>> getRoles() async {
    try {
      final response = await _apiClient.get('/api/Rols');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => Rol.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}
