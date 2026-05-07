import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import '../utils/context_extensions.dart';

mixin SafeAsync<T extends StatefulWidget> on State<T> {
  bool isLoading = false;

  Future<void> safeCall({
    required Future<void> Function() action,
    required BuildContext context,
    String? successMessage,
    bool showLoading = true,
    bool useDialog = false,
    VoidCallback? onRetry,
  }) async {
    if (showLoading && mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await action();
      if (successMessage != null && mounted) {
        context.showSuccessSnackBar(successMessage);
      }
    } catch (e) {
      final appError = handleApiError(e);
      logError(appError, context: 'SafeAsync');

      if (mounted) {
        if (useDialog) {
          context.showErrorDialog(
            appError.userMessage,
            onRetry: onRetry,
          );
        } else {
          context.showErrorSnackBar(
            appError.userMessage,
            type: appError.type,
            onRetry: onRetry,
          );
        }
      }
    } finally {
      if (mounted && showLoading) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
