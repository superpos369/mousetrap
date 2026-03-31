import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../cheese/cheese_rotation.dart';
import '../cheese/cheese_widget.dart';
import 'trap_animation.dart';
import 'trap_provider.dart';

class TrapScreen extends StatefulWidget {
  const TrapScreen({super.key});

  @override
  State<TrapScreen> createState() => _TrapScreenState();
}

class _TrapScreenState extends State<TrapScreen> with TickerProviderStateMixin {
  late final CheeseRotationController _rotCtrl;
  late final AnimationController _snapCtrl;   // 0 → 1, drives snap animation
  late final AnimationController _shakeCtrl;  // screen shake on snap
  late final AnimationController _cheeseAppear; // cheese fade/scale in

  BannerAd? _bannerAd;
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();
    _rotCtrl = CheeseRotationController(vsync: this);

    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cheeseAppear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _adLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  Future<void> _onTap() async {
    final provider = context.read<TrapProvider>();

    if (provider.isIdle) {
      _rotCtrl.pause();
      await provider.trigger();
      await _snapCtrl.forward(from: 0);
      _shakeCtrl.forward(from: 0);
      _loadAd();
    } else if (provider.isSnapped) {
      // Cheese disappears
      await _cheeseAppear.reverse();
      await provider.reset();
      _snapCtrl.value = 0;
      // Cheese reappears
      await _cheeseAppear.forward();
      _rotCtrl.resume();
    }
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _snapCtrl.dispose();
    _shakeCtrl.dispose();
    _cheeseAppear.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _onTap(),
        child: Stack(
          children: [
            // Radial glow behind cheese
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _cheeseAppear,
                builder: (_, __) => Center(
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.chedddarYellow
                              .withValues(alpha: 0.15 * _cheeseAppear.value),
                          blurRadius: 120,
                          spreadRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content — cheese OR trap
            _buildContent(),

            // Tap hint (shown only in idle)
            _buildHint(),

            // AdMob banner at bottom
            if (_adLoaded && _bannerAd != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: Listenable.merge([_snapCtrl, _cheeseAppear, _rotCtrl.controller]),
      builder: (context, _) {
        final provider = context.watch<TrapProvider>();
        final isSnappedOrSnapping =
            provider.state == TrapState.snapping ||
            provider.state == TrapState.snapped;

        // Screen shake offset
        final shakeX = _shakeCtrl.isAnimating
            ? _shake(_shakeCtrl.value) * 12
            : 0.0;

        return Transform.translate(
          offset: Offset(shakeX, 0),
          child: Center(
            child: isSnappedOrSnapping
                ? _buildTrap()
                : _buildCheese(),
          ),
        );
      },
    );
  }

  Widget _buildCheese() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotCtrl.controller, _cheeseAppear]),
      builder: (_, __) => CheeseWidget(
        rotationY: _rotCtrl.radians,
        scale: _cheeseAppear.value,
      )
          .animate(target: 1)
          .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1.0, 1.0),
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  Widget _buildTrap() {
    return AnimatedBuilder(
      animation: _snapCtrl,
      builder: (_, __) => TrapAnimation(snapProgress: _snapCtrl.value)
          .animate(target: _snapCtrl.isCompleted ? 1 : 0)
          .shake(hz: 8, duration: 300.ms),
    );
  }

  Widget _buildHint() {
    return Consumer<TrapProvider>(
      builder: (_, provider, __) {
        final text = provider.isSnapped ? 'Tippen zum Zurücksetzen' : 'Berühren';
        return Positioned(
          bottom: (_adLoaded ? 70 : 32),
          left: 0,
          right: 0,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.chedddarYellow.withValues(alpha: 0.45),
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
        );
      },
    );
  }

  /// Simple triangle-wave shake
  double _shake(double t) {
    const freq = 6.0;
    final v = (t * freq) % 1.0;
    return v < 0.5 ? v * 4 - 1 : (1 - v) * 4 - 1;
  }
}
