import 'package:flutter/material.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/services/app_service.dart';

class DialogHandler {
  static void showError(String message) {
    BuildContext? context = AppService.to.overlayContext;
    if (context == null) {
      logError("Navigator context is null: $message");
      return;
    }
    if (message.length > 400) message = "${message.substring(0, 400)}...";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        closeIconColor: Colors.white,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
      ),
    );
  }

  static void showSuccess(String message) {
    BuildContext? context = AppService.to.overlayContext;
    if (context == null) {
      logError("Navigator context is null: $message");
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        closeIconColor: Colors.white,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
      ),
    );
  }

  static void showSnackbar(String message) {
    BuildContext? context = AppService.to.overlayContext;
    if (context == null) {
      logError("Navigator context is null: $message");
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        closeIconColor: Colors.white,
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        showCloseIcon: true,
      ),
    );
  }

  static void showInfoDialog({
    required BuildContext context,
    required String title,
    required String text,
  }) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: MarkdownGenerator().buildWidgets(text),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
