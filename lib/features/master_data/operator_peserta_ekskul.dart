import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorPesertaEkskul extends ConsumerStatefulWidget {
  const OperatorPesertaEkskul({super.key});

  @override
  ConsumerState<OperatorPesertaEkskul> createState() => _OperatorPesertaEkskulState();
}

class _OperatorPesertaEkskulState extends ConsumerState<OperatorPesertaEkskul> with SafeAsync<OperatorPesertaEkskul> {
  String? _selectedEkskulId;

  void _showAddStudentDialog() {
    if (_selectedEkskulId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ekskul terlebih dahulu')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _StudentSelectionDialog(
        ekskulId: _selectedEkskulId!,
        onSuccess: () => ref.invalidate(ekskulParticipantsProvider(_selectedEkskulId!)),
      ),
    );
  }

  void _removeParticipant(EkskulParticipant participant) {
    safeCall(
      context: context,
      successMessage: 'Peserta berhasil dihapus',
      action: () async {
        await ref.read(masterServiceProvider).removeEkskulParticipant(participant.id);
        ref.invalidate(ekskulParticipantsProvider(_selectedEkskulId!));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ekskulAsync = ref.watch(allEkskulProvider);
    final participantsAsync = _selectedEkskulId != null 
        ? ref.watch(ekskulParticipantsProvider(_selectedEkskulId!)) 
        : const AsyncValue.data(<EkskulParticipant>[]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Peserta Ekstrakurikuler',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ekskulAsync.when(
                  data: (list) => DropdownButtonFormField<String>(
                    value: _selectedEkskulId,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Program Ekskul',
                      border: OutlineInputBorder(),
                    ),
                    items: list.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                    onChanged: (val) => setState(() => _selectedEkskulId = val),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _selectedEkskulId == null ? null : _showAddStudentDialog,
                icon: const Icon(Icons.group_add),
                label: const Text('Tambah Peserta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
            ),
            child: participantsAsync.when(
              data: (list) {
                if (_selectedEkskulId == null) {
                  return const Center(child: Text('Silakan pilih ekskul terlebih dahulu'));
                }
                if (list.isEmpty) {
                  return const Center(child: Text('Belum ada peserta di ekskul ini'));
                }
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('NIS')),
                    DataColumn(label: Text('Nama Siswa')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: list.map((p) => DataRow(cells: [
                    DataCell(Text(p.student?.nis ?? '-')),
                    DataCell(Text(p.student?.name ?? '-')),
                    DataCell(IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeParticipant(p),
                    )),
                  ])).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentSelectionDialog extends ConsumerStatefulWidget {
  final String ekskulId;
  final VoidCallback onSuccess;

  const _StudentSelectionDialog({required this.ekskulId, required this.onSuccess});

  @override
  ConsumerState<_StudentSelectionDialog> createState() => _StudentSelectionDialogState();
}

class _StudentSelectionDialogState extends ConsumerState<_StudentSelectionDialog> with SafeAsync<_StudentSelectionDialog> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);

    return AlertDialog(
      title: const Text('Pilih Siswa'),
      content: SizedBox(
        width: 400,
        height: 500,
        child: studentsAsync.when(
          data: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final student = list[index];
              return CheckboxListTile(
                title: Text(student.name),
                subtitle: Text(student.nis),
                value: _selectedIds.contains(student.id),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedIds.add(student.id);
                    } else {
                      _selectedIds.remove(student.id);
                    }
                  });
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: _selectedIds.isEmpty ? null : () {
            Navigator.pop(context);
            safeCall(
              context: context,
              successMessage: 'Peserta berhasil ditambahkan',
              action: () async {
                final service = ref.read(masterServiceProvider);
                for (final id in _selectedIds) {
                  await service.addEkskulParticipant(widget.ekskulId, id);
                }
                widget.onSuccess();
              },
            );
          },
          child: Text('Tambah ${_selectedIds.length} Siswa'),
        ),
      ],
    );
  }
}
