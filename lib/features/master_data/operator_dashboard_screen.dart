import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/router/app_router.dart';
import '../../core/network/supabase_service.dart';
import 'operator_master_siswa.dart';
import 'operator_master_guru.dart';
import 'operator_master_kelas.dart';
import 'operator_master_mapel.dart';
import 'operator_master_tahun_ajaran.dart';
import 'operator_master_jurusan.dart';
import 'operator_master_ekskul.dart';
import 'operator_master_bimbel.dart';
import 'operator_peserta_bimbel.dart';
import '../auth/presentation/login_screen.dart';
import '../../shared/widgets/profile_settings_screen.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() => _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  // Real Statistics
  int _totalSiswa = 0;
  int _totalGuru = 0;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentActivities();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null) {
        // ── JALUR RIIL (SUPABASE) ────────────────────────
        final client = SupabaseService().client;
        final siswaCount = await client.from('siswa').select('id');
        final guruCount = await client.from('guru').select('id');
        if (mounted) {
          setState(() {
            _totalSiswa = (siswaCount as List).length;
            _totalGuru = (guruCount as List).length;
            _isLoading = false;
          });
        }
      } else {
        // ── JALUR DEMO (SIMULASI DATA) ───────────────────
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          setState(() {
            _totalSiswa = 1250;
            _totalGuru = 84;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
    {'title': 'Master Tahun Ajaran', 'icon': Icons.calendar_today_outlined},
    {'title': 'Data Jurusan/Program', 'icon': Icons.account_tree_outlined},
    {'title': 'Data Pegawai (Guru & TU)', 'icon': Icons.badge_outlined},
    {'title': 'Data Siswa & Wali', 'icon': Icons.face_outlined},
    {'title': 'Data Kelas', 'icon': Icons.class_outlined},
    {'title': 'Data Mata Pelajaran', 'icon': Icons.library_books_outlined},
    {'title': 'Master Ekstrakurikuler', 'icon': Icons.sports_basketball_outlined},
    {'title': 'Master Program Bimbel', 'icon': Icons.auto_stories_outlined},
    {'title': 'Peserta & Akun Bimbel', 'icon': Icons.how_to_reg_outlined},
  ];

  Future<void> _fetchRecentActivities() async {
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('audit_log')
          .select('table_name, action, description, performed_at')
          .order('performed_at', ascending: false)
          .limit(5);
      if (mounted) setState(() => _recentActivities = List<Map<String, dynamic>>.from(res as List));
    } catch (_) {}
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '\${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '\${diff.inHours} jam lalu';
    return '\${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isDesktop),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                    child: Container(
                      color: const Color(0xFFF4F7FE),
                      child: _getCurrentScreen(), // Switcher konten untuk sub menu
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop ? Drawer(child: _buildSidebar()) : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 70,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storage, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SI Madrasah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3674),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      if (MediaQuery.of(context).size.width <= 800) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.brown.shade50 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            _menuItems[index]['icon'],
                            color: isSelected ? Colors.brown.shade600 : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _menuItems[index]['title'],
                              style: TextStyle(
                                color: isSelected ? Colors.brown.shade800 : Colors.grey.shade600,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.grey),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          if (isDesktop)
            IconButton(
              icon: const Icon(Icons.menu_open, color: Colors.grey),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const SizedBox(width: 16),

          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Operator Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B3674))),
              Text('Data Induk Madrasah', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
              } else if (value == 'logout') {
                context.go(AppRoutes.login);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings, size: 20),
                  title: Text('Pengaturan Profil', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, size: 20, color: Colors.red),
                  title: Text('Keluar (Logout)', style: TextStyle(fontSize: 14, color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
            child: const CircleAvatar(
              backgroundColor: Colors.brown,
              radius: 18,
              child: Icon(Icons.dns, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildMainContent();
      case 1:
        return const OperatorMasterTahunAjaran();
      case 2:
        return const OperatorMasterJurusan();
      case 3:
        return const OperatorMasterGuru();
      case 4:
        return const OperatorMasterSiswa();
      case 5:
        return const OperatorMasterKelas();
      case 6:
        return const OperatorMasterMapel();
      case 7:
        return const OperatorMasterEkskul();
      case 8:
        return const OperatorMasterBimbel();
      case 9:
        return const OperatorPesertaBimbel();
      default:
        return _buildMainContent();
    }
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Dashboard Data Center',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.sync),
                label: const Text('Sinkronisasi Emis / Dapodik'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // GRID STATISTIK MASTER DATA
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return GridView.count(
                crossAxisCount: isDesktop ? 4 : (constraints.maxWidth > 500 ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isDesktop ? 2.2 : 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(Colors.blueAccent, _totalSiswa.toString(), 'Total Siswa Terdaftar', Icons.groups),
                  _buildStatCard(Colors.green, _totalGuru.toString(), 'Total Guru & Staff', Icons.badge),
                  _buildStatCard(Colors.orangeAccent, '36', 'Total Rombongan Belajar', Icons.meeting_room),
                  _buildStatCard(Colors.purpleAccent, '42', 'Total Mata Pelajaran', Icons.auto_stories),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // ROW PANELS
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isDesktop ? 6 : 1,
                    child: _buildRecentActivityTable(),
                  ),
                  if (isDesktop) const SizedBox(width: 24),
                  if (isDesktop)
                    Expanded(
                      flex: 4,
                      child: _buildDataHealthCheck(),
                    ),
                ],
              );
            },
          ),

          if (!MediaQuery.of(context).size.width.isFinite || MediaQuery.of(context).size.width <= 800) ...[
            const SizedBox(height: 24),
            _buildDataHealthCheck(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(Color color, String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecentActivityTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aktivitas Perubahan Data Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
              TextButton(onPressed: null, child: const Text('Lihat Log Lengkap')),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
              columns: const [
                DataColumn(label: Text('Modul', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Detail', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Waktu', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                if (_recentActivities.isEmpty) ...[  
                  DataRow(cells: [
                    DataCell(Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey.shade500)),
                    )),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                  ]),
                ] else ..._recentActivities.map((a) {
                  final color = a['action'] == 'INSERT' ? Colors.green
                      : a['action'] == 'DELETE' ? Colors.red
                      : Colors.blue;
                  final time = _timeAgo(DateTime.tryParse(a['performed_at'] ?? '') ?? DateTime.now());
                  return _buildDataRow(
                    a['table_name'] ?? '-',
                    a['action'] ?? '-',
                    a['description'] ?? '-',
                    time,
                    color,
                  );
                }).toList(),
                _buildDataRow('Kelas', 'Penghapusan', 'Menghapus Kelas X IPS 4', '3 Jam lalu', Colors.red),
                _buildDataRow('Siswa', 'Mutasi Keluar', 'Diana Fitri (Pindah)', 'Kemarin', Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String modul, String aksi, String detail, String waktu, Color color) {
    return DataRow(
      cells: [
        DataCell(Text(modul, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(aksi, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(Text(detail)),
        DataCell(Text(waktu, style: TextStyle(color: Colors.grey.shade500))),
      ],
    );
  }

  Widget _buildDataHealthCheck() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kesehatan Data Master', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
          const SizedBox(height: 16),
          _healthCheckItem(Icons.warning_amber_rounded, '15 Siswa belum memiliki NISN', Colors.redAccent),
          _healthCheckItem(Icons.info_outline, '3 Guru belum melengkapi Foto Profil', Colors.orange),
          _healthCheckItem(Icons.group_off, '2 Kelas tidak memiliki Wali Kelas aktif', Colors.deepOrange),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Expanded(child: Text('98% Data Induk Sekolah dalam status Tervalidasi dan Bersih.', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthCheckItem(IconData icon, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
          ),
          TextButton(
            onPressed: null,
            style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero),
            child: Text('Perbaiki', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
