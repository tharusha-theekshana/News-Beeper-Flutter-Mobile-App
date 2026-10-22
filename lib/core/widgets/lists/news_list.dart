import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_messages.dart';
import '../../../core/enums/news_category.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/loader/app_loader.dart';
import '../../../providers/news_provider.dart';
import '../cards/news_card.dart';

/// Scrollable list of news for one [category] (null = top headlines).
/// Handles loading, error, empty and pull to refresh.
class NewsList extends StatefulWidget {
  final NewsCategory? category;

  const NewsList({super.key, this.category});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  @override
  void initState() {
    super.initState();
    // Load after the first frame, because loading calls notifyListeners().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NewsProvider>().loadNews(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, news, _) {
        final articles = news.articlesFor(widget.category);
        final error = news.errorFor(widget.category);

        if (articles.isNotEmpty) return _list(news, articles);
        if (error != null) return _message(context, news, error, showRetry: true);
        if (news.hasLoaded(widget.category)) {
          return _message(context, news, AppMessages.noNewsFound);
        }
        return const Center(child: AppLoader());
      },
    );
  }

  Widget _list(NewsProvider news, List articles) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => news.loadNews(widget.category, refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => NewsCard(article: articles[index]),
      ),
    );
  }

  Widget _message(
      BuildContext context,
      NewsProvider news,
      String text, {
        bool showRetry = false,
      }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (showRetry) ...[
            const SizedBox(height: 16),
            AppButton(
              label: 'Try again',
              width: 140,
              isLoading: news.isLoading(widget.category),
              onPressed: () => news.loadNews(widget.category, refresh: true),
            ),
          ],
        ],
      ),
    );
  }
}