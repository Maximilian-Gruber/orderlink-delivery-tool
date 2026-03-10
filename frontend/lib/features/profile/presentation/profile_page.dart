import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/features/auth/logic/auth_controller.dart';
import 'package:frontend/features/profile/logic/profile_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final authController = ref.read(authControllerProvider.notifier);
    
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.profile),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          child: _buildContent(
            context, 
            state, 
            controller, 
            authController, 
            theme, 
            loc
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileState state,
    ProfileController controller,
    AuthController authController,
    ThemeData theme,
    AppLocalizations loc,
  ) {
    if (state.loading && state.profile == null) {
      return _buildSkeletonList();
    }

    if (state.error != null && state.profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(loc.errorWhileLoading),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.refresh(),
              child: Text(loc.retry),
            ),
          ],
        ),
      );
    }

    if (state.profile == null) return const SizedBox.shrink();

    final profile = state.profile!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              profile.firstName.isNotEmpty && profile.lastName.isNotEmpty
                  ? profile.firstName[0] + profile.lastName[0]
                  : "?",
              style: TextStyle(
                fontSize: 36,
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          _buildInfoCard(
            context,
            title: loc.name,
            value: '${profile.firstName} ${profile.lastName}',
            icon: Icons.person_outline,
          ),
          _buildInfoCard(
            context,
            title: loc.email,
            value: profile.email,
            icon: Icons.email_outlined,
          ),
          _buildInfoCard(
            context,
            title: loc.role,
            value: profile.role,
            icon: Icons.badge_outlined,
          ),
          _buildInfoCard(
            context,
            title: loc.id,
            value: profile.employeeId,
            icon: Icons.numbers,
          ),
          
          const SizedBox(height: 32),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => authController.logout(),
              child: Text(loc.logout),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        children: [
          SizedBox(height: 24),
          _ProfileSkeleton(isAvatar: true),
          SizedBox(height: 32),
          _ProfileSkeleton(),
          _ProfileSkeleton(),
          _ProfileSkeleton(),
          _ProfileSkeleton(),
          SizedBox(height: 32),
          _ProfileSkeleton(isButton: true),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0, 
          vertical: 4.0
        ),
        leading: Icon(icon, color: theme.colorScheme.primary, size: 28),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  final bool isAvatar;
  final bool isButton;

  const _ProfileSkeleton({
    this.isAvatar = false,
    this.isButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);

    if (isAvatar) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }

    if (isButton) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      height: 72,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 60, height: 10, color: color),
                const SizedBox(height: 8),
                Container(width: 150, height: 12, color: color),
              ],
            )
          ],
        ),
      ),
    );
  }
}