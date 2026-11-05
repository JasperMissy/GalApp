import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/views/shell/app_shell.dart';
import 'package:galabau_app/views/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: GalabauApp()));
}

/// Wurzel der App: Riverpod-Scope, helles Theme und Navigationsrahmen.
class GalabauApp extends StatelessWidget {
  const GalabauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GaLaBau App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}