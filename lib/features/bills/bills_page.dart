import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/state/view_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../models/facture.dart';
import '../auth/session_provider.dart';
import 'bills_provider.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Factures')),
      body: SafeArea(
        child: Column(
          children: [
            if (provider.availableServices.length > 1)
              _FilterBar(provider: provider),
            Expanded(child: _Body(provider: provider)),
            if (provider.selectedTotal > 0) _PayBar(provider: provider),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final BillsProvider provider;

  const _Body({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.status.isLoading && provider.factures.isEmpty) {
      return const ListShimmer();
    }
    if (provider.status.isError && provider.factures.isEmpty) {
      return ErrorView(
        message: provider.error ?? 'Impossible de charger les factures.',
        onRetry: () => context.read<BillsProvider>().load(),
      );
    }
    if (provider.factures.isEmpty) {
      return const EmptyView(
        message: 'Aucune facture impayée.\nVous êtes à jour 🎉',
        icon: Icons.task_alt_rounded,
      );
    }

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () => context.read<BillsProvider>().load(),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: provider.factures.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final facture = provider.factures[index];
          return _FactureTile(
            facture: facture,
            selected: provider.isSelected(facture.reference),
            onToggle: () =>
                context.read<BillsProvider>().toggle(facture.reference),
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final BillsProvider provider;

  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final services = provider.availableServices;
    return SizedBox(
      height: 58,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _FilterChip(
            label: 'Tous',
            selected: provider.filter == null,
            onTap: () => context.read<BillsProvider>().setFilter(null),
          ),
          for (final service in services)
            _FilterChip(
              label: service,
              selected: provider.filter == service,
              onTap: () => context.read<BillsProvider>().setFilter(service),
            ),
        ],
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

class _FactureTile extends StatelessWidget {
  final Facture facture;
  final bool selected;
  final VoidCallback onToggle;

  const _FactureTile({
    required this.facture,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.serviceColor(facture.serviceName);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.receipt_long_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(facture.serviceName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.periode(facture.periode)} · ${facture.reference}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Formatters.money(facture.montant),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 10),
            _SelectCircle(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SelectCircle extends StatelessWidget {
  final bool selected;

  const _SelectCircle({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.brand : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.brand : AppColors.border,
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : null,
    );
  }
}

class _PayBar extends StatelessWidget {
  final BillsProvider provider;

  const _PayBar({required this.provider});

  Future<void> _pay(BuildContext context) async {
    final count = provider.selected.length;
    final total = provider.selectedTotal;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _PayConfirmSheet(provider: provider, count: count, total: total),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${provider.selected.length} sélectionnée(s)',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(Formatters.money(provider.selectedTotal),
                  style: theme.textTheme.titleLarge),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 160,
            child: PrimaryButton(
              label: 'Payer',
              icon: Icons.bolt_rounded,
              onPressed: () => _pay(context),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SheetState { confirm, loading, success, error }

class _PayConfirmSheet extends StatefulWidget {
  final BillsProvider provider;
  final int count;
  final num total;

  const _PayConfirmSheet({
    required this.provider,
    required this.count,
    required this.total,
  });

  @override
  State<_PayConfirmSheet> createState() => _PayConfirmSheetState();
}

class _PayConfirmSheetState extends State<_PayConfirmSheet> {
  _SheetState _state = _SheetState.confirm;

  Future<void> _submit() async {
    setState(() => _state = _SheetState.loading);
    final ok = await widget.provider.paySelected();
    if (!mounted) return;
    setState(() => _state = ok ? _SheetState.success : _SheetState.error);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 44,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    switch (_state) {
      case _SheetState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: CircularProgressIndicator(),
        );
      case _SheetState.success:
        final session = context.read<SessionProvider>();
        return Column(
          children: [
            _StatusIcon(icon: Icons.check_rounded, color: AppColors.credit),
            const SizedBox(height: 18),
            Text('Paiement réussi', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            _SummaryRow(
              label: 'Factures payées',
              value: '${widget.provider.lastPaidCount}',
            ),
            _SummaryRow(
              label: 'Total payé',
              value: Formatters.money(widget.provider.lastPaidTotal),
            ),
            _SummaryRow(
              label: 'Nouveau solde',
              value: Formatters.money(session.balance),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Terminé',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      case _SheetState.error:
        return Column(
          children: [
            _StatusIcon(icon: Icons.close_rounded, color: AppColors.debit),
            const SizedBox(height: 18),
            Text('Paiement échoué', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              widget.provider.paymentError ?? 'Une erreur est survenue.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Fermer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(label: 'Réessayer', onPressed: _submit),
                ),
              ],
            ),
          ],
        );
      case _SheetState.confirm:
        return Column(
          children: [
            Text('Payer les factures', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            _SummaryRow(label: 'Factures', value: '${widget.count}'),
            _SummaryRow(
                label: 'Total', value: Formatters.money(widget.total)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(label: 'Confirmer', onPressed: _submit),
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _StatusIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 40),
    ).animate().scale(
          duration: 350.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.5, 0.5),
        );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
