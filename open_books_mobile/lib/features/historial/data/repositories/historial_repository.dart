import '../datasources/historial_datasource.dart';
import '../../../libros/data/models/libro.dart';

class HistorialRepository {
  final HistorialDataSource _dataSource;

  HistorialRepository(this._dataSource);

  Future<List<Libro>> getHistorial({int cantidad = 10}) {
    return _dataSource.getHistorial(cantidad: cantidad);
  }
}
