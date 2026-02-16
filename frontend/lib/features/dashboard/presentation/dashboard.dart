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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final paddingStandard = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.04;
    final subtitleFontSize = screenWidth * 0.03;
    final buttonHeight = screenWidth * 0.12;
    final iconSize = screenWidth * 0.06;

    if (state.loading && state.routes.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
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
            icon: Icon(Icons.person, size: iconSize * 1),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: state.error != null
          ? Center(child: Text(state.error!))
          : RefreshIndicator(
              color: isDark ? Colors.white : Colors.black,
              onRefresh: () => controller.refresh(),
              child: ListView.builder(
                padding: EdgeInsets.all(paddingStandard * 0.75),
                itemCount: state.routes.length,
                itemBuilder: (context, index) {
                  final route = state.routes[index];
                  
                  return Card(
                    key: ValueKey(route.routeId),
                    margin: EdgeInsets.only(bottom: paddingStandard),
                    clipBehavior: Clip.antiAlias,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Icon(
                          Icons.local_shipping, 
                          color: isDark ? Colors.white : Colors.black,
                          size: iconSize,
                        ),
                        title: Text(
                          route.routeName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: titleFontSize,
                            letterSpacing: 0.5,
                          ),
                        ),
                        subtitle: Text(
                          "${route.customers.length} ${loc.stops}",
                          style: TextStyle(fontSize: subtitleFontSize),
                        ),
                        children: [
                          const Divider(height: 1),
                          ...route.customers.map((customer) => ListTile(
                            leading: Icon(
                              Icons.location_on_outlined, 
                              size: iconSize * 0.8, 
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            title: Text(
                              customer.customerName, 
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: subtitleFontSize * 1.1,
                              ),
                            ),
                            subtitle: Text(
                              "${customer.streetName} ${customer.streetNumber}, ${customer.postCode} ${customer.city}",
                              style: TextStyle(fontSize: subtitleFontSize),
                            ),
                          )),
                          
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              paddingStandard, 
                              paddingStandard * 0.5, 
                              paddingStandard, 
                              paddingStandard,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: buttonHeight,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        // Todo: Info Logik
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: screenWidth * 0.025,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      icon: Icon(Icons.info_outline, size: iconSize * 0.7),
                                      label: Text(loc.routeInfo.toUpperCase()),
                                    ),
                                  ),
                                ),
                                SizedBox(width: paddingStandard * 0.75),
                                Expanded(
                                  child: SizedBox(
                                    height: buttonHeight,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        // Todo: Start Logik
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: screenWidth * 0.025,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      icon: Icon(Icons.play_arrow, size: iconSize * 0.7),
                                      label: Text(loc.selectRoute.toUpperCase()),
                                    ),
                                  ),
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