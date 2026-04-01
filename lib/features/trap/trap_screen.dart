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
  late final AnimationController _snapCtrl;
  late final AnimationController _shakeCtrl;
  late final AnimationController _cheeseAppear;
  late final AnimationController _glowPulse;

  BannerAd? _bannerAd;
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();
    _rotCtrl = CheeseRotationController(vsync: this);

    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _cheeseAppear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      value: 1.0,
    );

    _glowPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
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
      _snapCtrl.forward(from: 0);
      _shakeCtrl.forward(from: 0);
      _loadAd();
    } else if (provider.isSnapped) {
      await _cheeseAppear.reverse();
      await provider.reset();
      _snapCtrl.value = 0;
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
    _glowPulse.dispose();
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
            // Subtle radial bg gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.1),
                    radius: 0.85,
                    colors: [
                      Color(0xFF1A1000),
                      Color(0xFF000000),
                    ],
                  ),
                ),
              ),
            ),

            // Animated glow
            _buildGlow(),

            // Main content
            _buildContent(),

            // Hint
            _buildHint(),

            // Ad
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

  Widget _buildGlow() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowPulse, _cheeseAppear]),
      builder: (_, __) {
        final pulse = 0.10 + _glowPulse.value * 0.07;
        return Positioned.fill(
          child: Center(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.chedddarYellow
                        .withValues(alpha: pulse * _cheeseAppear.value),
                    blurRadius: 130,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: Listenable.merge([_snapCtrl, _cheeseAppear, _shakeCtrl]),
      builder: (context, _) {
        final provider = context.watch<TrapProvider>();
        final isSnappedOrSnapping =
            provider.state == TrapState.snapping ||
            provider.state == TrapState.snapped;

        final shakeX = _shakeCtrl.isAnimating
            ? _shake(_shakeCtrl.value) * 14
            : 0.0;

        return Transform.translate(
          offset: Offset(shakeX, 0),
          child: Center(
            child: isSnappedOrSnapping ? _buildTrap() : _buildCheese(),
          ),
        );
      },
    );
  }

  Widget _buildCheese() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotCtrl.controller, _cheeseAppear]),
      builder: (_, __) => Transform.scale(
        scale: _cheeseAppear.value,
        child: Opacity(
          opacity: _cheeseAppear.value.clamp(0.0, 1.0),
          child: CheeseWidget(rotationY: _rotCtrl.radians),
        ),
      ),
    );
  }

  Widget _buildTrap() {
    return AnimatedBuilder(
      animation: _snapCtrl,
      builder: (_, __) => TrapAnimation(snapProgress: _snapCtrl.value),
    );
  }

  Widget _buildHint() {
    return Consumer<TrapProvider>(
      builder: (_, provider, __) {
        final text = provider.isSnapped
            ? 'TAP TO RESET'
            : 'TAP TO TRIGGER';

        return Positioned(
          bottom: (_adLoaded ? 72 : 36),
          left: 0,
          right: 0,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0x55F4A800),
              fontSize: 11,
              letterSpacing: 4,
              fontWeight: FontWeight.w500,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 900.ms)
              .then()
              .fadeOut(duration: 900.ms),
        );
      },
    );
  }

  double _shake(double t) {
    const freq = 7.0;
    final v = (t * freq) % 1.0;
    return v < 0.5 ? v * 4 - 1 : (1 - v) * 4 - 1;
  }
}
