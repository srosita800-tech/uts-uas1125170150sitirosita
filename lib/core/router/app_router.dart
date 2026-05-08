import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_katalog_laptop/features/auth/presentation/pages/temp_register.dart';
import 'package:uas_katalog_laptop/features/auth/presentation/pages/login_page.dart';
import 'package:uas_katalog_laptop/features/auth/presentation/pages/verify_email_page.dart';
import 'package:uas_katalog_laptop/features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final status = auth.status;
 
    return switch (status) {
      AuthStatus.authenticated    => child,
      AuthStatus.emailNotVerified => const VerifyEmailPage(),
      AuthStatus.loading || AuthStatus.initial => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _ => const LoginPage(),
    };
  }
}

class AppRouter {
  static const String splash      = '/';
  static const String login       = '/login';
  static const String register    = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard   = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    splash:      (_) => const SplashPage(),
    login:       (_) => const LoginPage(),
    register:    (_) => const RegisterPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    dashboard:   (_) => const AuthGuard(child: DashboardPage()),
  };
}