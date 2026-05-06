// lib/core/providers/master_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/master_data/services/master_service.dart';
import '../../features/master_data/models/master_models.dart';

final masterServiceProvider = Provider((ref) => MasterService());

final allClassesProvider = FutureProvider<List<ClassRoom>>((ref) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchAllClasses();
});

final allStudentsProvider = FutureProvider<List<Student>>((ref) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchAllStudents();
});

final allTeachersProvider = FutureProvider<List<Teacher>>((ref) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchAllTeachers();
});

final allSubjectsProvider = FutureProvider<List<Subject>>((ref) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchAllSubjects();
});

final allMajorsProvider = FutureProvider<List<Major>>((ref) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchAllMajors();
});

final allAcademicYearsProvider = FutureProvider<List<AcademicYear>>((ref) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchAllAcademicYears();
});

final allEkskulProvider = FutureProvider<List<Extracurricular>>((ref) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchAllEkskul();
});

final allBimbelProvider = FutureProvider<List<Tutoring>>((ref) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchAllBimbel();
});

final bimbelParticipantsProvider = FutureProvider.family<List<BimbelParticipant>, String>((ref, bimbelId) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchBimbelParticipants(bimbelId);
});

final ekskulParticipantsProvider = FutureProvider.family<List<EkskulParticipant>, String>((ref, ekskulId) async {
  final service = ref.watch(masterServiceProvider);
  return service.fetchEkskulParticipants(ekskulId);
});
