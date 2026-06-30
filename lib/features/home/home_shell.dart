import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../auth/session_provider.dart';
import '../bills/bills_page.dart';
import '../bills/bills_provider.dart';
import '../dashboard/dashboard_page.dart';
import '../dashboard/dashboard_provider.dart';
import '../history/history_page.dart';
import '../history/history_provider.dart';
import '../profile/profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      ChangeNotifierProvider<DashboardProvider>(
        create: (ctx) => DashboardProvider(
          ctx.read<ApiClient>(),
          ctx.read<SessionProvider>(),
        )..load(),
        child: DashboardPage(onGoToTab: _goToTab),
      ),
      ChangeNotifierProvider<HistoryProvider>(
        create: (ctx) => HistoryProvider(
          ctx.read<ApiClient>(),
          ctx.read<SessionProvider>(),
        )..load(),
        child: const HistoryPage(),
      ),
      ChangeNotifierProvider<BillsProvider>(
        create: (ctx) => BillsProvider(
          ctx.read<ApiClient>(),
          ctx.read<SessionProvider>(),
        )..load(),
        child: const BillsPage(),
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.brand.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.brand),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded, color: AppColors.brand),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long_rounded, color: AppColors.brand),
            label: 'Factures',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.brand),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
