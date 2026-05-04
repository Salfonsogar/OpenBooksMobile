// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_injector.dart';

class ReaderProviders {
  static List<BlocProvider> build(AppInjector inj) {
    return [
      BlocProvider.value(value: inj.settingsCubit),
    ];
  }
}