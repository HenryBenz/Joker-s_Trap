import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/app_theme.dart';
import '../data/rule_catalog.dart';
import '../widgets/png_button.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const _sections = [
    ('1. READ THE POSSIBILITIES', 'Every round shows an initial rule and two possible lies.'),
    ('2. LOCK AN ANCHOR', 'Your first card locks before the Joker reveals the real rule.'),
    ('3. COMPLETE THE HAND', 'Choose two more cards in order. Some rules care about selection order.'),
    ('4. SCORE THE ACT', 'Your card ranks form the base score. Satisfy the real rule to earn its bonus.'),
    ('5. USE AN OBJECTION', 'Spend one of two Objections to unlock your Anchor after the rule changes.'),
    ('6. BEAT THE JOKER', 'Equal or higher score wins the round. Win three of four rounds to clear a show.'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: ContentFrame(
          child: Column(
            children: [
              Row(
                children: [
                  IconTap(
                    icon: Icons.arrow_back_ios_new,
                    tooltip: 'Back',
                    onPressed: app.bindTap(() => context.pop()),
                  ),
                  Expanded(
                    child: Text('HOW TO PLAY', textAlign: TextAlign.center, style: AppTheme.display(22)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final section in _sections) ...[
                      Text(section.$1, style: AppTheme.display(18, color: AppColors.gold)),
                      const SizedBox(height: 6),
                      Text(section.$2, style: AppTheme.body(16)),
                      const SizedBox(height: 16),
                    ],
                    for (final rule in RuleCatalog.rules)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.royalPurple.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rule.name, style: AppTheme.display(16)),
                            Text(rule.condition, style: AppTheme.body(14)),
                            Text('+${rule.bonus}', style: AppTheme.body(14, color: AppColors.gold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
