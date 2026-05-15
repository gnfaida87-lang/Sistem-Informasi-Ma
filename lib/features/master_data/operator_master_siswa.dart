import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/master_models.dart';
import 'services/master_service.dart';
import '../../core/utils/excel_helper.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/network/d1_service.dart';
import 'package:sistem_informasi_ma/core/providers/master_provider.dart';
import 'utils/student_card_helper.dart';

class OperatorMasterSiswa extends ConsumerStatefulWidget {
  const OperatorMasterSiswa({super.key});

  @override
  ConsumerState<OperatorMasterSiswa> createState() => _OperatorMasterSiswaState();
}

class _OperatorMasterSiswaState extends ConsumerState<OperatorMasterSiswa> with SafeAsync<OperatorMasterSiswa> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  String _selectedKelasId = 'All';
  String _searchQuery = '';
  List<Student> _previewStudents = [];

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Future<void> _downloadTemplate() async {
    await ExcelHelper.exportToExcel(
      fileName: 'Template_Siswa.xlsx', 
      sheetName: 'Siswa', 
      headers: ['NISN', 'Nama Lengkap', 'ID Kelas', 'Nama Wali', 'No HP Wali'], 
      rows: [
        ['0012345678', 'Ahmad Fulan', 'cls_123', 'Bpk. Junaidi', '081234567890'],
      ]
    );
  }

  Future<void> _exportData() async {
    final students = ref.read(allStudentsProvider).value ?? [];
    if (students.isEmpty) return;

    await ExcelHelper.exportToExcel(
      fileName: 'Data_Siswa_Export.xlsx', 
      sheetName: 'Data Siswa', 
      headers: ['NISN', 'Nama Lengkap', 'ID Kelas', 'Status'], 
      rows: students.map((s) => [s.nis, s.name, s.classId ?? '', s.isActive ? 'Aktif' : 'Non-Aktif']).toList()
    );
  }

  Future<void> _processMassUpload() async {
    final rows = await ExcelHelper.importFromExcel();
    if (rows == null || rows.length < 2) return;

    List<Student> temp = [];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row[0] == null) continue;

      final nis = row[0].toString();
      final nama = row[1]?.toString() ?? '';
      final klsId = row[2]?.toString();
      final wali = row[3]?.toString();
      final hp = row[4]?.toString();
      
      if (nis.isNotEmpty && nama.isNotEmpty) {
        temp.add(Student(
          id: '',
          nis: nis,
          name: nama,
          classId: klsId,
          parentName: wali,
          phone: hp,
          isActive: true,
        ));
      }
    }

    if (temp.isNotEmpty) {
      _showPreviewDialog(temp);
    }
  }

  void _showPreviewDialog(List<Student> students) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Preview Import Siswa', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: SizedBox(
            width: 600,
            height: 500,
            child: Column(
              children: [
                const Text('Mohon periksa kembali data berikut sebelum disimpan ke database.', 
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = students[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(radius: 14, backgroundColor: Colors.blue.shade50, child: const Icon(Icons.person, size: 14, color: Colors.blue)),
                          title: Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text('NISN: ${s.nis} | Wali: ${s.parentName ?? "-"}', style: const TextStyle(fontSize: 11)),
                          trailing: Text(s.classId ?? '-', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Total: ${students.length} Siswa ditemukan', 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
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
                  successMessage: 'Berhasil mengimpor ${students.length} siswa',
                  action: () async {
                    final service = ref.read(masterServiceProvider);
                    for (var s in students) {
                      await service.addStudent(s);
                    }
                    ref.invalidate(allStudentsProvider);
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
              child: const Text('Simpan Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog({Student? student}) {
    final nisCtrl = TextEditingController(text: student?.nis);
    final namaCtrl = TextEditingController(text: student?.name);
    String? selectedKelasId = student?.classId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(student == null ? 'Registrasi Siswa Baru' : 'Edit Data Siswa', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nisCtrl,
                  decoration: InputDecoration(
                    labelText: 'NISN / NIS',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: namaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap Siswa',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: student?.parentName),
                  onChanged: (v) => student = Student(
                    id: student?.id ?? '',
                    nis: nisCtrl.text,
                    name: namaCtrl.text,
                    classId: selectedKelasId,
                    parentName: v,
                    phone: student?.phone,
                    isActive: student?.isActive ?? true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nama Wali / Orang Tua',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.family_restroom),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: student?.phone),
                  onChanged: (v) => student = Student(
                    id: student?.id ?? '',
                    nis: nisCtrl.text,
                    name: namaCtrl.text,
                    classId: selectedKelasId,
                    parentName: student?.parentName,
                    phone: v,
                    isActive: student?.isActive ?? true,
                  ),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'No. HP / WhatsApp Wali',
                    hintText: 'Contoh: 081234567890',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final classesAsync = ref.watch(allClassesProvider);
                    return classesAsync.when(
                      data: (classes) => DropdownButtonFormField<String>(
                        value: selectedKelasId,
                        decoration: InputDecoration(
                          labelText: 'Pilih Kelas',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: classes.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        )).toList(),
                        onChanged: (val) => setDialogState(() => selectedKelasId = val),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Gagal memuat kelas'),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final nis = nisCtrl.text;
                final nama = namaCtrl.text;
                if (nis.isEmpty || nama.isEmpty) return;

                Navigator.pop(context);
                safeCall(
                  context: context,
                  successMessage: 'Data Siswa Berhasil Disimpan',
                  action: () async {
                    final service = ref.read(masterServiceProvider);
                    final s = Student(
                      id: student?.id ?? '',
                      nis: nis,
                      name: nama,
                      classId: selectedKelasId,
                      parentName: student?.parentName,
                      phone: student?.phone,
                      isActive: student?.isActive ?? true,
                    );

                    if (student == null) {
                      await service.addStudent(s);
                    } else {
                      await service.updateStudent(s);
                    }
                    ref.invalidate(allStudentsProvider);
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3674), foregroundColor: Colors.white),
              child: const Text('Simpan Data'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Siswa?'),
        content: Text('Apakah Anda yakin ingin menghapus data ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteStudent(student.id);
                  ref.invalidate(allStudentsProvider);
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);
    final classesAsync = ref.watch(allClassesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Data Siswa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _downloadTemplate,
                    icon: const Icon(Icons.download),
                    label: const Text('Template'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _processMassUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Import Excel'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final students = ref.read(allStudentsProvider).value ?? [];
                      // Gunakan filter yang sama dengan tabel
                      final filtered = students.where((s) {
                        final matchSearch = s.name.toLowerCase().contains(_searchQuery) || s.nis.contains(_searchQuery);
                        final matchKelas = _selectedKelasId == 'All' || s.classId == _selectedKelasId;
                        return matchSearch && matchKelas;
                      }).toList();

                      if (filtered.isNotEmpty) {
                        StudentCardHelper.generateAndPrint(filtered);
                      }
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Cetak Kartu Login'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Siswa'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3674), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // FILTER BOX
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari Nama atau NISN...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  ),
                ),
                const VerticalDivider(),
                classesAsync.when(
                  data: (classes) => DropdownButton<String>(
                    value: _selectedKelasId,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(value: 'All', child: Text('Semua Kelas')),
                      ...classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (v) => setState(() => _selectedKelasId = v!),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const Text('Error'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TABLE
          studentsAsync.when(
            data: (students) {
              final filtered = students.where((s) {
                final matchSearch = s.name.toLowerCase().contains(_searchQuery) || s.nis.contains(_searchQuery);
                final matchKelas = _selectedKelasId == 'All' || s.classId == _selectedKelasId;
                return matchSearch && matchKelas;
              }).toList();

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Scrollbar(
                  controller: _horizontalController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalController,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                      columns: const [
                        DataColumn(label: Text('NISN/NIS')),
                        DataColumn(label: Text('Nama Siswa')),
                        DataColumn(label: Text('Nama Wali')),
                        DataColumn(label: Text('No. HP Wali')),
                        DataColumn(label: Text('Kelas')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: filtered.map((s) => DataRow(cells: [
                        DataCell(Text(s.nis)),
                        DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(s.parentName ?? '-')),
                        DataCell(Text(s.phone ?? '-')),
                        DataCell(Text(s.classId ?? '-')),
                        DataCell(Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => _showAddDialog(student: s)),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _deleteStudent(s)),
                          ],
                        )),
                      ])).toList(),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}
