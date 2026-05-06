import 'package:flutter/material.dart';
import '../services/teacher_service.dart';
import '../../../core/mixins/safe_async_mixin.dart';

class TeacherNilaiScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String subjectId;
  final String subjectName;
  final String jenisNilai; // 'Tugas', 'PTS', 'PAS'

  const TeacherNilaiScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.jenisNilai,
  });

  @override
  State<TeacherNilaiScreen> createState() => _TeacherNilaiScreenState();
}

class _TeacherNilaiScreenState extends State<TeacherNilaiScreen> with SafeAsync {
  final _teacherService = TeacherService();
  List<Map<String, dynamic>> _students = [];
  Map<String, double> _scores = {}; // studentId -> score

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
            _scores[s['id']] = 0.0;
          }
        });
      },
    );
  }

  Future<void> _saveScores() async {
    await safeCall(
      context: context,
      successMessage: 'Nilai ${widget.jenisNilai} berhasil disimpan',
      action: () async {
        // Logic to save to 'nilai' table
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nilai ${widget.jenisNilai} - ${widget.className}'),
        actions: [
          if (!isLoading)
            IconButton(
              onPressed: _saveScores,
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
                
                return ListTile(
                  title: Text(student['nama']),
                  subtitle: Text(student['nis']),
                  trailing: SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '0',
                      ),
                      onChanged: (val) {
                        final score = double.tryParse(val) ?? 0.0;
                        _scores[student['id']] = score;
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
