import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import 'ornate_frame.dart';
import 'png_button.dart';

class AppHaptics {
  static Future<void> light(bool enabled) async {
    if (enabled) await HapticFeedback.lightImpact();
  }

  static Future<void> medium(bool enabled) async {
    if (enabled) await HapticFeedback.mediumImpact();
  }

  static Future<void> success(bool enabled) async {
    if (enabled) await HapticFeedback.successNotification();
  }

  static Future<void> error(bool enabled) async {
    if (enabled) await HapticFeedback.errorNotification();
  }
}

Future<bool> showGameDialog({
  required BuildContext context,
  required String title,
  required String body,
  required String cancelLabel,
  required String confirmLabel,
  bool barrierDismissible = true,
  bool destructive = false,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    pageBuilder: (context, _, _) {
      return PopScope(
        canPop: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: OrnateFrame(
                          asset: AssetPaths.dialogFrame,
                          left: 0.14,
                          top: 0.23,
                          right: 0.14,
                          bottom: 0.25,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.display(18, shadow: false),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                body,
                                textAlign: TextAlign.center,
                                style: AppTheme.body(14, height: 1.3, shadow: false),
                              ),
                              const SizedBox(height: 12),
                              if (cancelLabel != confirmLabel) ...[
                                PngButton(
                                  label: cancelLabel,
                                  asset: AssetPaths.buttonSecondary,
                                  height: 52,
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                const SizedBox(height: 8),
                              ],
                              PngButton(
                                label: confirmLabel,
                                asset: destructive ? AssetPaths.buttonPrimary : AssetPaths.buttonGold,
                                darkenOnPress: !destructive,
                                inkLabel: !destructive,
                                height: 52,
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
  return result ?? false;
}

void showGameToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 24,
      right: 24,
      bottom: 48,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Material(
            color: AppColors.royalPurple,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(message, textAlign: TextAlign.center, style: AppTheme.body(15)),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future<void>.delayed(const Duration(seconds: 2), () {
    if (entry.mounted) entry.remove();
  });
}
