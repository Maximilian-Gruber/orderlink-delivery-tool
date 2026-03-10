import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(loc.errorWhileLoading));
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
              final isCurrentTarget = index == 0; 

              return _DraggableOrderCard(
                key: ValueKey(order.orderId), 
                order: order,
                isCurrentTarget: isCurrentTarget,
                theme: theme,
              );
            },
          ),
        ),
      ],
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
    double totalCents = order.products.fold(0, (sum, item) => sum + (item.amount * item.price));
    String formattedPrice = (totalCents / 100).toStringAsFixed(2);

    return Card(
      elevation: isCurrentTarget ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentTarget 
            ? BorderSide(color: theme.colorScheme.primary, width: 2) 
            : BorderSide.none,
      ),
      color: theme.cardTheme.color ?? theme.cardColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentTarget 
              ? theme.colorScheme.primary.withOpacity(0.08) 
              : Colors.transparent,
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
            style: TextStyle(
              fontWeight: isCurrentTarget ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
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
                "$formattedPrice €",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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