import 'package:flutter/material.dart';

/// Drives the slow idle rotation of the cheese.
/// Pauses when the trap fires, resets when cheese reappears.
class CheeseRotationController {
  final AnimationController controller;

  CheeseRotationController({required TickerProvider vsync})
      : controller = AnimationController(
          vsync: vsync,
          duration: const Duration(seconds: 8),
        ) {
    controller.repeat();
  }

  /// Current rotation in radians (0 → 2π)
  double get radians => controller.value * 2 * 3.14159265;

  void pause() => controller.stop();

  void resume() => controller.repeat();

  void dispose() => controller.dispose();
}
