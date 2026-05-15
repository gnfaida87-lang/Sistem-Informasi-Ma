import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/system_provider.dart';

class SystemDashboardScreen extends ConsumerWidget {
  const SystemDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    // Karena dipanggil dari Shell, kita tidak perlu Scaffold AppBar lagi
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BREADCRUMB
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Home / Analytic',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text('February 1, 2026 - February 28, 2026', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // GRID AREA DEPAN
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CHART AREA (KIRI)
                  Expanded(
                    flex: isDesktop ? 6 : 1,
                    child: _buildActivityStatisticsChart(),
                  ),
                  if (isDesktop) const SizedBox(width: 24),
                  // CARD AREA (KANAN SEPERTI GAMBAR)
                  if (isDesktop)
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          statsAsync.when(
                            data: (stats) => Row(
                              children: [
                                Expanded(child: _buildStatCard(Colors.pinkAccent, stats.totalStudents.toString(), 'Siswa Terdaftar', Icons.school)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStatCard(Colors.lightBlueAccent, stats.totalTeachers.toString(), 'Guru Aktif', Icons.person)),
                              ],
                            ),
                            loading: () => const Center(child: LinearProgressIndicator()),
                            error: (e, _) => Text('Error: $e'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                               Expanded(child: _buildStatCard(Colors.purpleAccent, 'Rp 0', 'Pemasukan (Bulan)', Icons.attach_money)),
                               const SizedBox(width: 16),
                               Expanded(child: _buildStatCard(Colors.white, '99.9%', 'Server Uptime', Icons.dns, isLight: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // "Update Sistem" Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Update Sistem Terkini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Versi 2.0 membawa fitur AI Sahabat Belajar untuk mempermudah analitik Madrasah.',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                const SizedBox(height: 12),
                                Text('Baca Lebih Lanjut →', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // BOTTOM SECTION SECARA ROW
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  // NEW USERS LIST
                  SizedBox(
                    width: isDesktop ? (constraints.maxWidth / 3) - 16 : constraints.maxWidth,
                    child: _buildNewUsersList(),
                  ),
                  // DONUT CHART
                  SizedBox(
                    width: isDesktop ? (constraints.maxWidth / 3) - 16 : constraints.maxWidth,
                    child: _buildSalesDonut(),
                  ),
                  // SALES DETAILS
                  SizedBox(
                    width: isDesktop ? (constraints.maxWidth / 3) - 16 : constraints.maxWidth,
                    child: _buildSalesDetails(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24), // jarak bawah
        ],
      ),
    );
  }

  // MOCKUP BENTUK GRAFIK (Karena tidak menggunakan package chart eksternal)
  Widget _buildActivityStatisticsChart() {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Statistik Aktivitas Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('Show By Month', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          // Mockup Visual Grafik (Bar & Line)
          Expanded(
            child: Stack(
              children: [
                // Garis Horizontal background
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) => const Divider(color: Colors.black12)),
                ),
                // Mockup Batang (Bar)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMockBar(80),
                    _buildMockBar(40),
                    _buildMockBar(70),
                    _buildMockBar(90),
                    _buildMockBar(50),
                    _buildMockBar(110),
                    _buildMockBar(70),
                  ],
                ),
                // Garis Bergelombang Mockup
                Center(child: Text('[ Grafik Dinamis FlChart akan di-render di sini ]', style: TextStyle(color: Colors.purple.withOpacity(0.3)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockBar(double height) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: Colors.purple.shade300,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }

  Widget _buildStatCard(Color color, String value, String title, IconData icon, {bool isLight = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLight ? [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: isLight ? Colors.purple : Colors.white70, size: 24),
              Icon(Icons.more_horiz, color: isLight ? Colors.grey : Colors.white70),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isLight ? Colors.black87 : Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: isLight ? Colors.grey : Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildNewUsersList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Baru Didaftarkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Belum ada user baru', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSalesDonut() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Persentase Kehadiran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120, height: 120,
                   child: CircularProgressIndicator(value: 0, strokeWidth: 12, backgroundColor: Colors.grey.shade100, color: Colors.purpleAccent),
                ),
                const Column(
                  children: [
                    Text('0%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Semester Ini', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          const Spacer(),
          const Text('• Kelas X: 80% \n• Kelas XI: 70%', style: TextStyle(height: 1.5, color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSalesDetails() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kapasitas Server Terdampak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _detailData(Icons.storage, '48 GB', 'Storage')),
              const SizedBox(width: 12),
              Expanded(child: _detailData(Icons.network_check, '95%', 'Uptime')),
            ],
          ),
          const Spacer(),
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.white],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('--- Wave Chart ---', style: TextStyle(color: Colors.purple.shade300))),
          )
        ],
      ),
    );
  }

  Widget _detailData(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: Colors.purpleAccent),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
