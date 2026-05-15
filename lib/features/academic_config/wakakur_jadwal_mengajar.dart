import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/academic_provider.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/teaching_schedule_pdf_helper.dart';
import 'models/scheduling_models.dart';
import 'models/academic_models.dart';
import 'models/school_models.dart';
import '../../shared/models/guru.dart';

class WakakurJadwalMengajar extends ConsumerStatefulWidget {
  const WakakurJadwalMengajar({super.key});

  @override
  ConsumerState<WakakurJadwalMengajar> createState() => _WakakurJadwalMengajarState();
}

class _WakakurJadwalMengajarState extends ConsumerState<WakakurJadwalMengajar> with SafeAsync {
  String _selectedDay = 'Senin';
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  
  String? _selectedSemesterId;
  String _selectedLevel = 'X';
  final List<String> _levels = ['X', 'XI', 'XII'];
  
  String? _selectedClassId; // null means "Semua Kelas"
  List<Kelas> _classes = [];
  List<TimeSlot> _timeSlots = [];
  List<Guru> _teachers = [];
  List<Mapel> _subjects = [];
  
  // Format: "timeSlotId_classId" -> ScheduleRow
  Map<String, ScheduleRow> _currentSchedule = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMetadata();
    });
  }

  Future<void> _loadMetadata() async {
    await safeCall(
      context: context,
      action: () async {
        final scheduleService = ref.read(scheduleServiceProvider);
        
        _teachers = await scheduleService.getAllTeachers();
        _subjects = await scheduleService.getAllSubjects();
        
        await _loadContextualData();
      },
    );
  }

  Future<void> _loadContextualData() async {
    final scheduleService = ref.read(scheduleServiceProvider);
    final semesters = ref.read(semestersProvider).value ?? [];
    
    if (_selectedSemesterId == null && semesters.isNotEmpty) {
      _selectedSemesterId = semesters.firstWhere((s) => s.isActive, orElse: () => semesters.first).id;
    }

    _classes = await scheduleService.getClassesByLevel(_selectedLevel);
    
    // Reset selected class if not in current level
    if (_selectedClassId != null && !_classes.any((c) => c.id == _selectedClassId)) {
      _selectedClassId = null;
    }
    _timeSlots = await scheduleService.getTimeSlots(_selectedDay);
    
    if (_selectedSemesterId != null && _classes.isNotEmpty) {
      final classIds = _classes.map((c) => c.id).toList();
      final schedules = await scheduleService.getSchedules(_selectedSemesterId!, classIds, _selectedDay);
      
      _currentSchedule = {};
      for (var s in schedules) {
        _currentSchedule['${s.timeSlotId}_${s.classId}'] = s;
      }
    }
    setState(() {});
  }

  Future<void> _handlePlotting(TimeSlot slot, Kelas kelas, Guru guru, Mapel subject) async {
    if (_selectedSemesterId == null) return;

    // Check teacher conflict (already teaching elsewhere at same time)
    bool isConflict = false;
    String conflictClass = '';
    
    _currentSchedule.forEach((key, value) {
      if (key.startsWith('${slot.id}_') && value.teacherId == guru.id) {
        isConflict = true;
        final cId = key.split('_')[1];
        conflictClass = _classes.firstWhere((c) => c.id == cId, orElse: () => Kelas(id: '', nama: 'Lain')).nama;
      }
    });

    if (isConflict) {
      context.showErrorSnackBar('Bentrok! ${guru.nama} sudah ada di kelas $conflictClass');
      return;
    }

    await safeCall(
      context: context,
      action: () async {
        final service = ref.read(scheduleServiceProvider);
        await service.saveSchedule(
          _selectedSemesterId!,
          kelas.id,
          slot.id,
          guru.id,
          subject.id,
        );
        await _loadContextualData();
      },
      successMessage: 'Plotting ${guru.nama} berhasil',
    );
  }

  Future<void> _removePlotting(TimeSlot slot, Kelas kelas) async {
     if (_selectedSemesterId == null) return;
     await safeCall(
       context: context,
       action: () async {
         final service = ref.read(scheduleServiceProvider);
         await service.deleteSchedule(_selectedSemesterId!, kelas.id, slot.id);
         await _loadContextualData();
       },
     );
  }

  Future<void> _resetSchedule() async {
    if (_selectedSemesterId == null || _classes.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Jadwal?'),
        content: Text('Apakah Anda yakin ingin menghapus SELURUH jadwal untuk Level $_selectedLevel pada hari $_selectedDay?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Hapus Semua', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await safeCall(
        context: context,
        action: () async {
          final service = ref.read(scheduleServiceProvider);
          for (var kelas in _classes) {
             await service.deleteSchedulesByClassAndDay(_selectedSemesterId!, kelas.id, _selectedDay);
          }
          await _loadContextualData();
        },
        successMessage: 'Jadwal hari $_selectedDay berhasil direset!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final semesters = ref.watch(semestersProvider).value ?? [];

    return Column(
      children: [
        _buildHeader(semesters),
        if (isLoading && _timeSlots.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildTimetableGrid()),
                _buildInventorySidebar(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(List<Semester> semesters) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Jadwal (Pengendali Tunggal)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
               const Spacer(),
               if (_currentSchedule.isNotEmpty) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    final semesters = ref.read(semestersProvider).value ?? [];
                    final activeSem = semesters.firstWhere((s) => s.id == _selectedSemesterId, orElse: () => semesters.first);
                    
                    TeachingSchedulePdfHelper.generateAndPrint(
                      semesterName: '${activeSem.nama} ${activeSem.yearName}',
                      level: _selectedLevel,
                      day: _selectedDay,
                      classes: _classes.where((c) => _selectedClassId == null || c.id == _selectedClassId).toList(),
                      timeSlots: _timeSlots,
                      scheduleData: _currentSchedule,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('Cetak PDF', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _resetSchedule,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.red),
                  label: const Text('Reset Hari Ini', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
               ],
               const SizedBox(width: 8),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                 decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                 child: Row(
                   children: [
                     Icon(Icons.cloud_done, size: 14, color: Colors.green.shade700),
                     const SizedBox(width: 4),
                     Text('Tersimpan', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                   ],
                 ),
               ),
               const SizedBox(width: 16),
               _buildFilterDropdown('Semester', _selectedSemesterId, semesters.map((s) => 
                 DropdownMenuItem(value: s.id, child: Text('${s.nama} ${s.yearName}', style: const TextStyle(fontSize: 12)))).toList(), 
                 (val) {
                   setState(() => _selectedSemesterId = val);
                   _loadContextualData();
                 }
               ),
              const SizedBox(width: 12),
              _buildFilterDropdown('Level', _selectedLevel, _levels.map((l) => 
                DropdownMenuItem(value: l, child: Text('Kelas $l', style: const TextStyle(fontSize: 12)))).toList(), 
                (val) {
                  setState(() => _selectedLevel = val!);
                  _loadContextualData();
                }
              ),
               const SizedBox(width: 12),
               _buildFilterDropdown('Kelas', _selectedClassId, [
                 const DropdownMenuItem(value: null, child: Text('Semua Kelas', style: TextStyle(fontSize: 12))),
                 ..._classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nama, style: const TextStyle(fontSize: 12)))),
               ], 
               (val) {
                 setState(() => _selectedClassId = val);
               }),
               const SizedBox(width: 12),
               _buildFilterDropdown('Hari', _selectedDay, _days.map((d) => 
                 DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(), 
                 (val) {
                   setState(() => _selectedDay = val!);
                   _loadContextualData();
                 }
               ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading) const LinearProgressIndicator(color: Colors.teal),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, dynamic value, List<DropdownMenuItem<dynamic>> items, Function(dynamic) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: value,
              items: items,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 12, color: Color(0xFF2B3674), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableGrid() {
    if (_classes.isEmpty) return const Center(child: Text('Pilih level kelas untuk melihat jadwal.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowHeight: 50,
            dataRowMinHeight: 80,
            dataRowMaxHeight: 80,
            headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
            columns: [
              const DataColumn(label: Text('Waktu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ..._classes
                  .where((c) => _selectedClassId == null || c.id == _selectedClassId)
                  .map((c) => DataColumn(label: Container(width: 140, child: Center(child: Text(c.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))))),
            ],
            rows: _timeSlots.map((slot) {
              final filteredClasses = _classes.where((c) => _selectedClassId == null || c.id == _selectedClassId).toList();
              return DataRow(
                cells: [
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slot.isBreak ? 'ISTIRAHAT' : 'Jam Ke-${slot.slotNumber}', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: slot.isBreak ? Colors.orange : Colors.black)),
                      Text(slot.timeRange, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  )),
                  ...filteredClasses.map((kelas) {
                    if (slot.isBreak) {
                      return DataCell(Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.orange.shade50,
                        alignment: Alignment.center,
                        child: Text(slot.label ?? 'Break', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ));
                    }
                    
                    final key = '${slot.id}_${kelas.id}';
                    final assigned = _currentSchedule[key];

                    return DataCell(_buildDragTarget(slot, kelas, assigned));
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDragTarget(TimeSlot slot, Kelas kelas, ScheduleRow? assigned) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (data) => _handlePlotting(slot, kelas, data['guru'] as Guru, data['mapel'] as Mapel),
      builder: (context, candidateData, rejectedData) {
        final isCandidate = candidateData.isNotEmpty;
        return Container(
          width: 140,
          height: 64,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isCandidate ? Colors.teal.shade50 : (assigned != null ? Colors.white : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: assigned != null ? Colors.teal.shade200 : (isCandidate ? Colors.teal : Colors.grey.shade100),
              width: isCandidate ? 2 : 1,
            ),
          ),
          child: assigned != null 
            ? Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(assigned.teacherName ?? '-', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(assigned.subjectName ?? '-', style: TextStyle(fontSize: 9, color: Colors.teal.shade700, fontWeight: FontWeight.w500), maxLines: 1),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0, top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, size: 16, color: Colors.redAccent),
                      onPressed: () => _removePlotting(slot, kelas),
                    ),
                  )
                ],
              )
            : const Center(child: Icon(Icons.add_rounded, size: 18, color: Colors.black12)),
        );
      },
    );
  }

  Widget _buildInventorySidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.teal.shade700,
            width: double.infinity,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inventori Plotting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                SizedBox(height: 4),
                Text('Drag Guru ke Jadwal', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: _subjects.isEmpty 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _subjects.length,
                  itemBuilder: (context, idx) {
                    final sub = _subjects[idx];
                    return ExpansionTile(
                      leading: const Icon(Icons.book_rounded, size: 20, color: Colors.teal),
                      title: Text(sub.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      children: _teachers.map((guru) => _buildDraggableTeacher(guru, sub)).toList(),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTeacher(Guru guru, Mapel subject) {
    return Draggable<Map<String, dynamic>>(
      data: {'guru': guru, 'mapel': subject},
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)],
            border: Border.all(color: Colors.teal),
          ),
          child: Text(guru.nama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_pin_rounded, size: 16, color: Colors.teal),
            const SizedBox(width: 10),
            Expanded(child: Text(guru.nama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
            const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
