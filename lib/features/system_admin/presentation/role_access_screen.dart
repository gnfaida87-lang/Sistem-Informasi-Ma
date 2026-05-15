import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';
import '../../../core/utils/context_extensions.dart';

class RoleAccessScreen extends StatefulWidget {
  const RoleAccessScreen({super.key});

  @override
  State<RoleAccessScreen> createState() => _RoleAccessScreenState();
}

class _RoleAccessScreenState extends State<RoleAccessScreen> {
  final _d1Service = D1Service();
  bool _isLoading = true;
  
  // Real roles from DB
  List<Map<String, dynamic>> _rolesDb = [];
  String? _selectedRoleId;
  String _selectedRoleCode = '';

  // Menu keys to map
  final List<String> _menuKeys = [
    '1. Dashboard Sistem & Aktifitas (User Activity, Logs)',
    '2. Manajemen User & Security (Role, Hak Akses)',
    '3. Master Data Siswa',
    '4. Master Data Guru',
    '5. Master Data Kelas & Rombel',
    '6. Master Data Mata Pelajaran',
    '7. Manajemen Bimbel',
    '8. Konfigurasi Periode Akademik',
    '9. Jadwal Akademik',
    '10. Absensi Harian Siswa',
    '11. Input Nilai & Tugas',
    '12. Validasi Nilai & Cetak Rapor',
    '13. Sistem Pembayaran & Keuangan',
    '14. Pengumuman Sekolah',
    '15. Integrasi AI & API',
  ];

  final Map<String, bool> _menuAccess = {};

  @override
  void initState() {
    super.initState();
    for (var key in _menuKeys) {
      _menuAccess[key] = false;
    }
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _d1Service.query("SELECT * FROM roles ORDER BY id ASC");
      _rolesDb = List<Map<String, dynamic>>.from(roles as List);
      
      if (_rolesDb.isNotEmpty) {
        _selectedRoleId = _rolesDb.first['id'];
        _selectedRoleCode = _rolesDb.first['code'];
        await _fetchPermissions();
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal memuat role: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPermissions() async {
    if (_selectedRoleId == null) return;
    
    // Reset all to false first
    for (var key in _menuKeys) {
      _menuAccess[key] = (_selectedRoleCode == 'SA'); // Default SA has all access
    }

    try {
      final perms = await _d1Service.query(
        "SELECT menu_key, is_allowed FROM role_permissions WHERE role_id = ?",
        params: [_selectedRoleId]
      );
      
      for (var p in (perms as List)) {
        if (_menuAccess.containsKey(p['menu_key'])) {
          _menuAccess[p['menu_key']] = p['is_allowed'] == 1;
        }
      }
    } catch (e) {
      debugPrint("Error fetching perms: $e");
    }
    setState(() {});
  }

  Future<void> _savePermissions() async {
    if (_selectedRoleId == null) return;
    
    setState(() => _isLoading = true);
    try {
      // Use transaction approach by deleting and re-inserting
      // Cloudflare D1 supports multiple statements or we can do it one by one
      await _d1Service.query("DELETE FROM role_permissions WHERE role_id = ?", params: [_selectedRoleId]);
      
      for (var entry in _menuAccess.entries) {
        if (entry.value) { // Only save allowed ones to keep DB small
          await _d1Service.query(
            "INSERT INTO role_permissions (role_id, menu_key, is_allowed) VALUES (?, ?, 1)",
            params: [_selectedRoleId, entry.key]
          );
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hak akses berhasil disinkronisasi ke Cloudflare D1')),
        );
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal menyimpan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading && _rolesDb.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.orange.shade800,
              child: const Text('Role & Hak Akses', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mapping Role ke Menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'Perhatian: Mapping ini secara otomatis akan direplikasi pada kontrol akses di Cloudflare D1.',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedRoleId,
                decoration: InputDecoration(
                  labelText: 'Pilih Role Detail',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.shield_outlined),
                ),
                items: _rolesDb.map((role) {
                  return DropdownMenuItem<String>(value: role['id'].toString(), child: Text("${role['nama']} (${role['code']})"));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRoleId = val;
                      _selectedRoleCode = _rolesDb.firstWhere((r) => r['id'].toString() == val)['code'];
                    });
                    _fetchPermissions();
                  }
                },
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Konfigurasi Hak Akses Modul', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Stack(
                children: [
                  ListView(
                    children: _menuKeys.map((String key) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SwitchListTile(
                          title: Text(key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text('Izinkan role $_selectedRoleCode mengakses halaman ini', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          value: _menuAccess[key] ?? false,
                          activeColor: Colors.orange.shade600,
                          onChanged: (bool value) {
                            setState(() => _menuAccess[key] = value);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  if (_isLoading) const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),

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
                  onPressed: _isLoading ? null : _savePermissions,
                  child: const Text('Simpan & Sinkronisasi Akses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
