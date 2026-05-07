import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/wali_kelas_service.dart';
import '../../../core/mixins/safe_async_mixin.dart';

class WaliKelasDataSiswaScreen extends StatefulWidget {
  final String classId;
  final String className;

  const WaliKelasDataSiswaScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<WaliKelasDataSiswaScreen> createState() => _WaliKelasDataSiswaScreenState();
}

class _WaliKelasDataSiswaScreenState extends State<WaliKelasDataSiswaScreen> with SafeAsync {
  final _waliKelasService = WaliKelasService();
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _waliKelasService.fetchStudentsWithParents(widget.classId);
        setState(() => _students = data);
      },
    );
  }

  void _launchWhatsApp(String? phone, String studentName) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor WhatsApp orang tua tidak tersedia')),
      );
      return;
    }

    final message = 'Assalamu\'alaikum, saya Wali Kelas dari $studentName...';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Data Siswa ${widget.className}'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2B3674),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    final parentName = student['parent_name'] ?? 'Tidak terdata';
                    final parentPhone = student['parent_phone'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text('${index + 1}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(student['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                        subtitle: Text('NIS: ${student['nis'] ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                _buildDetailItem(Icons.person_outline, 'Nama Orang Tua', parentName),
                                _buildDetailItem(Icons.phone_android, 'WhatsApp Ortu', parentPhone ?? 'Tidak terdata'),
                                const SizedBox(height: 16),
                                if (parentPhone != null && parentPhone.toString().isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _launchWhatsApp(parentPhone.toString(), student['name'] ?? ''),
                                      icon: const Icon(Icons.message, size: 18),
                                      label: const Text('Hubungi Orang Tua'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Belum ada data siswa di kelas ini', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
