// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_injector.dart';

// Library cubits now scoped - use BlocProvider in router/pages
class LibraryProviders {
  static List<BlocProvider> build(AppInjector inj) {
    return [];
  }
}