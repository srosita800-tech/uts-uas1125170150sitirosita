import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/main_navigation.dart';
import '../../../../core/routes/app_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();

      if (auth.status == AuthStatus.emailNotVerified || 
          (auth.firebaseUser != null && !auth.firebaseUser!.emailVerified)) {
        
        Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
      } else if (auth.status == AuthStatus.unauthenticated) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}