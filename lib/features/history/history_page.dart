import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/view_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/transaction_tile.dart';
import '../../models/wallet_transaction.dart';
import 'history_provider.dart';

class _Filter {
  final String label;
  final TransactionType? type;

  const _Filter(this.label, this.type);
}

const List<_Filter> _filters = [
  _Filter('Tous', null),
  _Filter('Dépôts', TransactionType.deposit),
  _Filter('Retraits', TransactionType.withdraw),
  _Filter('Transferts', TransactionType.transfer),
  _Filter('Paiements', TransactionType.payment),
];

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  for (final filter in _filters)
                    _FilterChip(
                      label: filter.label,
                      selected: provider.filter == filter.type,
                      onTap: () =>
                          context.read<HistoryProvider>().setFilter(filter.type),
                    ),
                ],
              ),
            ),
            Expanded(child: _Body(provider: provider)),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final HistoryProvider provider;

  const _Body({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.status.isLoading && provider.transactions.isEmpty) {
      return const ListShimmer();
    }
    if (provider.status.isError && provider.transactions.isEmpty) {
      return ErrorView(
        message: provider.error ?? 'Impossible de charger l\'historique.',
        onRetry: () => context.read<HistoryProvider>().load(),
      );
    }
    if (provider.transactions.isEmpty) {
      return const EmptyView(
        message: 'Aucune transaction à afficher.',
        icon: Icons.history_rounded,
      );
    }

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () => context.read<HistoryProvider>().load(),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: provider.transactions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            TransactionTile(tx: provider.transactions[index]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.brand : AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
