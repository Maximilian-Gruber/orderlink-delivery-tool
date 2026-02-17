import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/logic/auth_controller.dart';
import 'package:frontend/features/dashboard/models/route_model.dart';
import '../logic/dashboard_controller.dart';
import '../../../l10n/app_localizations.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final loc = AppLocalizations.of(context)!;
    final authController = ref.read(authControllerProvider.notifier);

    final screenWidth = MediaQuery.of(context).size.width;
    final paddingStandard = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.openRoutes.toUpperCase(),
          style: TextStyle(fontSize: screenWidth * 0.04, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, size: screenWidth * 0.06),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(paddingStandard),
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
            child: _buildMainContent(state, controller, loc, theme, paddingStandard, brightness, screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(DashboardState state, DashboardController controller, AppLocalizations loc, ThemeData theme, double padding, Brightness brightness, double screenWidth) {
    if (state.loading && state.allRoutes.isEmpty) {
      return _buildSkeletonList(padding);
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
        padding: EdgeInsets.symmetric(horizontal: padding),
        itemCount: state.filteredRoutes.length,
        itemBuilder: (context, index) {
          final route = state.filteredRoutes[index];
          return _RouteCard(
            key: ValueKey("${route.routeId}_$brightness"),
            route: route,
            controller: controller,
            loc: loc,
            theme: theme,
            screenWidth: screenWidth,
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList(double padding) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: padding),
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
  final double screenWidth;

  const _RouteCard({
    super.key,
    required this.route,
    required this.controller,
    required this.loc,
    required this.theme,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final padding = screenWidth * 0.04;
    return Card(
      margin: EdgeInsets.only(bottom: padding),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.local_shipping, size: screenWidth * 0.06),
          title: Text(
            route.routeName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
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
                    style: TextStyle(fontSize: screenWidth * 0.03),
                  ),
                )),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  _ActionButton(
                    label: loc.routeInfo.toUpperCase(),
                    icon: Icons.info_outline,
                    color: theme.colorScheme.secondary,
                    onPressed: () => _showRouteInfoDialog(context, route.routeId, route.routeName, controller, loc),
                    height: screenWidth * 0.12,
                    fontSize: screenWidth * 0.025,
                  ),
                  SizedBox(width: padding * 0.75),
                  _ActionButton(
                    label: loc.selectRoute.toUpperCase(),
                    icon: Icons.play_arrow,
                    color: theme.colorScheme.tertiary,
                    onPressed: () {HapticFeedback.lightImpact();},
                    height: screenWidth * 0.12,
                    fontSize: screenWidth * 0.025,
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
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${loc.details} $routeName".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      itemBuilder: (context, index) => _OrderInfoTile(order: data.orders[index], screenWidth: screenWidth, theme: theme),
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double height;
  final double fontSize;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onPressed, required this.height, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: height,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, inherit: false),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
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
  final double screenWidth;
  final ThemeData theme;

  const _OrderInfoTile({required this.order, required this.screenWidth, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("${order.streetName} ${order.streetNumber}",
              style: TextStyle(fontSize: screenWidth * 0.03, color: theme.disabledColor)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: order.products.map((p) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${p.amount}x ${p.productName}"),
                  Text("${(p.price / 100).toStringAsFixed(2)}€"),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}