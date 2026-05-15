import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorPesertaBimbel extends ConsumerStatefulWidget {
  const OperatorPesertaBimbel({super.key});

  @override
  ConsumerState<OperatorPesertaBimbel> createState() => _OperatorPesertaBimbelState();
}

class _OperatorPesertaBimbelState extends ConsumerState<OperatorPesertaBimbel> with SafeAsync<OperatorPesertaBimbel> {
  String? _selectedBimbelId;

  void _showSelectStudentDialog() {
    if (_selectedBimbelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih program bimbel terlebih dahulu')),
      );
      return;
    }

    final Set<String> selectedIds = {};
    String dialogSearchQuery = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pilih Peserta Bimbel', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: SizedBox(
            width: 600,
            height: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Nama Siswa atau NIS...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) {
                    setDialogState(() {
                      dialogSearchQuery = val.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Text('Pilih satu atau beberapa siswa sekaligus', 
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                const Divider(),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final studentsAsync = ref.watch(allStudentsProvider);
                      return studentsAsync.when(
                        data: (students) {
                          final filtered = students.where((s) => 
                            s.name.toLowerCase().contains(dialogSearchQuery) || 
                            s.nis.contains(dialogSearchQuery)
                          ).toList();

                          if (filtered.isEmpty) {
                            return const Center(child: Text('Siswa tidak ditemukan'));
                          }

                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final s = filtered[index];
                              return CheckboxListTile(
                                title: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                subtitle: Text('${s.nis} | ${s.classId ?? "Tanpa Kelas"}', style: const TextStyle(fontSize: 12)),
                                value: selectedIds.contains(s.id),
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == true) {
                                      selectedIds.add(s.id);
                                    } else {
                                      selectedIds.remove(s.id);
                                    }
                                  });
                                },
                                activeColor: Colors.brown,
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                      );
                    },
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
              onPressed: selectedIds.isEmpty ? null : () {
                Navigator.pop(context);
                safeCall(
                  context: context,
                  successMessage: 'Peserta Berhasil Ditambahkan',
                  action: () async {
                    final service = ref.read(masterServiceProvider);
                    for (final studentId in selectedIds) {
                      await service.addBimbelParticipant(_selectedBimbelId!, studentId);
                    }
                    ref.invalidate(bimbelParticipantsProvider(_selectedBimbelId!));
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade600, foregroundColor: Colors.white),
              child: Text('Tambahkan (${selectedIds.length}) Siswa'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bimbelListAsync = ref.watch(allBimbelProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Peserta & Akun Bimbel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showSelectStudentDialog,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Tambah Peserta Baru'),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.brown),
                const SizedBox(width: 12),
                const Text('Pilih Program Bimbel:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                bimbelListAsync.when(
                  data: (list) {
                    if (list.isEmpty) return const Text('Belum ada program bimbel');
                    return DropdownButton<String>(
                      value: _selectedBimbelId ?? (list.isNotEmpty ? list.first.id : null),
                      underline: const SizedBox(),
                      items: list.map((p) => 
                        DropdownMenuItem(value: p.id, child: Text(p.name, style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)))
                      ).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedBimbelId = val;
                        });
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (_selectedBimbelId != null)
            Consumer(
              builder: (context, ref, child) {
                final participantsAsync = ref.watch(bimbelParticipantsProvider(_selectedBimbelId!));
                return Container(
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
                      const Text('Daftar Peserta Bimbel', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                      const SizedBox(height: 16),
                      participantsAsync.when(
                        data: (participants) {
                          if (participants.isEmpty) {
                            return const Center(child: Text('Belum ada peserta di program ini'));
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                              columns: const [
                                DataColumn(label: Text('NIS', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: participants.map((p) => DataRow(
                                cells: [
                                  DataCell(Text(p.student?.nis ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(p.student?.name ?? '-')),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.person_remove_outlined, color: Colors.red, size: 18), 
                                      onPressed: () => _removeParticipant(p),
                                    ),
                                  ),
                                ],
                              )).toList(),
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
            ),
        ],
      ),
    );
  }

  void _removeParticipant(BimbelParticipant participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Peserta?'),
        content: Text('Keluarkan ${participant.student?.name} dari program ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Peserta Berhasil Dikeluarkan',
                action: () async {
                  await ref.read(masterServiceProvider).removeBimbelParticipant(participant.id);
                  ref.invalidate(bimbelParticipantsProvider(_selectedBimbelId!));
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
}
