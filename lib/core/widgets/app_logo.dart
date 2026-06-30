import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const AppLogo({super.key, this.size = 64, this.showWordmark = false});

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(height: 18),
        Text(
          'BadWallet',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
