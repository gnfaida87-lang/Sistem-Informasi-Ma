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
import 'presentation/finance_config_screen.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';
import '../../shared/widgets/shared_top_bar.dart';
import '../../shared/widgets/shared_sidebar.dart';

class AdminFinanceDashboardScreen extends ConsumerStatefulWidget {
  const AdminFinanceDashboardScreen({super.key});

  @override
  ConsumerState<AdminFinanceDashboardScreen> createState() => _AdminFinanceDashboardScreenState();
}

class _AdminFinanceDashboardScreenState extends ConsumerState<AdminFinanceDashboardScreen> with SafeAsync {
  int _selectedIndex = 0;
  final _financeService = FinanceService();
  FinanceReport? _report;
  List<Map<String, dynamic>> _recentTransactions = [];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard Keuangan', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pembayaran dan Lainnya', 'icon': Icons.payments_outlined},
    {'title': 'Tabungan Siswa', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pengeluaran Operasional', 'icon': Icons.money_off_csred_outlined},
    {'title': 'Laporan & Rekap', 'icon': Icons.analytics_outlined},
    {'title': 'Konfigurasi Biaya', 'icon': Icons.settings_applications_outlined},
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
          final transactions = await _financeService.fetchRecentTransactions();
          setState(() {
            _report = data;
            _recentTransactions = transactions;
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
          if (isDesktop) 
            SharedSidebar(
              selectedIndex: _selectedIndex,
              menuItems: _menuItems,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
              accentColor: Colors.green.shade700,
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
          accentColor: Colors.green.shade700,
        ),
      ) : null,
    );
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0: return _buildMainContent();
      case 1: return const FinanceSppPayment(); // Akan saya update isinya
      case 2: return const FinanceStudentSavings();
      case 3: return const FinanceOperationalExpenses();
      case 4: return const FinanceReports();
      case 5: return const FinanceConfigScreen();
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
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Kiri: Tabel Transaksi
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Transaksi Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                          TextButton(
                            onPressed: () => setState(() => _selectedIndex = 4), 
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_recentTransactions.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text('Belum ada riwayat transaksi'),
                        ))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentTransactions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final tx = _recentTransactions[index];
                            final isIncome = tx['type'] == 'pemasukan';
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isIncome ? Colors.green : Colors.red,
                                  size: 18,
                                ),
                              ),
                              title: Text(tx['description'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('${tx['category']} • ${tx['date'].toString().split('T')[0]}', style: const TextStyle(fontSize: 11)),
                              trailing: Text(
                                '${isIncome ? "+" : "-"} Rp ${tx['amount'].toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Kolom Kanan: Summary/Quick Actions
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.indigo.shade500]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Analisis SPP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('75% Terbayar', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: 0.75,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text('150 dari 200 Siswa sudah lunas', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
