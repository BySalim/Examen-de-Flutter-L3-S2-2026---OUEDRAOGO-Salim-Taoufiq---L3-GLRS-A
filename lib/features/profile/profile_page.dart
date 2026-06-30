import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../auth/session_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionProvider>();
    final wallet = session.wallet;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  height: 84,
                  width: 84,
                  decoration: BoxDecoration(
                    gradient: AppColors.balanceGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 16),
                Text(
                  Formatters.phone(session.phone),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(session.walletCode, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _InfoTile(
            icon: Icons.phone_iphone_rounded,
            label: 'Numéro de téléphone',
            value: Formatters.phone(session.phone),
          ),
          _InfoTile(
            icon: Icons.qr_code_rounded,
            label: 'Code portefeuille',
            value: session.walletCode,
          ),
          if (wallet != null && wallet.email.isNotEmpty)
            _InfoTile(
              icon: Icons.alternate_email_rounded,
              label: 'Email',
              value: wallet.email,
            ),
          _InfoTile(
            icon: Icons.savings_rounded,
            label: 'Devise',
            value: wallet?.currency ?? 'XOF',
          ),
          if (wallet?.createdAt != null)
            _InfoTile(
              icon: Icons.event_rounded,
              label: 'Membre depuis',
              value: Formatters.date(wallet!.createdAt!),
            ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => context.read<SessionProvider>().logout(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.debit,
              side: const BorderSide(color: AppColors.debit),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.brand, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
