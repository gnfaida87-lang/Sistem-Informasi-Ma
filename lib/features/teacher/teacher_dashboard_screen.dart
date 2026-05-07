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

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  final bool isWaliKelas;
  const TeacherDashboardScreen({super.key, this.isWaliKelas = false});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> with SafeAsync {
  int _currentIndex = 0;
  final _teacherService = TeacherService();
  final _waliKelasService = WaliKelasService();
  Map<String, dynamic>? _profile;
  List<TeachingSchedule> _schedules = [];
  String? _waliKelasClassName;
  String? _waliKelasClassId;

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
            setState(() => _schedules = scheduleData);
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
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwal'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Informasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun Saya'),
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
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat Pagi,', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text(_profile?['nama'] ?? 'Memuat...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                    if (_profile?['is_wali_kelas'] == 1 || _profile?['is_wali_kelas'] == true) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text('Wali Kelas: ${_waliKelasClassName ?? "Aktif"}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                      ),
                    ]
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                child: Icon(Icons.notifications_none, color: Colors.blue.shade700),
              )
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.blue.shade200, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jadwal Mengajar Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('${_schedules.length} Sesi Jadwal', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Tersebar di beberapa kelas', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.access_time, color: Colors.white, size: 32),
                )
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
              _buildMenuIcon(context, 'Materi &\nLatihan', Icons.menu_book, Colors.purple, _showSubmenuMateri),
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
    _showComingSoon('Materi & CBT');
  }

  void _showSubmenuPengumuman() {
    _showComingSoon('Pengumuman Kelas');
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

  Widget _buildAkunTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_profile?['nama'] ?? 'Guru', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
