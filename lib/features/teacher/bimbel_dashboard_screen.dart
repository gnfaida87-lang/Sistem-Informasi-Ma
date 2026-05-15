import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/auth_provider.dart';
import 'services/teacher_service.dart';
import 'services/bimbel_service.dart';
import 'models/teacher_models.dart';
import 'bimbel_submenus_screen.dart';
import '../../core/utils/context_extensions.dart';
import '../../core/network/d1_service.dart';
import '../../core/providers/system_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'presentation/bimbel_materi_screen.dart';
import 'presentation/bimbel_latihan_screen.dart';
import 'presentation/bimbel_jadwal_screen.dart';
import 'presentation/bimbel_nilai_unified_screen.dart';
import 'presentation/bimbel_absensi_unified_screen.dart';
import '../../shared/widgets/shared_top_bar.dart';
import 'package:intl/date_symbol_data_local.dart';

class BimbelDashboardScreen extends ConsumerStatefulWidget {
  const BimbelDashboardScreen({super.key});

  @override
  ConsumerState<BimbelDashboardScreen> createState() => _BimbelDashboardScreenState();
}

class _BimbelDashboardScreenState extends ConsumerState<BimbelDashboardScreen> with SafeAsync {
  int _currentIndex = 0;
  bool _isLoading = false;
  final _teacherService = TeacherService();
  final _bimbelService = BimbelService();
  Map<String, dynamic>? _profile;
  List<BimbelSession> _sessions = [];
  List<Map<String, dynamic>> _myPrograms = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeDateFormatting('id_ID', null).then((_) {
        _initDashboard();
      });
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
            
            final results = await Future.wait([
              _bimbelService.fetchTutorSessions(profileData['id']),
              _bimbelService.fetchProgramsByTeacher(profileData['id']),
            ]);

            setState(() {
              _sessions = results[0] as List<BimbelSession>;
              _myPrograms = results[1] as List<Map<String, dynamic>>;
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
      appBar: _currentIndex == 0 ? const SharedTopBar(title: 'Beranda Bimbel', showDrawer: false, showLogout: false) : null,
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
          selectedItemColor: Colors.deepPurple.shade700,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwal'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
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
        return _buildAkunTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final user = ref.read(authProvider).user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Hero Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      backgroundImage: (user?.profileUrl != null) ? NetworkImage(user!.profileUrl!) : null,
                      child: (user?.profileUrl == null) ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat Datang,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                          Text(
                            _profile?['nama'] ?? user?.fullName ?? 'Tutor Bimbel',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _profile?['nip'] != null ? 'NIP: ${_profile!['nip']}' : 'ID Tutor: ${user?.id.substring(0, 8).toUpperCase() ?? '-'}',
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green.shade400, borderRadius: BorderRadius.circular(4)),
                                child: const Text('AKTIF', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.verified_user, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Subjects / Programs Taught
                if (_myPrograms.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MATA PELAJARAN DIAMPUI:', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _myPrograms.map((prog) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(prog['nama'] ?? 'Bimbel', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                // Internal Quick Stats Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeroStat('Sesi', '${_sessions.length}', Icons.timer_outlined),
                      _buildHeroStat('Siswa', '24', Icons.people_outline), // Mock student count for now
                      _buildHeroStat('Avg', '85%', Icons.star_outline),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Live Session Indicator (If any)
          if (_sessions.any((s) => DateTime.now().isAfter(s.sessionDate) && DateTime.now().isBefore(s.sessionDate.add(Duration(minutes: s.durationMinutes)))))
            _buildLiveSessionCard(),

          const Text('Modul Bimbingan Belajar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4, // 4 items per row for a more compact, modern look
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuIcon(context, 'Jadwal', Icons.calendar_today, Colors.blue, _showSubmenuJadwal),
              _buildMenuIcon(context, 'Absensi', Icons.how_to_reg, Colors.green, _showSubmenuAbsensi),
              _buildMenuIcon(context, 'Nilai', Icons.score, Colors.orange, _showSubmenuNilai),
              _buildMenuIcon(context, 'Materi', Icons.menu_book, Colors.purple, _showSubmenuMateri),
              _buildMenuIcon(context, 'Al-Qur\'an', Icons.auto_stories, Colors.teal, () {
                context.push(AppRoutes.quran);
              }),
              _buildMenuIcon(context, 'AI Guru', Icons.auto_awesome, Colors.indigo, () {
                context.push(AppRoutes.aiGuru);
              }),
              _buildMenuIcon(context, 'Notif', Icons.campaign, Colors.red, _showSubmenuPengumuman),
              _buildMenuIcon(context, 'Lainnya', Icons.more_horiz, Colors.grey, () {}),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSubmenuJadwal() {
    if (_profile == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => BimbelJadwalScreen(
      teacherId: _profile!['id'],
    )));
  }

  void _showSubmenuAbsensi() {
    if (_profile == null || _myPrograms.isEmpty) {
      _showToast('Data belum siap atau Anda belum mengampu program bimbel');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => BimbelAbsensiUnifiedScreen(
      myPrograms: _myPrograms,
      teacherId: _profile!['id'],
    )));
  }

  void _showSubmenuNilai() {
    if (_profile == null || _myPrograms.isEmpty) {
      _showToast('Data belum siap atau Anda belum mengampu program bimbel');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => BimbelNilaiUnifiedScreen(
      myPrograms: _myPrograms,
      teacherId: _profile!['id'],
    )));
  }

  void _showSubmenuMateri() {
    if (_myPrograms.isEmpty) {
      _showToast('Anda belum mengampu mata pelajaran bimbel');
      return;
    }
    
    // Show program picker if multiple programs, otherwise go directly
    if (_myPrograms.length == 1) {
      final p = _myPrograms.first;
      Navigator.push(context, MaterialPageRoute(builder: (context) => BimbelLatihanUnifiedScreen(
        programId: p['id'],
        programName: p['nama'] ?? 'Bimbel',
      )));
    } else {
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
                const Text('Pilih Program Bimbel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _myPrograms.length,
                    itemBuilder: (context, index) {
                      final p = _myPrograms[index];
                      return ListTile(
                        leading: const Icon(Icons.school, color: Colors.deepPurple),
                        title: Text(p['nama'] ?? 'Bimbel'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BimbelLatihanUnifiedScreen(
                            programId: p['id'],
                            programName: p['nama'] ?? 'Bimbel',
                          )));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
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
              const Text('Pengumuman Bimbel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.campaign, color: Colors.red.shade700),
                title: const Text('Lihat Pengumuman'),
                onTap: () { Navigator.pop(context); context.push(AppRoutes.announcementParent); },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuIcon(BuildContext context, String title, IconData icon, MaterialColor color, VoidCallback onTap) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconBoxSize = screenWidth * 0.14;
    if (iconBoxSize > 60) iconBoxSize = 60;
    if (iconBoxSize < 45) iconBoxSize = 45;
    double iconSize = iconBoxSize * 0.45;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: color.shade50, width: 1),
            ),
            child: Icon(icon, color: color.shade700, size: iconSize),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: screenWidth < 360 ? 9 : 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
      ],
    );
  }

  Widget _buildLiveSessionCard() {
    final liveSession = _sessions.firstWhere((s) => DateTime.now().isAfter(s.sessionDate) && DateTime.now().isBefore(s.sessionDate.add(Duration(minutes: s.durationMinutes))));
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(Icons.record_voice_over, color: Colors.red.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('SEDANG BERLANGSUNG', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(width: 8),
                    _buildBlinkingDot(),
                  ],
                ),
                Text(liveSession.topic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(liveSession.programName ?? 'Bimbel', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showSubmenuAbsensi,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Absen', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlinkingDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    );
  }

  Widget _buildJadwalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jadwal Bimbel Anda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 24),
          if (_sessions.isEmpty)
             const Center(child: Text('Tidak ada sesi bimbel terdaftar', style: TextStyle(color: Colors.grey)))
          else
            ..._sessions.map((s) => _buildTimelineItem(
              '${s.sessionDate.hour.toString().padLeft(2, '0')}:${s.sessionDate.minute.toString().padLeft(2, '0')}',
              s.topic,
              s.programName ?? 'Bimbel',
              '${s.durationMinutes} Menit',
              DateTime.now().isAfter(s.sessionDate) && DateTime.now().isBefore(s.sessionDate.add(Duration(minutes: s.durationMinutes))),
            )),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String subject, String clas, String room, bool isNow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNow ? Colors.deepPurple.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNow ? Colors.deepPurple.shade200 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isNow ? Colors.deepPurple.shade700 : Colors.black87)),
                const SizedBox(height: 4),
                Text('Sesi', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(height: 40, width: 2, color: isNow ? Colors.deepPurple : Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 16)),
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
          'profile_bimbel_${userId}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}',
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
            'Profil Tutor Bimbel',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 32),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurple.shade100, width: 2),
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
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildProfileItem('NAMA LENGKAP TUTOR', _profile?['nama'] ?? user?.fullName ?? '-', Icons.person_outline),
          _buildProfileItem('NOMOR INDUK PEGAWAI (NIP)', _profile?['nip'] ?? '-', Icons.badge_outlined),
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
          Icon(icon, color: Colors.deepPurple.shade300, size: 22),
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

  void _showSessionPicker(BuildContext context, Function(BimbelSession) onSelected) {
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
              const Text('Pilih Sesi Bimbel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final s = _sessions[index];
                    return ListTile(
                      leading: const Icon(Icons.class_, color: Colors.deepPurple),
                      title: Text(s.programName ?? 'Bimbel Tanpa Nama'),
                      subtitle: Text('${s.topic} - ${s.sessionDate.toString().split(' ')[0]}'),
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(s);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }
}
