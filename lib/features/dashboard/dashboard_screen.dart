import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user.dart';
import '../../router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard — ${role.name}')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        children: [
          _CardBtn('Téléconsultation', Icons.video_call, () => AppRouter.goTelemed(context)),
          _CardBtn('Soins à domicile', Icons.home_health, () => AppRouter.goHomeCare(context)),
          _CardBtn('Transport (VSL)', Icons.local_taxi, () => AppRouter.goTransport(context)),
          _CardBtn('EEG/ENMG', Icons.monitor_heart, () => AppRouter.goEeg(context)),
          _CardBtn('Académie', Icons.school, () => AppRouter.goAcademy(context)),
          _CardBtn('Boutique', Icons.storefront, () => AppRouter.goShop(context)),
          _CardBtn('Réglages', Icons.settings, () => AppRouter.goSettings(context)),
        ],
      ),
    );
  }
}

class _CardBtn extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _CardBtn(this.title, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 38),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
