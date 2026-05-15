import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/exam_schedule_pdf_helper.dart';

class WakakurJadwalUjian extends StatefulWidget {
  const WakakurJadwalUjian({super.key});

  @override
  State<WakakurJadwalUjian> createState() => _WakakurJadwalUjianState();
}

class _WakakurJadwalUjianState extends State<WakakurJadwalUjian> {
  final _d1Service = D1Service();
  bool _isSaving = false;
  String _selectedExamType = 'PAS (Penilaian Akhir Semester)';
  final TextEditingController _examNameController = TextEditingController(text: 'Penilaian Akhir Semester 2025');
  String _selectedDate = 'Hari Ke-1';
  String _selectedSemester = 'Ganjil';
  String _selectedClassLevel = 'X';
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  
  List<String> _dates = ['Hari Ke-1'];

  List<String> _rooms = ['Ruang 01', 'Ruang 02', 'Ruang 03', 'Ruang 04'];
  
  List<Map<String, String>> _sessions = [
    {'sesi': 'Sesi 1', 'waktu': '07:30 - 09:30'},
    {'sesi': 'Sesi 2', 'waktu': '10:00 - 12:00'},
    {'sesi': 'Sesi 3', 'waktu': '13:00 - 15:00'},
  ];

  final List<Map<String, String>> _examSubjects = [];

  final Map<String, Map<String, String>> _examSchedule = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _ensureTableExists();
    await _fetchInventory();
    await _fetchExistingSchedules();
  }

  Future<void> _ensureTableExists() async {
    try {
      const sql = """
        CREATE TABLE IF NOT EXISTS exam_schedules (
          id TEXT PRIMARY KEY,
          exam_type TEXT,
          exam_name TEXT,
          semester TEXT,
          class_level TEXT,
          date_label TEXT,
          session_name TEXT,
          time_range TEXT,
          room_name TEXT,
          subject_name TEXT,
          supervisor_name TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      """;
      await _d1Service.query(sql);
    } catch (e) {
      debugPrint("Error ensureTableExists: $e");
    }
  }

  Future<void> _fetchInventory() async {
    try {
      final gurus = await _d1Service.query("SELECT nama FROM teachers WHERE is_active = 1 ORDER BY nama");
      final mapels = await _d1Service.query("SELECT nama FROM subjects ORDER BY nama");
      
      setState(() {
        _examSubjects.clear();
        for (var m in (mapels as List)) {
          // We don't want cross join here, just show available subjects.
          // For now, let's just use the first teacher as default or let user choose?
          // Actually, the UI expects a Map<String, String> with 'mapel' and 'pengawas'.
          // I'll just map subjects and pick a default pengawas if available.
          String defaultPengawas = gurus.isNotEmpty ? gurus[0]['nama'].toString() : '-';
          _examSubjects.add({
            'mapel': m['nama'].toString(),
            'pengawas': defaultPengawas,
          });
        }
      });
    } catch (e) {
      debugPrint("Error fetch inventory: $e");
    }
  }

  Future<void> _fetchExistingSchedules() async {
    try {
      final results = await _d1Service.query(
        "SELECT * FROM exam_schedules WHERE exam_type = ? AND semester = ? AND class_level = ?",
        params: [_selectedExamType, _selectedSemester, _selectedClassLevel],
      );

      setState(() {
        _examSchedule.clear();
        for (var row in results) {
          // Find session index
          int sessionIdx = _sessions.indexWhere((s) => s['sesi'] == row['session_name']);
          if (sessionIdx == -1) {
            // Add session if not exists
            _sessions.add({'sesi': row['session_name'], 'waktu': row['time_range']});
            sessionIdx = _sessions.length - 1;
          }

          // Add date if not exists
          if (!_dates.contains(row['date_label'])) {
            _dates.add(row['date_label']);
          }

          // Add room if not exists
          if (!_rooms.contains(row['room_name'])) {
            _rooms.add(row['room_name']);
          }

          String key = '${row['date_label']}_${sessionIdx}_${row['room_name']}';
          _examSchedule[key] = {
            'mapel': row['subject_name'],
            'pengawas': row['supervisor_name'],
          };
          
          if (row['exam_name'] != null) {
            _examNameController.text = row['exam_name'];
          }
        }
      });
    } catch (e) {
      debugPrint("Error fetchExistingSchedules: $e");
    }
  }

  Future<void> _savePlotting() async {
    if (_examSchedule.isEmpty) {
      context.showErrorSnackBar('Jadwal masih kosong!');
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Hapus jadwal lama untuk ujian/semester/level ini (agar tidak duplikat)
      await _d1Service.query(
        "DELETE FROM exam_schedules WHERE exam_type = ? AND semester = ? AND class_level = ?",
        params: [_selectedExamType, _selectedSemester, _selectedClassLevel],
      );

      // Simpan jadwal baru
      for (var entry in _examSchedule.entries) {
        final keyParts = entry.key.split('_'); // date_session_room
        final dateLabel = keyParts[0];
        final sessionIdx = int.parse(keyParts[1]);
        final roomName = keyParts[2];
        final session = _sessions[sessionIdx];

        await _d1Service.query(
          """
          INSERT INTO exam_schedules 
          (id, exam_type, exam_name, semester, class_level, date_label, session_name, time_range, room_name, subject_name, supervisor_name) 
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          """,
          params: [
            "ex_${DateTime.now().millisecondsSinceEpoch}_${entry.key}",
            _selectedExamType,
            _examNameController.text,
            _selectedSemester,
            _selectedClassLevel,
            dateLabel,
            session['sesi'],
            session['waktu'],
            roomName,
            entry.value['mapel'],
            entry.value['pengawas'],
          ],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal Ujian BERHASIL DISIMPAN & SINKRON ke database!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      context.showErrorSnackBar('Gagal menyimpan: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _handleDrop(String room, int sessionIndex, Map<String, String> exam) {
    // Conflict check: Is this supervisor already in another room during this session?
    bool hasConflict = false;
    String conflictingRoom = '';

    for (var otherRoom in _rooms) {
      if (otherRoom == room) continue;
      String key = '${_selectedDate}_${sessionIndex}_$otherRoom';
      if (_examSchedule[key]?['pengawas'] == exam['pengawas']) {
        hasConflict = true;
        conflictingRoom = otherRoom;
        break;
      }
    }

    if (hasConflict) {
      _showConflictWarning(exam['pengawas']!, conflictingRoom, _sessions[sessionIndex]['sesi']!);
    } else {
      setState(() {
        String key = '${_selectedDate}_${sessionIndex}_$room';
        _examSchedule[key] = exam;
      });
    }
  }

  void _showConflictWarning(String name, String room, String session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Konflik Pengawas!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('$name sudah dijadwalkan mengawas di **$room** pada **$session**. \n\nSatu pengawas tidak dapat mengawasi dua ruangan sekaligus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _mainScrollController,
      child: Column(
        children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Manajemen Jadwal Ujian',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Icon(Icons.sync, size: 14, color: Colors.teal.shade700),
                        const SizedBox(width: 4),
                        Text('Synced with Master Data', style: TextStyle(fontSize: 10, color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.shade200)),
                    child: DropdownButton<String>(
                      value: _selectedExamType,
                      underline: const SizedBox(),
                      items: ['PAS (Penilaian Akhir Semester)', 'PTS (Penilaian Tengah Semester)', 'Ujian Madrasah (UM)', 'Custom']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        setState(() => _selectedExamType = val!);
                        _fetchExistingSchedules();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // MANUAL CONFIG ROW
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nama Ujian (Manual)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              TextField(
                                controller: _examNameController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: UnderlineInputBorder(),
                                  hintText: 'Input nama ujian...',
                                  hintStyle: TextStyle(fontSize: 13),
                                ),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Semester', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              DropdownButton<String>(
                                value: _selectedSemester,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: ['Ganjil', 'Genap'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedSemester = val!);
                                  _fetchExistingSchedules();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Level Kelas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                               DropdownButton<String>(
                                value: _selectedClassLevel,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: ['X', 'XI', 'XII'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedClassLevel = val!);
                                  _fetchExistingSchedules();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Pilih Tanggal Ujian:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 12),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _dates.map((d) {
                              bool isSelected = _selectedDate == d;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(d, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black)),
                                  selected: isSelected,
                                  selectedColor: Colors.teal,
                                  onSelected: (val) => setState(() => _selectedDate = d),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                             String newDate = 'Hari Ke-${_dates.length + 1}';
                             _dates.add(newDate);
                             _selectedDate = newDate;
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah Tanggal', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade50, foregroundColor: Colors.teal.shade700),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_examSchedule.isEmpty) {
                            context.showErrorSnackBar('Jadwal masih kosong, tidak ada yang bisa dicetak.');
                            return;
                          }
                          ExamSchedulePdfHelper.generateAndPrint(
                            examName: _examNameController.text,
                            examType: _selectedExamType,
                            semester: _selectedSemester,
                            classLevel: _selectedClassLevel,
                            dates: _dates,
                            rooms: _rooms,
                            sessions: _sessions,
                            schedule: _examSchedule,
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Cetak PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _savePlotting,
                        icon: _isSaving 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload_outlined),
                        label: Text(_isSaving ? 'Menyimpan...' : 'Simpan & Sinkronkan'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // GRID JADWAL UJIAN & INVENTORY
        Container(
          height: 550, 
          margin: const EdgeInsets.only(top: 0),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                          columnSpacing: 20,
                          headingRowHeight: 50,
                          dataRowMinHeight: 80,
                          dataRowMaxHeight: 80,
                          headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                          border: TableBorder.all(color: Colors.grey.shade200),
                          columns: [
                            DataColumn(label: Row(
                              children: [
                                const Text('Sesi / Waktu', style: TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, size: 18, color: Colors.teal), 
                                  onPressed: () {
                                    setState(() {
                                      int nextSesi = _sessions.length + 1;
                                      _sessions.add({'sesi': 'Sesi $nextSesi', 'waktu': '00:00 - 00:00'});
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline, size: 16, color: Colors.red.shade300), 
                                  onPressed: () {
                                    if (_sessions.isNotEmpty) {
                                      setState(() {
                                        _sessions.removeLast();
                                      });
                                    }
                                  },
                                ),
                              ],
                            )),
                            for (var r in _rooms)
                              DataColumn(label: Row(
                                children: [
                                  Text(r, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 14, color: Colors.red), 
                                    onPressed: () {
                                      setState(() {
                                        _rooms.remove(r);
                                        _examSchedule.removeWhere((k, v) => k.endsWith('_$r'));
                                      });
                                    },
                                  ),
                                ],
                              )),
                            DataColumn(label: IconButton(
                              icon: const Icon(Icons.add_business_rounded, color: Colors.teal), 
                              onPressed: () {
                                setState(() {
                                  int nextRoom = _rooms.length + 1;
                                  _rooms.add('Ruang ${nextRoom.toString().padLeft(2, '0')}');
                                });
                              },
                            )),
                          ],
                          rows: List.generate(_sessions.length, (sessionIndex) {
                            final session = _sessions[sessionIndex];
                            return DataRow(
                              cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () => _showEditSessionDialog(sessionIndex),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(session['sesi']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        Text(session['waktu']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                                ..._rooms.map((room) {
                                  String key = '${_selectedDate}_${sessionIndex}_$room';
                                  var assigned = _examSchedule[key];

                                  return DataCell(
                                    DragTarget<Map<String, String>>(
                                      onAccept: (exam) => _handleDrop(room, sessionIndex, exam),
                                      builder: (context, candidateData, rejectedData) {
                                        return Container(
                                          width: 160,
                                          height: 70,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            color: candidateData.isNotEmpty ? Colors.orange.shade50 : (assigned != null ? Colors.white : Colors.grey.shade50),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: assigned != null ? Colors.orange.shade200 : (candidateData.isNotEmpty ? Colors.orange : Colors.grey.shade200)),
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
                                                        Text(assigned['mapel']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.person, size: 10, color: Colors.orange),
                                                            const SizedBox(width: 4),
                                                            Expanded(child: Text(assigned['pengawas']!, style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 1)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0, top: 0,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.close, size: 12, color: Colors.red),
                                                      onPressed: () => setState(() => _examSchedule.remove(key)),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Center(child: Icon(Icons.add_circle_outline, size: 16, color: Colors.grey.shade300)),
                                        );
                                      },
                                    ),
                                  );
                                }),
                                const DataCell(SizedBox.shrink()), // Matches the 'Add Room' column
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

              // SUBJECTS INVENTORY
              Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(left: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mata Pelajaran & Pengawas', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                    const Text('Drag ke Ruang Ujian', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _examSubjects.length,
                        itemBuilder: (context, index) {
                          final exam = _examSubjects[index];
                          return Draggable<Map<String, String>>(
                            data: exam,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Container(
                                width: 230,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                                ),
                                child: Text(exam['mapel']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                border: Border.all(color: Colors.orange.shade100),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exam['mapel']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  const SizedBox(height: 4),
                                  Text('Pengawas: ${exam['pengawas']}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

      ],
    ),
  );
}

  @override
  void dispose() {
    _mainScrollController.dispose();
    _horizontalScrollController.dispose();
    _examNameController.dispose();
    super.dispose();
  }

  void _showEditSessionDialog(int index) {
     final TextEditingController nameC = TextEditingController(text: _sessions[index]['sesi']);
     final TextEditingController timeC = TextEditingController(text: _sessions[index]['waktu']);
     
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Edit Sesi Ujian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Label Sesi', isDense: true)),
             const SizedBox(height: 12),
             TextField(controller: timeC, decoration: const InputDecoration(labelText: 'Waktu (contoh 07:30 - 09:30)', isDense: true)),
           ],
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
           TextButton(
             onPressed: () {
               setState(() {
                 _sessions[index] = {'sesi': nameC.text, 'waktu': timeC.text};
               });
               Navigator.pop(context);
             }, 
             child: const Text('Simpan')
           ),
         ],
       ),
     );
  }

}
