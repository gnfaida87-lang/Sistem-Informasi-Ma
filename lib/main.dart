import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/network/supabase_config.dart';
import 'core/network/supabase_service.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cek konfigurasi Supabase sebelum initialize
  if (!SupabaseConfig.isConfigured) {
    runApp(const _ConfigErrorApp());
    return;
  }

  // Inisialisasi Supabase
  await SupabaseService.initialize();

  // Inisiasi dependency tambahan
  await setupInjection();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Tampil error screen jika supabase_config.dart belum diisi
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_outlined,
                    size: 72, color: Colors.red.shade300),
                const SizedBox(height: 24),
                const Text(
                  'Konfigurasi Supabase Belum Diisi',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Buka lib/core/network/supabase_config.dart\n'
                  'dan isi url serta anonKey dari dashboard Supabase Anda.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Text(
                      'DEBUG: Atau jalankan dengan:\n'
                      'flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co '
                      '--dart-define=SUPABASE_ANON_KEY=eyJ...',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
