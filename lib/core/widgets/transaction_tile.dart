import 'package:flutter/material.dart';

import '../../models/wallet_transaction.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransaction tx;

  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tx.isCredit ? AppColors.credit : AppColors.debit;
    final sign = tx.isCredit ? '+' : '−';
    final detail = _detail();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconFor(tx.type), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelFor(tx),
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tx.createdAt != null ? Formatters.dateTime(tx.createdAt!) : '—',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign ${Formatters.money(tx.amount)}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
              if (detail != null) ...[
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String? _detail() {
    if (tx.type == TransactionType.transfer && tx.counterpartyPhone != null) {
      return Formatters.phone(tx.counterpartyPhone!);
    }
    if (tx.type == TransactionType.payment && tx.reference != null) {
      return tx.reference;
    }
    return null;
  }

  static IconData _iconFor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.south_west_rounded;
      case TransactionType.withdraw:
        return Icons.north_east_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
      case TransactionType.payment:
        return Icons.receipt_long_rounded;
      case TransactionType.unknown:
        return Icons.receipt_rounded;
    }
  }

  static String _labelFor(WalletTransaction tx) {
    switch (tx.type) {
      case TransactionType.deposit:
        return 'Dépôt';
      case TransactionType.withdraw:
        return 'Retrait';
      case TransactionType.transfer:
        return tx.isCredit ? 'Transfert reçu' : 'Transfert émis';
      case TransactionType.payment:
        return 'Paiement facture';
      case TransactionType.unknown:
        return tx.description ?? 'Transaction';
    }
  }
}
