import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/models/user.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/telemed/telemed_screens.dart';
import 'features/homecare/homecare_screen.dart';
import 'features/transport/transport_screen.dart';
import 'features/eeg_enmg/eeg_screens.dart';
import 'features/academy/academy_screen.dart';
import 'features/shop/shop_screens.dart';
import 'features/settings/settings_screen.dart';

final currentUserRoleProvider = StateProvider<UserRole?>((ref) => null);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dash', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/telemed', builder: (_, __) => const TelemedHome()),
      GoRoute(path: '/homecare', builder: (_, __) => const HomeCareScreen()),
      GoRoute(path: '/transport', builder: (_, __) => const TransportScreen()),
      GoRoute(path: '/eeg', builder: (_, __) => const EegHome()),
      GoRoute(path: '/academy', builder: (_, __) => const AcademyScreen()),
      GoRoute(path: '/shop', builder: (_, __) => const ShopHome()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
    redirect: (ctx, state) {
      final role = ref.read(currentUserRoleProvider);
      if (state.subloc == '/' || role != null) return null;
      return '/';
    },
  );
});

class AppRouter {
  static void goDashboard(BuildContext context) => context.go('/dash');
  static void goTelemed(BuildContext context) => context.go('/telemed');
  static void goHomeCare(BuildContext context) => context.go('/homecare');
  static void goTransport(BuildContext context) => context.go('/transport');
  static void goEeg(BuildContext context) => context.go('/eeg');
  static void goAcademy(BuildContext context) => context.go('/academy');
  static void goShop(BuildContext context) => context.go('/shop');
  static void goSettings(BuildContext context) => context.go('/settings');
}
