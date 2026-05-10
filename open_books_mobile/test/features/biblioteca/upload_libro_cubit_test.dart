import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_books_mobile/features/biblioteca/data/models/create_user_libro.dart';
import 'package:open_books_mobile/features/biblioteca/data/repositories/user_libros_repository.dart';
import 'package:open_books_mobile/features/biblioteca/logic/cubit/upload_libro_cubit.dart';

class MockUserLibrosRepository extends Mock implements UserLibrosRepository {}

void main() {
  late MockUserLibrosRepository repository;

  setUpAll(() {
    registerFallbackValue(const CreateUserLibroRequest(
      titulo: '',
      autor: '',
      categoriasIds: [],
    ));
  });

  setUp(() {
    repository = MockUserLibrosRepository();
  });

  group('UploadLibroCubit', () {
    blocTest<UploadLibroCubit, UploadLibroState>(
      'initial state is UploadLibroInitial',
      build: () => UploadLibroCubit(repository: repository),
      verify: (cubit) => expect(cubit.state, isA<UploadLibroInitial>()),
    );

    blocTest<UploadLibroCubit, UploadLibroState>(
      'subirLibro success emits [UploadLibroLoading, UploadLibroSuccess] and returns true',
      setUp: () {
        when(() => repository.crearLibro(any())).thenAnswer((_) async => true);
      },
      build: () => UploadLibroCubit(repository: repository),
      act: (cubit) => cubit.subirLibro(
        titulo: 'Test',
        autor: 'Author',
        categoriasIds: [1],
      ),
      expect: () => [
        isA<UploadLibroLoading>(),
        isA<UploadLibroSuccess>(),
      ],
    );

    blocTest<UploadLibroCubit, UploadLibroState>(
      'subirLibro failure emits [UploadLibroLoading, UploadLibroError]',
      setUp: () {
        when(() => repository.crearLibro(any()))
            .thenThrow(Exception('Error de conexión'));
      },
      build: () => UploadLibroCubit(repository: repository),
      act: (cubit) => cubit.subirLibro(
        titulo: 'Test',
        autor: 'Author',
        categoriasIds: [1],
      ),
      expect: () => [
        isA<UploadLibroLoading>(),
        isA<UploadLibroError>().having(
          (s) => s.message,
          'message',
          'Error de conexión',
        ),
      ],
    );

    blocTest<UploadLibroCubit, UploadLibroState>(
      'reset sets state back to UploadLibroInitial',
      build: () => UploadLibroCubit(repository: repository),
      seed: () => UploadLibroSuccess(),
      act: (cubit) => cubit.reset(),
      expect: () => [isA<UploadLibroInitial>()],
    );
  });
}
