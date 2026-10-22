import 'package:flutter/material.dart';
import 'package:newsbeeper/models/news_model.dart';
import 'package:provider/provider.dart';

import '../../../providers/saved_news_provider.dart';
import '../../constants/app_messages.dart';
import '../../theme/app_theme.dart';
import '../toaster/app_snack_bar.dart';

/// Bookmark icon that saves / removes a news article.
/// Used on the news card and on the news details page.
class SaveNewsButton extends StatelessWidget {
  final NewsModel  article;
  final double size;

  const SaveNewsButton({super.key, required this.article, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedNewsProvider>(
      builder: (context, saved, _) {
        final isSaved = saved.isSaved(article);

        return IconButton(
          tooltip: isSaved ? 'Remove from saved' : 'Save news',
          visualDensity: VisualDensity.compact,
          iconSize: size,
          icon: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: isSaved ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
          ),
          // null disables the button while saving
          onPressed: saved.isBusy(article)
              ? null
              : () => _onPressed(context, saved, isSaved),
        );
      },
    );
  }

  Future<void> _onPressed(
      BuildContext context,
      SavedNewsProvider saved,
      bool wasSaved,
      ) async {
    final error = await saved.toggleSave(article);

    // The card can be gone already (removed from the saved list).
    if (!context.mounted) return;

    if (error != null) {
      AppSnackBar.error(context, error);
    } else {
      AppSnackBar.success(
        context,
        wasSaved ? AppMessages.newsRemoved : AppMessages.newsSaved,
      );
    }
  }
}