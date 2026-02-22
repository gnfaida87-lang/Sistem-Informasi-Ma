import 'package:flutter/material.dart';
import '../auth/presentation/login_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final bool isWaliKelas;
  const TeacherDashboardScreen({super.key, this.isWaliKelas = false});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _currentIndex = 0;

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
                    const Text('Ahmad Fauzi, S.Pd', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                    if (widget.isWaliKelas) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text('Wali Kelas: X IPA 1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
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
                      const Text('4 Jam Pelajaran', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Kelas X IPA 1 & XI IPS 2', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
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
          const Text('Menu Akademik', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuIcon(context, 'Absensi\nSiswa', Icons.co_present, Colors.green, _showSubmenuAbsensi),
              _buildMenuIcon(context, 'Penilaian\nSiswa', Icons.history_edu, Colors.orange, _showSubmenuNilai),
              _buildMenuIcon(context, 'Materi & CBT', Icons.menu_book, Colors.purple, _showSubmenuMateri),
              _buildMenuIcon(context, 'Al-Qur\'an\nDigital', Icons.menu_book_outlined, Colors.teal, _showSubmenuAlQuran),
              _buildMenuIcon(context, 'AI Sahabat\nGuru', Icons.smart_toy, Colors.indigo, _showSubmenuAIGuru),
              _buildMenuIcon(context, 'Pengumuman\nKelas', Icons.campaign, Colors.red, _showSubmenuPengumuman),
              if (widget.isWaliKelas) ...[
                _buildMenuIcon(context, 'Data Siswa\n(Wali Kelas)', Icons.face_retouching_natural, Colors.blueGrey, _showSubmenuDataSiswa),
                _buildMenuIcon(context, 'Rekap Kelas\n(Wali Kelas)', Icons.pie_chart, Colors.brown, _showSubmenuRekapKelas),
              ],
            ],
          ),
        ],
      ),
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
                onTap: () { Navigator.pop(context); _showToast('Membuka Input Absensi...'); },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.history, color: Colors.blue.shade700)),
                title: const Text('Riwayat Absensi'),
                subtitle: const Text('Cek histori absen siswa'),
                onTap: () { Navigator.pop(context); _showToast('Membuka Riwayat Absensi...'); },
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
                onTap: () { Navigator.pop(context); _showToast('Membuka Input Tugas...'); },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_document, color: Colors.red.shade700)),
                title: const Text('Input Nilai PTS / PAS / UAS'),
                onTap: () { Navigator.pop(context); _showToast('Membuka Input Ujian...'); },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.bar_chart, color: Colors.teal.shade700)),
                title: const Text('Rekap Nilai'),
                onTap: () { Navigator.pop(context); _showToast('Membuka Rekap Nilai...'); },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.visibility, color: Colors.blue.shade700)),
                title: const Text('Lihat Hasil Nilai'),
                onTap: () { Navigator.pop(context); _showToast('Melihat Hasil Nilai Lengkap...'); },
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
                onTap: () { Navigator.pop(context); _showToast('Membuka Upload Materi...'); },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.video_call, color: Colors.blue.shade700),
                title: const Text('Link Zoom / Meet'),
                onTap: () { Navigator.pop(context); _showToast('Membuat Link Vicon...'); },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.quiz, color: Colors.orange.shade700),
                title: const Text('Latihan (CBT PG/Essai)'),
                onTap: () { Navigator.pop(context); _showToast('Membuat Latihan CBT...'); },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.format_list_numbered, color: Colors.green.shade700),
                title: const Text('Hasil Latihan Perkelas'),
                onTap: () { Navigator.pop(context); _showToast('Melihat Hasil CBT...'); },
              ),
              const Divider(),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.archive, color: Colors.grey.shade700),
                title: const Text('Arsip Materi'),
                onTap: () { Navigator.pop(context); _showToast('Membuka Arsip...'); },
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
                onTap: () { Navigator.pop(context); _showToast('Membuka Qur\'an...'); },
              ),
              ListTile(
                leading: Icon(Icons.headset, color: Colors.teal.shade700),
                title: const Text('Audio MP3 Murottal'),
                onTap: () { Navigator.pop(context); _showToast('Membuka Audio MP3...'); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuAIGuru() {
    _showToast('Memulai sesi Asisten AI Sahabat Guru...');
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
                onTap: () { Navigator.pop(context); _showToast('Membuka form pengumuman...'); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuDataSiswa() {
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
              const Text('Data Siswa Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.person, color: Colors.blueGrey.shade700)),
                title: const Text('Profil Siswa'),
                subtitle: const Text('Lihat data bio dan kontak siswa perwalian'),
                onTap: () { Navigator.pop(context); _showToast('Membuka Profil Siswa...'); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuRekapKelas() {
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
              const Text('Rekap Kelas Perwalian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.grading, color: Colors.brown.shade700)),
                title: const Text('Rekap Nilai Kelas'),
                subtitle: const Text('Kompilasi nilai seluruh mapel kelas Anda'),
                onTap: () { Navigator.pop(context); _showToast('Membuka Rekap Nilai...'); },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.checklist, color: Colors.teal.shade700)),
                title: const Text('Rekap Absensi Kelas'),
                subtitle: const Text('Laporan kehadiran bulanan & persentase'),
                onTap: () { Navigator.pop(context); _showToast('Membuka Rekap Absensi...'); },
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
              color: color.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color.shade700, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: JADWAL
  // ==========================================
  Widget _buildJadwalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jadwal Mengajar Anda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 24),
          _buildTimelineItem('07:30 - 09:00', 'Matematika Terapan', 'Kelas X IPA 1', 'Ruang 12', true),
          _buildTimelineItem('09:15 - 10:45', 'Pramuka (Ekskul)', 'Lapangan Utama', 'Luar Ruangan', false),
          _buildTimelineItem('11:00 - 12:30', 'Matematika Terapan', 'Kelas XI IPS 2', 'Ruang 04', false),
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
          const Text('Papan Pegumuman', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 24),
          _buildInfoCard('Rapat Pleno Kenaikan Kelas', 'Acara wajib dihadiri seluruh wali kelas', '24 Feb 2026', Icons.groups, Colors.purple),
          _buildInfoCard('Tenggat Input Nilai Rapot', 'Batas akhir pengisian E-Rapor di sistem.', '28 Feb 2026', Icons.warning_amber, Colors.red),
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
          const Text('Ahmad Fauzi, S.Pd', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('NIP. 198002012010011005', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 32),

          // FORM BIODATA
          _buildBioField('Nama Lengkap', 'Ahmad Fauzi, S.Pd'),
          _buildBioField('Mata Pelajaran', 'Matematika Terapan'),
          _buildBioField('Nomor HP / WA', '0812-3456-7890'),
          _buildBioField('Alamat Email', 'ahmad.fauzi@madrasah.sch.id'),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Simpan Perubahan Biodata'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
