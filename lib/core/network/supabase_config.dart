// ─────────────────────────────────────────────────────────
// SUPABASE CONFIGURATION
//
// CARA MENDAPATKAN NILAI INI:
// 1. Buka https://supabase.com/dashboard
// 2. Pilih project Anda
// 3. Klik Settings → API
// 4. Salin "Project URL" ke supabaseUrl
// 5. Salin "anon public" key ke supabaseAnonKey
//
// ⚠ JANGAN commit file ini ke Git jika sudah diisi.
//   Tambahkan ke .gitignore atau gunakan --dart-define
// ─────────────────────────────────────────────────────────

class SupabaseConfig {
  // Ganti dengan URL project Supabase Anda
  // Contoh: 'https://abcdefghij.supabase.co'
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  // Ganti dengan anon key project Supabase Anda
  // Contoh: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  /// Cek apakah konfigurasi sudah diisi
  static bool get isConfigured =>
      url != 'YOUR_SUPABASE_URL' && anonKey != 'YOUR_SUPABASE_ANON_KEY';
}
