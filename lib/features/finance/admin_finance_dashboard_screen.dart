import 'package:flutter/material.dart';
import '../auth/presentation/login_screen.dart';
import '../../shared/widgets/profile_settings_screen.dart';
import 'finance_spp_payment.dart';
import 'finance_other_fees.dart';
import 'finance_operational_expenses.dart';
import 'finance_reports.dart';

class AdminFinanceDashboardScreen extends StatefulWidget {
  const AdminFinanceDashboardScreen({super.key});

  @override
  State<AdminFinanceDashboardScreen> createState() => _AdminFinanceDashboardScreenState();
}

class _AdminFinanceDashboardScreenState extends State<AdminFinanceDashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard Keuangan', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Pembayaran SPP', 'icon': Icons.receipt_long_outlined},
    {'title': 'Biaya Lainnya', 'icon': Icons.payments_outlined},
    {'title': 'Pengeluaran Operasional', 'icon': Icons.money_off_csred_outlined},
    {'title': 'Laporan & Rekap', 'icon': Icons.analytics_outlined},
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
          const SizedBox(width: 16),
          // Search Box - Shortcut Pencarian NISN untuk Tagihan
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari NISN (Cek Tagihan / Bayar Cepat)',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Admin Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2B3674))),
              Text('Loket & Bendahara', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
              } else if (value == 'logout') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
        return const FinanceOperationalExpenses();
      case 4:
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
          const Text(
            'Posisi Keuangan & Arus Kas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),

          // STATISTIK KARTU
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
                  _buildStatCard(Colors.blueAccent, 'Rp 14.5M', 'Total Kas Internal Sekolah', Icons.account_balance),
                  _buildStatCard(Colors.green, 'Rp 1.2M', 'Pemasukan Hari Ini', Icons.arrow_downward), // Inflow
                  _buildStatCard(Colors.redAccent, 'Rp 450Jt', 'Pengeluaran Hari Ini', Icons.arrow_upward), // Outflow
                  _buildStatCard(Colors.orange, '35', 'Siswa Belum Lunas SPP', Icons.warning_amber_rounded),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // PANEL ARUS KAS & TRANSAKSI TERAKHIR
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isDesktop ? 5 : 1,
                    child: _buildTransactionList(),
                  ),
                  if (isDesktop) const SizedBox(width: 24),
                  if (isDesktop)
                    Expanded(
                      flex: 4,
                      child: _buildCollectionProgress(),
                    ),
                ],
              );
            },
          ),
          
          if (!MediaQuery.of(context).size.width.isFinite || MediaQuery.of(context).size.width <= 800) ...[
            const SizedBox(height: 24),
            _buildCollectionProgress(),
          ],
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

  Widget _buildTransactionList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Log Transaksi Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
              TextButton(onPressed: () {}, child: const Text('Ke Jurnal Lengkap')),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
              columns: const [
                DataColumn(label: Text('Waktu', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Siswa/Keterangan', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Jenis', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Nominal', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                _buildDataRow('10:45', 'Ahmad Rizal (XII IPA 1)', 'SPP April', 'Rp 250.000', Colors.green),
                _buildDataRow('09:15', 'Nadia Safira (X IPS 2)', 'Daftar Ulang', 'Rp 1.500.000', Colors.green),
                _buildDataRow('08:30', 'Bayar Listrik Sekolah', 'Pengeluaran', 'Rp 4.000.000', Colors.red),
                _buildDataRow('07:50', 'Bagas Pramoedya (-)', 'Buku Paket', 'Rp 450.000', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String waktu, String keterangan, String jenis, String nominal, Color nominalColor) {
    return DataRow(
      cells: [
        DataCell(Text(waktu, style: TextStyle(color: Colors.grey.shade500))),
        DataCell(Text(keterangan, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
            child: Text(jenis, style: TextStyle(color: Colors.grey.shade800, fontSize: 11)),
          ),
        ),
        DataCell(Text(
          nominalColor == Colors.red ? '- $nominal' : '+ $nominal', 
          style: TextStyle(color: nominalColor, fontWeight: FontWeight.bold)
        )),
      ],
    );
  }

  Widget _buildCollectionProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kolektibilitas SPP (Bulan Berjalan)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 24),
          _buildProgressItem('Kelas X', 0.85, Colors.blue),
          const SizedBox(height: 16),
          _buildProgressItem('Kelas XI', 0.95, Colors.green),
          const SizedBox(height: 16),
          _buildProgressItem('Kelas XII', 0.70, Colors.orange),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send),
            label: const Text('Peringatkan Penunggak via WA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }
}
