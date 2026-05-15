import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorMasterTahunAjaran extends ConsumerStatefulWidget {
  const OperatorMasterTahunAjaran({super.key});

  @override
  ConsumerState<OperatorMasterTahunAjaran> createState() => _OperatorMasterTahunAjaranState();
}

class _OperatorMasterTahunAjaranState extends ConsumerState<OperatorMasterTahunAjaran> with SafeAsync<OperatorMasterTahunAjaran> {
  final TextEditingController _tahunController = TextEditingController();

  void _showAddDialog({AcademicYear? academicYear}) {
    if (academicYear != null) {
      _tahunController.text = academicYear.year;
    } else {
      _tahunController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(academicYear == null ? 'Tambah Tahun Ajaran Baru' : 'Edit Tahun Ajaran', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tahunController,
              decoration: InputDecoration(
                labelText: 'Tahun Ajaran',
                hintText: 'Contoh: 2026/2027',
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
              final tahun = _tahunController.text;

              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Berhasil Disimpan',
                action: () async {
                  final service = ref.read(masterServiceProvider);
                  final newYear = AcademicYear(
                    id: academicYear?.id ?? '',
                    year: tahun,
                    isActive: academicYear?.isActive ?? false,
                  );

                  if (academicYear == null) {
                    await service.addAcademicYear(newYear);
                  } else {
                    await service.updateAcademicYear(newYear);
                  }
                  ref.invalidate(allAcademicYearsProvider);
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

  void _deleteAcademicYear(AcademicYear academicYear) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tahun Ajaran?'),
        content: Text('Apakah Anda yakin ingin menghapus ${academicYear.year}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Tahun Ajaran Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteAcademicYear(academicYear.id);
                  ref.invalidate(allAcademicYearsProvider);
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

  void _toggleActiveStatus(AcademicYear academicYear) {
    safeCall(
      context: context,
      successMessage: 'Tahun Ajaran Berhasil Diaktifkan',
      action: () async {
        final service = ref.read(masterServiceProvider);
        // Menggunakan fungsi eksklusif: aktifkan satu, matikan yang lain
        await service.setActiveAcademicYear(academicYear.id);
        ref.invalidate(allAcademicYearsProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final academicYearsAsync = ref.watch(allAcademicYearsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Master Tahun Ajaran',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Tahun Ajaran'),
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
                const Text('Daftar Tahun Ajaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                academicYearsAsync.when(
                  data: (years) {
                    if (years.isEmpty) {
                      return const Center(child: Text('Belum ada data tahun ajaran'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                        columns: const [
                          DataColumn(label: Text('Tahun Ajaran', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: years.map((y) => _buildDataRow(y)).toList(),
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

  DataRow _buildDataRow(AcademicYear year) {
    return DataRow(
      cells: [
        DataCell(Text(year.year, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: year.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(year.isActive ? 'Aktif' : 'Nonaktif', style: TextStyle(color: year.isActive ? Colors.green : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showAddDialog(academicYear: year)),
              if (!year.isActive)
                IconButton(icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 18), onPressed: () => _toggleActiveStatus(year)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _deleteAcademicYear(year)),
            ],
          ),
        ),
      ],
    );
  }
}
