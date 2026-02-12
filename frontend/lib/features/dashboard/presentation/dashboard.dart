import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/logic/auth_controller.dart';
import '../logic/dashboard_controller.dart';
import '../../../l10n/app_localizations.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final loc = AppLocalizations.of(context)!;
    final authController = ref.read(authControllerProvider.notifier);

    if (state.loading && state.routes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.openRoutes),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: state.error != null
          ? Center(child: Text(state.error!))
          : RefreshIndicator(
              onRefresh: () => controller.refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.routes.length,
                itemBuilder: (context, index) {
                  final route = state.routes[index];
                  
                  return Card(
                    key: ValueKey(route.routeId),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(Icons.local_shipping_outlined, color: Colors.blue),
                        title: Text(
                          route.routeName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("${route.customers.length} ${loc.stops}"),
                        children: [
                          const Divider(height: 1),
                          ...route.customers.map((customer) => ListTile(
                            leading: const Icon(Icons.person_pin_circle_outlined, color: Colors.orange),
                            title: Text(customer.customerName),
                            subtitle: Text(
                              "${customer.streetName} ${customer.streetNumber}\n${customer.postCode} ${customer.city}",
                            ),
                            isThreeLine: true,
                          )),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                                  onPressed: () {
                                    // Todo: Info Logik
                                  },
                                ),
                                
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Todo: Route Starten Logik
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.play_arrow),
                                  label: Text(loc.selectRoute),
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
}