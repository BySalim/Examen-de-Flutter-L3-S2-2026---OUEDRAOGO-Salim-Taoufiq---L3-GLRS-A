import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/state/view_status.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/amount_keypad.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/primary_button.dart';
import 'session_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+221');

  bool _pinStep = false;
  String _phone = '';
  String _pin = '';

  static final RegExp _phonePattern = RegExp(r'^\+221\d{9}$');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _goToPin() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      setState(() {
        _phone = _phoneController.text.trim();
        _pinStep = true;
      });
    }
  }

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() => _pin += digit);
    if (_pin.length == 4) _submit();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    final session = context.read<SessionProvider>();
    final ok = await session.login(_phone);
    if (!ok && mounted) {
      setState(() {
        _pin = '';
        _pinStep = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(session.error ?? 'Connexion impossible.'),
          backgroundColor: AppColors.debit,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<SessionProvider>().status.isLoading;

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pinStep
              ? _PinView(
                  key: const ValueKey('pin'),
                  phone: _phone,
                  pin: _pin,
                  loading: loading,
                  onDigit: _onDigit,
                  onDelete: _onDelete,
                  onBack: () => setState(() {
                    _pinStep = false;
                    _pin = '';
                  }),
                )
              : _PhoneView(
                  key: const ValueKey('phone'),
                  formKey: _formKey,
                  controller: _phoneController,
                  pattern: _phonePattern,
                  onContinue: _goToPin,
                ),
        ),
      ),
    );
  }
}

class _PhoneView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final RegExp pattern;
  final VoidCallback onContinue;

  const _PhoneView({
    super.key,
    required this.formKey,
    required this.controller,
    required this.pattern,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const AppLogo(size: 60),
          const SizedBox(height: 32),
          Text('Bienvenue', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Connectez-vous avec votre numéro BadWallet pour accéder à votre portefeuille.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 36),
          Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                LengthLimitingTextInputFormatter(13),
              ],
              style: theme.textTheme.titleMedium,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: '+221770000003',
                prefixIcon: Icon(Icons.phone_iphone_rounded),
              ),
              validator: (value) {
                final v = (value ?? '').trim();
                if (!pattern.hasMatch(v)) {
                  return 'Format attendu : +221 suivi de 9 chiffres.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text('Démo : +221770000003',
                  style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Continuer',
            icon: Icons.arrow_forward_rounded,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _PinView extends StatelessWidget {
  final String phone;
  final String pin;
  final bool loading;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onBack;

  const _PinView({
    super.key,
    required this.phone,
    required this.pin,
    required this.loading,
    required this.onDigit,
    required this.onDelete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: loading ? null : onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Text('Code secret', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Saisissez votre code à 4 chiffres pour ${Formatters.phone(phone)}.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 36),
          if (loading)
            const SizedBox(
              height: 16,
              child: Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.brand : Colors.transparent,
                    border: Border.all(
                      color: filled ? AppColors.brand : AppColors.border,
                      width: 1.6,
                    ),
                  ),
                );
              }),
            ),
          const Spacer(),
          IgnorePointer(
            ignoring: loading,
            child: AmountKeypad(onDigit: onDigit, onDelete: onDelete),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
