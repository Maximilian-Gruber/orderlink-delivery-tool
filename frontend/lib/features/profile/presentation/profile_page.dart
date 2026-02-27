import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/logic/auth_controller.dart';
import '../logic/profile_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final authController = ref.read(authControllerProvider.notifier);
    
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = screenWidth * 0.05;
    final avatarRadius = screenWidth * 0.12;
    final buttonHeight = screenWidth * 0.12;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.profile),
      ),
      body: _buildContent(
        context, 
        state, 
        controller, 
        authController, 
        screenWidth, 
        contentPadding, 
        avatarRadius, 
        buttonHeight, 
        theme, 
        loc
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileState state,
    ProfileController controller,
    AuthController authController,
    double screenWidth,
    double contentPadding,
    double avatarRadius,
    double buttonHeight,
    ThemeData theme,
    AppLocalizations loc,
  ) {
    if (state.loading && state.profile == null) {
      return _buildSkeletonList(contentPadding, screenWidth);
    }

    if (state.error != null && state.profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: screenWidth * 0.12, color: Colors.red),
            SizedBox(height: screenWidth * 0.04),
            Text(loc.errorWhileLoading),
            SizedBox(height: screenWidth * 0.04),
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
      padding: EdgeInsets.symmetric(horizontal: contentPadding, vertical: screenWidth * 0.05),
      child: Column(
        children: [
          SizedBox(height: screenWidth * 0.05),
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              profile.firstName.isNotEmpty && profile.lastName.isNotEmpty
                  ? profile.firstName[0] + profile.lastName[0]
                  : "?",
              style: TextStyle(
                fontSize: screenWidth * 0.08,
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.08),
          
          _buildInfoCard(
            context,
            screenWidth: screenWidth,
            title: loc.name,
            value: '${profile.firstName} ${profile.lastName}',
            icon: Icons.person_outline,
          ),
          _buildInfoCard(
            context,
            screenWidth: screenWidth,
            title: loc.email,
            value: profile.email,
            icon: Icons.email_outlined,
          ),
          _buildInfoCard(
            context,
            screenWidth: screenWidth,
            title: loc.role,
            value: profile.role,
            icon: Icons.badge_outlined,
          ),
          _buildInfoCard(
            context,
            screenWidth: screenWidth,
            title: loc.id,
            value: profile.employeeId,
            icon: Icons.numbers,
          ),
          
          SizedBox(height: screenWidth * 0.08),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                textStyle: TextStyle(
                  fontSize: screenWidth * 0.045,
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

  Widget _buildSkeletonList(double padding, double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: screenWidth * 0.05),
      child: Column(
        children: [
          SizedBox(height: screenWidth * 0.05),
          const _ProfileSkeleton(isAvatar: true),
          SizedBox(height: screenWidth * 0.08),
          const _ProfileSkeleton(),
          const _ProfileSkeleton(),
          const _ProfileSkeleton(),
          const _ProfileSkeleton(),
          SizedBox(height: screenWidth * 0.08),
          const _ProfileSkeleton(isButton: true),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required double screenWidth,
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, 
          vertical: screenWidth * 0.01
        ),
        leading: Icon(icon, color: theme.colorScheme.primary, size: screenWidth * 0.06),
        title: Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
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
    final screenWidth = MediaQuery.of(context).size.width;

    if (isAvatar) {
      return Container(
        width: screenWidth * 0.24,
        height: screenWidth * 0.24,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }

    if (isButton) {
      return Container(
        width: double.infinity,
        height: screenWidth * 0.12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      height: screenWidth * 0.15,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: screenWidth * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: screenWidth * 0.15, height: 10, color: color),
                const SizedBox(height: 8),
                Container(width: screenWidth * 0.4, height: 12, color: color),
              ],
            )
          ],
        ),
      ),
    );
  }
}