import 'package:flutter/material.dart';

class WakakurJadwalMengajar extends StatelessWidget {
  const WakakurJadwalMengajar({super.key});

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
                'Plotting Jadwal Mengajar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Jadwal Otomatis (AI)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Distribusi Jam Mengajar Guru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Text('Filter Jurusan', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down, size: 16),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _jadwalItem('Ahmad Fauzi, S.Pd', 'Matematika Terapan', '24 Jam', '8 Kelas', true),
                _jadwalItem('Drs. Joko Susilo', 'Sejarah Peminatan', '16 Jam', '5 Kelas', true),
                _jadwalItem('Lina Marlina, S.Si', 'Biologi Lintas Minat', '6 Jam', '2 Kelas', false), // underload
                _jadwalItem('Rina Fitriani, M.Pd', 'Bahasa Inggris', '32 Jam', '10 Kelas', false), // overload
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jadwalItem(String name, String subject, String hours, String classes, bool isIdeal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIdeal ? Colors.white : Colors.red.shade50,
        border: Border.all(color: isIdeal ? Colors.grey.shade200 : Colors.red.shade200),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isIdeal ? Colors.teal.shade50 : Colors.red.shade100,
            child: Icon(Icons.person, color: isIdeal ? Colors.teal : Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subject, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(hours, style: TextStyle(fontWeight: FontWeight.bold, color: isIdeal ? Colors.black87 : Colors.red, fontSize: 14)),
              Text(classes, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal.shade700,
              elevation: 0,
              side: BorderSide(color: Colors.teal.shade200),
            ),
            child: const Text('Edit Plotting', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
