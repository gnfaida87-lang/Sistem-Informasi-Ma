import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorMasterEkskul extends ConsumerStatefulWidget {
  const OperatorMasterEkskul({super.key});

  @override
  ConsumerState<OperatorMasterEkskul> createState() => _OperatorMasterEkskulState();
}

class _OperatorMasterEkskulState extends ConsumerState<OperatorMasterEkskul> with SafeAsync<OperatorMasterEkskul> {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _pembinaCtrl = TextEditingController();

  void _showAddDialog({Extracurricular? ekskul}) {
    String? selectedCoachId = ekskul?.coach;
    if (ekskul != null) {
      _namaCtrl.text = ekskul.name;
    } else {
      _namaCtrl.clear();
      selectedCoachId = null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(ekskul == null ? 'Tambah Ekstrakurikuler Baru' : 'Edit Ekstrakurikuler', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Ekskul',
                  hintText: 'Contoh: Pramuka, PMR, Futsal',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final teachersAsync = ref.watch(allTeachersProvider);
                  return teachersAsync.when(
                    data: (teachers) => DropdownButtonFormField<String>(
                      value: selectedCoachId,
                      decoration: InputDecoration(
                        labelText: 'Pilih Pembina',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person_pin_outlined),
                      ),
                      items: teachers.map((t) => DropdownMenuItem(
                        value: t.name, // Kita gunakan nama dulu untuk kemudahan display
                        child: Text(t.name),
                      )).toList(),
                      onChanged: (value) => setDialogState(() => selectedCoachId = value),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Gagal mengambil data guru'),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final nama = _namaCtrl.text;
                final pembina = selectedCoachId;

                Navigator.pop(context);
                safeCall(
                  context: context,
                  successMessage: 'Data Berhasil Disimpan',
                  action: () async {
                    final service = ref.read(masterServiceProvider);
                    final newEkskul = Extracurricular(
                      id: ekskul?.id ?? '',
                      name: nama,
                      coach: pembina,
                    );

                    if (ekskul == null) {
                      await service.addEkskul(newEkskul);
                    } else {
                      await service.updateEkskul(newEkskul);
                    }
                    ref.invalidate(allEkskulProvider);
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

  void _showDeleteDialog(Extracurricular ekskul) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Apakah Anda yakin ingin menghapus Ekstrakurikuler "${ekskul.name}"?'),
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
                successMessage: 'Data Ekstrakurikuler Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteEkskul(ekskul.id);
                  ref.invalidate(allEkskulProvider);
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _manageMembers(Extracurricular ekskul) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Anggota: ${ekskul.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: SizedBox(
            width: 500,
            height: 600,
            child: Column(
              children: [
                // Pencarian Siswa Baru
                Consumer(
                  builder: (context, ref, child) {
                    final studentsAsync = ref.watch(allStudentsProvider);
                    return studentsAsync.when(
                      data: (students) => Autocomplete<Student>(
                        displayStringForOption: (s) => "${s.nis} - ${s.name}",
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty) return const Iterable<Student>.empty();
                          return students.where((s) => 
                            s.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) || 
                            s.nis.contains(textEditingValue.text)
                          );
                        },
                        onSelected: (student) async {
                          await safeCall(
                            context: context,
                            successMessage: 'Siswa berhasil ditambahkan',
                            action: () async {
                              await ref.read(masterServiceProvider).addEkskulParticipant(ekskul.id, student.id);
                              setDialogState(() {}); // Refresh list
                            },
                          );
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) => TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Cari Nama Siswa atau NISN...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: const Icon(Icons.add_circle, color: Colors.blue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Gagal memuat data siswa'),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Divider(),
                const Text('Daftar Anggota Saat Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<EkskulParticipant>>(
                    future: ref.read(masterServiceProvider).fetchEkskulParticipants(ekskul.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final members = snapshot.data ?? [];
                      if (members.isEmpty) {
                        return const Center(child: Text('Belum ada anggota', style: TextStyle(color: Colors.grey)));
                      }
                      return ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final m = members[index];
                          return ListTile(
                            title: Text(m.student?.name ?? 'Siswa Tidak Dikenal', style: const TextStyle(fontSize: 14)),
                            subtitle: Text('NISN: ${m.student?.nis ?? "-"}', style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                              onPressed: () async {
                                await safeCall(
                                  context: context,
                                  successMessage: 'Siswa dihapus dari ekskul',
                                  action: () async {
                                    await ref.read(masterServiceProvider).removeEkskulParticipant(m.id);
                                    setDialogState(() {}); // Refresh list
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ekskulAsync = ref.watch(allEkskulProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Master Ekstrakurikuler',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(),
                    icon: const Icon(Icons.add),
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
                const Text('Daftar Kegiatan Ekstrakurikuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                ekskulAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(child: Text('Belum ada data ekskul'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                        columns: const [
                          DataColumn(label: Text('Nama Ekskul', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Pembina', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: list.map((e) => _buildDataRow(e)).toList(),
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

  DataRow _buildDataRow(Extracurricular ekskul) {
    return DataRow(
      cells: [
        DataCell(Text(ekskul.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(ekskul.coach ?? '-')),
        DataCell(
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _manageMembers(ekskul),
                icon: const Icon(Icons.people_outline, size: 18),
                label: const Text('Anggota', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.indigo),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 18), 
                tooltip: 'Edit Ekskul',
                onPressed: () => _showAddDialog(ekskul: ekskul),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), 
                tooltip: 'Hapus Ekskul',
                onPressed: () => _showDeleteDialog(ekskul),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
