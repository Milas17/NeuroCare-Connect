import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeCodeProvider = StateProvider<String>((ref) => 'fr');
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
