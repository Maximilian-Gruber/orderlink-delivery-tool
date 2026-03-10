import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/features/auth/logic/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin(BuildContext context, AuthController controller, AppLocalizations loc) {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.loginError, textAlign: TextAlign.center),
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 1500),
      ),
      );
      return;
    }

    controller.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final siteConfigAsync = ref.watch(siteConfigProvider);

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyMedium!.color;
    final loc = AppLocalizations.of(context)!;
    
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.loginError, textAlign: TextAlign.center),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Company Name / Logo
                siteConfigAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Text(
                      loc.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  data: (config) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Column(
                        children: [
                          if (config.logoPath.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Image.network(
                                config.logoPath,
                                height: MediaQuery.of(context).size.height * 0.3,
                              ),
                            ),
                          Text(
                            config.companyName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: loc.email,
                    labelStyle: TextStyle(color: textColor?.withOpacity(0.6)),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: loc.password,
                    labelStyle: TextStyle(color: textColor?.withOpacity(0.6)),
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: theme.brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: state.loading
                        ? null
                        : () => _attemptLogin(context, controller, loc),
                    child: state.loading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(loc.login),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}