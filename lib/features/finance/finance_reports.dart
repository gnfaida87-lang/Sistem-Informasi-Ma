import 'package:flutter/material.dart';

class FinanceReports extends StatelessWidget {
  const FinanceReports({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Laporan & Rekapitulasi Jurnal Keuangan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print),
                label: const Text('Generate PDF / Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              border: Border.all(color: Colors.green.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text('LAPORAN LABA RUGI OPERASIONAL MURNI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
                const Center(
                  child: Text('Periode Berjalan: Februari 2026', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ),
                const Divider(height: 48, thickness: 2),

                // PEMASUKAN
                const Text('LAPORAN PEMASUKAN (+)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 12),
                _reportItem('1. Total Kolektivitas SPP Bulanan', 'Rp 120.000.000'),
                _reportItem('2. Pembayaran Daftar Ulang Siswa', 'Rp 45.000.000'),
                _reportItem('3. Sumbangan Alumni & Yayasan', 'Rp 15.000.000'),
                const Divider(),
                _reportTotal('TOTAL PEMASUKAN KOTOR', 'Rp 180.000.000', Colors.green.shade800),
                
                const SizedBox(height: 32),

                // PENGELUARAN
                const Text('LAPORAN PENGELUARAN (-)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 12),
                _reportItem('1. Beban Honorarium & Gaji Guru Induk', 'Rp 65.000.000'),
                _reportItem('2. Beban Utilitas PLN & PDAM', 'Rp 6.000.000'),
                _reportItem('3. Perbaikan Sarana Infrastruktur', 'Rp 14.000.000'),
                _reportItem('4. Beban Event & Konservasi Publik', 'Rp 2.000.000'),
                const Divider(),
                _reportTotal('TOTAL PENGELUARAN OPERATOR', 'Rp 87.000.000', Colors.red.shade800),

                const Divider(height: 48, thickness: 2),
                
                // NET INCOME
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('NET CASH FLOW / SURPLUS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Rp 93.000.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _reportItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _reportTotal(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}
