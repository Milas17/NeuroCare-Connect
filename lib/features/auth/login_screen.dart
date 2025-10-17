import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user.dart';
import '../../router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('NeuroCare Connect')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Text('Sélection du rôle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _RoleBtn(role: UserRole.patient, label: 'Patient'),
              _RoleBtn(role: UserRole.doctor, label: 'Médecin'),
              _RoleBtn(role: UserRole.regulator, label: 'Régulateur'),
              _RoleBtn(role: UserRole.driver, label: 'Conducteur'),
            ],
          )
        ],
      ),
    );
  }
}

class _RoleBtn extends ConsumerWidget {
  final UserRole role;
  final String label;
  const _RoleBtn({required this.role, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ref.read(currentUserRoleProvider.notifier).state = role;
        AppRouter.goDashboard(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        child: Text(label),
      ),
    );
  }
}
