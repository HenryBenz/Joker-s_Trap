import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/asset_paths.dart';

class PngAsset extends StatelessWidget {
  const PngAsset({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final String path;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stack) {
        if (kDebugMode) {
          return ColoredBox(
            color: const Color(0xFFFF00FF),
            child: Text(
              path,
              style: AppTheme.body(10, color: Colors.white),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class PngButton extends StatefulWidget {
  const PngButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.asset = AssetPaths.buttonPrimary,
    this.darkenOnPress = false,
    this.inkLabel = false,
    this.height = 58,
  });

  final String label;
  final VoidCallback? onPressed;
  final String asset;
  final bool darkenOnPress;
  final bool inkLabel;
  final double height;

  @override
  State<PngButton> createState() => _PngButtonState();
}

class _PngButtonState extends State<PngButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Art is 900×190. Filling a short full-width box smears the gems.
        // Art is 900×190. A full-width slot keeps that ratio. A half-width
        // slot used to shrink the plate to ~30px; keep a readable height and
        // crop the pointed ends instead of smearing the gems.
        const ratio = 900 / 190;
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : widget.height * ratio;
        final naturalW = widget.height * ratio;
        final roomy = maxW >= naturalW - 1;
        final width = roomy ? naturalW : maxW;
        final height = roomy ? widget.height : math.min(widget.height, math.max(50.0, maxW * 0.36));
        final labelSize = (height * 0.30).clamp(13.0, 17.0);
        return Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: enabled ? 1 : 0.62,
            child: GestureDetector(
              onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
              onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
              onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
              onTap: widget.onPressed,
              behavior: HitTestBehavior.opaque,
              child: AnimatedScale(
                scale: _pressed ? 0.96 : 1,
                duration: Duration(milliseconds: _pressed ? 80 : 120),
                child: SizedBox(
                  width: width,
                  height: math.max(height, 48),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height),
                      boxShadow: const [
                        BoxShadow(color: Color(0xF0000000), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(height * 0.45),
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          PngAsset(path: widget.asset, fit: roomy ? BoxFit.fill : BoxFit.cover),
                          if (_pressed && widget.darkenOnPress) const ColoredBox(color: Color(0x33000000)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * (roomy ? 0.14 : 0.1)),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.center,
                                style: AppTheme.body(
                                  labelSize,
                                  color: widget.inkLabel ? AppColors.ink : AppColors.cream,
                                  weight: FontWeight.w800,
                                  height: 1,
                                  shadow: false,
                                ).copyWith(
                                  shadows: [
                                    Shadow(
                                      color: widget.inkLabel ? const Color(0x66FFFFFF) : const Color(0xEE000000),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class IconTap extends StatelessWidget {
  const IconTap({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.gold),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
