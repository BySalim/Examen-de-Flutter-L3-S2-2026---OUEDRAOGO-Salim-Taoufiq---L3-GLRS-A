import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/amount_keypad.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/sheet_widgets.dart';
import '../auth/session_provider.dart';
import 'transfer_provider.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TransferProvider>(
      create: (ctx) => TransferProvider(
        ctx.read<ApiClient>(),
        ctx.read<SessionProvider>(),
      ),
      child: const _TransferView(),
    );
  }
}

class _TransferView extends StatefulWidget {
  const _TransferView();

  @override
  State<_TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<_TransferView> {
  final _phoneController = TextEditingController(text: '+221');
  String _amount = '';
  String? _error;
  bool _opening = false;

  static final RegExp _phonePattern = RegExp(r'^\+221\d{9}$');

  int get _amountValue => _amount.isEmpty ? 0 : int.parse(_amount);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_amount.length >= 9) return;
    if (_amount.isEmpty && digit == '0') return;
    setState(() => _amount += digit);
  }

  void _onDelete() {
    if (_amount.isEmpty) return;
    setState(() => _amount = _amount.substring(0, _amount.length - 1));
  }

  Future<void> _continue() async {
    if (_opening) return;

    final session = context.read<SessionProvider>();
    final phone = _phoneController.text.trim();
    final amount = _amountValue;

    String? error;
    if (!_phonePattern.hasMatch(phone)) {
      error = 'Numéro destinataire invalide (format +221 puis 9 chiffres).';
    } else if (phone == session.phone) {
      error = 'Vous ne pouvez pas transférer vers votre propre numéro.';
    } else if (amount <= 0) {
      error = 'Saisissez un montant à transférer.';
    } else if (amount > session.balance) {
      error = 'Solde insuffisant pour ce transfert.';
    }

    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _error = null);
    FocusScope.of(context).unfocus();

    _opening = true;
    try {
      final provider = context.read<TransferProvider>();
      final success = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ConfirmSheet(
          provider: provider,
          receiverPhone: phone,
          amount: amount,
        ),
      );
      if (success == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Transfert')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  LengthLimitingTextInputFormatter(13),
                ],
                decoration: const InputDecoration(
                  labelText: 'Numéro du destinataire',
                  hintText: '+221770000002',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Montant à envoyer',
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        Formatters.money(_amountValue),
                        maxLines: 1,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Solde : ${Formatters.money(session.balance)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.debit),
                      ),
                    ],
                  ],
                ),
              ),
              AmountKeypad(onDigit: _onDigit, onDelete: _onDelete),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Continuer',
                icon: Icons.arrow_forward_rounded,
                onPressed: _continue,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SheetState { confirm, loading, success, error }

class _ConfirmSheet extends StatefulWidget {
  final TransferProvider provider;
  final String receiverPhone;
  final int amount;

  const _ConfirmSheet({
    required this.provider,
    required this.receiverPhone,
    required this.amount,
  });

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  _SheetState _state = _SheetState.confirm;

  Future<void> _submit() async {
    setState(() => _state = _SheetState.loading);
    final ok = await widget.provider.submit(
      receiverPhone: widget.receiverPhone,
      amount: widget.amount,
    );
    if (!mounted) return;
    setState(() => _state = ok ? _SheetState.success : _SheetState.error);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
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
        final result = widget.provider.result;
        return Column(
          children: [
            const StatusIcon(icon: Icons.check_rounded, color: AppColors.credit),
            const SizedBox(height: 18),
            Text('Transfert réussi', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            SummaryRow(label: 'Montant', value: Formatters.money(widget.amount)),
            SummaryRow(
                label: 'Destinataire',
                value: Formatters.phone(widget.receiverPhone)),
            if (result != null)
              SummaryRow(
                label: 'Nouveau solde',
                value: Formatters.money(result.senderBalanceAfter),
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
            const StatusIcon(icon: Icons.close_rounded, color: AppColors.debit),
            const SizedBox(height: 18),
            Text('Transfert échoué', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              widget.provider.error ?? 'Une erreur est survenue.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
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
            Text('Confirmer le transfert',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            SummaryRow(label: 'Montant', value: Formatters.money(widget.amount)),
            SummaryRow(
                label: 'Destinataire',
                value: Formatters.phone(widget.receiverPhone)),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
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
