import 'package:flutter/material.dart';

class OperatorMasterKelas extends StatelessWidget {
  const OperatorMasterKelas({super.key});

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
                'Data Master Kelas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.meeting_room),
                label: const Text('Buat Rombel Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildClassCard('X IPA 1', 'Agus Prayitno, M.Pd', 32, 35),
              _buildClassCard('X IPS 1', 'Siti Rahmawati, S.Pd', 30, 35),
              _buildClassCard('XI IPA 1', 'Drs. Budi Santoso', 31, 35),
              _buildClassCard('XI IPS 2', 'Nisa Nabila, S.Si', 36, 35, isOvercapacity: true),
              _buildClassCard('XII IPA 1', 'Belum Diatur', 0, 35, isWarning: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(String namaKelas, String waliKelas, int jumlahSiswa, int kapasitas, {bool isOvercapacity = false, bool isWarning = false}) {
    Color cardBorderStr = isWarning ? Colors.orange : (isOvercapacity ? Colors.red : Colors.grey.shade200);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderStr, width: isWarning || isOvercapacity ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(namaKelas, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2B3674))),
              Icon(Icons.more_horiz, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 12),
          Text('Wali Kelas: $waliKelas', style: TextStyle(color: isWarning ? Colors.orange.shade800 : Colors.grey.shade600, fontSize: 13, fontWeight: isWarning ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kapasitas/Ruang', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  Text('$jumlahSiswa / $kapasitas Siswa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isOvercapacity ? Colors.red : Colors.green.shade700)),
                ],
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.brown.shade700,
                  side: BorderSide(color: Colors.brown.shade200),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text('Kelola', style: TextStyle(fontSize: 12)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
