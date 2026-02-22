import 'package:flutter/material.dart';

class FinanceSppPayment extends StatelessWidget {
  const FinanceSppPayment({super.key});

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
                'Pembayaran SPP Bulanan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Virtual Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // PANEL PENCARIAN SISWA TERINCAR
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Siswa / Masukkan NISN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Ketik Nomor Induk atau Nama Lengkap',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Proses Pencarian', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // HASIL PENCAPAIAN / KARTU SPP (MOCKUP DUMMY AHMAD RIZAL)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade400, width: 2), // Highlight
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 20, backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ahmad Rizal Fachry (NISN: 001293)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                        Text('Kelas XII IPA 1 • Wali Kelas: Drs. Budi Santoso', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Status Pembayaran Terakhir', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Menunggak 2 Bulan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                      ],
                    )
                  ],
                ),
                const Divider(height: 32),
                
                // TABEL BULANAN SPP
                const Text('Kartu Iuran SPP Tahunan (Rp 250.000 / Bulan)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                    dataRowMinHeight: 40,
                    dataRowMaxHeight: 45,
                    columns: const [
                      DataColumn(label: Text('Bulan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(label: Text('Tanggal Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                    rows: [
                      _buildBulanRow('Juli', true, '15 Jul 2025'),
                      _buildBulanRow('Agustus', true, '18 Agt 2025'),
                      _buildBulanRow('September', false, '- (Tertunggak)'),
                      _buildBulanRow('Oktober', false, '- (Tertunggak)'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildBulanRow(String bulan, bool isPaid, String tanggal) {
    return DataRow(
      color: MaterialStateProperty.all(isPaid ? Colors.transparent : Colors.red.shade50),
      cells: [
        DataCell(Text(bulan, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: isPaid ? Colors.green.shade100 : Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
            child: Text(isPaid ? 'Lunas' : 'Belum Lunas', style: TextStyle(color: isPaid ? Colors.green.shade800 : Colors.red.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(Text(tanggal, style: TextStyle(color: isPaid ? Colors.black87 : Colors.red.shade700))),
        DataCell(
          isPaid 
            ? TextButton.icon(onPressed: () {}, icon: const Icon(Icons.receipt, size: 14), label: const Text('Kwitansi', style: TextStyle(fontSize: 12)))
            : ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, minimumSize: const Size(0, 30), padding: const EdgeInsets.symmetric(horizontal: 16)),
                child: const Text('Bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
        ),
      ],
    );
  }
}
