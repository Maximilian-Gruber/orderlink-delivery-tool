import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/dashboard/models/route_model.dart';
import 'package:go_router/go_router.dart';
import '../logic/dashboard_controller.dart';
import '../../../l10n/app_localizations.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.openRoutes.toUpperCase(),
          style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) => controller.updateSearch(value),
                  decoration: InputDecoration(
                    hintText: "${loc.search}...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardTheme.color,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildMainContent(state, controller, loc, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(DashboardState state, DashboardController controller, AppLocalizations loc, ThemeData theme) {
    final brightness = theme.brightness;
    if (state.loading && state.allRoutes.isEmpty) {
      return _buildSkeletonList();
    }

    if (state.error != null && state.allRoutes.isEmpty) {
      return _buildErrorState(state.error!, controller, theme, loc);
    }

    if (state.filteredRoutes.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: _buildEmptyState(loc, theme),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: state.filteredRoutes.length,
        itemBuilder: (context, index) {
          final route = state.filteredRoutes[index];
          return _RouteCard(
            key: ValueKey("${route.routeId}_$brightness"),
            route: route,
            controller: controller,
            loc: loc,
            theme: theme,
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: 5,
      itemBuilder: (context, index) => const _RouteSkeleton(),
    );
  }

  Widget _buildErrorState(String errorKey, DashboardController controller, ThemeData theme, AppLocalizations loc) {
    final displayMsg = errorKey == "timeout" ? loc.errorTimeout : loc.errorWhileLoading;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(displayMsg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry.toUpperCase()),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc, ThemeData theme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: theme.disabledColor),
              const SizedBox(height: 16),
              Text(loc.noRoutesFound, style: TextStyle(color: theme.disabledColor)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteCustomers route;
  final DashboardController controller;
  final AppLocalizations loc;
  final ThemeData theme;

  const _RouteCard({
    super.key,
    required this.route,
    required this.controller,
    required this.loc,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.local_shipping, size: 28),
          title: Text(
            route.routeName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text("${route.customers.length} ${loc.stops}"),
          children: [
            const Divider(height: 1),
            ...route.customers.map((customer) => ListTile(
                  leading: const Icon(Icons.location_on_outlined, size: 20),
                  title: Text(customer.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${customer.streetName} ${customer.streetNumber}, ${customer.postCode} ${customer.city}",
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _ActionButton(
                    label: loc.routeInfo.toUpperCase(),
                    icon: Icons.info_outline,
                    color: theme.colorScheme.secondary,
                    onPressed: () => _showRouteInfoDialog(context, route.routeId, route.routeName, controller, loc),
                  ),
                  const SizedBox(width: 12),
                  _ActionButton(
                    label: loc.selectRoute.toUpperCase(),
                    icon: Icons.play_arrow,
                    color: theme.colorScheme.tertiary,
                    onPressed: () {HapticFeedback.lightImpact();},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteInfoDialog(BuildContext context, String routeId, String routeName, DashboardController controller, AppLocalizations loc) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        key: ValueKey("dialog_$brightness"),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 900,
            maxHeight: MediaQuery.of(context).size.height * 0.8
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${loc.details} $routeName".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(height: 24),
                Flexible(
                  child: FutureBuilder<RouteOrders?>(
                    future: controller.getRouteDetails(routeId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError || snapshot.data == null) return Center(child: Text(loc.errorWhileLoading));
                      final data = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.orders.length,
                        itemBuilder: (context, index) => _OrderInfoTile(order: data.orders[index], theme: theme),
                      );
                    },
                  ),
                ),
                const Divider(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.close.toUpperCase()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, inherit: false),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _RouteSkeleton extends StatelessWidget {
  const _RouteSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 80,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 120, height: 12, color: color),
                const SizedBox(height: 8),
                Container(width: 60, height: 10, color: color),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _OrderInfoTile extends StatelessWidget {
  final RouteOrder order;
  final ThemeData theme;

  const _OrderInfoTile({required this.order, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("${order.streetName} ${order.streetNumber}",
              style: TextStyle(fontSize: 14, color: theme.disabledColor)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: order.products.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "${p.amount}x ${p.productName}",
                        softWrap: true,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${(p.price / 100).toStringAsFixed(2)}€",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}