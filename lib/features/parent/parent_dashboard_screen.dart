import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'presentation/parent_jadwal_widget.dart';
import 'parent_submenus_screen.dart';
import '../../core/router/app_router.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/auth_provider.dart';
import 'services/parent_service.dart';
import 'models/parent_models.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> with SafeAsync {
  int _currentIndex = 0;
  final _parentService = ParentService();
  ParentChildProfile? _profile;
  ChildAttendanceSummary? _attendanceToday;
  int _pendingBillsCount = 0;
  double _savingsBalance = 0;
  List<Map<String, dynamic>> _examSchedules = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDashboard();
    });
  }

  Future<void> _initDashboard() async {
    await safeCall(
      context: context,
      action: () async {
        final user = ref.read(authProvider).user;
        
        if (user != null) {
          final profileData = await _parentService.getParentDashboardProfile(user.id);
          if (profileData != null) {
            setState(() => _profile = profileData);
            final results = await Future.wait<dynamic>([
              _parentService.getChildAttendanceToday(profileData.childId),
              _parentService.getStudentFinances(profileData.childId),
              _parentService.getStudentSavings(profileData.childId),
            ]);
            setState(() {
              _attendanceToday = results[0] as ChildAttendanceSummary?;
              _pendingBillsCount = (results[1] as List).length;
              _savingsBalance = results[2] as double;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepOrange.shade700,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwal'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Keuangan'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil Saya'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildJadwalTab();
      case 2:
        return _buildKeuanganTab();
      case 3:
        return _buildAkunTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.deepOrange,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Portal Wali Murid,', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text(_profile?.parentName ?? 'Memuat...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text('Anak: ${_profile?.childName ?? '...'} (${_profile?.childClass ?? '...'})', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                    ),
                    const SizedBox(height: 4),
                    Text('Wali Kelas: ${_profile?.waliKelasName ?? '...'}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.deepOrange.shade50, shape: BoxShape.circle),
                child: Icon(Icons.notifications_active, color: Colors.deepOrange.shade700),
              )
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepOrange.shade700, Colors.deepOrange.shade400]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.deepOrange.shade200, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Kehadiran Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                            child: Text(_attendanceToday?.status ?? 'BELUM ABSEN', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          ),
                          const SizedBox(width: 8),
                          Text(_attendanceToday?.time ?? '--:--', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_attendanceToday != null ? 'Anak Anda telah tiba di Madrasah.' : 'Anak Anda belum melakukan absensi hari ini.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.fingerprint, color: Colors.white, size: 32),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text('Menu Utama Portal Orang Tua', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: [
              _buildMenuIcon(context, 'Akademik', Icons.school_rounded, Colors.blue, _showSubmenuAkademik),
              _buildMenuIcon(context, 'Keuangan', Icons.account_balance_wallet_rounded, Colors.green, _showSubmenuKeuangan),
              _buildMenuIcon(context, 'Jadwal', Icons.event_note_rounded, Colors.orange, _showSubmenuJadwal),
              _buildMenuIcon(context, 'Materi\n& Tugas', Icons.library_books_rounded, Colors.purple, _showSubmenuMateri),
              _buildMenuIcon(context, 'Bimbel', Icons.groups_rounded, Colors.teal, _showSubmenuBimbel),
              _buildMenuIcon(context, 'Al-Qur\'an', Icons.menu_book_rounded, Colors.brown, () {
                context.push(AppRoutes.quran);
              }),
              _buildMenuIcon(context, 'AI Sahabat\nBelajar', Icons.auto_awesome_rounded, Colors.indigo, () {
                context.push(AppRoutes.aiBelajar);
              }),
              _buildMenuIcon(context, 'Pengumuman', Icons.campaign_rounded, Colors.red, () {
                context.push(AppRoutes.announcementParent);
              }),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSubmenuAkademik() {
    _showComingSoon('Menu Akademik');
  }

  void _showSubmenuKeuangan() {
    _showComingSoon('Menu Keuangan');
  }

  void _showSubmenuJadwal() {
    _showComingSoon('Menu Jadwal');
  }

  void _showSubmenuMateri() {
    _showComingSoon('Materi & Tugas');
  }

  void _showSubmenuBimbel() {
    _showComingSoon('Menu Bimbel');
  }

  Widget _buildMenuIcon(BuildContext context, String title, IconData icon, MaterialColor color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            title, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B3674), height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalTab() {
    return const ParentJadwalWidget();
  }

  Widget _buildKeuanganTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kewajiban & Tabungan Anak', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 24),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
            leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(Icons.account_balance_wallet, color: Colors.green.shade700)),
            title: Text('Tabungan Siswa (${_profile?.childName ?? 'Anak'})'),
            subtitle: const Text('Saldo Total Saat Ini'),
            trailing: Text('Rp ${_savingsBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildAkunTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Pengaturan Akun Wali Murid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 32),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(_profile?.parentName ?? 'Orang Tua', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Wali Murid: ${_profile?.childName ?? '...'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go(AppRoutes.login);
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Keluar Aplikasi (Logout)'),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String fitur) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Segera Hadir'),
        content: Text('Fitur $fitur sedang dalam pengembangan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
