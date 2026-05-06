import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/academic_provider.dart';
import '../../core/providers/system_provider.dart';
import 'wakakur_master_akademik.dart';
import 'wakakur_jadwal_mengajar.dart';
import 'wakakur_jadwal_ujian.dart';
import 'wakakur_monitoring_akademik.dart';
import 'wakakur_rapor.dart';
import 'wakakur_kenaikan.dart';
import 'wakakur_laporan_bimbel.dart';
import '../auth/presentation/login_screen.dart';
import '../../shared/widgets/profile_settings_screen.dart';
import 'models/academic_models.dart';

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
    final systemSettings = ref.watch(systemSettingsProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(systemSettings?.schoolName ?? 'SI Madrasah'),
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
                      child: _getCurrentScreen(isDesktop),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop ? Drawer(child: _buildSidebar(systemSettings?.schoolName ?? 'SI Madrasah')) : null,
    );
  }

  Widget _buildSidebar(String schoolName) {
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
                    color: Colors.teal.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    schoolName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      setState(() => _selectedIndex = index);
                      if (MediaQuery.of(context).size.width <= 800) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal.shade50 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            _menuItems[index]['icon'],
                            color: isSelected ? Colors.teal.shade600 : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _menuItems[index]['title'],
                              style: TextStyle(
                                color: isSelected ? Colors.teal.shade800 : Colors.grey.shade600,
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
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _syncData(),
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sinkronkan Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade50,
              foregroundColor: Colors.teal.shade700,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Wakil Kurikulum', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B3674))),
              Text('Kendali Akademik', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          _buildUserActionMenu(),
        ],
      ),
    );
  }

  Widget _buildUserActionMenu() {
    return PopupMenuButton<String>(
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
        backgroundColor: Colors.teal,
        radius: 18,
        child: Icon(Icons.menu_book, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _getCurrentScreen(bool isDesktop) {
    switch (_selectedIndex) {
      case 0:
        return _buildMainDashboard(isDesktop);
      case 1:
        return WakakurMasterAkademik(key: _screenKey);
      case 2:
        return WakakurJadwalMengajar(key: _screenKey);
      case 3:
        return WakakurJadwalUjian(key: _screenKey);
      case 4:
        return WakakurMonitoringAkademik(key: _screenKey);
      case 5:
        return WakakurRapor(key: _screenKey);
      case 6:
        return WakakurKenaikanKelas(key: _screenKey);
      case 7:
        return WakakurLaporanBimbel(key: _screenKey);
      default:
        return _buildMainDashboard(isDesktop);
    }
  }

  Widget _buildMainDashboard(bool isDesktop) {
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
                'Ringkasan Kurikulum',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const Spacer(),
              // SYNCED SEMESTER DROPDOWN
              semestersAsync.when(
                data: (semesters) {
                  _selectedSemesterId ??= activeSemester?.id ?? (semesters.isNotEmpty ? semesters.first.id : null);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal.shade100),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSemesterId,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal.shade600, size: 20),
                        style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                        onChanged: (String? newValue) => setState(() => _selectedSemesterId = newValue),
                        items: semesters.map<DropdownMenuItem<String>>((s) {
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text('${s.nama} ${s.yearName ?? ""}'),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(width: 150, child: LinearProgressIndicator()),
                error: (_, __) => const Text('Gagal memuat semester'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // GRID STATISTIK
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // DASHBOARD WIDGETS
          isDesktop 
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _buildValidationQueue()),
                  const SizedBox(width: 24),
                  Expanded(flex: 4, child: _buildTeacherActionBoard()),
                ],
              )
            : Column(
                children: [
                  _buildValidationQueue(),
                  const SizedBox(height: 24),
                  _buildTeacherActionBoard(),
                ],
              ),
          const SizedBox(height: 40),
          _buildGovernanceAnalysis(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    double childAspectRatio = 2.2;

    if (screenWidth < 600) {
      crossAxisCount = 1;
      childAspectRatio = 4.0;
    } else if (screenWidth < 1100) {
      crossAxisCount = 2;
      childAspectRatio = 2.5;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(Colors.blueAccent, '95%', 'Progress Rapor', Icons.assignment_turned_in),
        _buildStatCard(Colors.redAccent, '12', 'Guru Belum Input', Icons.pending_actions),
        _buildStatCard(Colors.orangeAccent, '5', 'Kelas Belum Absen', Icons.event_busy),
        _buildStatCard(Colors.teal, '3.210', 'Plotting Jam', Icons.schedule),
      ],
    );
  }

  Widget _buildStatCard(Color color, String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildValidationQueue() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Antrian Validasi Rapor Akhir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          // Mock data for now, could be connected to RaporProvider later
          ...List.generate(3, (index) => _buildValidationItem(index)),
        ],
      ),
    );
  }

  Widget _buildValidationItem(int index) {
    final classes = ['XII IPA 1', 'XI IPS 3', 'X IPA 2'];
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.orange.shade50, child: const Icon(Icons.grading, color: Colors.orange, size: 18)),
      title: Text('Kelas: ${classes[index]}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: const Text('Status: Menunggu Validasi', style: TextStyle(fontSize: 12, color: Colors.orange)),
      trailing: ElevatedButton(onPressed: () {}, child: const Text('Periksa', style: TextStyle(fontSize: 11))),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTeacherActionBoard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Warning: Belum Input Nilai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          const SizedBox(height: 16),
          _buildTeacherWarning('Ahmad Fauzi, S.Pd', 'Matematika'),
          _buildTeacherWarning('Rina Fitria, S.Si', 'Biologi'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.notifications_active, size: 16),
              label: const Text('Kirim Peringatan'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade600, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherWarning(String name, String subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
          Text(subject, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildGovernanceAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tata Kelola & Analisis Sistem', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.indigo.shade100)),
          child: const Row(
            children: [
              Icon(Icons.sync_alt_rounded, color: Colors.indigo),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Sistem Master Akademik sekarang sepenuhnya sinkron dengan Database pusat. Validasi yang dilakukan di sini akan berdampak langsung pada hak akses Guru dalam pengisian nilai.',
                  style: TextStyle(fontSize: 13, color: Colors.indigo),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _syncData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    
    ref.invalidate(semestersProvider);
    ref.invalidate(departmentsProvider);
    ref.invalidate(activeSemesterProvider);

    if (!mounted) return;
    Navigator.pop(context);

    setState(() => _screenKey = UniqueKey());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sinkronisasi Database Berhasil! Data terbaru telah dimuat.')),
    );
  }
}
