import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/providers/master_provider.dart';
import 'models/master_models.dart';

class OperatorMasterKelas extends ConsumerStatefulWidget {
  const OperatorMasterKelas({super.key});

  @override
  ConsumerState<OperatorMasterKelas> createState() => _OperatorMasterKelasState();
}

class _OperatorMasterKelasState extends ConsumerState<OperatorMasterKelas> with SafeAsync<OperatorMasterKelas> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  String? _selectedWaliKelasId;

  void _showAddDialog({ClassRoom? classRoom}) {
    if (classRoom != null) {
      _nameController.text = classRoom.name;
      _capacityController.text = classRoom.kapasitas.toString();
      _selectedWaliKelasId = classRoom.waliKelasId;
    } else {
      _nameController.clear();
      _capacityController.clear();
      _selectedWaliKelasId = null;
    }

    final teachersAsync = ref.read(allTeachersProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classRoom == null ? 'Buat Rombel Baru' : 'Edit Rombel', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kelas',
                  hintText: 'Contoh: XII IPA 1',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              teachersAsync.when(
                data: (teachers) => DropdownButtonFormField<String>(
                  value: _selectedWaliKelasId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Wali Kelas',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person_pin_outlined),
                  ),
                  items: teachers.map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text(t.name),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedWaliKelasId = value),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Gagal mengambil data guru'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kapasitas Siswa',
                  hintText: 'Default: 35',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.groups_outlined),
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
              final name = _nameController.text;
              final kapasitas = int.tryParse(_capacityController.text) ?? 35;
              
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Data Berhasil Disimpan',
                action: () async {
                  final service = ref.read(masterServiceProvider);
                  final newClass = ClassRoom(
                    id: classRoom?.id ?? '',
                    name: name,
                    waliKelasId: _selectedWaliKelasId,
                    kapasitas: kapasitas,
                  );

                  if (classRoom == null) {
                    await service.addClass(newClass);
                  } else {
                    await service.updateClass(newClass);
                  }
                  ref.invalidate(allClassesProvider);
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

  void _deleteClass(ClassRoom classRoom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas?'),
        content: Text('Apakah Anda yakin ingin menghapus kelas ${classRoom.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              safeCall(
                context: context,
                successMessage: 'Kelas Berhasil Dihapus',
                action: () async {
                  await ref.read(masterServiceProvider).deleteClass(classRoom.id);
                  ref.invalidate(allClassesProvider);
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

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(allClassesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Data Master Kelas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(),
                icon: const Icon(Icons.meeting_room),
                label: const Text('Buat Rombel Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          classesAsync.when(
            data: (classes) {
              if (classes.isEmpty) {
                return const Center(child: Text('Belum ada data kelas'));
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                ),
                itemCount: classes.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final classRoom = classes[index];
                  return _buildClassCard(classRoom);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(ClassRoom classRoom) {
    final double percent = (classRoom.jumlahSiswa / classRoom.kapasitas).clamp(0.0, 1.0);
    final bool isFull = classRoom.jumlahSiswa >= classRoom.kapasitas;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isFull ? Colors.red.shade100 : Colors.grey.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(classRoom.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2B3674))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_pin, size: 14, color: Colors.brown.shade400),
                      const SizedBox(width: 4),
                      Text(classRoom.waliKelasNama ?? "Wali Kelas Belum Diatur", 
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'delete') {
                    _deleteClass(classRoom);
                  } else if (val == 'edit') {
                    _showAddDialog(classRoom: classRoom);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 8), Text('Edit Rombel')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus Rombel')])),
                ],
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.more_vert, color: Colors.grey.shade500, size: 20),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${classRoom.jumlahSiswa} / ${classRoom.kapasitas} Siswa', 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isFull ? Colors.red : Colors.green.shade700)
              ),
              if (isFull)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                  child: const Text('PENUH', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade100,
              color: isFull ? Colors.red : (percent > 0.8 ? Colors.orange : Colors.green),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
