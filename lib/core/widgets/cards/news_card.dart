import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsbeeper/models/news_model.dart';

import '../../router/app_route_names.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../buttons/save_news_button.dart';

/// One news item: image, title, short description, source and time.
/// Tap opens the news details page.
class NewsCard extends StatelessWidget {
  final NewsModel article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push(AppRouteNames.newsDetail, extra: article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null) _image(article.imageUrl!),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 0),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (article.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Text(
                  article.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium!.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      article.sourceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall!.copyWith(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    DateFormatter.timeAgo(article.publishedAt),
                    style: textTheme.bodySmall,
                  ),
                  SaveNewsButton(article: article, size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(String url) {
    return Image.network(
      url,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      // Grey box while loading and when the image fails to load.
      loadingBuilder: (context, child, progress) =>
      progress == null ? child : _imagePlaceholder(),
      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppTheme.borderColor.withValues(alpha: 0.4),
      child: const Icon(Icons.image_outlined, color: AppTheme.textSecondaryColor),
    );
  }
}