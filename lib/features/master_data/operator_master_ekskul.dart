import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorMasterEkskul extends ConsumerStatefulWidget {
  const OperatorMasterEkskul({super.key});

  @override
  ConsumerState<OperatorMasterEkskul> createState() => _OperatorMasterEkskulState();
}

class _OperatorMasterEkskulState extends ConsumerState<OperatorMasterEkskul> with SafeAsync<OperatorMasterEkskul> {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _pembinaCtrl = TextEditingController();

  void _showAddDialog({Extracurricular? ekskul}) {
    if (ekskul != null) {
      _namaCtrl.text = ekskul.name;
      _pembinaCtrl.text = ekskul.coach ?? '';
    } else {
      _namaCtrl.clear();
      _pembinaCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ekskul == null ? 'Tambah Ekstrakurikuler Baru' : 'Edit Ekstrakurikuler', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Ekskul',
                hintText: 'Contoh: Pramuka, PMR, Futsal',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pembinaCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Pembina',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person_pin_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final nama = _namaCtrl.text;
              final pembina = _pembinaCtrl.text;

              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Berhasil Disimpan',
                action: () async {
                  final service = ref.read(masterServiceProvider);
                  final newEkskul = Extracurricular(
                    id: ekskul?.id ?? '',
                    name: nama,
                    coach: pembina,
                  );

                  if (ekskul == null) {
                    await service.addEkskul(newEkskul);
                  } else {
                    await service.updateEkskul(newEkskul);
                  }
                  ref.invalidate(allEkskulProvider);
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Extracurricular ekskul) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Apakah Anda yakin ingin menghapus Ekstrakurikuler "${ekskul.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Ekstrakurikuler Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteEkskul(ekskul.id);
                  ref.invalidate(allEkskulProvider);
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ekskulAsync = ref.watch(allEkskulProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Master Ekstrakurikuler',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Satuan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daftar Kegiatan Ekstrakurikuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                ekskulAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(child: Text('Belum ada data ekskul'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                        columns: const [
                          DataColumn(label: Text('Nama Ekskul', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Pembina', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: list.map((e) => _buildDataRow(e)).toList(),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Extracurricular ekskul) {
    return DataRow(
      cells: [
        DataCell(Text(ekskul.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(ekskul.coach ?? '-')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 18), 
                tooltip: 'Edit Ekskul',
                onPressed: () => _showAddDialog(ekskul: ekskul),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), 
                tooltip: 'Hapus Ekskul',
                onPressed: () => _showDeleteDialog(ekskul),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
