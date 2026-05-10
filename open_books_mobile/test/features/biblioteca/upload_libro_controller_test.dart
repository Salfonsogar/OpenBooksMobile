import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import 'package:open_books_mobile/features/biblioteca/logic/cubit/upload_libro_cubit.dart';
import 'package:open_books_mobile/features/biblioteca/logic/upload_libro_controller.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockFilePicker extends Mock implements FilePicker {}

class MockUploadLibroCubit extends Mock implements UploadLibroCubit {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockFilePicker mockFilePicker;
  late UploadLibroController controller;

  setUpAll(() {
    registerFallbackValue(FileType.any);
  });

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockFilePicker = MockFilePicker();
    controller = UploadLibroController(
      imagePicker: mockImagePicker,
      filePicker: mockFilePicker,
    );
  });

  group('pickPortada', () {
    test('returns empty result when no image selected', () async {
      when(
        () => mockImagePicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => null);

      final result = await controller.pickPortada();

      expect(result.portadaBase64, isNull);
    });

    test('returns base64 when image selected', () async {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_image.png');
      await tempFile.writeAsBytes([1, 2, 3]);

      final xFile = XFile(tempFile.path);
      when(
        () => mockImagePicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => xFile);

      final result = await controller.pickPortada();

      expect(result.portadaBase64, equals(base64Encode([1, 2, 3])));

      await tempFile.delete();
    });
  });

  group('pickArchivo', () {
    test('returns empty result when no file selected', () async {
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => null);

      final result = await controller.pickArchivo();

      expect(result.archivoBase64, isNull);
      expect(result.nombreArchivo, isNull);
    });

    test('returns file data when file selected', () async {
      final platformFile = PlatformFile(
        name: 'test.epub',
        size: 3,
        bytes: Uint8List.fromList([10, 20, 30]),
      );
      final pickResult = FilePickerResult([platformFile]);

      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => pickResult);

      final result = await controller.pickArchivo();

      expect(result.archivoBase64, equals(base64Encode([10, 20, 30])));
      expect(result.nombreArchivo, equals('test.epub'));
    });
  });

  group('subirLibro', () {
    test('delegates to UploadLibroCubit', () async {
      final mockCubit = MockUploadLibroCubit();
      when(
        () => mockCubit.subirLibro(
          titulo: any(named: 'titulo'),
          autor: any(named: 'autor'),
          descripcion: any(named: 'descripcion'),
          categoriasIds: any(named: 'categoriasIds'),
          portadaBase64: any(named: 'portadaBase64'),
          archivoBase64: any(named: 'archivoBase64'),
          nombreArchivo: any(named: 'nombreArchivo'),
        ),
      ).thenAnswer((_) async => true);

      final result = await controller.subirLibro(
        cubit: mockCubit,
        titulo: 'Test Book',
        autor: 'Test Author',
        categoriasIds: [1, 2],
      );

      expect(result, isTrue);
      verify(
        () => mockCubit.subirLibro(
          titulo: 'Test Book',
          autor: 'Test Author',
          categoriasIds: [1, 2],
        ),
      ).called(1);
    });
  });
}
