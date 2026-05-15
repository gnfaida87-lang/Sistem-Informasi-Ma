import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/network/d1_service.dart';
import '../../core/providers/auth_provider.dart';
import 'headmaster_academic_report.dart';
import 'headmaster_finance_report.dart';
import 'headmaster_announcement.dart';
import '../../shared/widgets/shared_top_bar.dart';
import '../../shared/widgets/shared_sidebar.dart';

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

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard Utama', 'icon': Icons.dashboard_outlined},
    {'title': 'Laporan Akademik', 'icon': Icons.school_outlined},
    {'title': 'Laporan Keuangan', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pengumuman', 'icon': Icons.campaign_outlined},
  ];

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
        
        int totalMoney = 0;
        try {
          final now = DateTime.now();
          final monthStr = now.month.toString().padLeft(2, '0');
          final yearStr = now.year.toString();
          final financeRes = await _d1Service.query(
            "SELECT SUM(amount) as total FROM pembayaran_spp WHERE paid_at LIKE ?",
            params: ["$yearStr-$monthStr%"]
          );
          totalMoney = (financeRes as List).isNotEmpty ? (financeRes.first['total'] ?? 0) : 0;
        } catch (_) {}
        
        if (mounted) {
          setState(() {
            _totalSiswa = (siswaData as List).isNotEmpty ? (siswaData.first['count'] ?? 0) : 0;
            _totalGuru = (guruData as List).isNotEmpty ? (guruData.first['count'] ?? 0) : 0;
            _totalFinance = "Rp ${totalMoney.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Row(
        children: [
          if (isDesktop) 
            SharedSidebar(
              selectedIndex: _selectedIndex,
              menuItems: _menuItems,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
              accentColor: const Color(0xFF2B3674),
            ),
          Expanded(
            child: Column(
              children: [
                SharedTopBar(title: _menuItems[_selectedIndex]['title']),
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
      drawer: !isDesktop ? Drawer(
        child: SharedSidebar(
          selectedIndex: _selectedIndex,
          menuItems: _menuItems,
          onItemSelected: (index) => setState(() => _selectedIndex = index),
          accentColor: const Color(0xFF2B3674),
        ),
      ) : null,
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
