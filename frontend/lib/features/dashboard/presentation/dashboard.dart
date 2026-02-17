import 'package:flutter/material.dart';
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
    final brightness = theme.brightness; // Wichtig für Keys
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final loc = AppLocalizations.of(context)!;
    final authController = ref.read(authControllerProvider.notifier);

    final screenWidth = MediaQuery.of(context).size.width;
    final paddingStandard = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.04;
    final subtitleFontSize = screenWidth * 0.03;
    final buttonHeight = screenWidth * 0.12;
    final iconSize = screenWidth * 0.06;

    if (state.loading && state.routes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.openRoutes.toUpperCase(),
          style: TextStyle(fontSize: titleFontSize, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, size: iconSize),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: state.error != null
          ? Center(child: Text(state.error!))
          : RefreshIndicator(
              onRefresh: () => controller.refresh(),
              child: ListView.builder(
                padding: EdgeInsets.all(paddingStandard * 0.75),
                itemCount: state.routes.length,
                itemBuilder: (context, index) {
                  final route = state.routes[index];
                  return Card(
                    // Key ändert sich beim Theme-Wechsel -> sauberer Rebuild
                    key: ValueKey("${route.routeId}_$brightness"),
                    margin: EdgeInsets.only(bottom: paddingStandard),
                    child: Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Icon(Icons.local_shipping, size: iconSize),
                        title: Text(
                          route.routeName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize),
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
                                  style: TextStyle(fontSize: subtitleFontSize),
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.all(paddingStandard),
                            child: Row(
                              children: [
                                _ActionButton(
                                  label: loc.routeInfo.toUpperCase(),
                                  icon: Icons.info_outline,
                                  color: Colors.blue,
                                  onPressed: () => _showRouteInfoDialog(context, route.routeId, route.routeName, controller, loc),
                                  height: buttonHeight,
                                  fontSize: screenWidth * 0.025,
                                ),
                                SizedBox(width: paddingStandard * 0.75),
                                _ActionButton(
                                  label: loc.selectRoute.toUpperCase(),
                                  icon: Icons.play_arrow,
                                  color: Colors.green,
                                  onPressed: () { /* Start Logik */ },
                                  height: buttonHeight,
                                  fontSize: screenWidth * 0.025,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _ActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required double height,
    required double fontSize,
  }) {
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

  void _showRouteInfoDialog(BuildContext context, String routeId, String routeName, DashboardController controller, AppLocalizations loc) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final screenWidth = MediaQuery.of(context).size.width;

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
              Text(
                "${loc.details} $routeName".toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
              ),
              const Divider(height: 24),
              Flexible(
                child: FutureBuilder<RouteOrders?>(
                  future: controller.getRouteDetails(routeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return Center(child: Text(loc.errorWhileLoading));
                    }

                    final data = snapshot.data!;
                    return ListView.builder(
                      key: ValueKey("popup_list_$brightness"),
                      shrinkWrap: true,
                      itemCount: data.orders.length,
                      itemBuilder: (context, index) {
                        final order = data.orders[index];
                        return _OrderInfoTile(
                          key: ValueKey("order_${order.orderId}_$brightness"),
                          order: order, 
                          screenWidth: screenWidth, 
                          theme: theme
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                height: screenWidth * 0.1,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    textStyle: TextStyle(fontSize: screenWidth * 0.025, fontWeight: FontWeight.bold, inherit: false),
                  ),
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

class _OrderInfoTile extends StatelessWidget {
  final RouteOrder order;
  final double screenWidth;
  final ThemeData theme;

  const _OrderInfoTile({super.key, required this.order, required this.screenWidth, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("${order.streetName} ${order.streetNumber}",
              style: TextStyle(fontSize: screenWidth * 0.03, color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: order.products
                  .map((p) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${p.amount}x ${p.productName}"),
                          Text("${(p.price / 100).toStringAsFixed(2)}€"),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}