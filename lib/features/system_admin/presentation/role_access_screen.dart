import 'package:flutter/material.dart';

class RoleAccessScreen extends StatefulWidget {
  const RoleAccessScreen({super.key});

  @override
  State<RoleAccessScreen> createState() => _RoleAccessScreenState();
}

class _RoleAccessScreenState extends State<RoleAccessScreen> {
  // Simulasi dari ERD (ROLES)
  final List<String> _roles = [
    'SUPERADMIN',
    'KEPALA_MADRASAH',
    'WAKIL_KURIKULUM',
    'OPERATOR_DATA',
    'ADMIN_KEUANGAN',
    'GURU_MAPEL',
    'GURU_BIMBEL',
    'ORANG_TUA'
  ];

  String _selectedRole = 'GURU_MAPEL';

  // State simulasi untuk mapping menu (Akan dihubungkan dengan RLS / API)
  final Map<String, bool> _menuAccess = {
    '1. Dashboard Sistem & Aktifitas (User Activity, Logs)': false,
    '2. Manajemen User & Security (Role, Hak Akses)': false,
    '3. Master Data Siswa': false,
    '4. Master Data Guru': false,
    '5. Master Data Kelas & Rombel': false,
    '6. Master Data Mata Pelajaran': false,
    '7. Manajemen Bimbel': false,
    '8. Konfigurasi Periode Akademik': false,
    '9. Jadwal Akademik': false,
    '10. Absensi Harian Siswa': false,
    '11. Input Nilai & Tugas': false,
    '12. Validasi Nilai & Cetak Rapor': false,
    '13. Sistem Pembayaran & Keuangan': false,
    '14. Pengumuman Sekolah': false,
    '15. Integrasi AI & API': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.orange.shade800,
              child: const Text('Role & Hak Akses', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            // Informasi Aturan Keras (Dari Dokumen ERD)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mapping Role ke Menu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Perhatian: Mapping ini secara otomatis akan direplikasi pada Rule Row Level Security (RLS) di Supabase. Role "Wali Kelas" tidak masuk konfigurasi ini karena berstatus Flag pada Guru.',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                  ),
                ],
              ),
            ),

            // Pilih Role target
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Pilih Role Detail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.shield_outlined),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRole = val;
                      // Reset to mock state based on role
                      _menuAccess.updateAll((key, value) => val == 'SUPERADMIN');
                    });
                  }
                },
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Konfigurasi Hak Akses Modul',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            // Toggle Switches
            Expanded(
              child: ListView(
                children: _menuAccess.keys.map((String key) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SwitchListTile(
                      title: Text(key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('Izinkan role $_selectedRole mengakses halaman ini', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      value: _menuAccess[key]!,
                      activeColor: Colors.orange.shade600,
                      onChanged: (bool value) {
                        setState(() {
                          _menuAccess[key] = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Save Action
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Konfigurasi RLS & Routing Role Berhasil Disimpan (Mock)')),
                    );
                  },
                  child: const Text('Simpan & Sinkronisasi RLS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
