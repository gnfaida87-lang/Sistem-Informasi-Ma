import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/router/app_router.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../announcement/presentation/announcement_list_widget.dart';
import 'presentation/teacher_jadwal_widget.dart';
import 'services/teacher_service.dart';
import 'services/wali_kelas_service.dart';
import 'models/teacher_models.dart';
import 'presentation/teacher_absensi_screen.dart';
import 'presentation/teacher_nilai_screen.dart';
import 'presentation/wali_kelas_data_siswa_screen.dart';
import 'presentation/wali_kelas_rekap_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final bool isWaliKelas;
  const TeacherDashboardScreen({super.key, this.isWaliKelas = false});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> with SafeAsync {
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
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    await safeCall(
      context: context,
      action: () async {
        final user = Supabase.instance.client.auth.currentUser;
        
        if (user != null) {
          // ── JALUR RIIL (SUPABASE) ────────────────────────
          final profileData = await _teacherService.getTeacherProfileByUserId(user.id);
          if (profileData != null) {
            setState(() => _profile = profileData);
            if (profileData['is_wali_kelas'] == true) {
              final classData = await _waliKelasService.fetchWaliKelasClass(profileData['id']);
              setState(() {
                _waliKelasClassName = classData?['nama'];
                _waliKelasClassId = classData?['id'];
              });
            }
            final scheduleData = await _teacherService.fetchScheduleByTeacher(profileData['id']);
            setState(() => _schedules = scheduleData);
          }
        } else {
          // ── JALUR DEMO (SIMULASI DATA) ───────────────────
          setState(() {
            _profile = {
              'id': 'demo-teacher-id',
              'nama': 'Guru Demo (Simulasi)',
              'is_wali_kelas': true,
              'nip': '123456789'
            };
            _waliKelasClassName = 'X IPA 1 (Demo)';
            _waliKelasClassId = 'demo-class-id';
            _schedules = [
              TeachingSchedule(
                id: '1', teacherId: 'demo', subjectId: '1', classId: 'demo',
                day: 'Senin', startTime: '07:30', endTime: '09:00',
                className: 'X IPA 1', subjectName: 'Matematika'
              )
            ];
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold dengan BottomNavigationBar Khusus Tampilan Mobile
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

  // ==========================================
  // TAB 1: HOME (GRID MODEREN MOBILE FRIENDLY)
  // ==========================================
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER PROFIL SINGKAT
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
                    if (_profile?['is_wali_kelas'] == true) ...[
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

          // KARTU SUMMARY HARI INI
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

          // GRID MENU UTAMA
          const Text('Menu Akademik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8, // Memberikan ruang vertikal lebih agar tidak overflow
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

              if (_profile?['is_wali_kelas'] == true) ...[
                _buildMenuIcon(context, 'Kelas\nSaya', Icons.school, Colors.blueGrey, _showSubmenuKelasSaya),
              ],
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // BOTTOM SHEET SUB-MENU JADWAL
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
                  setState(() => _currentIndex = 1); // Pindah ke tab jadwal
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.calendar_view_week, color: Colors.indigo.shade700)),
                title: const Text('Jadwal Mingguan'),
                onTap: () { Navigator.pop(context); setState(() => _currentIndex = 1); },
              ),
            ],
          ),
        );
      },
    );
  }

  // BOTTOM SHEET SUB-MENU ABSENSI
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
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.history, color: Colors.blue.shade700)),
                title: const Text('Riwayat Absensi'),
                subtitle: const Text('Cek histori absen siswa'),
                onTap: () { Navigator.pop(context); _showComingSoon('Riwayat Absensi'); },
              ),
            ],
          ),
        );
      },
    );
  }

  // BOTTOM SHEET SUB-MENU NILAI
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
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_document, color: Colors.red.shade700)),
                title: const Text('Input Nilai PTS / PAS / UAS'),
                onTap: () { 
                  Navigator.pop(context); 
                  if (_schedules.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherNilaiScreen(
                      classId: _schedules.first.classId,
                      className: 'Kelas Terdaftar',
                      subjectId: _schedules.first.subjectId,
                      subjectName: 'Mata Pelajaran',
                      jenisNilai: 'Ujian',
                    )));
                  } else {
                    _showToast('Anda belum memiliki jadwal mengajar terdaftar');
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.bar_chart, color: Colors.teal.shade700)),
                title: const Text('Rekap Nilai'),
                onTap: () { Navigator.pop(context); _showComingSoon('Rekap Nilai'); },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.visibility, color: Colors.blue.shade700)),
                title: const Text('Lihat Hasil Nilai'),
                onTap: () { Navigator.pop(context); _showComingSoon('Hasil Nilai Lengkap'); },
              ),
            ],
          ),
        );
      },
    );
  }

  // BOTTOM SHEET SUB-MENU MATERI
  void _showSubmenuMateri() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Materi & CBT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.cloud_upload, color: Colors.purple.shade700),
                title: const Text('Upload Materi (Google Drive)'),
                onTap: () { Navigator.pop(context); _showComingSoon('Upload Materi'); },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.video_call, color: Colors.blue.shade700),
                title: const Text('Link Zoom / Meet'),
                onTap: () { Navigator.pop(context); _showComingSoon('Video Conference'); },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.quiz, color: Colors.orange.shade700),
                title: const Text('Latihan (CBT PG/Essai)'),
                onTap: () { Navigator.pop(context); _showComingSoon('Latihan CBT'); },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.format_list_numbered, color: Colors.green.shade700),
                title: const Text('Hasil Latihan Perkelas'),
                onTap: () { Navigator.pop(context); _showComingSoon('Hasil CBT'); },
              ),
              const Divider(),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.archive, color: Colors.grey.shade700),
                title: const Text('Arsip Materi'),
                onTap: () { Navigator.pop(context); _showComingSoon('Arsip Materi'); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuAlQuran() {
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
              const Text('Al-Qur\'an Digital', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.search, color: Colors.teal.shade700),
                title: const Text('Pencarian Ayat / Surah'),
                onTap: () { Navigator.pop(context); context.push(AppRoutes.quran); },
              ),
              ListTile(
                leading: Icon(Icons.headset, color: Colors.teal.shade700),
                title: const Text('Audio MP3 Murottal'),
                onTap: () { Navigator.pop(context); context.push(AppRoutes.quran); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuAIGuru() {
    context.push(AppRoutes.aiGuru);
  }

  void _showSubmenuPengumuman() {
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
              const Text('Pengumuman Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.campaign, color: Colors.red.shade700),
                title: const Text('Buat Pengumuman Baru'),
                subtitle: const Text('Broadcast info ke kelas'),
                onTap: () { Navigator.pop(context); _showComingSoon('Buat Pengumuman Kelas'); },
              ),
            ],
          ),
        );
      },
    );
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
              const Divider(),
              _buildSubmenuItem(
                icon: Icons.checklist_rtl,
                color: Colors.green,
                title: 'Absensi Kelas Perwalian',
                subtitle: 'Kontrol kehadiran harian siswa Anda',
                onTap: () {
                  Navigator.pop(context);
                  if (_waliKelasClassId != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherAbsensiScreen(
                      classId: _waliKelasClassId!,
                      className: _waliKelasClassName ?? 'Kelas Saya',
                      subjectId: 'HOMEROOM',
                      subjectName: 'Wali Kelas',
                    )));
                  }
                },
              ),
              const SizedBox(height: 16),
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
        title: Row(children: [
          Icon(Icons.construction_outlined, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          const Text('Segera Hadir'),
        ]),
        content: Text('Fitur $fitur sedang dalam pengembangan dan akan tersedia di versi berikutnya.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  Widget _buildMenuIcon(BuildContext context, String title, IconData icon, MaterialColor color, VoidCallback onTap) {
    // Ukuran responsif berdasarkan lebar layar
    double screenWidth = MediaQuery.of(context).size.width;
    double iconBoxSize = screenWidth * 0.16; // Kotak ikon lebih besar
    if (iconBoxSize > 70) iconBoxSize = 70;
    if (iconBoxSize < 50) iconBoxSize = 50;

    double iconSize = iconBoxSize * 0.5; // Ukuran ikon di dalam kotak

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
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: color.shade700, size: iconSize),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: screenWidth < 360 ? 10 : 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2B3674),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: JADWAL
  // ==========================================
  Widget _buildJadwalTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 24, top: 24, bottom: 8),
            child: Text('Agenda Pendidik', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          ),
          TabBar(
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue.shade700,
            tabs: const [
              Tab(text: 'Mengajar (Harian)'),
              Tab(text: 'Mengawas Ujian'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const TeacherJadwalWidget(),
                const _ExamScheduleWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamTimelineItem(String date, String time, String subject, String room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          Container(height: 35, width: 2, color: Colors.orange.shade300, margin: const EdgeInsets.symmetric(horizontal: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(room, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.verified_user_outlined, size: 20, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String subject, String clas, String room, bool isNow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNow ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNow ? Colors.blue.shade200 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(time.split(' - ')[0], style: TextStyle(fontWeight: FontWeight.bold, color: isNow ? Colors.blue.shade700 : Colors.black87)),
              const SizedBox(height: 4),
              Text(time.split(' - ')[1], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          Container(height: 40, width: 2, color: isNow ? Colors.blue : Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.meeting_room, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('$clas • $room', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: INFORMASI
  // ==========================================
  Widget _buildInformasiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Papan Pengumuman', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 24),
          AnnouncementListWidget(targetRoleFilter: 'GM'),
        ],
      ),
    );
  }


  Widget _buildInfoCard(String title, String desc, String date, IconData icon, MaterialColor color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text(date, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.shade700)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: AKUN SAYA
  // ==========================================
  Widget _buildAkunTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Profil Pendidik', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 32),
          
          // AREA UPLOAD FOTO
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade100, width: 3),
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_profile?['nama'] ?? 'Memuat...', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('NIP. ${_profile?['nip'] ?? '-'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 32),

          // FORM BIODATA
          _buildBioField('Nama Lengkap', _profile?['nama'] ?? '-'),
          _buildBioField('NIP / ID', _profile?['nip'] ?? '-'),
          _buildBioField('Status Wali Kelas', (_profile?['is_wali_kelas'] == true) ? 'Ya' : 'Tidak'),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                safeCall(
                  context: context,
                  successMessage: 'Biodata berhasil diperbarui',
                  action: () async {
                    await Future.delayed(const Duration(seconds: 1));
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Simpan Perubahan Biodata'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
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

  Widget _buildBioField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          )
        ],
      ),
    );
  }
}

// ── Widget Jadwal Ujian (fetch dari Supabase) ──────────────
class _ExamScheduleWidget extends StatefulWidget {
  const _ExamScheduleWidget();
  @override
  State<_ExamScheduleWidget> createState() => _ExamScheduleWidgetState();
}

class _ExamScheduleWidgetState extends State<_ExamScheduleWidget> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _schedules = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final teacherId = _supabase.auth.currentUser?.id;
      final res = await _supabase
          .from('exam_schedules')
          .select('id, exam_date, start_time, end_time, subject_name, room, exam_type')
          .eq('teacher_id', teacherId ?? '')
          .gte('exam_date', DateTime.now().toIso8601String().substring(0, 10))
          .order('exam_date')
          .limit(20);
      setState(() {
        _schedules = List<Map<String, dynamic>>.from(res as List);
        _loading = false;
      });
    } catch (_) {
      setState(() { _loading = false; _error = 'Jadwal ujian belum tersedia'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: Padding(
      padding: EdgeInsets.all(32),
      child: CircularProgressIndicator(),
    ));
    if (_schedules.isEmpty) return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.event_available_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(_error ?? 'Tidak ada jadwal ujian mendatang',
              style: TextStyle(color: Colors.grey.shade500)),
        ]),
      ),
    );

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final s = _schedules[i];
        final date = s['exam_date']?.toString() ?? '';
        final start = (s['start_time'] ?? '00:00').toString().substring(0, 5);
        final end = (s['end_time'] ?? '00:00').toString().substring(0, 5);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(children: [
                Text(date.length >= 7 ? date.substring(8, 10) : '-',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                Text(date.length >= 7 ? _monthAbbr(int.tryParse(date.substring(5, 7)) ?? 1) : '',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade500)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['subject_name'] ?? 'Mata Ujian',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.access_time_outlined, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('$start – $end', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(width: 12),
                Icon(Icons.room_outlined, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(s['room'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ]),
              if (s['exam_type'] != null)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s['exam_type'], style: TextStyle(fontSize: 11, color: Colors.orange.shade800)),
                ),
            ])),
          ]),
        );
      },
    );
  }

  String _monthAbbr(int m) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return m >= 1 && m <= 12 ? months[m - 1] : '';
  }
}
