import 'package:flutter/material.dart';
import '../../core/network/supabase_service.dart';
import 'package:intl/intl.dart';

class HeadmasterFinanceReport extends StatefulWidget {
  const HeadmasterFinanceReport({super.key});

  @override
  State<HeadmasterFinanceReport> createState() => _HeadmasterFinanceReportState();
}

class _HeadmasterFinanceReportState extends State<HeadmasterFinanceReport> {
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      final response = await SupabaseService().client
          .from('pembayaran')
          .select('*, jenis_pembayaran(nama), siswa(nama)')
          .order('tanggal_bayar', ascending: false)
          .limit(10);
      
      final List<dynamic> data = response;
      setState(() {
        _recentTransactions = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data keuangan. Pastikan tabel 'pembayaran' sudah disetup.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchFinanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Laporan Keuangan Eksekutif',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3674),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchFinanceData,
                  tooltip: 'Refresh Laporan',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isDesktop ? 6 : 1,
                      child: _buildTransactionList(),
                    ),
                    if (isDesktop) const SizedBox(width: 24),
                    if (isDesktop)
                      Expanded(
                        flex: 4,
                        child: _buildArrearsSummary(),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aliran Kas Masuk Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          _isLoading
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _recentTransactions.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada transaksi terekam.')))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentTransactions.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final tx = _recentTransactions[index];
                      final amount = tx['jumlah'] ?? 0;
                      final type = (tx['jenis_pembayaran'] != null) ? (tx['jenis_pembayaran']['nama'] ?? 'Pembayaran') : 'Pembayaran';
                      final student = (tx['siswa'] != null) ? (tx['siswa']['nama'] ?? 'Siswa') : 'Siswa';
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green,
                          child: const Icon(Icons.arrow_downward, size: 20),
                        ),
                        title: Text(type.toString()),
                        subtitle: Text('Oleh: ${student.toString()}'),
                        trailing: Text(
                          '+ ${currencyFormat.format(amount)}', 
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildArrearsSummary() {
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
          const Text('Top Tunggakan Kelas (Watchlist)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          const SizedBox(height: 16),
          const Center(child: Text('Data tunggakan akan muncul setelah sistem tagihan diaktifkan.', style: TextStyle(fontSize: 12, color: Colors.grey))),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text('Monitoring tunggakan memerlukan sinkronisasi Data Tagihan dari Admin Keuangan.', style: TextStyle(fontSize: 12, color: Colors.orange))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
