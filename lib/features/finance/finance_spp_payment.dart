import 'package:flutter/material.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/utils/context_extensions.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';
import '../master_data/services/master_service.dart';
import '../master_data/models/master_models.dart';
import 'finance_other_fees.dart';
import '../../core/utils/receipt_helper.dart';
import '../../core/network/d1_service.dart';

class FinanceSppPayment extends StatefulWidget {
  const FinanceSppPayment({super.key});

  @override
  State<FinanceSppPayment> createState() => _FinanceSppPaymentState();
}

class _FinanceSppPaymentState extends State<FinanceSppPayment> with SafeAsync, SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final _financeService = FinanceService();
  final _masterService = MasterService();

  Student? _foundSiswa;
  List<SppRecord> _riwayatSpp = [];
  
  List<String> _bulanAjaran = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateBulanAjaran();
  }

  void _generateBulanAjaran() async {
    final d1 = D1Service();
    final res = await d1.query("SELECT academic_start_month FROM system_settings WHERE id = 1 LIMIT 1");
    int start = res.isNotEmpty ? (res.first['academic_start_month'] ?? 7) : 7;
    
    final allMonths = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    
    List<String> generated = [];
    for (int i = 0; i < 12; i++) {
      int index = (start - 1 + i) % 12;
      generated.add(allMonths[index]);
    }
    
    if (mounted) {
      setState(() {
        _bulanAjaran.clear();
        _bulanAjaran.addAll(generated);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _searchSiswa() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.showErrorSnackBar('Masukkan NIS atau Nama Siswa terlebih dahulu.');
      return;
    }

    await safeCall(
      context: context,
      action: () async {
        final results = await _masterService.searchStudents(query);
        if (results.isEmpty) {
          _foundSiswa = null;
          _riwayatSpp = [];
          if (mounted) context.showErrorSnackBar('Siswa tidak ditemukan.');
        } else {
          _foundSiswa = results.first;
          await _fetchRiwayatSpp(_foundSiswa!.id);
        }
        setState(() {});
      },
    );
  }

  double _currentSppAmount = 250000;

  Future<void> _fetchRiwayatSpp(String studentId) async {
    final data = await _financeService.fetchSppByStudent(studentId);
    
    String? level;
    if (_foundSiswa?.classId != null) {
      level = _foundSiswa!.classId!.split('-').first;
    }
    
    final nominal = await _financeService.getSppAmount(level);
    
    setState(() {
      _riwayatSpp = data;
      _currentSppAmount = nominal;
    });
  }

  Future<void> _bayarSpp(String bulan) async {
    if (_foundSiswa == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Siswa: ${_foundSiswa!.name}'),
            Text('Bulan: $bulan'),
            Text('Nominal: Rp ${_currentSppAmount.toStringAsFixed(0)}', 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await safeCall(
      context: context,
      successMessage: 'Pembayaran SPP $bulan berhasil!',
      action: () async {
        final record = SppRecord(
          id: '', 
          studentId: _foundSiswa!.id,
          amount: _currentSppAmount,
          paidAt: DateTime.now(),
          status: 'lunas',
          month: bulan,
          year: DateTime.now().year.toString(),
        );
        await _financeService.addSppPayment(record);
        await _fetchRiwayatSpp(_foundSiswa!.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2B3674),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2B3674),
            tabs: const [
              Tab(text: 'Pembayaran SPP'),
              Tab(text: 'Tagihan Lainnya'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSppContent(),
              const FinanceOtherFees(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSppContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pembayaran SPP Siswa',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _searchSiswa(),
                        decoration: InputDecoration(
                          hintText: 'Masukkan NIS atau Nama Siswa untuk pembayaran SPP',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: const Color(0xFFF4F7FE),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _searchSiswa,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B3674),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cari Siswa'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_foundSiswa != null) _buildSiswaCard(),
        ],
      ),
    );
  }

  Widget _buildSiswaCard() {
    final siswa = _foundSiswa!;
    final Set<String> bulanLunas = _riwayatSpp
        .where((p) => p.status == 'lunas')
        .map((p) => p.month ?? '')
        .toSet();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [BoxShadow(color: Colors.blue.shade50.withOpacity(0.5), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.person, color: Colors.blue)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(siswa.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                  Text('NIS: ${siswa.nis}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _bulanAjaran.length,
            itemBuilder: (context, index) {
              final bulan = _bulanAjaran[index];
              final isPaid = bulanLunas.contains(bulan);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isPaid ? Colors.green.shade100 : Colors.red.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(bulan, style: TextStyle(fontWeight: FontWeight.bold, color: isPaid ? Colors.green.shade800 : Colors.red.shade800, fontSize: 11)),
                    if (isPaid)
                      const Icon(Icons.check_circle, color: Colors.green, size: 16)
                    else
                      InkWell(
                        onTap: isLoading ? null : () => _bayarSpp(bulan),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Bayar', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const Text('Riwayat Pembayaran Terbaru', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
          const SizedBox(height: 16),
          if (_riwayatSpp.isEmpty)
            const Center(child: Text('Belum ada riwayat pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _riwayatSpp.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final rec = _riwayatSpp[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(Icons.receipt_long, color: Colors.green, size: 20),
                  ),
                  title: Text('SPP Bulan ${rec.month} ${rec.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Dibayar pada: ${rec.paidAt.toString().split('.')[0]}', style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Rp ${rec.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.blue, size: 20),
                        onPressed: () {
                          ReceiptHelper.printReceipt(
                            title: 'KWITANSI PEMBAYARAN SPP',
                            studentName: siswa.name,
                            nis: siswa.nis,
                            amount: 'Rp ${rec.amount.toStringAsFixed(0)}',
                            description: 'Pembayaran SPP bulan ${rec.month} ${rec.year}',
                            transactionId: 'SPP-${rec.id}',
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
