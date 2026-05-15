import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';
import '../services/parent_service.dart';

class ParentKeuanganScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ParentKeuanganScreen({super.key, required this.studentId, required this.studentName});

  @override
  State<ParentKeuanganScreen> createState() => _ParentKeuanganScreenState();
}

class _ParentKeuanganScreenState extends State<ParentKeuanganScreen> {
  final _service = ParentService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.getStudentSavings(widget.studentId),
        _service.getStudentFinances(widget.studentId),
      ]);
      
      setState(() {
        _payments = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan Siswa'),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tagihan Lainnya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                  const SizedBox(height: 16),
                  _buildOtherFeesList(),
                  const SizedBox(height: 32),
                  const Text('Riwayat Pembayaran SPP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                  const SizedBox(height: 16),
                  _buildPaymentList(),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildOtherFeesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _service.getOtherFees(widget.studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final fees = snapshot.data!;
        if (fees.isEmpty) {
          return const Text('Tidak ada tagihan lainnya.', style: TextStyle(color: Colors.grey, fontSize: 13));
        }
        return Column(
          children: fees.map((f) {
            final isLunas = f['status'] == 'lunas';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isLunas ? Colors.green.shade50 : Colors.red.shade50,
                  child: Icon(isLunas ? Icons.check_circle_outline : Icons.error_outline, 
                       color: isLunas ? Colors.green : Colors.red),
                ),
                title: Text(f['name'] ?? 'Tagihan', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Tenggat: ${f['tenggat_waktu']?.toString().split("T")[0] ?? "-"}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Rp ${f['amount']}', style: TextStyle(fontWeight: FontWeight.bold, color: isLunas ? Colors.green : Colors.red)),
                    Text(isLunas ? 'Lunas' : 'Belum Bayar', 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isLunas ? Colors.green : Colors.red)),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }


  Widget _buildPaymentList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadFiscalInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final info = snapshot.data!;
        final List<String> months = info['months'];
        final Set<String> paidMonths = _payments.map((p) => p['bulan']?.toString() ?? '').toSet();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status SPP Bulanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: months.length,
              itemBuilder: (context, index) {
                final bulan = months[index];
                final isPaid = paidMonths.contains(bulan);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isPaid ? Colors.green.shade100 : Colors.red.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(bulan, style: TextStyle(fontWeight: FontWeight.bold, color: isPaid ? Colors.green.shade800 : Colors.red.shade800, fontSize: 11)),
                      Icon(isPaid ? Icons.check_circle : Icons.error_outline, 
                           color: isPaid ? Colors.green : Colors.red, size: 16),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text('Riwayat Transaksi Terakhir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
            const SizedBox(height: 16),
            if (_payments.isEmpty)
              const Text('Belum ada transaksi terekam.', style: TextStyle(color: Colors.grey, fontSize: 13))
            else
              ..._payments.take(5).map((p) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  dense: true,
                  title: Text('Pembayaran SPP ${p["bulan"]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p["tanggal_bayar"]?.toString().split("T")[0] ?? "-"),
                  trailing: Text('Rp ${p["jumlah"]}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              )).toList(),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadFiscalInfo() async {
    final d1 = D1Service();
    final res = await d1.query("SELECT academic_start_month FROM system_settings WHERE id = 1 LIMIT 1");
    int start = res.isNotEmpty ? (res.first['academic_start_month'] ?? 7) : 7;
    
    final allMonths = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    List<String> generated = [];
    for (int i = 0; i < 12; i++) {
      int index = (start - 1 + i) % 12;
      generated.add(allMonths[index]);
    }
    return {'months': generated};
  }
}
