import 'package:flutter/material.dart';
import '../auth/presentation/login_screen.dart';
import 'parent_submenus_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
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
                    const Text('Bpk. Haryanto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text('Orang Tua: Ahmad Rizal (X IPA 1)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                    ),
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
                            child: const Text('HADIR', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          ),
                          const SizedBox(width: 8),
                          const Text('06:45 WIB', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Anak Anda telah tiba di Madrasah.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11)),
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

          // GRID MENU UTAMA ORANG TUA
          const Text('Pantau Akademik Anak', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuIcon(context, 'Akademik\n& Nilai', Icons.history_edu, Colors.blue, _showSubmenuAkademik),
              _buildMenuIcon(context, 'Materi\n& Tugas', Icons.menu_book, Colors.purple, _showSubmenuMateri),
              _buildMenuIcon(context, 'Ekstra\nBimbel', Icons.groups, Colors.teal, _showSubmenuBimbel),
              _buildMenuIcon(context, 'Al-Qur\'an\nDigital', Icons.menu_book_outlined, Colors.green, () { _showToast('Membuka Qur\'an Digital...'); }),
              _buildMenuIcon(context, 'AI Sahabat\nBelajar', Icons.auto_awesome, Colors.indigo, () { _showToast('Membuka Chatbot Sahabat Belajar...'); }),
              _buildMenuIcon(context, 'Pengumuman\nSekolah', Icons.campaign, Colors.red, () { _showToast('Membuka Papan Pengumuman...'); }),
            ],
          ),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Akademik & Nilai Anak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.assignment, color: Colors.blue.shade700)),
                title: const Text('Lihat Nilai Tugas & Ujian'),
                subtitle: const Text('Update nilai formatif & sumatif per mata pelajaran'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentAkademikNilaiScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.school, color: Colors.green.shade700)),
                title: const Text('E-Rapor Digital / Semester'),
                subtitle: const Text('Cetak dan Lihat hasil belajar akhir semester'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentAkademikRaporScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.history, color: Colors.orange.shade700)),
                title: const Text('Rekap Kehadiran / Absensi'),
                subtitle: const Text('Buku statistik presensi anak Anda'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentAkademikAbsensiScreen()));
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Materi & Tugas Harian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.menu_book, color: Colors.purple.shade700)),
                title: const Text('Materi Pelajaran'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentMateriTugasScreen(isTugas: false)));
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.edit_document, color: Colors.red.shade700)),
                title: const Text('Tugas yang Belum Dikerjakan'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentMateriTugasScreen(isTugas: true)));
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.check_circle, color: Colors.green.shade700)),
                title: const Text('Status Pengumpulan Tugas'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentStatusTugasScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubmenuBimbel() {
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
              const Text('Bimbingan Belajar Eksternal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.star, color: Colors.teal.shade700)),
                title: const Text('Bimbel Terdaftar'),
                subtitle: const Text('Persiapan UTBK & Olimpiade'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentBimbelProgramScreen()));
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.score, color: Colors.orange.shade700)),
                title: const Text('Rekap Try Out / Nilai Bimbel'),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentBimbelNilaiScreen()));
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color.shade700, size: 24),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87)),
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
            child: Text('Jadwal Ahmad Rizal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          ),
          TabBar(
            labelColor: Colors.deepOrange.shade700,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepOrange.shade700,
            tabs: const [
              Tab(text: 'Pelajaran (Ganjil)'),
              Tab(text: 'Jadwal Ujian'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildTimelineItem('07:30 - 09:00', 'Matematika', 'Bpk. Ahmad Fauzi', true),
                    _buildTimelineItem('09:00 - 10:30', 'Fisika', 'Ibu Ratna', false),
                    _buildTimelineItem('10:45 - 12:15', 'Bahasa Inggris', 'Mr. John', false),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildTimelineItem('Senin, 15 Mar', 'Ujian Tengah Semester', 'Matematika & Fisika', false),
                    _buildTimelineItem('Selasa, 16 Mar', 'Ujian Tengah Semester', 'B. Inggris & Sejarah', false),
                  ],
                ),
              ],
            ),
          ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade200)),
            leading: CircleAvatar(backgroundColor: Colors.red.shade50, child: Icon(Icons.receipt_long, color: Colors.red.shade700)),
            title: const Text('Status Tagihan Bulanan (SPP)'),
            subtitle: Text('Anda menunggak 2 bulan.', style: TextStyle(color: Colors.red.shade700)),
            trailing: ElevatedButton(
              onPressed: () { _showToast('Membuka Virtual Account Transfer...'); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              child: const Text('Bayar'),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
            leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(Icons.savings, color: Colors.green.shade700)),
            title: const Text('Tabungan Siswa (Ahmad Rizal)'),
            subtitle: const Text('Saldo Total Saat Ini'),
            trailing: const Text('Rp 1.250.000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
            onTap: () { _showToast('Membuka detail mutasi celengan...'); },
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(Icons.history, color: Colors.grey.shade700)),
            title: const Text('Riwayat History Pembayaran'),
            onTap: () { _showToast('Membuka Kwitansi Lunas...'); },
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
          const Text('Haryanto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Wali Murid: Ahmad Rizal Fachry', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 32),

          _buildBioField('Nomor HP Utama (Terhubung WA/Tagihan)', '0821-2233-4455'),
          _buildBioField('Alamat Email', 'haryanto1980@gmail.com'),
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
