import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorMasterJurusan extends ConsumerStatefulWidget {
  const OperatorMasterJurusan({super.key});

  @override
  ConsumerState<OperatorMasterJurusan> createState() => _OperatorMasterJurusanState();
}

class _OperatorMasterJurusanState extends ConsumerState<OperatorMasterJurusan> with SafeAsync<OperatorMasterJurusan> {
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();

  void _showAddDialog({Major? major}) {
    if (major != null) {
      _kodeController.text = major.code;
      _namaController.text = major.name;
    } else {
      _kodeController.clear();
      _namaController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(major == null ? 'Tambah Jurusan / Program' : 'Edit Jurusan', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _kodeController,
              decoration: InputDecoration(
                labelText: 'Kode Jurusan',
                hintText: 'Contoh: IPA, IPS',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap Jurusan',
                hintText: 'Contoh: Ilmu Pengetahuan Alam',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final kode = _kodeController.text;
              final nama = _namaController.text;

              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Berhasil Disimpan',
                action: () async {
                  final service = ref.read(masterServiceProvider);
                  final newMajor = Major(
                    id: major?.id ?? '',
                    code: kode,
                    name: nama,
                  );

                  if (major == null) {
                    await service.addMajor(newMajor);
                  } else {
                    await service.updateMajor(newMajor);
                  }
                  ref.invalidate(allMajorsProvider);
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

  void _deleteMajor(Major major) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jurusan?'),
        content: Text('Apakah Anda yakin ingin menghapus ${major.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Jurusan Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteMajor(major.id);
                  ref.invalidate(allMajorsProvider);
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final majorsAsync = ref.watch(allMajorsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Master Jurusan / Program',
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
                const Text('Daftar Jurusan & Program Keahlian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                majorsAsync.when(
                  data: (majors) {
                    if (majors.isEmpty) {
                      return const Center(child: Text('Belum ada data jurusan'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                        columns: const [
                          DataColumn(label: Text('Kode', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Nama Jurusan', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: majors.map((m) => _buildDataRow(m)).toList(),
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

  DataRow _buildDataRow(Major major) {
    return DataRow(
      cells: [
        DataCell(Text(major.code, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(major.name)),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showAddDialog(major: major)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _deleteMajor(major)),
            ],
          ),
        ),
      ],
    );
  }
}
