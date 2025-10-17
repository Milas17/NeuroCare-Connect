import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeCodeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Thème sombre'),
            value: theme == ThemeMode.dark,
            onChanged: (v) => ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light,
          ),
          ListTile(
            title: const Text('Langue'),
            trailing: DropdownButton<String>(
              value: locale,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => ref.read(localeCodeProvider.notifier).state = v ?? 'fr',
            ),
          )
        ],
      ),
    );
  }
}
