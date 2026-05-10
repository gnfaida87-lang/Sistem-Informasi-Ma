import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/providers/system_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tetap watch agar settings di-load di background,
    // tapi JANGAN blokir UI jika error/loading
    ref.watch(systemSettingsProvider);

    return MaterialApp.router(
      title: 'Sistem Informasi Madrasah',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B5BDB)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
    );
  }
}
