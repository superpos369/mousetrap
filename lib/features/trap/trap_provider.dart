import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants.dart';

enum TrapState { idle, snapping, snapped, resetting }

class TrapProvider extends ChangeNotifier {
  TrapState _state = TrapState.idle;
  TrapState get state => _state;

  bool get isIdle => _state == TrapState.idle;
  bool get isSnapped => _state == TrapState.snapped;

  final AudioPlayer _player = AudioPlayer();

  Future<void> trigger() async {
    if (_state != TrapState.idle) return;

    _state = TrapState.snapping;
    notifyListeners();

    // Haptic — heavy impact for the snap
    await HapticFeedback.heavyImpact();

    // Play snap sound
    await _player.play(AssetSource(AppAssets.snapSound.replaceFirst('assets/', '')));

    // Wait for snap animation to finish
    await Future.delayed(const Duration(milliseconds: 350));

    _state = TrapState.snapped;
    notifyListeners();
  }

  Future<void> reset() async {
    if (_state != TrapState.snapped) return;

    _state = TrapState.resetting;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    _state = TrapState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
