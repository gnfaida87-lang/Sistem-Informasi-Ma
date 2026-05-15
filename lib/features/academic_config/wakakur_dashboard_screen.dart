import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/academic_provider.dart';
import '../../core/providers/system_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'wakakur_master_akademik.dart';
import 'wakakur_jadwal_mengajar.dart';
import 'wakakur_jadwal_ujian.dart';
import 'wakakur_monitoring_akademik.dart';
import 'wakakur_rapor.dart';
import 'wakakur_kenaikan.dart';
import 'wakakur_laporan_bimbel.dart';
import '../../shared/widgets/shared_top_bar.dart';
import '../../shared/widgets/shared_sidebar.dart';

class WakakurDashboardScreen extends ConsumerStatefulWidget {
  const WakakurDashboardScreen({super.key});

  @override
  ConsumerState<WakakurDashboardScreen> createState() => _WakakurDashboardScreenState();
}

class _WakakurDashboardScreenState extends ConsumerState<WakakurDashboardScreen> {
  int _selectedIndex = 0;
  Key _screenKey = UniqueKey();
  String? _selectedSemesterId;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard_outlined},
    {'title': 'Master Akademik', 'icon': Icons.account_tree_outlined},
    {'title': 'Jadwal Mengajar', 'icon': Icons.calendar_month_outlined},
    {'title': 'Jadwal Ujian', 'icon': Icons.event_note_outlined},
    {'title': 'Monitoring Akademik', 'icon': Icons.insights_outlined},
    {'title': 'Rapor', 'icon': Icons.assignment_outlined},
    {'title': 'Kenaikan Kelas', 'icon': Icons.trending_up_outlined},
    {'title': 'Laporan Bimbel', 'icon': Icons.menu_book_outlined},
  ];

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
              accentColor: Colors.teal.shade700,
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
          accentColor: Colors.teal.shade700,
        ),
      ) : null,
    );
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0: return _buildMainDashboard();
      case 1: return WakakurMasterAkademik(key: _screenKey);
      case 2: return WakakurJadwalMengajar(key: _screenKey);
      case 3: return WakakurJadwalUjian(key: _screenKey);
      case 4: return WakakurMonitoringAkademik(key: _screenKey);
      case 5: return WakakurRapor(key: _screenKey);
      case 6: return WakakurKenaikanKelas(key: _screenKey);
      case 7: return WakakurLaporanBimbel(key: _screenKey);
      default: return _buildMainDashboard();
    }
  }

  Widget _buildMainDashboard() {
    final semestersAsync = ref.watch(semestersProvider);
    final activeSemester = ref.watch(activeSemesterProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Dashboard Kurikulum',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              semestersAsync.when(
                data: (semesters) {
                  _selectedSemesterId ??= activeSemester?.id ?? (semesters.isNotEmpty ? semesters.first.id : null);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSemesterId,
                        onChanged: (String? newValue) => setState(() => _selectedSemesterId = newValue),
                        items: semesters.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nama))).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Text('Gunakan menu samping untuk mengatur jadwal, rapor, dan monitoring akademik.'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(Colors.blue, '0%', 'Progress Rapor', Icons.assignment_turned_in),
        _buildStatCard(Colors.red, '0', 'Guru Belum Input', Icons.pending_actions),
        _buildStatCard(Colors.orange, '0', 'Kelas Belum Absen', Icons.event_busy),
        _buildStatCard(Colors.teal, '0', 'Plotting Jam', Icons.schedule),
      ],
    );
  }

  Widget _buildStatCard(Color color, String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _syncData() async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    await Future.delayed(const Duration(milliseconds: 800));
    ref.invalidate(semestersProvider);
    ref.invalidate(departmentsProvider);
    ref.invalidate(activeSemesterProvider);
    if (!mounted) return;
    Navigator.pop(context);
    setState(() => _screenKey = UniqueKey());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sinkronisasi Berhasil!')));
  }
}
