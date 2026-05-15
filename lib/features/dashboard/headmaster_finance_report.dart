import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/network/d1_service.dart';

class HeadmasterFinanceReport extends StatefulWidget {
  const HeadmasterFinanceReport({super.key});

  @override
  State<HeadmasterFinanceReport> createState() => _HeadmasterFinanceReportState();
}

class _HeadmasterFinanceReportState extends State<HeadmasterFinanceReport> {
  final _d1Service = D1Service();
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  double _totalIncomeMonth = 0;

  @override
  void initState() {
    super.initState();
    _fetchFinanceData();
  }

  Future<void> _fetchFinanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Ambil transaksi terbaru
      final txData = await _d1Service.query(
        """
        SELECT p.*, s.nama as siswa_nama
        FROM pembayaran_spp p
        LEFT JOIN siswa s ON p.student_id = s.id
        ORDER BY p.paid_at DESC
        LIMIT 10
        """
      );
      
      // 2. Ambil total bulan ini
      final now = DateTime.now();
      final monthStr = now.month.toString().padLeft(2, '0');
      final yearStr = now.year.toString();
      final summaryRes = await _d1Service.query(
        "SELECT SUM(amount) as total FROM pembayaran_spp WHERE paid_at LIKE ?",
        params: ["$yearStr-$monthStr%"]
      );
      
      setState(() {
        _recentTransactions = List<Map<String, dynamic>>.from(txData as List);
        _totalIncomeMonth = (summaryRes as List).isNotEmpty ? (summaryRes.first['total'] ?? 0).toDouble() : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data keuangan dari D1.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: _fetchFinanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Laporan Keuangan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
            ),
            const SizedBox(height: 24),
            
            // SUMMARY CARDS
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Penerimaan Bulan Ini', 
                    currencyFormat.format(_totalIncomeMonth), 
                    Icons.payments, 
                    Colors.green
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Target Bulanan', 
                    '-', 
                    Icons.ads_click, 
                    Colors.blue
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaksi Terbaru (SPP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!))
          else if (_recentTransactions.isEmpty)
            const Center(child: Text('Belum ada transaksi.'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final tx = _recentTransactions[index];
                final amount = tx['amount'] ?? 0;
                final student = tx['siswa_nama'] ?? 'Siswa';
                final month = tx['month'] ?? '-';
                
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.arrow_downward, color: Colors.green)),
                  title: Text("SPP Bulan $month"),
                  subtitle: Text('Siswa: $student'),
                  trailing: Text(
                    currencyFormat.format(amount), 
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
        ],
      ),
    );
  }
}
