import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:excel/excel.dart' as excel_pkg;
import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

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

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Future<void> _downloadTemplate() async {
    try {
      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel['Siswa'];
      excel.setDefaultSheet('Siswa');

      sheet.appendRow([
        excel_pkg.TextCellValue('NISN'),
        excel_pkg.TextCellValue('Nama Lengkap'),
        excel_pkg.TextCellValue('Kelas'),
        excel_pkg.TextCellValue('Nama Ayah'),
        excel_pkg.TextCellValue('Nama Ibu'),
      ]);

      sheet.appendRow([
        excel_pkg.TextCellValue('0012345678'),
        excel_pkg.TextCellValue('Ahmad Fulan'),
        excel_pkg.TextCellValue('X IPA 1'),
        excel_pkg.TextCellValue('Budi'),
        excel_pkg.TextCellValue('Siti'),
      ]);

      if (kIsWeb) {
        final bytes = excel.encode();
        if (bytes != null) {
          final content = base64Encode(bytes);
          final anchor = html.AnchorElement(
              href: "data:application/octet-stream;charset=utf-16le;base64,$content")
            ..setAttribute("download", "Template_Siswa.xlsx")
            ..click();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Template sedang diunduh...'), backgroundColor: Colors.green),
            );
          }
        }
        return;
      }

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Simpan Template Excel',
        fileName: 'Template_Siswa.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final bytes = excel.encode();
        if (bytes != null) {
          final file = File(outputFile);
          await file.writeAsBytes(bytes);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Template disimpan di: $outputFile'), backgroundColor: Colors.green),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat template: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _processMassUpload(FilePickerResult result) async {
    Navigator.pop(context);
    await safeCall(
      context: context,
      successMessage: 'Import berhasil dijalankan',
      action: () async {
        Uint8List? bytes;
        if (kIsWeb) {
          bytes = result.files.single.bytes;
        } else if (result.files.single.path != null) {
          bytes = await File(result.files.single.path!).readAsBytes();
        }

        if (bytes == null) throw 'Gagal membaca file';

        final excel = excel_pkg.Excel.decodeBytes(bytes);
        final table = excel.tables[excel.tables.keys.first];
        if (table == null) return;

        final service = ref.read(masterServiceProvider);
        int successCount = 0;

        for (int i = 1; i < table.maxRows; i++) {
          final row = table.rows[i];
          if (row.isEmpty || row[0]?.value == null) continue;

          final nis = row[0]?.value.toString() ?? '';
          final nama = row[1]?.value.toString() ?? '';
          
          if (nis.isNotEmpty && nama.isNotEmpty) {
            await service.addStudent(Student(
              id: '',
              nis: nis,
              name: nama,
              isActive: true,
            ));
            successCount++;
          }
        }

        ref.invalidate(allStudentsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Berhasil import $successCount siswa'), backgroundColor: Colors.green),
          );
        }
      },
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
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nisCtrl,
                    decoration: InputDecoration(
                      labelText: 'NISN / NIS',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: namaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap Siswa',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.person_outline),
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
                          onChanged: (value) => setDialogState(() => selectedKelasId = value),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
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
                  successMessage: 'Data Siswa Berhasil Disimpan',
                  action: () async {
                    final service = ref.read(masterServiceProvider);
                    final newStudent = Student(
                      id: student?.id ?? '',
                      nis: nisCtrl.text,
                      name: namaCtrl.text,
                      classId: selectedKelasId,
                      isActive: true,
                    );

                    if (student == null) {
                      await service.addStudent(newStudent);
                    } else {
                      await service.updateStudent(newStudent);
                    }
                    ref.invalidate(allStudentsProvider);
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade600, foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Siswa?', style: TextStyle(color: Colors.red)),
        content: Text('Apakah Anda yakin ingin menghapus ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Siswa Berhasil Dihapus',
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

  void _showImportDialog() {
    FilePickerResult? selectedResult;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Import Data Siswa (Bulk)', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  FilePickerResult? result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx', 'xls', 'csv'],
                  );
                  if (result != null) {
                    setDialogState(() => selectedResult = result);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: 350,
                  decoration: BoxDecoration(
                    color: selectedResult != null ? Colors.green.shade50 : Colors.brown.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selectedResult != null ? Colors.green.shade300 : Colors.brown.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        selectedResult != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined, 
                        size: 48, 
                        color: selectedResult != null ? Colors.green.shade500 : Colors.brown.shade400
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedResult != null 
                            ? 'File Terpilih:\n${selectedResult!.files.single.name}' 
                            : 'Klik di sini untuk memilih\nfile Excel/CSV dari komputer', 
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
              onPressed: selectedResult == null ? null : () => _processMassUpload(selectedResult!),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade600, foregroundColor: Colors.white),
              child: const Text('Mulai Import'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);
    final classesAsync = ref.watch(allClassesProvider);

    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalController,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Data Master Siswa & Wali',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _downloadTemplate,
                      icon: const Icon(Icons.download_for_offline_outlined),
                      label: const Text('Unduh Templet'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.brown.shade700,
                        side: BorderSide(color: Colors.brown.shade300),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showImportDialog,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Massal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDialog(),
                      icon: const Icon(Icons.person_add),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Daftar Seluruh Siswa & Informasi Wali', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                      Row(
                        children: [
                          classesAsync.when(
                            data: (classes) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedKelasId,
                                  items: [
                                    const DropdownMenuItem(value: 'All', child: Text('Semua Kelas', style: TextStyle(fontSize: 13))),
                                    ...classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 13)))),
                                  ],
                                  onChanged: (val) => setState(() => _selectedKelasId = val!),
                                ),
                              ),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text('Error: $e'),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 250,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                            child: TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Cari Nama, NIS...',
                                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 16),
                  studentsAsync.when(
                    data: (students) {
                      final filtered = students.where((s) {
                        final matchKelas = _selectedKelasId == 'All' || s.classId == _selectedKelasId;
                        final matchSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                            s.nis.toLowerCase().contains(_searchQuery.toLowerCase());
                        return matchKelas && matchSearch;
                      }).toList();

                      if (filtered.isEmpty) return const Center(child: Text('Tidak ada data siswa'));

                      return classesAsync.when(
                        data: (classes) => Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                              columns: const [
                                DataColumn(label: Text('NISN/NIS', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Orang Tua', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filtered.map((s) {
                                final className = classes.where((c) => c.id == s.classId).firstOrNull?.name ?? '-';
                                return _buildDataRow(s, className);
                              }).toList(),
                            ),
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
      ),
    );
  }

  DataRow _buildDataRow(Student student, String className) {
    return DataRow(
      cells: [
        DataCell(Text(student.nis, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(student.name)),
        DataCell(Text(className)),
        DataCell(Text(student.parentName ?? '-')),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showAddDialog(student: student)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _showDeleteDialog(student)),
            ],
          ),
        ),
      ],
    );
  }
}
