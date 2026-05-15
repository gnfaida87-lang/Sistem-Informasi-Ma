import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/auth_provider.dart';
import '../announcement/presentation/announcement_list_widget.dart';
import 'presentation/teacher_jadwal_widget.dart';
import 'services/teacher_service.dart';
import 'services/wali_kelas_service.dart';
import 'models/teacher_models.dart';
import 'presentation/teacher_absensi_screen.dart';
import 'presentation/teacher_nilai_screen.dart';
import 'presentation/wali_kelas_data_siswa_screen.dart';
import 'presentation/wali_kelas_rekap_screen.dart';
import 'presentation/bimbel_materi_screen.dart';
import 'presentation/teacher_materi_unified_screen.dart';
import 'presentation/teacher_exam_proctoring_screen.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/network/d1_service.dart';
import '../../core/providers/system_provider.dart';
import '../../core/utils/context_extensions.dart';

import '../../shared/widgets/shared_top_bar.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  final bool isWaliKelas;
  const TeacherDashboardScreen({super.key, this.isWaliKelas = false});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> with SafeAsync {
  int _currentIndex = 0;
  bool _isLoading = false;
  final _teacherService = TeacherService();
  final _waliKelasService = WaliKelasService();
  Map<String, dynamic>? _profile;
  List<TeachingSchedule> _schedules = [];
  String? _waliKelasClassName;
  String? _waliKelasClassId;
  int _unreadAnnouncements = 0;

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
          final profileData = await _teacherService.getTeacherProfileByUserId(user.id);
          if (profileData != null) {
            setState(() => _profile = profileData);
            if (profileData['is_wali_kelas'] == 1 || profileData['is_wali_kelas'] == true) {
              final classData = await _waliKelasService.fetchWaliKelasClass(profileData['id']);
              setState(() {
                _waliKelasClassName = classData?['nama'];
                _waliKelasClassId = classData?['id'];
              });
            }
            final scheduleData = await _teacherService.fetchScheduleByTeacher(profileData['id']);
            final announcements = await _teacherService.getAnnouncements();
            
            setState(() {
              _schedules = scheduleData;
              _unreadAnnouncements = announcements.length; // Simplified: count all as unread initially
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
      appBar: _currentIndex == 0 ? const SharedTopBar(title: 'Beranda Guru', showDrawer: false, showLogout: false) : null,
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
              if (index == 2) _unreadAnnouncements = 0; // Clear badge when visiting Info
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwal'),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(_unreadAnnouncements.toString()),
                isLabelVisible: _unreadAnnouncements > 0,
                child: const Icon(Icons.campaign),
              ), 
              label: 'Info'
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
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
        return _buildInformasiTab();
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
          // --- HERO SECTION: IDENTITAS GURU ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        (_profile?['nama'] ?? 'G')
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile?['nama'] ?? 'Memuat...',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'NIP: ${_profile?['nip'] ?? '-'}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (_profile?['is_wali_kelas'] == 1 || _profile?['is_wali_kelas'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Wali Kelas ${_waliKelasClassName ?? ""}',
                          style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sesi Mengajar Hari Ini',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11),
                        ),
                        Text(
                          '${_schedules.length} Jadwal',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calendar_month,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text('Menu Akademik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuIcon(context, 'Jadwal\nMengajar', Icons.calendar_today, Colors.blue, _showSubmenuJadwal),
              _buildMenuIcon(context, 'Absensi\nSiswa', Icons.co_present, Colors.green, _showSubmenuAbsensi),
              _buildMenuIcon(context, 'Penilaian\nSiswa', Icons.history_edu, Colors.orange, _showSubmenuNilai),
              _buildMenuIcon(context, 'Materi', Icons.menu_book, Colors.purple, _showSubmenuMateri),
              _buildMenuIcon(context, 'Al-Qur\'an\nDigital', Icons.menu_book_outlined, Colors.teal, () {
                context.push(AppRoutes.quran);
              }),
              _buildMenuIcon(context, 'AI Sahabat\nGuru', Icons.smart_toy, Colors.indigo, () {
                context.push(AppRoutes.aiGuru);
              }),
              _buildMenuIcon(context, 'Pengumuman\nKelas', Icons.campaign, Colors.red, _showSubmenuPengumuman),

              if (_profile?['is_wali_kelas'] == 1 || _profile?['is_wali_kelas'] == true) ...[
                _buildMenuIcon(context, 'Kelas\nSaya', Icons.school, Colors.blueGrey, _showSubmenuKelasSaya),
              ],
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSubmenuJadwal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jadwal Mengajar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.today, color: Colors.blue.shade700)),
                title: const Text('Jadwal Hari Ini'),
                onTap: () { 
                  Navigator.pop(context); 
                  setState(() => _currentIndex = 1);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.assignment_ind, color: Colors.orange.shade700)),
                title: const Text('Jadwal Mengawas Ujian'),
                subtitle: const Text('Tugas piket pengawasan ujian'),
                onTap: () { 
                  Navigator.pop(context); 
                  if (_profile != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherExamProctoringScreen(
                      teacherName: _profile!['nama'],
                    )));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuAbsensi() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Menu Absensi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.fact_check, color: Colors.green.shade700)),
                title: const Text('Input Absensi'),
                subtitle: const Text('Kehadiran Kelas Berds. Jadwal'),
                onTap: () { 
                  Navigator.pop(context); 
                  if (_schedules.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherAbsensiScreen(
                      classId: _schedules.first.classId,
                      className: 'Kelas Terdaftar',
                      subjectId: _schedules.first.subjectId,
                      subjectName: 'Mata Pelajaran',
                    )));
                  } else {
                    _showToast('Anda belum memiliki jadwal mengajar terdaftar');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuNilai() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Menu Penilaian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.assignment, color: Colors.orange.shade700)),
                title: const Text('Input Nilai Tugas'),
                onTap: () { 
                  Navigator.pop(context); 
                  if (_schedules.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherNilaiScreen(
                      classId: _schedules.first.classId,
                      className: 'Kelas Terdaftar',
                      subjectId: _schedules.first.subjectId,
                      subjectName: 'Mata Pelajaran',
                      jenisNilai: 'Tugas',
                    )));
                  } else {
                    _showToast('Anda belum memiliki jadwal mengajar terdaftar');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuMateri() {
    if (_profile == null) {
      _showToast('Data profil belum siap');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherMateriUnifiedScreen(
      profile: _profile!,
      schedules: _schedules,
    )));
  }

  Widget _buildSubmenuIconSmall(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showSubmenuPengumuman() {
    context.push(AppRoutes.announcementParent);
  }

  void _showSubmenuKelasSaya() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.school, color: Colors.blueGrey.shade700),
                  const SizedBox(width: 12),
                  Text('Kelas Saya: ${_waliKelasClassName ?? "..."}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              _buildSubmenuItem(
                icon: Icons.face_retouching_natural,
                color: Colors.blue,
                title: 'Data Siswa',
                subtitle: 'Profil, kontak, dan data wali siswa',
                onTap: () {
                  Navigator.pop(context);
                  if (_waliKelasClassId != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => WaliKelasDataSiswaScreen(
                      classId: _waliKelasClassId!,
                      className: _waliKelasClassName ?? 'Kelas',
                    )));
                  }
                },
              ),
              const Divider(),
              _buildSubmenuItem(
                icon: Icons.pie_chart,
                color: Colors.brown,
                title: 'Rekap Nilai & Akademik',
                subtitle: 'Melihat perkembangan nilai kelas perwalian',
                onTap: () {
                  Navigator.pop(context);
                  if (_waliKelasClassId != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => WaliKelasRekapScreen(
                      classId: _waliKelasClassId!,
                      className: _waliKelasClassName ?? 'Kelas',
                    )));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmenuItem({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      onTap: onTap,
    );
  }

  void _showComingSoon(String fitur) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Segera Hadir'),
        content: Text('Fitur $fitur sedang dalam pengembangan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildMenuIcon(BuildContext context, String title, IconData icon, MaterialColor color, VoidCallback onTap) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconBoxSize = screenWidth * 0.16;
    if (iconBoxSize > 70) iconBoxSize = 70;
    if (iconBoxSize < 50) iconBoxSize = 50;
    double iconSize = iconBoxSize * 0.5;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color.shade700, size: iconSize),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalTab() {
    return const TeacherJadwalWidget();
  }

  Widget _buildInformasiTab() {
    return AnnouncementListWidget(targetRoleFilter: 'guru');
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
          'profile_teacher_${userId}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}',
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
            'Profil Pengajar',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 32),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade100, width: 2),
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
                  backgroundColor: Colors.blue.shade700,
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildProfileItem('NAMA LENGKAP GURU', _profile?['nama'] ?? user?.fullName ?? '-', Icons.person_outline),
          _buildProfileItem('NOMOR INDUK PEGAWAI (NIP)', _profile?['nip'] ?? '-', Icons.badge_outlined),
          _buildProfileItem('STATUS WALI KELAS', (widget.isWaliKelas ? 'Wali Kelas $_waliKelasClassName' : 'Guru Mata Pelajaran'), Icons.school_outlined),
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
          Icon(icon, color: Colors.blue.shade300, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
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
}
