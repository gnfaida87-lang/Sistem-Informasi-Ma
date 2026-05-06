import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/parent_jadwal_widget.dart';
import 'parent_submenus_screen.dart';
import '../../core/router/app_router.dart';
import '../../core/mixins/safe_async_mixin.dart';
import 'services/parent_service.dart';
import 'models/parent_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}


class _ParentDashboardScreenState extends State<ParentDashboardScreen> with SafeAsync {
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
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    await safeCall(
      context: context,
      action: () async {
        final user = Supabase.instance.client.auth.currentUser;
        
        if (user != null) {
          // ── JALUR RIIL (SUPABASE) ────────────────────────
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
        } else {
          // ── JALUR DEMO (SIMULASI DATA) ───────────────────
          setState(() {
            _profile = ParentChildProfile(
              parentId: 'demo-parent',
              parentName: 'Bpk. Haryanto (Simulasi)',
              childId: 'demo-child',
              childName: 'Fatih (Demo)',
              childClass: 'X IPA 1',
              classId: 'demo-class-id',
              waliKelasName: 'Ibu Siti Aminah',
            );
            _attendanceToday = ChildAttendanceSummary(
              status: 'HADIR',
              time: '07:15',
              date: DateTime.now(),
            );
            _pendingBillsCount = 2;
            _savingsBalance = 1250000;
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

  // ==========================================
  // TAB 1: HOME (GRID MODEREN MOBILE FRIENDLY)
  // ==========================================
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER PROFIL SINGKAT ORANG TUA
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

          // KARTU SUMMARY AKTIVITAS ANAK
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

          // GRID MENU UTAMA ORANG TUA (RE-DESIGNED)
          const Text('Menu Utama Portal Orang Tua', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3, // Reduced to 3 for better spacing and larger icons
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85, // Adjust ratio to give more vertical space for text
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

  // ==========================================
  // BOTTOM SHEETS MODUL ORANG TUA
  // ==========================================
  void _showSubmenuAkademik() {
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
              const Text('1. Menu Akademik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSubmenuItem(Icons.assignment, Colors.blue, 'Nilai Tugas / PTS / PAS / UAS', 'Lihat perkembangan nilai per semester', () {
                Navigator.pop(context);
                if (_profile != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ParentAkademikNilaiScreen(studentId: _profile!.childId)));
                }
              }),
              _buildSubmenuItem(Icons.school, Colors.green, 'Rapor Digital', 'Cetak & lihat hasil belajar per semester', () {
                Navigator.pop(context);
                _showComingSoon('Fitur ini');
              }),
              _buildSubmenuItem(Icons.history, Colors.orange, 'Absensi Siswa', 'Pantau kehadiran anak per semester', () {
                Navigator.pop(context);
                _showComingSoon('Absensi Siswa');
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuKeuangan() {
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
              const Text('2. Menu Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSubmenuItem(Icons.receipt_long, Colors.red, 'Tagihan (SPP/Ujian)', 'Cek tagihan yang harus dibayar', () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              }),
              _buildSubmenuItem(Icons.history, Colors.blue, 'Riwayat Pembayaran', 'Lihat kwitansi digital sebelumnya', () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              }),
              _buildSubmenuItem(Icons.account_balance_wallet, Colors.green, 'Tabungan Siswa', 'Pantau saldo tabungan/celengan anak', () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuJadwal() {
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
              const Text('3. Menu Jadwal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSubmenuItem(Icons.calendar_today, Colors.orange, 'Jadwal Pelajaran', 'Cek jadwal harian per semester', () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              }),
              _buildSubmenuItem(Icons.assignment_ind, Colors.red, 'Jadwal Ujian', 'Cek jadwal PTS/PAS/UAS', () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              }),
            ],
          ),
        );
      },
    );
  }


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
              const Text('4. Materi & Tugas Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSubmenuItem(Icons.menu_book, Colors.purple, 'Materi Pelajaran', 'Baca materi hari ini', () {
                Navigator.pop(context);
                _showComingSoon('Materi Pelajaran');
              }),
              _buildSubmenuItem(Icons.edit_document, Colors.red, 'Tugas Baru', 'Tugas yang harus dikerjakan', () {
                Navigator.pop(context);
                _showComingSoon('Tugas & PR');
              }),
              _buildSubmenuItem(Icons.check_circle, Colors.green, 'Status Pengumpulan', 'Cek tugas yang sudah dikumpul', () {
                Navigator.pop(context);
                _showComingSoon('Status Tugas');
              }),
            ],
          ),
        );
      },
    );
  }


  void _showSubmenuBimbel() {
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
              const Text('5. Bimbingan Belajar (Bimbel)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSubmenuItem(Icons.star, Colors.teal, 'Program Terdaftar', 'Cek program bimbel anak', () {
                Navigator.pop(context);
                if (_profile != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ParentBimbelProgramScreen(studentId: _profile!.childId)));
                }
              }),
              _buildSubmenuItem(Icons.schedule, Colors.blue, 'Jadwal Bimbel', 'Lihat agenda bimbel mingguan', () {
                Navigator.pop(context);
                _showComingSoon('Jadwal Bimbel');
              }),
              _buildSubmenuItem(Icons.score, Colors.orange, 'Nilai Bimbel', 'Rekap skor Try Out & Latihan', () {
                Navigator.pop(context);
                _showComingSoon('Program Bimbel');
              }),
              _buildSubmenuItem(Icons.how_to_reg, Colors.green, 'Absensi Bimbel', 'Cek kehadiran anak di bimbel', () {
                Navigator.pop(context);
                _showComingSoon('Absensi Bimbel');
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmenuItem(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
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
            child: Icon(icon, color: color, size: 32), // Increased icon size
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

  // ==========================================
  // TAB 2: JADWAL PELAJARAN / UJIAN ANAK
  // ==========================================
  Widget _buildJadwalTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 24, top: 24, bottom: 8),
            child: Text('Agenda Belajar & Ujian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          ),
          TabBar(
            labelColor: Colors.deepOrange.shade700,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepOrange.shade700,
            tabs: const [
              Tab(text: 'Pelajaran Harian'),
              Tab(text: 'Jadwal Ujian'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const ParentJadwalWidget(),
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_examSchedules.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(child: Column(children: [
                          Icon(Icons.event_available_outlined, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Belum ada jadwal ujian mendatang',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ])),
                      )
                    else
                      ..._examSchedules.map((s) {
                        final date = s['exam_date']?.toString() ?? '';
                        final start = (s['start_time'] ?? '00:00').toString().substring(0, 5);
                        final end = (s['end_time'] ?? '00:00').toString().substring(0, 5);
                        return _buildExamTimelineItem(date, '\$start – \$end',
                            s['subject_name'] ?? 'Mata Ujian', s['room'] ?? '-');
                      }).toList(),
                  ],
                ),
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
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
          Container(height: 30, width: 2, color: Colors.deepOrange.shade200, margin: const EdgeInsets.symmetric(horizontal: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(room, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.info_outline, size: 18, color: Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String subject, String teacher, bool isNow) {
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
          Text(time.split(' - ')[0], style: TextStyle(fontWeight: FontWeight.bold, color: isNow ? Colors.blue.shade700 : Colors.black87)),
          Container(height: 30, width: 2, color: isNow ? Colors.blue : Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(teacher, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: KEUANGAN 
  // ==========================================
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _pendingBillsCount > 0 ? Colors.red.shade200 : Colors.green.shade200)),
            leading: CircleAvatar(backgroundColor: _pendingBillsCount > 0 ? Colors.red.shade50 : Colors.green.shade50, child: Icon(Icons.receipt_long, color: _pendingBillsCount > 0 ? Colors.red.shade700 : Colors.green.shade700)),
            title: const Text('Status Tagihan Bulanan (SPP)'),
            subtitle: Text(_pendingBillsCount > 0 ? 'Anda memiliki $_pendingBillsCount tagihan belum lunas.' : 'Seluruh tagihan sudah lunas. Terima kasih.', style: TextStyle(color: _pendingBillsCount > 0 ? Colors.red.shade700 : Colors.green.shade700)),
            trailing: _pendingBillsCount > 0 ? ElevatedButton(
              onPressed: () { _showComingSoon('Pembayaran Virtual Account'); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              child: const Text('Bayar'),
            ) : const Icon(Icons.check_circle, color: Colors.green),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
            leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(Icons.account_balance_wallet, color: Colors.green.shade700)),
            title: Text('Tabungan Siswa (${_profile?.childName ?? 'Anak'})'),
            subtitle: const Text('Saldo Total Saat Ini'),
            trailing: Text('Rp ${_savingsBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
            onTap: () { setState(() => _currentIndex = 2); },
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(Icons.history, color: Colors.grey.shade700)),
            title: const Text('Riwayat History Pembayaran'),
            onTap: () { setState(() => _currentIndex = 2); },
          ),
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
          const Text('Pengaturan Akun Wali Murid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 32),
          
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepOrange.shade100, width: 3),
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.deepOrange.shade700, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_profile?.parentName ?? 'Orang Tua', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Wali Murid: ${_profile?.childName ?? '...'}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text('Kelas: ${_profile?.childClass ?? '...'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          Text('Wali Kelas: ${_profile?.waliKelasName ?? '...'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),

          const SizedBox(height: 32),

          _buildBioField('Nomor HP Utama (Terhubung WA/Tagihan)', '0821-2233-4455'),
          _buildBioField('Alamat Email', 'haryanto1980@gmail.com'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go(AppRoutes.login),
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
        content: Text('Fitur $fitur sedang dalam pengembangan dan akan segera tersedia.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B3674),
              foregroundColor: Colors.white,
            ),
            child: const Text('Oke'),
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
}
