import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/logic/auth_controller.dart';
import 'package:frontend/features/auth/presentation/login_page.dart';
import 'package:frontend/features/dashboard/presentation/dashboard.dart';
import 'package:frontend/features/profile/presentation/profile_page.dart';
import 'package:frontend/features/active_route/presentation/active_route_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final loggedIn = authState.token != null;
      final isLoggingIn = state.uri.path == '/login';

      if (!loggedIn && !isLoggingIn) {
        return '/login';
      }

      if (loggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/route/:id',
        builder: (context, state) {
          final routeId = state.pathParameters['id']!;
          return ActiveRoutePage(routeId: routeId);
        },
      ),
    ],
  );
});
