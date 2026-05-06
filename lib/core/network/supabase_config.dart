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
    defaultValue: 'https://dmkuvecsaldnmzrddctj.supabase.co',
  );

  // Ganti dengan anon key project Supabase Anda
  // Contoh: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRta3V2ZWNzYWxkbm16cmRkY3RqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMzA4NjMsImV4cCI6MjA5MzYwNjg2M30.6IKuo2Ibjfro67CG_ksnCMcu1QnuOxT3ySi4N3mApq0',
  );

  /// Cek apakah konfigurasi sudah diisi
  static bool get isConfigured =>
      url != 'YOUR_SUPABASE_URL' && anonKey != 'YOUR_SUPABASE_ANON_KEY';
}
