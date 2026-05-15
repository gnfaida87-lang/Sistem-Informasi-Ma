import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel_pkg;
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorMasterMapel extends ConsumerStatefulWidget {
  const OperatorMasterMapel({super.key});

  @override
  ConsumerState<OperatorMasterMapel> createState() => _OperatorMasterMapelState();
}

class _OperatorMasterMapelState extends ConsumerState<OperatorMasterMapel> with SafeAsync<OperatorMasterMapel> {
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kkmController = TextEditingController();
  List<Subject> _previewSubjects = [];

  void _showAddDialog({Subject? subject}) {
    if (subject != null) {
      _kodeController.text = subject.code ?? '';
      _namaController.text = subject.name;
      _kkmController.text = subject.kkm.toString();
    } else {
      _kodeController.clear();
      _namaController.clear();
      _kkmController.text = '75';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subject == null ? 'Tambah Mata Pelajaran' : 'Edit Mata Pelajaran', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _kodeController,
                decoration: InputDecoration(
                  labelText: 'Kode Mapel',
                  hintText: 'Contoh: MTK, FIS, BIO',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Mata Pelajaran',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _kkmController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'KKM Default',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
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
              final kode = _kodeController.text;
              final nama = _namaController.text;
              final kkm = int.tryParse(_kkmController.text) ?? 75;

              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Berhasil Disimpan',
                action: () async {
                  final service = ref.read(masterServiceProvider);
                  final newSubject = Subject(
                    id: subject?.id ?? '',
                    code: kode,
                    name: nama,
                    kkm: kkm,
                  );

                  if (subject == null) {
                    await service.addSubject(newSubject);
                  } else {
                    await service.updateSubject(newSubject);
                  }
                  ref.invalidate(allSubjectsProvider);
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

  void _deleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mata Pelajaran?'),
        content: Text('Apakah Anda yakin ingin menghapus ${subject.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Mata Pelajaran Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteSubject(subject.id);
                  ref.invalidate(allSubjectsProvider);
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
    try {
      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel['Mapel'];
      excel.setDefaultSheet('Mapel');

      sheet.appendRow([
        excel_pkg.TextCellValue('Kode Mapel'),
        excel_pkg.TextCellValue('Nama Mata Pelajaran'),
        excel_pkg.TextCellValue('KKM'),
      ]);

      sheet.appendRow([
        excel_pkg.TextCellValue('MTKW'),
        excel_pkg.TextCellValue('Matematika Wajib'),
        excel_pkg.IntCellValue(75),
      ]);

      if (kIsWeb) {
        final bytes = excel.encode();
        if (bytes != null) {
          final content = base64Encode(bytes);
          final anchor = html.AnchorElement(
              href: "data:application/octet-stream;charset=utf-16le;base64,$content")
            ..setAttribute("download", "Template_Mapel.xlsx")
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
        fileName: 'Template_Mapel.xlsx',
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

  void _processPreview(FilePickerResult result, Function(void Function()) setDialogState) {
    final bytes = result.files.single.bytes;
    if (bytes == null) return;

    try {
      final excel = excel_pkg.Excel.decodeBytes(bytes);
      List<Subject> tempSubjects = [];

      for (var table in excel.tables.keys) {
        final rows = excel.tables[table]?.rows;
        if (rows == null || rows.length < 2) continue;

        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.isEmpty || row[0] == null) continue;

          final kode = row[0]?.value?.toString() ?? '';
          final nama = row[1]?.value?.toString() ?? '';
          final kkm = int.tryParse(row[2]?.value?.toString() ?? '75') ?? 75;

          if (nama.isNotEmpty) {
            tempSubjects.add(Subject(id: '', code: kode, name: nama, kkm: kkm));
          }
        }
      }

      setDialogState(() {
        _previewSubjects = tempSubjects;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membaca file: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _saveImportedSubjects() async {
    if (_previewSubjects.isEmpty) return;

    Navigator.pop(context); // Tutup dialog preview
    await safeCall(
      context: context,
      successMessage: 'Berhasil mengimpor ${_previewSubjects.length} Mata Pelajaran!',
      action: () async {
        final service = ref.read(masterServiceProvider);
        for (var s in _previewSubjects) {
          await service.addSubject(s);
        }
        ref.invalidate(allSubjectsProvider);
        setState(() {
          _previewSubjects = [];
        });
      },
    );
  }

  void _showImportDialog() {
    FilePickerResult? selectedResult;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Import Mata Pelajaran (Bulk)', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_previewSubjects.isEmpty)
                  InkWell(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['xlsx', 'xls', 'csv'],
                      );
                      if (result != null) {
                        _processPreview(result, setDialogState);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.brown.shade400),
                          const SizedBox(height: 12),
                          const Text('Klik untuk memilih file Excel', 
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  const Text('Preview Data (Mohon periksa kembali):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: ListView.separated(
                      itemCount: _previewSubjects.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = _previewSubjects[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(backgroundColor: Colors.brown.shade100, child: Text(s.code ?? '?', style: const TextStyle(fontSize: 10, color: Colors.brown))),
                          title: Text(s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: Text('KKM: ${s.kkm}', style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Total: ${_previewSubjects.length} Mata Pelajaran', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() => _previewSubjects = []);
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            if (_previewSubjects.isNotEmpty)
              ElevatedButton(
                onPressed: _saveImportedSubjects,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                child: const Text('Simpan Sekarang'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(allSubjectsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Data Master Mata Pelajaran',
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
                    icon: const Icon(Icons.add_box_outlined),
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
                const Text('Daftar Kurikulum & Mata Pelajaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                subjectsAsync.when(
                  data: (subjects) {
                    if (subjects.isEmpty) {
                      return const Center(child: Text('Belum ada data mata pelajaran'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                        columns: const [
                          DataColumn(label: Text('Kode', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Nama Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('KKM', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: subjects.map((s) => _buildMapelRow(s)).toList(),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildMapelRow(Subject subject) {
    return DataRow(
      cells: [
        DataCell(Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(4)),
            child: Text(subject.code ?? '-', style: TextStyle(color: Colors.brown.shade800, fontWeight: FontWeight.bold)),
        )),
        DataCell(Text(subject.name)),
        DataCell(Text(subject.kkm.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () => _showAddDialog(subject: subject)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _deleteSubject(subject)),
            ],
          ),
        ),
      ],
    );
  }
}
