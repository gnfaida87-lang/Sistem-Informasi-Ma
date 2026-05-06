import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppErrorType { network, auth, notFound, validation, server, unknown }

class AppException implements Exception {
  final String message;
  final AppErrorType type;
  final dynamic originalError;

  AppException({
    required this.message,
    required this.type,
    this.originalError,
  });

  String get userMessage {
    switch (type) {
      case AppErrorType.network:
        return 'Periksa koneksi internet Anda dan coba lagi.';
      case AppErrorType.auth:
        return 'Sesi Anda berakhir. Silakan login ulang.';
      case AppErrorType.notFound:
        return 'Data yang dicari tidak ditemukan.';
      case AppErrorType.validation:
        return message;
      case AppErrorType.server:
        return 'Terjadi kesalahan pada server. Coba beberapa saat lagi.';
      case AppErrorType.unknown:
      default:
        return 'Terjadi kesalahan tak terduga. Coba beberapa saat lagi.';
    }
  }
}

AppException handleSupabaseError(dynamic error) {
  if (error is PostgrestException) {
    switch (error.code) {
      case '23505':
        return AppException(
          message: 'Data sudah ada, tidak bisa duplikat.',
          type: AppErrorType.validation,
          originalError: error,
        );
      case '23503':
        return AppException(
          message: 'Data terkait tidak ditemukan.',
          type: AppErrorType.notFound,
          originalError: error,
        );
      case '42501':
        return AppException(
          message: 'Anda tidak punya akses ke data ini.',
          type: AppErrorType.auth,
          originalError: error,
        );
      default:
        return AppException(
          message: error.message,
          type: AppErrorType.server,
          originalError: error,
        );
    }
  }
  if (error is AuthException) {
    return AppException(
      message: 'Sesi berakhir, silakan login ulang.',
      type: AppErrorType.auth,
      originalError: error,
    );
  }
  if (error is SocketException) {
    return AppException(
      message: 'Tidak ada koneksi internet.',
      type: AppErrorType.network,
      originalError: error,
    );
  }
  if (error is TimeoutException) {
    return AppException(
      message: 'Koneksi timeout, coba lagi.',
      type: AppErrorType.network,
      originalError: error,
    );
  }
  if (error is AppException) return error;
  return AppException(
    message: error.toString(),
    type: AppErrorType.unknown,
    originalError: error,
  );
}

void logError(AppException e, {String? context}) {
  final ctx = context != null ? '[$context]' : '';
  // ignore: avoid_print
  print('[ERROR]$ctx ${e.message} | type: ${e.type} | original: ${e.originalError}');
}
