import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../widgets/png_button.dart';

class RoundResultOverlay extends StatelessWidget {
  const RoundResultOverlay({
    super.key,
    required this.won,
    required this.tied,
    required this.playerTotal,
    required this.jokerTotal,
    required this.finalRound,
    required this.onNext,
  });

  final bool won;
  final bool tied;
  final int playerTotal;
  final int jokerTotal;
  final bool finalRound;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final title = won ? 'YOU CAUGHT THE LIE' : 'THE JOKER LAUGHS';
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.84),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              child: AspectRatio(
                aspectRatio: 1080 / 1550,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    return Stack(
                      children: [
                        const Positioned.fill(
                          child: PngAsset(path: AssetPaths.panelResult, fit: BoxFit.fill),
                        ),
                        Positioned(
                          left: w * 0.18,
                          right: w * 0.18,
                          top: h * 0.275,
                          height: h * 0.055,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: AppTheme.display(26, shadow: false),
                            ),
                          ),
                        ),
                        Positioned(
                          left: w * 0.16,
                          right: w * 0.16,
                          top: h * 0.34,
                          bottom: h * (tied ? 0.38 : 0.34),
                          child: PngAsset(
                            path: won ? AssetPaths.jokerReactionLose : AssetPaths.jokerReactionWin,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          left: w * 0.16,
                          right: w * 0.16,
                          top: h * (tied ? 0.63 : 0.665),
                          height: h * 0.04,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'YOUR $playerTotal   •   JOKER $jokerTotal',
                              textAlign: TextAlign.center,
                              style: AppTheme.body(18, shadow: false),
                            ),
                          ),
                        ),
                        if (tied)
                          Positioned(
                            left: w * 0.16,
                            right: w * 0.16,
                            top: h * 0.685,
                            height: h * 0.045,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'THE PLAYER\'S MERCY — TIES BELONG TO YOU',
                                textAlign: TextAlign.center,
                                style: AppTheme.body(14, color: AppColors.gold, shadow: false),
                              ),
                            ),
                          ),
                        Positioned(
                          left: w * 0.205,
                          right: w * 0.205,
                          top: h * 0.818,
                          bottom: h * 0.098,
                          child: _PlaqueButton(
                            label: finalRound ? 'Show Results' : 'Next Round',
                            onPressed: onNext,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaqueButton extends StatefulWidget {
  const _PlaqueButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_PlaqueButton> createState() => _PlaqueButtonState();
}

class _PlaqueButtonState extends State<_PlaqueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: _pressed ? const Color(0x55000000) : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.label,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: AppTheme.body(20, color: AppColors.cream, weight: FontWeight.w800, height: 1, shadow: false)
                .copyWith(
                  shadows: const [
                    Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
