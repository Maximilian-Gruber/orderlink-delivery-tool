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
      return _buildSkeletonList(theme);
    }

    if (state.error != null && state.orders.isEmpty) {
      return _buildErrorState(state.error!, controller, theme, loc);
    }

    if (state.orders.isEmpty) {
      return Center(
        child: Text(
          loc.noRoutesFound,
          style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5)),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  state.routeName ?? "",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${state.orders.length} ${loc.stops}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: state.orders.length,
            onReorder: controller.reorderOrders,
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final double animValue = Curves.easeInOut.transform(animation.value);
                  final double elevation = lerpDouble(0, 12, animValue)!;
                  return Material(
                    elevation: elevation,
                    color: Colors.transparent,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return _DraggableOrderCard(
                key: ValueKey(order.orderId),
                order: order,
                index: index,
                isCurrentTarget: index == 0,
                theme: theme,
                loc: loc,
                onMoveToTop: () {
                  if (index > 0) controller.reorderOrders(index, 0);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 6,
      itemBuilder: (context, index) => _OrderSkeleton(theme: theme),
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
            Text(
              loc.errorWhileLoading,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
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
  final int index;
  final bool isCurrentTarget;
  final ThemeData theme;
  final VoidCallback onMoveToTop;
  final AppLocalizations loc;

  const _DraggableOrderCard({
    super.key,
    required this.order,
    required this.index,
    required this.isCurrentTarget,
    required this.theme,
    required this.onMoveToTop,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'de_DE', symbol: '€', decimalDigits: 2);
    double totalCents = order.products.fold(0, (sum, item) => sum + (item.amount * item.price));
    String formattedPrice = currencyFormatter.format(totalCents / 100);

    final Color solidActiveColor = Color.alphaBlend(
      theme.colorScheme.primary.withOpacity(0.05),
      theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: isCurrentTarget ? solidActiveColor : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTarget 
              ? theme.colorScheme.primary 
              : theme.dividerTheme.color ?? Colors.transparent,
          width: isCurrentTarget ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          isThreeLine: true, 
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          leading: _buildStepIndicator(),
          title: Text(
            order.customerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isCurrentTarget ? FontWeight.bold : FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "${order.streetName} ${order.streetNumber}\n${order.postCode} ${order.city}",
              maxLines: 2,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.2,
              ),
            ),
          ),
          trailing: SizedBox(
            width: 110, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedPrice,
                        maxLines: 1,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildActionBadge(),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                _buildDragHandle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isCurrentTarget ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "${index + 1}",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isCurrentTarget ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBadge() {
    if (!isCurrentTarget) {
      return GestureDetector(
        onTap: onMoveToTop,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_double_arrow_up_rounded, size: 12, color: theme.colorScheme.primary),
              const SizedBox(width: 2),
              Text(
                loc.prio.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          loc.current.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            color: theme.colorScheme.onTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildDragHandle() {
    return ReorderableDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Icon(
          Icons.drag_indicator_rounded,
          color: theme.colorScheme.onSurface.withOpacity(0.2),
          size: 20,
        ),
      ),
    );
  }
}

class _OrderSkeleton extends StatelessWidget {
  final ThemeData theme;
  const _OrderSkeleton({required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.onSurface.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 100,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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