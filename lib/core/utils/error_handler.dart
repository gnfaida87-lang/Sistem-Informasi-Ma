import 'dart:async';
import 'dart:io';

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
        return 'Sesi Anda berakhir atau login gagal. Silakan coba lagi.';
      case AppErrorType.notFound:
        return 'Data yang dicari tidak ditemukan.';
      case AppErrorType.validation:
        return message;
      case AppErrorType.server:
        return 'Terjadi kesalahan pada server Cloudflare. Coba beberapa saat lagi.';
      case AppErrorType.unknown:
      default:
        return 'Terjadi kesalahan tak terduga. Coba beberapa saat lagi.';
    }
  }
}

AppException handleApiError(dynamic error) {
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
