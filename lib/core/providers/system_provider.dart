import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/system_admin/services/system_service.dart';
import '../../features/system_admin/models/system_settings_model.dart';

final systemServiceProvider = Provider((ref) => SystemService());

final systemSettingsProvider = FutureProvider<SystemSettings>((ref) async {
  final service = ref.watch(systemServiceProvider);
  return service.fetchSettings();
});
