import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';
import '../../core/utils/excel_helper.dart';
import 'utils/teacher_card_helper.dart';

class OperatorMasterGuru extends ConsumerStatefulWidget {
  const OperatorMasterGuru({super.key});

  @override
  ConsumerState<OperatorMasterGuru> createState() => _OperatorMasterGuruState();
}

class _OperatorMasterGuruState extends ConsumerState<OperatorMasterGuru> with SafeAsync<OperatorMasterGuru> {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _nipCtrl = TextEditingController();
  bool _isWaliKelas = false;

  void _showAddDialog({Teacher? teacher}) {
    if (teacher != null) {
      _namaCtrl.text = teacher.name;
      _nipCtrl.text = teacher.nip ?? '';
      _isWaliKelas = teacher.isWaliKelas;
    } else {
      _namaCtrl.clear();
      _nipCtrl.clear();
      _isWaliKelas = false;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(teacher == null ? 'Registrasi Guru Baru' : 'Edit Data Guru', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _namaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap (Gelar)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nipCtrl,
                  decoration: InputDecoration(
                    labelText: 'NIP',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Wali Kelas'),
                  value: _isWaliKelas,
                  onChanged: (val) => setDialogState(() => _isWaliKelas = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final nama = _namaCtrl.text;
                final nip = _nipCtrl.text;
                final isWali = _isWaliKelas;

                Navigator.pop(context);
                safeCall(
                  context: context,
                  successMessage: 'Data Guru Berhasil Disimpan',
                  action: () async {
                    final service = ref.read(masterServiceProvider);
                    final newTeacher = Teacher(
                      id: teacher?.id ?? '',
                      name: nama,
                      nip: nip.isEmpty ? null : nip,
                      isWaliKelas: isWali,
                    );

                    if (teacher == null) {
                      await service.addTeacher(newTeacher);
                    } else {
                      await service.updateTeacher(newTeacher);
                    }
                    ref.invalidate(allTeachersProvider);
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
      ),
    );
  }

  void _showDeleteDialog(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Guru?'),
        content: Text('Apakah Anda yakin ingin menghapus ${teacher.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Guru Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteTeacher(teacher.id);
                  ref.invalidate(allTeachersProvider);
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

  Future<void> _downloadTemplate() async {
    await ExcelHelper.exportToExcel(
      fileName: 'Template_Guru.xlsx', 
      sheetName: 'Guru', 
      headers: ['Nama Lengkap', 'NIP', 'Wali Kelas (YA/TIDAK)'], 
      rows: [
        ['Drs. Budi Santoso', '198001012005011001', 'YA'],
      ]
    );
  }

  Future<void> _exportData() async {
    final teachers = ref.read(allTeachersProvider).value ?? [];
    if (teachers.isEmpty) return;

    await ExcelHelper.exportToExcel(
      fileName: 'Data_Guru_Export.xlsx', 
      sheetName: 'Data Guru', 
      headers: ['Nama Lengkap', 'NIP', 'Wali Kelas'], 
      rows: teachers.map((t) => [t.name, t.nip ?? '', t.isWaliKelas ? 'YA' : 'TIDAK']).toList()
    );
  }

  Future<void> _processMassUpload() async {
    final rows = await ExcelHelper.importFromExcel();
    if (rows == null || rows.length < 2) return;

    List<Teacher> temp = [];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row[0] == null) continue;

      final nama = row[0].toString();
      final nip = row[1]?.toString();
      final isWali = row[2]?.toString().toUpperCase() == 'YA';
      
      if (nama.isNotEmpty) {
        temp.add(Teacher(
          id: '',
          name: nama,
          nip: nip,
          isWaliKelas: isWali,
        ));
      }
    }

    if (temp.isNotEmpty) {
      _showPreviewDialog(temp);
    }
  }

  void _showPreviewDialog(List<Teacher> teachers) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Preview Import Guru & Staf', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: SizedBox(
            width: 600,
            height: 500,
            child: Column(
              children: [
                const Text('Data berikut akan disimpan dan akun login akan dibuat otomatis.', 
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: ListView.separated(
                      itemCount: teachers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final t = teachers[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(radius: 14, backgroundColor: Colors.brown.shade50, child: const Icon(Icons.school, size: 14, color: Colors.brown)),
                          title: Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text('NIP: ${t.nip ?? "-"} | Wali Kelas: ${t.isWaliKelas ? "YA" : "TIDAK"}', style: const TextStyle(fontSize: 11)),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Total: ${teachers.length} Guru/Staf ditemukan', 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await safeCall(
                  context: context,
                  successMessage: 'Berhasil mengimpor ${teachers.length} guru/staf',
                  action: () async {
                    final service = ref.read(masterServiceProvider);
                    for (var t in teachers) {
                      await service.addTeacher(t);
                    }
                    ref.invalidate(allTeachersProvider);
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade700, foregroundColor: Colors.white),
              child: const Text('Simpan & Buat Akun'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(allTeachersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Data Master Guru & Pegawai',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _downloadTemplate,
                    icon: const Icon(Icons.download_for_offline_outlined),
                    label: const Text('Unduh Template'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.brown.shade700,
                      side: BorderSide(color: Colors.brown.shade300),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _processMassUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import Massal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _exportData,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Ekspor Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final list = ref.read(allTeachersProvider).value ?? [];
                      if (list.isNotEmpty) {
                        TeacherCardHelper.generateAndPrint(list);
                      }
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Cetak Kartu Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(),
                    icon: const Icon(Icons.person_add_alt_1),
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
                const Text('Daftar Rekan Pendidik dan Tenaga Kependidikan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                teachersAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(child: Text('Belum ada data guru'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                        columns: const [
                          DataColumn(label: Text('Nama / NIP', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Wali Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: list.map((guru) => _buildDataRow(guru)).toList(),
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

  DataRow _buildDataRow(Teacher teacher) {
    return DataRow(
      cells: [
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 16, backgroundColor: Colors.brown, child: Icon(Icons.person, size: 18, color: Colors.white)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (teacher.nip != null) Text('NIP. ${teacher.nip}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        )),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: teacher.isWaliKelas ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              teacher.isWaliKelas ? 'YA' : 'TIDAK',
              style: TextStyle(
                color: teacher.isWaliKelas ? Colors.green.shade700 : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 10
              ),
            ),
          )
        ),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showAddDialog(teacher: teacher)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _showDeleteDialog(teacher)),
            ],
          ),
        ),
      ],
    );
  }
}
