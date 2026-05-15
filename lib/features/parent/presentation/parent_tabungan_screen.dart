import 'package:flutter/material.dart';
import '../services/parent_service.dart';
import 'package:intl/intl.dart';

class ParentTabunganScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ParentTabunganScreen({super.key, required this.studentId, required this.studentName});

  @override
  State<ParentTabunganScreen> createState() => _ParentTabunganScreenState();
}

class _ParentTabunganScreenState extends State<ParentTabunganScreen> {
  final _service = ParentService();
  bool _isLoading = true;
  double _totalSavings = 0.0;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Kita tambahkan fetchHistory nanti di ParentService
      final results = await Future.wait([
        _service.getStudentSavings(widget.studentId),
        _fetchHistoryFromD1(widget.studentId), // Temporary local fetch until Service updated
      ]);
      
      setState(() {
        _totalSavings = results[0] as double;
        _history = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper fetch sementara sebelum ParentService diupdate permanen
  Future<List<Map<String, dynamic>>> _fetchHistoryFromD1(String studentId) async {
    final results = await _service.getStudentSavingsHistory(studentId);
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabungan Siswa'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2B3674),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 32),
                  const Text('Riwayat Transaksi', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                  const SizedBox(height: 16),
                  _buildHistoryList(),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.blue.shade500],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Saldo Tabungan', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('SI MADRASAH PAY', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withOpacity(0.5), size: 40),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(_totalSavings)}',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 14),
                const SizedBox(width: 8),
                Text('Siswa: ${widget.studentName}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Belum ada transaksi tabungan.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final bool isDeposit = item['jenis'] == 'setor';
        final Color accentColor = isDeposit ? Colors.green : Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDeposit ? Icons.south_west_rounded : Icons.north_east_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDeposit ? 'Setoran Tabungan' : 'Penarikan Tabungan',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(item['tanggal'])),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Text(
                '${isDeposit ? "+" : "-"} Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item['jumlah'])}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: accentColor),
              ),
            ],
          ),
        );
      },
    );
  }
}
