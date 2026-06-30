import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/home_shell.dart';
import 'login_screen.dart';
import 'session_provider.dart';
import 'splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();

    final Widget child;
    if (session.restoring) {
      child = const SplashScreen();
    } else if (session.isAuthenticated) {
      child = const HomeShell();
    } else {
      child = const LoginScreen();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: child,
    );
  }
}
