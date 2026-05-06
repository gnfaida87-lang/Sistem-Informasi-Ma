// lib/core/providers/promotion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/academic_config/services/promotion_service.dart';
import '../../features/academic_config/models/promotion_models.dart';

final promotionServiceProvider = Provider((ref) => PromotionService());

final promotionCriteriaProvider = FutureProvider<List<PromotionCriteria>>((ref) async {
  final service = ref.watch(promotionServiceProvider);
  return service.fetchCriteria();
});

final alumniProvider = FutureProvider.family<List<Alumni>, String>((ref, query) async {
  final service = ref.watch(promotionServiceProvider);
  return service.fetchAlumni(query);
});
