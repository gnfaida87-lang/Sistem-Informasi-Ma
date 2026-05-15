import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../services/bimbel_service.dart';
import '../../../core/network/d1_service.dart';

class BimbelMateriScreen extends StatefulWidget {
  final String title;
  final String? programId;

  const BimbelMateriScreen({super.key, required this.title, this.programId});

  @override
  State<BimbelMateriScreen> createState() => _BimbelMateriScreenState();
}

class _BimbelMateriScreenState extends State<BimbelMateriScreen> {
  final _service        = BimbelService();
  final _linkController = TextEditingController();
  final _judulController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  bool _isSaving  = false;

  // Tentukan tipe berdasarkan judul
  String get _type {
    final t = widget.title.toLowerCase();
    if (t.contains('zoom') || t.contains('meet')) return 'zoom';
    if (t.contains('youtube') || t.contains('video')) return 'youtube';
    if (t.contains('cbt') || t.contains('latihan')) return 'cbt';
    if (t.contains('arsip')) return 'arsip';
    if (t.contains('upload') || t.contains('drive')) return 'drive';
    return 'link';
  }

  IconData get _typeIcon {
    switch (_type) {
      case 'zoom':    return Icons.video_call;
      case 'youtube': return Icons.play_circle;
      case 'cbt':     return Icons.quiz;
      case 'arsip':   return Icons.archive;
      case 'drive':   return Icons.cloud;
      default:        return Icons.link;
    }
  }

  Color get _typeColor {
    switch (_type) {
      case 'zoom':    return Colors.blue.shade700;
      case 'youtube': return Colors.red.shade700;
      case 'cbt':     return Colors.orange.shade700;
      case 'arsip':   return Colors.grey.shade700;
      case 'drive':   return Colors.green.shade700;
      default:        return Colors.purple.shade700;
    }
  }

  String get _hintText {
    switch (_type) {
      case 'zoom':    return 'https://zoom.us/j/... atau meet.google.com/...';
      case 'youtube': return 'https://youtube.com/watch?v=...';
      case 'drive':   return 'https://drive.google.com/...';
      default:        return 'Masukkan URL atau konten';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMateri();
  }

  @override
  void dispose() {
    _linkController.dispose();
    _judulController.dispose();
    super.dispose();
  }

  Future<void> _loadMateri() async {
    if (widget.programId == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final items = await _service.fetchMateri(widget.programId!, type: _type);
      setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMateri() async {
    if (_judulController.text.trim().isEmpty || _linkController.text.trim().isEmpty) {
      _showSnack('Judul dan link wajib diisi');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _service.saveMateri(
        programId: widget.programId ?? '',
        type: _type,
        judul: _judulController.text.trim(),
        url: _linkController.text.trim(),
      );
      _judulController.clear();
      _linkController.clear();
      await _loadMateri();
      _showSnack('Berhasil disimpan!', success: true);
    } catch (e) {
      _showSnack('Gagal menyimpan: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() => _isSaving = true);
      final file = result.files.first;
      
      try {
        final d1 = D1Service();
        final uploadResult = await d1.uploadFile(
          file.bytes!,
          file.name,
        );

        if (uploadResult['success'] == true) {
          setState(() {
            _linkController.text = uploadResult['fileUrl'] ?? '';
            if (_judulController.text.isEmpty) {
              _judulController.text = file.name;
            }
          });
          if (mounted) _showSnack('File berhasil diunggah ke Drive!', success: true);
        } else {
          if (mounted) _showSnack('Gagal mengunggah: ${uploadResult['message']}');
        }
      } catch (e) {
        if (mounted) _showSnack('Gagal mengunggah: $e');
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Tidak bisa membuka link');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('Disalin ke clipboard!', success: true);
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        backgroundColor: _typeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              // Form input
              Container(
                color: _typeColor.withOpacity(0.05),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  TextField(
                    controller: _judulController,
                    decoration: InputDecoration(
                      labelText: 'Judul / Nama',
                      hintText: 'Contoh: Latihan Soal Bab 3',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      prefixIcon: Icon(_typeIcon, color: _typeColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      labelText: 'URL / Link',
                      hintText: _hintText,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      prefixIcon: const Icon(Icons.link, color: Colors.grey),
                      suffixIcon: _type == 'drive' 
                        ? IconButton(
                            icon: const Icon(Icons.file_upload_outlined, color: Colors.green),
                            onPressed: _isSaving ? null : _pickFile,
                            tooltip: 'Unggah File ke Drive',
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveMateri,
                      icon: _isSaving
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save, size: 18),
                      label: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _typeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ]),
              ),

              const Divider(height: 1),

              // List materi
              Expanded(
                child: _items.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_typeIcon, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('Belum ada ${widget.title}',
                            style: TextStyle(color: Colors.grey.shade500)),
                        const Text('Tambahkan menggunakan form di atas',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildMateriTile(item);
                        },
                      ),
              ),
            ]),
    );
  }

  Widget _buildMateriTile(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_typeIcon, color: _typeColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['judul'] ?? item['title'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(item['url'] ?? '-',
              style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (item['created_at'] != null)
            Text(item['created_at'].toString().split('T')[0],
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ])),
        PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'open') _openUrl(item['url'] ?? '');
            if (val == 'copy') _copyToClipboard(item['url'] ?? '');
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'open',
                child: Row(children: [Icon(Icons.open_in_new, size: 16), SizedBox(width: 8), Text('Buka Link')])),
            const PopupMenuItem(value: 'copy',
                child: Row(children: [Icon(Icons.copy, size: 16), SizedBox(width: 8), Text('Salin Link')])),
          ],
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
        ),
      ]),
    );
  }
}
