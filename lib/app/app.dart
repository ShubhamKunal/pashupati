import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/config.dart';
import 'router.dart';
import 'theme/theme.dart';

class PashupatiApp extends ConsumerWidget {
  const PashupatiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: PashupatiTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

