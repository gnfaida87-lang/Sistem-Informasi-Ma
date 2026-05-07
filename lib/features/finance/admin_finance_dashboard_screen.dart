import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/auth_provider.dart';
import 'finance_spp_payment.dart';
import 'finance_other_fees.dart';
import 'finance_operational_expenses.dart';
import 'finance_reports.dart';
import 'presentation/finance_student_savings.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';
import '../../shared/widgets/profile_settings_screen.dart';

class AdminFinanceDashboardScreen extends ConsumerStatefulWidget {
  const AdminFinanceDashboardScreen({super.key});

  @override
  ConsumerState<AdminFinanceDashboardScreen> createState() => _AdminFinanceDashboardScreenState();
}

class _AdminFinanceDashboardScreenState extends ConsumerState<AdminFinanceDashboardScreen> with SafeAsync {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
    });
  }

  Future<void> _fetchDashboardData() async {
    await safeCall(
      context: context,
      action: () async {
        final user = ref.read(authProvider).user;
        if (user != null) {
          final data = await _financeService.fetchFinanceReport();
          setState(() => _report = data);
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
                      setState(() => _selectedIndex = index);
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
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Admin Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B3674))),
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
      case 1: return const FinanceSppPayment();
      case 2: return const FinanceOtherFees();
      case 3: return const FinanceStudentSavings();
      case 4: return const FinanceOperationalExpenses();
      case 5: return const FinanceReports();
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
            'Posisi Keuangan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),
          if (_report != null)
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(Colors.blue, 'Rp ${_report!.netIncome.toStringAsFixed(0)}', 'Saldo Kas', Icons.account_balance),
                _buildStatCard(Colors.green, 'Rp ${_report!.totalSpp.toStringAsFixed(0)}', 'Pemasukan SPP', Icons.arrow_downward),
                _buildStatCard(Colors.red, 'Rp ${_report!.totalOperationalExpenses.toStringAsFixed(0)}', 'Pengeluaran', Icons.arrow_upward),
                _buildStatCard(Colors.orange, 'Rp ${_report!.totalOtherFees.toStringAsFixed(0)}', 'Lainnya', Icons.payments_outlined),
              ],
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Text('Ringkasan keuangan akan tampil di sini berdasarkan data transaksi D1 terbaru.'),
          ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
