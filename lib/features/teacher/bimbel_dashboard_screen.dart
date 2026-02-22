import 'package:flutter/material.dart';
import '../auth/presentation/login_screen.dart';
import 'bimbel_submenus_screen.dart';

class BimbelDashboardScreen extends StatefulWidget {
  const BimbelDashboardScreen({super.key});

  @override
  State<BimbelDashboardScreen> createState() => _BimbelDashboardScreenState();
}

class _BimbelDashboardScreenState extends State<BimbelDashboardScreen> {
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
          selectedItemColor: Colors.deepPurple.shade700,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwal Bimbel'),
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
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat Datang,', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const Text('Dr. Ilham Ramadhani', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text('Tutor Eksternal (Bimbel)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.deepPurple.shade50, shape: BoxShape.circle),
                child: Icon(Icons.notifications_none, color: Colors.deepPurple.shade700),
              )
            ],
          ),
          const SizedBox(height: 24),

          // KARTU SUMMARY HARI INI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.deepPurple.shade200, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jadwal Bimbel Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      const Text('2 Sesi Kelas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Persiapan UTBK & Olimpiade', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.groups, color: Colors.white, size: 32),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // GRID MENU UTAMA BIMBEL
          const Text('Modul Bimbingan Belajar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuIcon(context, 'Absensi\nBimbel', Icons.how_to_reg, Colors.green, _showSubmenuAbsensi),
              _buildMenuIcon(context, 'Nilai & Evaluasi', Icons.score, Colors.orange, _showSubmenuNilai),
              _buildMenuIcon(context, 'Materi &\nLatihan', Icons.menu_book, Colors.purple, _showSubmenuMateri),
            ],
          ),
        ],
      ),
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
              const Text('Menu Absensi Bimbel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.fact_check, color: Colors.green.shade700)),
                title: const Text('Input Absensi'),
                subtitle: const Text('Kehadiran Siswa Bimbel Hari Ini'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelAbsensiScreen(isRiwayat: false)));
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.history, color: Colors.blue.shade700)),
                title: const Text('Riwayat Absensi'),
                subtitle: const Text('Cek histori absen peserta bimbel'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelAbsensiScreen(isRiwayat: true)));
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
              const Text('Penilaian Bimbel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.assignment, color: Colors.orange.shade700)),
                title: const Text('Input Nilai Latihan / Try Out'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelNilaiScreen(isRekap: false)));
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.bar_chart, color: Colors.teal.shade700)),
                title: const Text('Rekap Nilai Siswa'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelNilaiScreen(isRekap: true)));
                },
              ),
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
              const Text('Materi & Latihan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.cloud_upload, color: Colors.purple.shade700),
                title: const Text('Upload Materi (Google Drive)'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelMateriScreen(title: 'Upload Materi')));
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.video_call, color: Colors.blue.shade700),
                title: const Text('Link Zoom / Meet'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelMateriScreen(title: 'Tautan Kelas Online (Zoom/Meet)')));
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.play_circle, color: Colors.red.shade700),
                title: const Text('Video Pelajaran (YouTube)'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelMateriScreen(title: 'Tautan Video YouTube')));
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.quiz, color: Colors.orange.shade700),
                title: const Text('Latihan (CBT PG/Essai)'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelMateriScreen(title: 'Latihan CBT')));
                },
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.format_list_numbered, color: Colors.green.shade700),
                title: const Text('Hasil Latihan Per Siswa'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelMateriScreen(title: 'Hasil Latihan Siswa')));
                },
              ),
              const Divider(),
              ListTile(
                visualDensity: VisualDensity.compact,
                leading: Icon(Icons.archive, color: Colors.grey.shade700),
                title: const Text('Arsip Materi (Repostable)'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BimbelMateriScreen(title: 'Arsip Materi Bimbel')));
                },
              ),
            ],
          ),
        );
      },
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
  // TAB 2: JADWAL BIMBEL
  // ==========================================
  Widget _buildJadwalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jadwal Bimbel Anda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 24),
          _buildTimelineItem('15:00 - 16:30', 'Olimpiade Fisika', 'Kelompok Prestasi', 'Laboratorium Fisika', true),
          _buildTimelineItem('16:45 - 18:15', 'Persiapan UTBK Mtk', 'Kelas Intensif XII', 'Ruang 04', false),
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
          Column(
            children: [
              Text(time.split(' - ')[0], style: TextStyle(fontWeight: FontWeight.bold, color: isNow ? Colors.deepPurple.shade700 : Colors.black87)),
              const SizedBox(height: 4),
              Text(time.split(' - ')[1], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
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

  // ==========================================
  // TAB 3: AKUN SAYA
  // ==========================================
  Widget _buildAkunTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Profil Tutor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
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
                  border: Border.all(color: Colors.deepPurple.shade100, width: 3),
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Dr. Ilham Ramadhani', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Tutor Eksternal (LBB)', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 32),

          // FORM BIODATA
          _buildBioField('Nama Lengkap', 'Dr. Ilham Ramadhani'),
          _buildBioField('Materi Pegangan', 'Persiapan UTBK & Olimpiade'),
          _buildBioField('Nomor HP / WA', '0852-1234-9090'),
          _buildBioField('Afiliasi / Universitas', 'Lembaga Bimbingan UI'),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Simpan Perubahan'),
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

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }
}
