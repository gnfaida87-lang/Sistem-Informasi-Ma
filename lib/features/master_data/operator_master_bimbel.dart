import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorMasterBimbel extends ConsumerStatefulWidget {
  const OperatorMasterBimbel({super.key});

  @override
  ConsumerState<OperatorMasterBimbel> createState() => _OperatorMasterBimbelState();
}

class _OperatorMasterBimbelState extends ConsumerState<OperatorMasterBimbel> with SafeAsync<OperatorMasterBimbel> {
  final TextEditingController _namaCtrl = TextEditingController();
  String? _selectedTeacherId;

  void _showAddDialog({Tutoring? bimbel}) {
    if (bimbel != null) {
      _namaCtrl.text = bimbel.name;
      _selectedTeacherId = bimbel.teacherId;
    } else {
      _namaCtrl.clear();
      _selectedTeacherId = null;
    }

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final teachersAsync = ref.watch(allTeachersProvider);
          return AlertDialog(
            title: Text(bimbel == null ? 'Tambah Program Bimbel Baru' : 'Edit Program Bimbel', 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _namaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Program Bimbel',
                      hintText: 'Contoh: Sukses PTN, Persiapan OSN',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  teachersAsync.when(
                    data: (teachers) => DropdownButtonFormField<String>(
                      value: _selectedTeacherId,
                      decoration: InputDecoration(
                        labelText: 'Guru Pengampu',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: teachers.map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.name),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedTeacherId = value),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error loading teachers: $e'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nama = _namaCtrl.text;
                  final teacherId = _selectedTeacherId;

                  Navigator.pop(context);
                  safeCall(
                    context: context,
                    successMessage: 'Data Berhasil Disimpan',
                    action: () async {
                      final service = ref.read(masterServiceProvider);
                      final newBimbel = Tutoring(
                        id: bimbel?.id ?? '',
                        name: nama,
                        teacherId: teacherId,
                      );

                      if (bimbel == null) {
                        await service.addBimbel(newBimbel);
                      } else {
                        await service.updateBimbel(newBimbel);
                      }
                      ref.invalidate(allBimbelProvider);
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
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Tutoring bimbel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Program Bimbel?'),
        content: Text('Apakah Anda yakin ingin menghapus ${bimbel.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Program Bimbel Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteBimbel(bimbel.id);
                  ref.invalidate(allBimbelProvider);
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
    final bimbelAsync = ref.watch(allBimbelProvider);
    final teachersAsync = ref.watch(allTeachersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Master Program Bimbel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Program Bimbel Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
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
                const Text('Daftar Program Bimbel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                bimbelAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(child: Text('Belum ada data bimbel'));
                    }
                    return teachersAsync.when(
                      data: (teachers) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                          columns: const [
                            DataColumn(label: Text('Nama Program', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Guru Pengampu', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Peserta', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: list.map((b) {
                            final teacher = teachers.where((t) => t.id == b.teacherId).firstOrNull;
                            return _buildDataRow(b, teacher?.name ?? '-');
                          }).toList(),
                        ),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
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

  DataRow _buildDataRow(Tutoring bimbel, String teacherName) {
    return DataRow(
      cells: [
        DataCell(Text(bimbel.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(teacherName)),
        DataCell(
          Consumer(
            builder: (context, ref, child) {
              final participantsAsync = ref.watch(bimbelParticipantsProvider(bimbel.id));
              return participantsAsync.when(
                data: (list) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: list.isNotEmpty ? Colors.blue.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${list.length} Siswa',
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold,
                      color: list.isNotEmpty ? Colors.blue.shade700 : Colors.grey,
                    ),
                  ),
                ),
                loading: () => const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Text('?'),
              );
            },
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showAddDialog(bimbel: bimbel)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _showDeleteDialog(bimbel)),
            ],
          ),
        ),
      ],
    );
  }
}
