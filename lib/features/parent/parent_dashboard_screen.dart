import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'presentation/parent_jadwal_widget.dart';
import 'presentation/parent_materi_screen.dart';
import 'presentation/parent_bimbel_screen.dart';
import 'presentation/parent_akademik_screen.dart';
import 'presentation/parent_keuangan_screen.dart';
import 'presentation/parent_tabungan_screen.dart';
import 'parent_submenus_screen.dart';
import '../../core/router/app_router.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/auth_provider.dart';
import 'services/parent_service.dart';
import 'models/parent_models.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/network/d1_service.dart';
import '../../core/providers/system_provider.dart';
import '../../core/utils/context_extensions.dart';

import '../../shared/widgets/shared_top_bar.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> with SafeAsync {
  int _currentIndex = 0;
  bool _isLoading = false;
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
      appBar: _currentIndex == 0 ? const SharedTopBar(title: 'Portal Orang Tua', showDrawer: false, showLogout: false) : null,
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwal'),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(_pendingBillsCount.toString()),
                isLabelVisible: _pendingBillsCount > 0,
                child: const Icon(Icons.account_balance_wallet),
              ), 
              label: 'Pembayaran'
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
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
          if (_profile != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
              child: Row(
                children: [
                  Icon(Icons.face, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Anak: ${_profile?.childName ?? '...'} (${_profile?.childClass ?? '...'})', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                      Text('Wali Kelas: ${_profile?.waliKelasName ?? '-'}', style: TextStyle(fontSize: 10, color: Colors.blue.shade700)),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

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
              _buildMenuIcon(context, 'Pembayaran\n& Lainnya', Icons.account_balance_wallet_rounded, Colors.green, _showSubmenuKeuangan),
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
              _buildMenuIcon(context, 'Tabungan', Icons.account_balance_rounded, Colors.orange, _showSubmenuTabungan),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSubmenuAkademik() {
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun Anda belum terhubung dengan data siswa manapun.'), behavior: SnackBarBehavior.floating));
      return;
    }

    // Ekstrak level kelas (X, XI, atau XII) dari string kelas (misal: "Kelas X-A")
    String classLevel = 'X'; 
    if (_profile!.childClass.contains('XII')) {
      classLevel = 'XII';
    } else if (_profile!.childClass.contains('XI')) {
      classLevel = 'XI';
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => ParentAkademikScreen(
      studentId: _profile!.childId,
      studentName: _profile!.childName,
      classLevel: classLevel,
    )));
  }

  void _showSubmenuKeuangan() {
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun Anda belum terhubung dengan data siswa manapun.'), behavior: SnackBarBehavior.floating));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ParentKeuanganScreen(
      studentId: _profile!.childId,
      studentName: _profile!.childName,
    )));
  }

  void _showSubmenuTabungan() {
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun Anda belum terhubung dengan data siswa manapun.'), behavior: SnackBarBehavior.floating));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ParentTabunganScreen(
      studentId: _profile!.childId,
      studentName: _profile!.childName,
    )));
  }

  void _showSubmenuJadwal() {
    setState(() => _currentIndex = 1);
  }

  void _showSubmenuMateri() {
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data anak belum dimuat, coba refresh'),
        behavior: SnackBarBehavior.floating));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParentMateriScreen(studentId: _profile!.childId),
      ),
    );
  }

  void _showSubmenuBimbel() {
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data anak belum dimuat, coba refresh'),
        behavior: SnackBarBehavior.floating));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParentBimbelScreen(studentId: _profile!.childId),
      ),
    );
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

  Future<void> _pickAndUploadProfile() async {
    final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.first.bytes != null) {
      final file = result.files.first;
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) return;

      setState(() => _isLoading = true);
      try {
        final d1 = D1Service();
        final uploadResult = await d1.uploadFile(
          file.bytes!,
          'profile_parent_${userId}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}',
        );

        if (uploadResult['success'] == true) {
          final previewLink = uploadResult['fileUrl'];
          await d1.query("UPDATE users SET profile_url = ? WHERE id = ?", params: [previewLink, userId]);
          _initDashboard(); // Refresh data
          if (mounted) context.showSuccessSnackBar('Foto profil berhasil diperbarui!');
        } else {
          if (mounted) context.showErrorSnackBar('Gagal mengunggah: ${uploadResult['message']}');
        }
      } catch (e) {
        if (mounted) context.showErrorSnackBar('Gagal mengunggah: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildAkunTab() {
    final user = ref.read(authProvider).user;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Profil Pengguna',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 32),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepOrange.shade100, width: 2),
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (user?.profileUrl != null && user!.profileUrl!.isNotEmpty) 
                      ? NetworkImage(user.profileUrl!) 
                      : null,
                  child: (user?.profileUrl == null || user!.profileUrl!.isEmpty) 
                      ? Icon(Icons.person, size: 70, color: Colors.grey.shade400) 
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: FloatingActionButton.small(
                  onPressed: _pickAndUploadProfile,
                  backgroundColor: Colors.deepOrange,
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildProfileItem('NAMA ORANG TUA', _profile?.parentName ?? user?.fullName ?? '-', Icons.person_outline),
          _buildProfileItem('NAMA ANAK', _profile?.childName ?? '-', Icons.child_care),
          _buildProfileItem('NIS / NIM ANAK', _profile?.childNis ?? '-', Icons.badge_outlined),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _showLogoutConfirmation,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar dari Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Versi 2.0.1 - Sistem Informasi Madrasah',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange.shade300, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
          letterSpacing: 0.5,
        ),
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
