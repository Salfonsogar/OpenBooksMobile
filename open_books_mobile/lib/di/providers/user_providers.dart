import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_injector.dart';

// User cubits now scoped - use BlocProvider in router/pages
class UserProviders {
  static List<BlocProvider> build(AppInjector inj) {
    return [];
  }
}