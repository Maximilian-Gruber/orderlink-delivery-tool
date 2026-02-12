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
    final siteConfigAsync = ref.watch(siteConfigProvider);

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
              // Company Name / Logo
              siteConfigAsync.when(
                loading: () => Padding(
                  padding: EdgeInsets.only(bottom: screenWidth * 0.12),
                  child: const CircularProgressIndicator(),
                ),
                error: (_, __) => Padding(
                  padding: EdgeInsets.only(bottom: screenWidth * 0.12),
                  child: Text(
                    loc.appName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                data: (config) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: screenWidth * 0.12),
                    child: Column(
                      children: [
                        if (config.logoPath.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Image.network(
                              config.logoPath,
                              height: screenWidth * 0.5,
                            ),
                          ),
                        Text(
                          config.companyName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
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
              SizedBox(height: screenWidth * 0.04),

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
              SizedBox(height: screenWidth * 0.06),

              // Error Message
              if (state.error != null)
                Padding(
                  padding: EdgeInsets.only(bottom: screenWidth * 0.04),
                  child: Text(
                    loc.loginError,
                    style: TextStyle(color: theme.colorScheme.error, fontSize: screenWidth * 0.04),
                  ),
                ),

              // Login Button
              SizedBox(
                width: fieldWidth,
                height: screenWidth * 0.12,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    textStyle: TextStyle(
                      fontSize: screenWidth * 0.05,
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
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          child: CircularProgressIndicator(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                            strokeWidth: screenWidth * 0.01,
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
