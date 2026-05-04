// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter_bloc/flutter_bloc.dart';
import 'di/app_injector.dart';
import 'di/providers/core_providers.dart';
import 'di/providers/library_providers.dart';
import 'di/providers/user_providers.dart';
import 'di/providers/reader_providers.dart';

class AppProviders {
  static List<BlocProvider> build(AppInjector injector) {
    return [
      ...CoreProviders.build(injector),
      ...LibraryProviders.build(injector),
      ...UserProviders.build(injector),
      ...ReaderProviders.build(injector),
    ];
  }
}