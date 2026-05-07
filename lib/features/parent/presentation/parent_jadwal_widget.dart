import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../academic_config/services/schedule_service.dart';
import '../../academic_config/services/academic_service.dart';
import '../../academic_config/models/scheduling_models.dart';
import '../services/parent_service.dart';

class ParentJadwalWidget extends ConsumerStatefulWidget {
  const ParentJadwalWidget({super.key});

  @override
  ConsumerState<ParentJadwalWidget> createState() => _ParentJadwalWidgetState();
}

class _ParentJadwalWidgetState extends ConsumerState<ParentJadwalWidget> {
  final ScheduleService _scheduleService = ScheduleService();
  final AcademicService _academicService = AcademicService();
  final ParentService _parentService = ParentService();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<ScheduleRow> _schedules = [];
  String? _activeSemesterId;
  String _selectedDay = 'Senin';
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw 'User tidak ditemukan';
      }

      // 1. Get Child's Class ID via Parent Profile
      final profile = await _parentService.getParentDashboardProfile(user.id);
      if (profile == null) throw 'Profil orang tua tidak ditemukan';
      
      final classId = profile.classId;
      if (classId.isEmpty) throw 'Data kelas anak tidak ditemukan';

      // 2. Get Active Semester
      final semesters = await _academicService.getActiveSemesters();
      if (semesters.isEmpty) throw 'Tahun ajaran belum diatur';
      
      final activeSem = semesters.firstWhere((s) => s.isActive, orElse: () => semesters.first);
      _activeSemesterId = activeSem.id;

      // 3. Get Schedules
      _schedules = await _scheduleService.getClassSchedules(classId, _activeSemesterId!);
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text('Error: $_errorMessage'));

    final dailySchedules = _schedules.where((s) => s.day == _selectedDay).toList();
    dailySchedules.sort((a, b) => (a.startTime ?? '').compareTo(b.startTime ?? ''));

    return Column(
      children: [
        _buildDaySelector(),
        Expanded(
          child: dailySchedules.isEmpty 
            ? _buildEmptyState()
            : _buildScheduleList(dailySchedules),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDay == _days[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(_days[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedDay = _days[index]),
              selectedColor: Colors.deepOrange.shade100,
              labelStyle: TextStyle(
                color: isSelected ? Colors.deepOrange.shade800 : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
           const SizedBox(height: 16),
           Text('Libur hari $_selectedDay', style: const TextStyle(color: Colors.grey)),
         ],
       ),
     );
  }

  Widget _buildScheduleList(List<ScheduleRow> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final startTime = (item.startTime ?? "00:00");
        final endTime = (item.endTime ?? "00:00");
        final timeRange = '${startTime.length > 5 ? startTime.substring(0, 5) : startTime} - ${endTime.length > 5 ? endTime.substring(0, 5) : endTime}';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.school_outlined, color: Colors.deepOrange.shade700, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.subjectName ?? 'Mata Pelajaran', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2B3674))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(item.teacherName ?? '-', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(width: 12),
                        Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(timeRange, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
