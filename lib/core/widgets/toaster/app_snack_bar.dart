import 'package:flutter/material.dart';

import '../../enums/snack_bar_type.dart';
import '../../theme/app_theme.dart';

class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.info);

  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final accent = _colorFor(type);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.backgroundColor
            : AppTheme.snackBarBackgroundColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration:
            duration ??
            (type == SnackBarType.error
                ? const Duration(seconds: 4)
                : const Duration(seconds: 3)),
        dismissDirection: DismissDirection.horizontal,
        content: Row(
          children: [
            _iconBadge(type, accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        showCloseIcon: true,
        closeIconColor: Colors.white70,
      ),
    );
  }

  // Inside icon
  static Widget _iconBadge(SnackBarType type, Color accent) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(_iconFor(type), size: 18, color: accent),
    );
  }

  static Color _colorFor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppTheme.successColor;
      case SnackBarType.error:
        return AppTheme.errorColor;
      case SnackBarType.warning:
        return AppTheme.warningColor;
      case SnackBarType.info:
        return AppTheme.infoColor;
    }
  }

  static IconData _iconFor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_rounded;
      case SnackBarType.error:
        return Icons.error_outline_rounded;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }
}
