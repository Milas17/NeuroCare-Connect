import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_state.dart';
import 'router.dart';
import 'strings.dart';
import 'theme.dart';

class NeuroCareApp extends ConsumerWidget {
  const NeuroCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeCodeProvider);
    final strings = AppStrings.of(locale);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: strings.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
