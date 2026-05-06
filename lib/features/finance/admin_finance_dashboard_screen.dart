import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/router/app_router.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../auth/presentation/login_screen.dart';
import '../../shared/widgets/profile_settings_screen.dart';
import 'finance_spp_payment.dart';
import 'finance_other_fees.dart';
import 'finance_operational_expenses.dart';
import 'finance_reports.dart';
import 'presentation/finance_student_savings.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';

class AdminFinanceDashboardScreen extends StatefulWidget {
  const AdminFinanceDashboardScreen({super.key});

  @override
  State<AdminFinanceDashboardScreen> createState() => _AdminFinanceDashboardScreenState();
}

class _AdminFinanceDashboardScreenState extends State<AdminFinanceDashboardScreen> with SafeAsync {
  int _selectedIndex = 0;
  final _financeService = FinanceService();
  FinanceReport? _report;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard Keuangan', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pembayaran SPP', 'icon': Icons.receipt_long_outlined},
    {'title': 'Pemasukan/Biaya Lainnya', 'icon': Icons.payments_outlined},
    {'title': 'Tabungan Siswa', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pengeluaran Operasional', 'icon': Icons.money_off_csred_outlined},
    {'title': 'Laporan & Rekap', 'icon': Icons.analytics_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    await safeCall(
      context: context,
      action: () async {
        final user = Supabase.instance.client.auth.currentUser;
        
        if (user != null) {
          // ── JALUR RIIL (SUPABASE) ────────────────────────
          final data = await _financeService.fetchFinanceReport();
          setState(() => _report = data);
        } else {
          // ── JALUR DEMO (SIMULASI DATA) ───────────────────
          await Future.delayed(const Duration(milliseconds: 600));
          setState(() {
            _report = FinanceReport(
              totalSppIn: 450000000,
              totalOtherFees: 15000000,
              totalExpenses: 120000000,
              totalSavings: 250000000,
              month: 'April',
              year: '2026',
            );
          });
        }
      },
    );
  }

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
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.monetization_on, color: Colors.white, size: 20),
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
                      setState(() {
                        _selectedIndex = index;
                      });
                      if (MediaQuery.of(context).size.width <= 800) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.shade50 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            _menuItems[index]['icon'],
                            color: isSelected ? Colors.green.shade700 : Colors.grey.shade500,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _menuItems[index]['title'],
                              style: TextStyle(
                                color: isSelected ? Colors.green.shade800 : Colors.grey.shade600,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          if (isDesktop)
            IconButton(
              icon: const Icon(Icons.menu_open, color: Colors.grey),
              onPressed: () {},
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.green.shade700),
            tooltip: 'Sinkronkan Data',
            onPressed: isLoading ? null : _fetchDashboardData,
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Admin Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B3674))),
              Text('Loket & Bendahara', style: TextStyle(color: Colors.grey.shade50, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
              } else if (value == 'logout') {
                context.go(AppRoutes.login);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings, size: 20),
                  title: Text('Pengaturan Profil', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, size: 20, color: Colors.red),
                  title: Text('Keluar (Logout)', style: TextStyle(fontSize: 14, color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
            child: const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 18,
              child: Icon(Icons.account_balance, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildMainContent();
      case 1:
        return const FinanceSppPayment();
      case 2:
        return const FinanceOtherFees();
      case 3:
        return const FinanceStudentSavings();
      case 4:
        return const FinanceOperationalExpenses();
      case 5:
        return const FinanceReports();
      default:
        return _buildMainContent();
    }
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Posisi Keuangan & Arus Kas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              if (isLoading)
                const CircularProgressIndicator(),
            ],
          ),
          const SizedBox(height: 24),

          if (_report != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                return GridView.count(
                  crossAxisCount: isDesktop ? 4 : (constraints.maxWidth > 500 ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 2.0 : 2.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(Colors.blueAccent, 'Rp ${_report!.netIncome.toStringAsFixed(0)}', 'Total Saldo Kas', Icons.account_balance),
                    _buildStatCard(Colors.green, 'Rp ${_report!.totalSpp.toStringAsFixed(0)}', 'Total Pemasukan SPP', Icons.arrow_downward),
                    _buildStatCard(Colors.redAccent, 'Rp ${_report!.totalOperationalExpenses.toStringAsFixed(0)}', 'Total Pengeluaran', Icons.arrow_upward),
                    _buildStatCard(Colors.orange, 'Rp ${_report!.totalOtherFees.toStringAsFixed(0)}', 'Tagihan Lainnya', Icons.payments_outlined),
                  ],
                );
              },
            ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Keuangan Sekolah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Gunakan menu di samping untuk melihat rincian pembayaran SPP, tagihan lainnya, dan laporan lengkap.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Color color, String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

