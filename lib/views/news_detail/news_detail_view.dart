import 'package:flutter/material.dart';
import 'package:newsbeeper/models/news_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_messages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/buttons/save_news_button.dart';
import '../../core/widgets/scaffold/app_scaffold.dart';
import '../../core/widgets/toaster/app_snack_bar.dart';

class NewsDetailView extends StatelessWidget {
  final NewsModel article;

  const NewsDetailView({super.key, required this.article});

  // Opens the original article in the browser.
  Future<void> _openArticle(BuildContext context) async {
    var opened = false;
    final uri = Uri.tryParse(article.url);

    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }

    if (!opened && context.mounted) {
      AppSnackBar.error(context, AppMessages.openLinkFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('News Details'),
        actions: [SaveNewsButton(article: article), const SizedBox(width: 4)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null) _image(article.imageUrl!),
            const SizedBox(height: 16),
            Text(article.title, style: textTheme.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    article.sourceName,
                    style: textTheme.bodyLarge!.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  DateFormatter.full(article.publishedAt),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            if (article.author != null) ...[
              const SizedBox(height: 4),
              Text('By ${article.author}', style: textTheme.bodySmall),
            ],
            const Divider(height: 28),
            if (article.description.isNotEmpty)
              Text(
                article.description,
                style: textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            // The API sends only the first part of the story.
            if (article.content.isNotEmpty &&
                article.content != article.description) ...[
              const SizedBox(height: 12),
              Text(
                article.content,
                style: textTheme.bodyLarge!.copyWith(height: 1.5),
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Read full article',
              icon: Icons.open_in_new_rounded,
              onPressed: () => _openArticle(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: double.infinity,
        height: 210,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
        progress == null ? child : _placeholder(),
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 210,
      color: AppTheme.borderColor.withValues(alpha: 0.4),
      child: const Icon(Icons.image_outlined, color: AppTheme.textSecondaryColor),
    );
  }
}