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

  Future<void> _processMassUpload(FilePickerResult result) async {
    Navigator.pop(context); // Tutup dialog
    await safeCall(
      context: context,
      successMessage: 'Berhasil import Mata Pelajaran!',
      action: () async {
        // LOGIKA UNTUK INSERT KE SUPABASE DARI FILE EXCEL / CSV BISA DITAMBAHKAN DI SINI
        await Future.delayed(const Duration(seconds: 2)); // Simulasi
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
                    setDialogState(() {
                      selectedResult = result;
                    });
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
                      if (selectedResult == null) ...[
                        const SizedBox(height: 4),
                        Text('Maksimal 5MB (.xlsx, .csv)', 
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
