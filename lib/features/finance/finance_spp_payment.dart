import 'package:flutter/material.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/utils/context_extensions.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';
import '../master_data/services/master_service.dart';
import '../master_data/models/master_models.dart';

class FinanceSppPayment extends StatefulWidget {
  const FinanceSppPayment({super.key});

  @override
  State<FinanceSppPayment> createState() => _FinanceSppPaymentState();
}

class _FinanceSppPaymentState extends State<FinanceSppPayment> with SafeAsync {
  final TextEditingController _searchController = TextEditingController();
  final _financeService = FinanceService();
  final _masterService = MasterService();

  Student? _foundSiswa;
  List<SppRecord> _riwayatSpp = [];
  
  final List<String> _bulanAjaran = [
    'Juli', 'Agustus', 'September', 'Oktober',
    'November', 'Desember', 'Januari', 'Februari',
    'Maret', 'April', 'Mei', 'Juni'
  ];

  @override
  void dispose() {
    _searchController.dispose();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pembayaran SPP',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _searchSiswa(),
                        decoration: InputDecoration(
                          hintText: 'NIS atau Nama Siswa',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _searchSiswa,
                      child: const Text('Cari'),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(siswa.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('NIS: ${siswa.nis}'),
          const Divider(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bulanAjaran.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final bulan = _bulanAjaran[index];
              final isPaid = bulanLunas.contains(bulan);
              return ListTile(
                title: Text(bulan),
                trailing: isPaid 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                      onPressed: isLoading ? null : () => _bayarSpp(bulan),
                      child: const Text('Bayar'),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
