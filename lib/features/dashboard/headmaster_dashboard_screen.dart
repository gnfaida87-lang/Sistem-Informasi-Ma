import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/network/d1_service.dart';
import '../../core/providers/auth_provider.dart';
import 'headmaster_academic_report.dart';
import 'headmaster_finance_report.dart';
import 'headmaster_announcement.dart';
import '../../shared/widgets/profile_settings_screen.dart';

class HeadmasterDashboardScreen extends ConsumerStatefulWidget {
  const HeadmasterDashboardScreen({super.key});

  @override
  ConsumerState<HeadmasterDashboardScreen> createState() => _HeadmasterDashboardScreenState();
}

class _HeadmasterDashboardScreenState extends ConsumerState<HeadmasterDashboardScreen> {
  final _d1Service = D1Service();
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  int _totalSiswa = 0;
  int _totalGuru = 0;
  double _avgAttendance = 0.0; 
  String _totalFinance = "Rp 0";

  @override
  void initState() {
    super.initState();
    _fetchExecutiveSummary();
  }

  Future<void> _fetchExecutiveSummary() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      
      if (user != null) {
        final siswaData = await _d1Service.query("SELECT COUNT(*) as count FROM students");
        final guruData = await _d1Service.query("SELECT COUNT(*) as count FROM teachers");
        
        if (mounted) {
          setState(() {
            _totalSiswa = (siswaData as List).first['count'] ?? 0;
            _totalGuru = (guruData as List).first['count'] ?? 0;
            _totalFinance = "Rp 0";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard Utama', 'icon': Icons.dashboard_outlined},
    {'title': 'Laporan Akademik', 'icon': Icons.school_outlined},
    {'title': 'Laporan Keuangan', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pengumuman', 'icon': Icons.campaign_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isDesktop),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                    child: Container(
                      color: const Color(0xFFF4F7FE),
                      child: _getCurrentScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop ? Drawer(child: _buildSidebar()) : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 70,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B3674),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SI Madrasah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3674),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      if (MediaQuery.of(context).size.width <= 800) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF4F7FE) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            _menuItems[index]['icon'],
                            color: isSelected ? const Color(0xFF2B3674) : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _menuItems[index]['title'],
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF2B3674) : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.grey),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Kepala Madrasah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B3674))),
              Text('SI Madrasah', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0: return _buildMainContent();
      case 1: return const HeadmasterAcademicReport();
      case 2: return const HeadmasterFinanceReport();
      case 3: return const HeadmasterAnnouncement();
      default: return _buildMainContent();
    }
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Eksekutif',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(Colors.blue, _totalSiswa.toString(), 'Siswa Aktif', Icons.people_alt),
                _buildStatCard(Colors.green, '$_avgAttendance%', 'Kehadiran', Icons.how_to_reg),
                _buildStatCard(Colors.orange, '0%', 'Ketuntasan', Icons.fact_check),
                _buildStatCard(Colors.purple, _totalFinance, 'Pemasukan', Icons.payments),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Text('Monitoring data madrasah secara real-time dari Cloudflare D1.'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(Color color, String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}
