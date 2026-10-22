import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'png_button.dart';

enum JokerMotion { idle, laugh, shock, bow }

class JokerPortrait extends StatefulWidget {
  const JokerPortrait({
    super.key,
    required this.asset,
    this.blinkAsset,
    this.motion = JokerMotion.idle,
    this.reduceMotion = false,
    this.height,
  });

  final String asset;
  final String? blinkAsset;
  final JokerMotion motion;
  final bool reduceMotion;
  final double? height;

  @override
  State<JokerPortrait> createState() => _JokerPortraitState();
}

class _JokerPortraitState extends State<JokerPortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);
  Timer? _blinkTimer;
  bool _eyesClosed = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    if (widget.blinkAsset == null) return;
    final wait = 4000 + _random.nextInt(3001);
    _blinkTimer = Timer(Duration(milliseconds: wait), _blink);
  }

  Future<void> _blink() async {
    if (!mounted || widget.blinkAsset == null) return;
    for (var i = 0; i < 2; i++) {
      if (!mounted) return;
      setState(() => _eyesClosed = true);
      await Future<void>.delayed(const Duration(milliseconds: 110));
      if (!mounted) return;
      setState(() => _eyesClosed = false);
      if (i == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 90));
      }
    }
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(JokerPortrait oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion) {
      _float.stop();
    } else if (!_float.isAnimating && widget.motion == JokerMotion.idle) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = PngAsset(
      path: _eyesClosed && widget.blinkAsset != null
          ? widget.blinkAsset!
          : widget.asset,
      fit: BoxFit.contain,
    );
    Widget child = image;
    if (!widget.reduceMotion && widget.motion == JokerMotion.idle) {
      child = AnimatedBuilder(
        animation: _float,
        builder: (context, portrait) {
          return Transform.translate(
            offset: Offset(0, -6 * _float.value),
            child: portrait,
          );
        },
        child: image,
      );
    } else if (!widget.reduceMotion && widget.motion == JokerMotion.laugh) {
      child = const _LaughMotion(child: SizedBox.shrink());
    }
    if (widget.motion == JokerMotion.laugh && !widget.reduceMotion) {
      child = _LaughMotion(child: image);
    } else if (widget.motion == JokerMotion.shock && !widget.reduceMotion) {
      child = _ShockMotion(child: image);
    }
    return SizedBox(height: widget.height, child: child);
  }
}

class _LaughMotion extends StatefulWidget {
  const _LaughMotion({required this.child});
  final Widget child;

  @override
  State<_LaughMotion> createState() => _LaughMotionState();
}

class _LaughMotionState extends State<_LaughMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = sin(_controller.value * pi * 6);
        return Transform.rotate(
          angle: wave * 2 * pi / 180,
          child: Transform.scale(
            scale: 1 + (sin(_controller.value * pi * 2).abs() * 0.03),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _ShockMotion extends StatefulWidget {
  const _ShockMotion({required this.child});
  final Widget child;

  @override
  State<_ShockMotion> createState() => _ShockMotionState();
}

class _ShockMotionState extends State<_ShockMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scale = t < 180 / 480
            ? 1 + (0.08 * (t / (180 / 480)))
            : 1.08 - (0.08 * ((t - 180 / 480) / (300 / 480)));
        return Transform.scale(scale: scale.clamp(1, 1.08), child: child);
      },
      child: widget.child,
    );
  }
}
