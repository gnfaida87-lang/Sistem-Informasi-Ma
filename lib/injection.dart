import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/d1_provider.dart';
import 'core/providers/auth_provider.dart';

Future<void> setupInjection() async {
  // Pendaftaran untuk injection jika ada yang lain.
  // riverpod bersifat lazy jadi provider akan terinisialisasi pada saat dipanggil (watch/read).
}