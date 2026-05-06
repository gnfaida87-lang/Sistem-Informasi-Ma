import 'package:flutter/material.dart';
import '../services/teacher_service.dart';
import '../../../core/mixins/safe_async_mixin.dart';

class TeacherAbsensiScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String subjectId;
  final String subjectName;

  const TeacherAbsensiScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<TeacherAbsensiScreen> createState() => _TeacherAbsensiScreenState();
}

class _TeacherAbsensiScreenState extends State<TeacherAbsensiScreen> with SafeAsync {
  final _teacherService = TeacherService();
  List<Map<String, dynamic>> _students = [];
  Map<String, String> _attendance = {}; // studentId -> status ('hadir', 'sakit', 'izin', 'alfa')

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _teacherService.fetchStudentsByClass(widget.classId);
        setState(() {
          _students = data;
          for (var s in data) {
            _attendance[s['id']] = 'hadir'; // default hadir
          }
        });
      },
    );
  }

  Future<void> _saveAttendance() async {
    await safeCall(
      context: context,
      successMessage: 'Absensi berhasil disimpan',
      action: () async {
        // Logic to save to 'absensi' table
        // For now we just simulate success as we need to ensure 'absensi' table structure
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Absensi ${widget.className}'),
            Text(widget.subjectName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          if (!isLoading)
            IconButton(
              onPressed: _saveAttendance,
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final status = _attendance[student['id']];

                return ListTile(
                  title: Text(student['nama']),
                  subtitle: Text(student['nis']),
                  trailing: DropdownButton<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
                      DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                      DropdownMenuItem(value: 'izin', child: Text('Izin')),
                      DropdownMenuItem(value: 'alfa', child: Text('Alfa')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _attendance[student['id']] = val);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
