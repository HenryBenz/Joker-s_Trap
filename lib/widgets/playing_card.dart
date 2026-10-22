import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../models/card_model.dart';
import 'png_button.dart';

class PlayingCard extends StatelessWidget {
  const PlayingCard({
    super.key,
    required this.card,
    this.faceDown = false,
    this.selection,
    this.orderBadge,
    this.width = 72,
  });

  final CardModel? card;
  final bool faceDown;
  final CardSelection? selection;
  final int? orderBadge;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width / 0.68;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: PngAsset(
              path: faceDown || card == null
                  ? AssetPaths.cardBack
                  : (card!.isRed
                      ? AssetPaths.cardFaceRed
                      : AssetPaths.cardFaceBlack),
              fit: BoxFit.fill,
            ),
          ),
          if (!faceDown && card != null) ...[
            Positioned(
              left: width * 0.08,
              top: height * 0.06,
              child: Text(
                '${card!.rank}',
                style: AppTheme.display(
                  width * 0.22,
                  color: card!.isRed ? AppColors.jokerRed : AppColors.ink,
                ),
              ),
            ),
            Positioned(
              right: width * 0.08,
              bottom: height * 0.06,
              child: Transform.rotate(
                angle: 3.14159,
                child: Text(
                  '${card!.rank}',
                  style: AppTheme.display(
                    width * 0.22,
                    color: card!.isRed ? AppColors.jokerRed : AppColors.ink,
                  ),
                ),
              ),
            ),
            PngAsset(
              path: AssetPaths.suitAsset(card!.suit.name),
              fit: BoxFit.contain,
            ),
          ],
          if (selection != null)
            Positioned.fill(
              child: PngAsset(
                path: selection == CardSelection.anchor
                    ? AssetPaths.cardSelectionAnchor
                    : AssetPaths.cardSelectionNormal,
                fit: BoxFit.fill,
              ),
            ),
          if (orderBadge != null)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$orderBadge',
                  style: AppTheme.body(12, color: AppColors.ink, weight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum CardSelection { anchor, normal }
