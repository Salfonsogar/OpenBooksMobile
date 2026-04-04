import 'package:flutter/material.dart';
import 'app_initializer.dart';
import 'app.dart';
import 'di/app_injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();
  runApp(OpenBooksApp(injector: injector));
}