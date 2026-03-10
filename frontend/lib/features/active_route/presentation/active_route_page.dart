import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'order_selection_tab.dart';

class ActiveRoutePage extends ConsumerStatefulWidget {
  final String routeId;
  const ActiveRoutePage({super.key, required this.routeId});

  @override
  ConsumerState<ActiveRoutePage> createState() => _ActiveRoutePageState();
}

class _ActiveRoutePageState extends ConsumerState<ActiveRoutePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    final List<Widget> tabs = [
      OrderSelectionTab(routeId: widget.routeId),
      const Center(child: Text("Navigation Tab - WIP")),
      const Center(child: Text("Kundeninformation Tab - WIP")),
      const Center(child: Text("Bezahlung Tab - WIP")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.activeRoute.toUpperCase()), 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).disabledColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: loc.orders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.navigation_outlined),
            activeIcon: const Icon(Icons.navigation),
            label: loc.navigation,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: loc.customer,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.payment_outlined),
            activeIcon: const Icon(Icons.payment),
            label: loc.payment,
          ),
        ],
      ),
    );
  }
}