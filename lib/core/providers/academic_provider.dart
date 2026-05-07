import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/academic_config/services/academic_service.dart';
import '../../features/academic_config/services/schedule_service.dart';
import '../../features/academic_config/services/grading_service.dart';
import '../../features/academic_config/models/academic_models.dart';

final academicServiceProvider = Provider((ref) => AcademicService());
final scheduleServiceProvider = Provider((ref) => ScheduleService());
final gradingServiceProvider  = Provider((ref) => GradingService());

final semestersProvider = FutureProvider<List<Semester>>((ref) async {
  final service = ref.watch(academicServiceProvider);
  return service.getActiveSemesters();
});

final departmentsProvider = FutureProvider<List<Department>>((ref) async {
  final service = ref.watch(academicServiceProvider);
  return service.getDepartments();
});

final activeSemesterProvider = FutureProvider<Semester?>((ref) async {
  final semesters = await ref.watch(semestersProvider.future);
  try {
    return semesters.firstWhere((s) => s.isActive);
  } catch (_) {
    return semesters.isNotEmpty ? semesters.first : null;
  }
});
