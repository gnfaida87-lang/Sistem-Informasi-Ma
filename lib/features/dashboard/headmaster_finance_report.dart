import 'package:flutter/material.dart';

class HeadmasterFinanceReport extends StatelessWidget {
  const HeadmasterFinanceReport({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Keuangan Eksekutif',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
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
          const Text('Aliran Kas Masuk (Hari Ini)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green,
                  child: const Icon(Icons.arrow_downward, size: 20),
                ),
                title: Text('Pembayaran SPP Bulan ${['Januari', 'Februari', 'Desember', 'Januari', 'Februari'][index]}'),
                subtitle: Text('Oleh: Siswa ID-${100+index} • Admin: Kasir Utama'),
                trailing: const Text('+ Rp 250.000', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(onPressed: () {}, child: const Text('Lihat Seluruh Transaksi')),
          )
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
          _arrearItem('Kelas XI IPS 2', 'Rp 4.500.000', 12),
          _arrearItem('Kelas X IPA 3', 'Rp 3.250.000', 8),
          _arrearItem('Kelas XII IPS 1', 'Rp 1.500.000', 3),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text('Pastikan Admin Keuangan sudah mengirim rekapan tagihan ke Parent Portal.', style: TextStyle(fontSize: 12, color: Colors.orange))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrearItem(String title, String amount, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('$count Siswa menunggak', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
        ],
      ),
    );
  }
}
