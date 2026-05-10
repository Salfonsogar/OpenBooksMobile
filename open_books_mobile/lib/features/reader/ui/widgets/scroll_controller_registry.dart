import 'package:flutter/material.dart';

class ScrollControllerRegistry {
  final Map<int, ScrollController> _controllers = {};

  ScrollController getController(int index) {
    return _controllers.putIfAbsent(index, () => ScrollController());
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  bool hasController(int index) => _controllers.containsKey(index);
  ScrollController? controller(int index) => _controllers[index];
}