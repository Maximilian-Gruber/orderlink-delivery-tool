import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/features/dashboard/models/route_model.dart';
import 'package:frontend/features/active_route/logic/active_route_controller.dart';

class OrderSelectionTab extends ConsumerWidget {
  final String routeId;
  const OrderSelectionTab({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeRouteControllerProvider(routeId));
    final controller = ref.read(activeRouteControllerProvider(routeId).notifier);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    if (state.loading && state.orders.isEmpty) {
      return _buildSkeletonList();
    }

    if (state.error != null && state.orders.isEmpty) {
      return _buildErrorState(state.error!, controller, theme, loc);
    }

    if (state.orders.isEmpty) {
      return Center(child: Text(loc.noRoutesFound));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.routeName ?? "",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: state.orders.length,
            onReorder: controller.reorderOrders,
            footer: const SizedBox(height: 16),
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return Material(
                elevation: 0,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return _DraggableOrderCard(
                key: ValueKey(order.orderId),
                order: order,
                isCurrentTarget: index == 0,
                theme: theme,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      itemBuilder: (context, index) => const _OrderSkeleton(),
    );
  }

  Widget _buildErrorState(String errorKey, ActiveRouteController controller, ThemeData theme, AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(loc.errorWhileLoading, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.loadRouteOrders(),
              icon: const Icon(Icons.refresh),
              label: Text(loc.retry.toUpperCase()),
            )
          ],
        ),
      ),
    );
  }
}

class _DraggableOrderCard extends StatelessWidget {
  final RouteOrder order;
  final bool isCurrentTarget;
  final ThemeData theme;

  const _DraggableOrderCard({
    super.key,
    required this.order,
    required this.isCurrentTarget,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€', decimalDigits: 2);
    double totalCents = order.products.fold(0, (sum, item) => sum + (item.amount * item.price));
    String formattedPrice = currencyFormatter.format(totalCents / 100);

    return Card(
      elevation: isCurrentTarget ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentTarget ? BorderSide(color: theme.colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentTarget ? theme.colorScheme.primary.withOpacity(0.08) : Colors.transparent,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Icon(
            isCurrentTarget ? Icons.location_on : Icons.location_on_outlined,
            color: isCurrentTarget ? theme.colorScheme.primary : theme.disabledColor,
            size: 32,
          ),
          title: Text(
            order.customerName,
            style: TextStyle(fontWeight: isCurrentTarget ? FontWeight.bold : FontWeight.normal, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text("${order.streetName} ${order.streetNumber}"),
              Text("${order.postCode} ${order.city}"),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedPrice,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Icon(Icons.drag_handle, color: theme.disabledColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSkeleton extends StatelessWidget {
  const _OrderSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 100,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 140, height: 14, color: color),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 10, color: color),
                ],
              ),
            ),
            Container(width: 50, height: 16, color: color),
          ],
        ),
      ),
    );
  }
}