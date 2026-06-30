import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/app_logo.dart';

class BadWalletApp extends StatelessWidget {
  const BadWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BadWallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _BootScreen(),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: AppLogo(size: 96, showWordmark: true)),
    );
  }
}
