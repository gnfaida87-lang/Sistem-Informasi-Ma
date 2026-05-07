import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/d1_service.dart';

/// Provider untuk D1 Service singleton.
final d1ServiceProvider = Provider<D1Service>((ref) {
  return D1Service();
});
