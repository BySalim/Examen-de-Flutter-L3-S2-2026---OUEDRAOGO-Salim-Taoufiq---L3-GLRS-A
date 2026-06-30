import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/view_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/transaction_tile.dart';
import '../auth/session_provider.dart';
import '../transfers/transfer_screen.dart';
import 'dashboard_provider.dart';

class DashboardPage extends StatefulWidget {
  final ValueChanged<int> onGoToTab;

  const DashboardPage({super.key, required this.onGoToTab});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _hidden = false;

  Future<void> _openTransfer() async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TransferScreen()),
    );
    if (!mounted) return;
    if (done == true) {
      context.read<DashboardProvider>().load();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Transfert effectué avec succès.'),
          backgroundColor: AppColors.credit,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () => context.read<DashboardProvider>().load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _Greeting(phone: session.phone),
              const SizedBox(height: 20),
              _BalanceCard(
                balance: session.balance,
                code: session.walletCode,
                hidden: _hidden,
                onToggle: () => setState(() => _hidden = !_hidden),
              ),
              const SizedBox(height: 24),
              _QuickActions(
                onTransfer: _openTransfer,
                onPay: () => widget.onGoToTab(2),
                onHistory: () => widget.onGoToTab(1),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transactions récentes',
                      style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => widget.onGoToTab(1),
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _RecentList(dashboard: dashboard),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String phone;

  const _Greeting({required this.phone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour 👋', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(Formatters.phone(phone), style: theme.textTheme.titleLarge),
            ],
          ),
        ),
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.notifications_none_rounded,
              color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final num balance;
  final String code;
  final bool hidden;
  final VoidCallback onToggle;

  const _BalanceCard({
    required this.balance,
    required this.code,
    required this.hidden,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.balanceGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde disponible',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  hidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                hidden ? '•  •  •  •  •' : Formatters.money(balance),
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white.withValues(alpha: 0.85), size: 18),
              const SizedBox(width: 8),
              Text(
                code,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onTransfer;
  final VoidCallback onPay;
  final VoidCallback onHistory;

  const _QuickActions({
    required this.onTransfer,
    required this.onPay,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.send_rounded,
          label: 'Transférer',
          onTap: onTransfer,
        ),
        _ActionButton(
          icon: Icons.receipt_long_rounded,
          label: 'Payer',
          onTap: onPay,
        ),
        _ActionButton(
          icon: Icons.history_rounded,
          label: 'Historique',
          onTap: onHistory,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.brand, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _RecentList extends StatelessWidget {
  final DashboardProvider dashboard;

  const _RecentList({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    if (dashboard.status.isLoading && dashboard.recent.isEmpty) {
      return Column(
        children: List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerBox(height: 70),
          ),
        ),
      );
    }

    if (dashboard.status.isError && dashboard.recent.isEmpty) {
      return ErrorView(
        message: dashboard.error ?? 'Impossible de charger les transactions.',
        onRetry: () => context.read<DashboardProvider>().load(),
      );
    }

    if (dashboard.recent.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: EmptyView(
          message: 'Aucune transaction pour le moment.',
          icon: Icons.receipt_long_outlined,
        ),
      );
    }

    return Column(
      children: [
        for (final tx in dashboard.recent)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TransactionTile(tx: tx),
          ),
      ],
    );
  }
}
