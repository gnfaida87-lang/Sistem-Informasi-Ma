import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/providers/system_provider.dart';
import 'core/utils/error_handler.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan AsyncValue.when secara hati-hati di root.
    // Pastikan tidak ada exception yang dilempar sebelum return.
    final settingsAsync = ref.watch(systemSettingsProvider);

    return MaterialApp.router(
      title: 'Sistem Informasi Madrasah',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      builder: (context, child) {
        if (child == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return settingsAsync.when(
          data: (settings) => child,
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) {
            String message = 'Terjadi kesalahan sistem';
            if (err is AppException) {
              message = err.userMessage;
            } else {
              message = err.toString();
            }
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(systemSettingsProvider),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B5BDB)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
    );
  }
}
