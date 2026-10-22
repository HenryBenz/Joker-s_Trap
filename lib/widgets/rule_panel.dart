import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/asset_paths.dart';
import '../data/rule_catalog.dart';
import '../models/rule_model.dart';
import 'ornate_frame.dart';

class RulePanel extends StatelessWidget {
  const RulePanel({
    super.key,
    required this.rule,
    required this.label,
    required this.onTap,
    this.compact = false,
    this.gold = false,
    this.dimmed = false,
    this.height,
  });

  final RuleId rule;
  final String label;
  final VoidCallback onTap;
  final bool compact;
  final bool gold;
  final bool dimmed;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final model = RuleCatalog.byId(rule);
    final short = MediaQuery.sizeOf(context).height < 700;
    final panelHeight = height ?? (compact ? (short ? 108.0 : 128.0) : (short ? 128.0 : 152.0));
    final nameSize = compact ? (short ? 13.0 : 14.0) : (short ? 15.0 : 16.0);
    final bodySize = compact ? (short ? 11.0 : 12.0) : (short ? 12.0 : 13.0);
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: panelHeight,
          width: double.infinity,
          child: OrnateFrame(
            asset: compact ? AssetPaths.panelRuleOption : AssetPaths.panelRule,
            left: 0.13,
            top: compact ? 0.24 : 0.27,
            right: 0.13,
            bottom: compact ? 0.26 : 0.29,
            highlight: gold ? AppColors.gold.withValues(alpha: 0.22) : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.body(compact ? 10 : 11, color: AppColors.gold, height: 1, shadow: false),
                ),
                const SizedBox(height: 2),
                Text(
                  model.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.display(nameSize, shadow: false).copyWith(height: 1.05),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    model.condition,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTheme.body(bodySize, height: 1.15, shadow: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
