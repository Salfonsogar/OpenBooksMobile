import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'cubit/upload_libro_cubit.dart';

class PickPortadaResult {
  final String? portadaBase64;

  const PickPortadaResult({this.portadaBase64});
}

class PickArchivoResult {
  final String? archivoBase64;
  final String? nombreArchivo;

  const PickArchivoResult({this.archivoBase64, this.nombreArchivo});
}

class UploadLibroController {
  final ImagePicker _imagePicker;
  final FilePicker _filePicker;

  UploadLibroController({
    ImagePicker? imagePicker,
    FilePicker? filePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _filePicker = filePicker ?? FilePicker.platform;

  Future<PickPortadaResult> pickPortada() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      return PickPortadaResult(portadaBase64: base64Encode(bytes));
    }

    return const PickPortadaResult();
  }

  Future<PickArchivoResult> pickArchivo() async {
    final result = await _filePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        return PickArchivoResult(
          archivoBase64: base64Encode(file.bytes!),
          nombreArchivo: file.name,
        );
      }
    }

    return const PickArchivoResult();
  }

  Future<bool> subirLibro({
    required UploadLibroCubit cubit,
    required String titulo,
    required String autor,
    String? descripcion,
    required List<int> categoriasIds,
    String? portadaBase64,
    String? archivoBase64,
    String? nombreArchivo,
  }) async {
    return cubit.subirLibro(
      titulo: titulo,
      autor: autor,
      descripcion: descripcion,
      categoriasIds: categoriasIds,
      portadaBase64: portadaBase64,
      archivoBase64: archivoBase64,
      nombreArchivo: nombreArchivo,
    );
  }
}
