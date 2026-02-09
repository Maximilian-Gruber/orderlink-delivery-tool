import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/auth_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyMedium!.color;
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth * 0.9;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Name / Logo
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Text(
                  loc.appName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              // Email Field
              SizedBox(
                width: fieldWidth,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: loc.email,
                    labelStyle: TextStyle(color: textColor?.withOpacity(0.6)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              SizedBox(
                width: fieldWidth,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: loc.password,
                    labelStyle: TextStyle(color: textColor?.withOpacity(0.6)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    loc.loginError,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),

              // Login Button
              SizedBox(
                width: fieldWidth,
                height: 50,
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
                      : () {
                          controller.login(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                  child: state.loading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(loc.login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
