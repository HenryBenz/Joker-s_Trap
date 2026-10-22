import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class AudioIconButton extends StatelessWidget {
  const AudioIconButton({
    super.key,
    required this.muted,
    required this.onPressed,
  });

  final bool muted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: muted ? 'Unmute' : 'Mute',
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(
          muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
