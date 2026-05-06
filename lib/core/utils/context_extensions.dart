import 'package:flutter/material.dart';
import 'error_handler.dart';

extension ShowError on BuildContext {
  void showErrorSnackBar(String message, {AppErrorType? type, VoidCallback? onRetry}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: type == AppErrorType.network && onRetry != null
            ? SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : SnackBarAction(
                label: 'Tutup',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(this).hideCurrentSnackBar();
                },
              ),
      ),
    );
  }

  void showErrorDialog(String message, {String? title, VoidCallback? onRetry}) {
    showDialog(
      context: this,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? 'Terjadi Kesalahan'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
            if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Coba Lagi'),
              ),
          ],
        );
      },
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
