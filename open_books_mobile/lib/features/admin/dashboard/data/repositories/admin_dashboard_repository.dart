import '../../../../../shared/services/local_database.dart';
import '../datasources/admin_dashboard_datasource.dart';
import '../models/admin_stats.dart';

class AdminDashboardRepository {
  final AdminDashboardDataSource _dataSource;

  AdminDashboardRepository(this._dataSource);

  Future<AdminStats> getStats() async {
    return await _dataSource.getStats();
  }

void setDependencies({
    required LocalDatabase localDatabase,
    required String token,
  }) {
    _dataSource.setDependencies(
      localDatabase: localDatabase,
      token: token,
    );
  }
}