import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/network/d1_service.dart';
import '../../core/providers/auth_provider.dart';
import 'operator_master_siswa.dart';
import 'operator_master_guru.dart';
import 'operator_master_kelas.dart';
import 'operator_master_mapel.dart';
import 'operator_master_tahun_ajaran.dart';
import 'operator_master_jurusan.dart';
import 'operator_master_ekskul.dart';
import 'operator_master_bimbel.dart';
import 'operator_peserta_bimbel.dart';
import '../../shared/widgets/shared_top_bar.dart';
import '../../shared/widgets/shared_sidebar.dart';

class OperatorDashboardScreen extends ConsumerStatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  ConsumerState<OperatorDashboardScreen> createState() => _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends ConsumerState<OperatorDashboardScreen> {
  final _d1Service = D1Service();
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  int _totalSiswa = 0;
  int _totalGuru = 0;
  int _totalKelas = 0;
  int _totalMapel = 0;
  List<Map<String, dynamic>> _recentActivities = [];

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

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      
      if (user != null) {
        final siswaData = await _d1Service.query("SELECT COUNT(*) as count FROM students WHERE is_active = 1");
        final guruData = await _d1Service.query("SELECT COUNT(*) as count FROM teachers WHERE is_active = 1");
        final kelasData = await _d1Service.query("SELECT COUNT(*) as count FROM classes");
        final mapelData = await _d1Service.query("SELECT COUNT(*) as count FROM subjects");
        
        List<dynamic> logData = [];
        try {
          logData = await _d1Service.query(
            "SELECT table_name, action, description, performed_at FROM audit_log ORDER BY performed_at DESC LIMIT 5"
          );
        } catch (_) {}

        if (mounted) {
          setState(() {
            _totalSiswa = (siswaData as List).isNotEmpty ? ((siswaData.first['count'] ?? 0) as num).toInt() : 0;
            _totalGuru = (guruData as List).isNotEmpty ? ((guruData.first['count'] ?? 0) as num).toInt() : 0;
            _totalKelas = (kelasData as List).isNotEmpty ? ((kelasData.first['count'] ?? 0) as num).toInt() : 0;
            _totalMapel = (mapelData as List).isNotEmpty ? ((mapelData.first['count'] ?? 0) as num).toInt() : 0;
            _recentActivities = List<Map<String, dynamic>>.from(logData as List);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          if (isDesktop) 
            SharedSidebar(
              selectedIndex: _selectedIndex,
              menuItems: _menuItems,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
              accentColor: const Color(0xFF2B3674),
            ),
          Expanded(
            child: Column(
              children: [
                SharedTopBar(title: _menuItems[_selectedIndex]['title']),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                    child: Container(
                      color: const Color(0xFFF4F7FE),
                      child: _getCurrentScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop ? Drawer(
        child: SharedSidebar(
          selectedIndex: _selectedIndex,
          menuItems: _menuItems,
          onItemSelected: (index) => setState(() => _selectedIndex = index),
          accentColor: const Color(0xFF2B3674),
        ),
      ) : null,
    );
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0: return _buildMainContent();
      case 1: return const OperatorMasterTahunAjaran();
      case 2: return const OperatorMasterJurusan();
      case 3: return const OperatorMasterGuru();
      case 4: return const OperatorMasterSiswa();
      case 5: return const OperatorMasterKelas();
      case 6: return const OperatorMasterMapel();
      case 7: return const OperatorMasterEkskul();
      case 8: return const OperatorMasterBimbel();
      case 9: return const OperatorPesertaBimbel();
      default: return _buildMainContent();
    }
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Data Center',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildStatGrid(),
            const SizedBox(height: 24),
            _buildRecentActivityTable(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(Colors.blue, _totalSiswa.toString(), 'Siswa', Icons.groups),
        _buildStatCard(Colors.green, _totalGuru.toString(), 'Guru', Icons.badge),
        _buildStatCard(Colors.orange, _totalKelas.toString(), 'Kelas', Icons.meeting_room),
        _buildStatCard(Colors.purple, _totalMapel.toString(), 'Mapel', Icons.auto_stories),
      ],
    );
  }

  Widget _buildStatCard(Color color, String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aktivitas Terakhir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivities.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final a = _recentActivities[index];
              return ListTile(
                dense: true,
                title: Text(a['description'] ?? '-'),
                subtitle: Text("${a['table_name']} • ${a['action']}"),
                trailing: Text(_timeAgo(a['performed_at'])),
              );
            },
          ),
          if (_recentActivities.isEmpty)
            const Center(child: Text('Belum ada aktivitas tercatat.')),
        ],
      ),
    );
  }

  String _timeAgo(dynamic dateTime) {
    if (dateTime == null) return '-';
    DateTime dt;
    if (dateTime is DateTime) {
      dt = dateTime;
    } else if (dateTime is String) {
      dt = DateTime.tryParse(dateTime) ?? DateTime.now();
    } else {
      return '-';
    }

    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} hari yang lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam yang lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit yang lalu';
    return 'Baru saja';
  }
}
