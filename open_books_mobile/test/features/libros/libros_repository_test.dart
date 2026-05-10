import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/libros/data/datasources/categorias_datasource.dart';
import 'package:open_books_mobile/features/libros/data/datasources/libros_datasource.dart';
import 'package:open_books_mobile/features/libros/data/datasources/resenas_datasource.dart';
import 'package:open_books_mobile/features/libros/data/datasources/valoraciones_datasource.dart';
import 'package:open_books_mobile/features/libros/data/models/categoria.dart';
import 'package:open_books_mobile/features/libros/data/models/denuncia_resena.dart';
import 'package:open_books_mobile/features/libros/data/models/libro.dart';
import 'package:open_books_mobile/features/libros/data/models/libro_detalle.dart';
import 'package:open_books_mobile/features/libros/data/models/paged_result.dart';
import 'package:open_books_mobile/features/libros/data/models/resena.dart';
import 'package:open_books_mobile/features/libros/data/repositories/libros_repository.dart';

class MockLibrosDataSource extends Mock implements LibrosDataSource {}
class MockCategoriasDataSource extends Mock implements CategoriasDataSource {}
class MockValoracionesDataSource extends Mock
    implements ValoracionesDataSource {}
class MockResenasDataSource extends Mock implements ResenasDataSource {}

void main() {
  group('LibrosRepository', () {
    late MockLibrosDataSource librosDataSource;
    late MockCategoriasDataSource categoriasDataSource;
    late MockValoracionesDataSource valoracionesDataSource;
    late MockResenasDataSource resenasDataSource;
    late LibrosRepository repository;

    setUp(() {
      librosDataSource = MockLibrosDataSource();
      categoriasDataSource = MockCategoriasDataSource();
      valoracionesDataSource = MockValoracionesDataSource();
      resenasDataSource = MockResenasDataSource();
      repository = LibrosRepository(
        librosDataSource,
        categoriasDataSource,
        valoracionesDataSource,
        resenasDataSource,
      );
    });

    group('getLibros', () {
      test('delegates to LibrosDataSource', () async {
        final expected = PagedResult<Libro>(
          page: 1,
          pageSize: 10,
          total: 1,
          totalPages: 1,
          data: [],
        );
        when(
          () => librosDataSource.getLibros(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            categorias: any(named: 'categorias'),
            autor: any(named: 'autor'),
          ),
        ).thenAnswer((_) async => expected);

        final result =
            await repository.getLibros(query: 'test', page: 1, pageSize: 10);

        expect(result, equals(expected));
        verify(
          () => librosDataSource.getLibros(
            query: 'test',
            page: 1,
            pageSize: 10,
            categorias: null,
            autor: null,
          ),
        ).called(1);
      });
    });

    group('getLibroDetalle', () {
      test('delegates to LibrosDataSource', () async {
        final expected = LibroDetalle(
          id: 1,
          titulo: 'Test',
          autor: 'Author',
          descripcion: 'Desc',
          promedioValoraciones: 0,
          cantidadValoraciones: 0,
          resenas: [],
          totalResenas: 0,
          categorias: [],
        );
        when(
          () => librosDataSource.getLibroDetalle(
            1,
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => expected);

        final result = await repository.getLibroDetalle(1);

        expect(result, equals(expected));
        verify(
          () => librosDataSource.getLibroDetalle(1, page: 1, pageSize: 5),
        ).called(1);
      });
    });

    group('getCategorias', () {
      test('delegates to CategoriasDataSource', () async {
        final expected = PagedResult<Categoria>(
          page: 1,
          pageSize: 50,
          total: 0,
          totalPages: 0,
          data: [],
        );
        when(
          () => categoriasDataSource.getCategorias(
            pageNumber: any(named: 'pageNumber'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => expected);

        final result = await repository.getCategorias();

        expect(result, equals(expected));
        verify(
          () => categoriasDataSource.getCategorias(
            pageNumber: 1,
            pageSize: 50,
          ),
        ).called(1);
      });
    });

    group('crearValoracion', () {
      test('delegates to ValoracionesDataSource', () async {
        when(() => valoracionesDataSource.crearValoracion(1, 4))
            .thenAnswer((_) async {});

        await repository.crearValoracion(1, 4);

        verify(() => valoracionesDataSource.crearValoracion(1, 4)).called(1);
      });
    });

    group('crearResena', () {
      test('delegates to ResenasDataSource', () async {
        final expected = Resena(
          id: 1,
          usuarioId: 1,
          nombreUsuario: 'User',
          texto: 'Buen libro',
          fecha: DateTime(2024, 1, 1),
        );
        when(() => resenasDataSource.crearResena(1, 'Buen libro'))
            .thenAnswer((_) async => expected);

        final result = await repository.crearResena(1, 'Buen libro');

        expect(result, equals(expected));
        verify(() => resenasDataSource.crearResena(1, 'Buen libro')).called(1);
      });
    });

    group('crearDenunciaResena', () {
      test('delegates to ResenasDataSource', () async {
        final expected = DenunciaResena(
          id: 1,
          idDenunciante: 1,
          nombreDenunciante: 'Alice',
          idDenunciado: 2,
          nombreDenunciado: 'Bob',
          comentario: 'Comentario',
        );
        when(
          () => resenasDataSource.crearDenunciaResena(
            idDenunciante: any(named: 'idDenunciante'),
            idDenunciado: any(named: 'idDenunciado'),
            idResena: any(named: 'idResena'),
            motivo: any(named: 'motivo'),
            comentario: any(named: 'comentario'),
          ),
        ).thenAnswer((_) async => expected);

        final result = await repository.crearDenunciaResena(
          idDenunciante: 1,
          idDenunciado: 2,
          idResena: 5,
          motivo: 'Spam',
          comentario: 'Comentario',
        );

        expect(result, equals(expected));
        verify(
          () => resenasDataSource.crearDenunciaResena(
            idDenunciante: 1,
            idDenunciado: 2,
            idResena: 5,
            motivo: 'Spam',
            comentario: 'Comentario',
          ),
        ).called(1);
      });
    });
  });
}
