import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_messages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/cards/news_card.dart';
import '../../core/widgets/loader/app_loader.dart';
import '../../core/widgets/scaffold/app_scaffold.dart';
import '../../providers/saved_news_provider.dart';

/// Shows the news saved by the signed in user.
class SavedNewsView extends StatefulWidget {
  const SavedNewsView({super.key});

  @override
  State<SavedNewsView> createState() => _SavedNewsViewState();
}

class _SavedNewsViewState extends State<SavedNewsView> {
  @override
  void initState() {
    super.initState();
    // Load after the first frame, because loading calls notifyListeners().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SavedNewsProvider>().loadSaved();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Saved News')),
      body: Consumer<SavedNewsProvider>(
        builder: (context, saved, _) {
          if (saved.articles.isNotEmpty) return _list(saved);
          if (saved.errorMessage != null) {
            return _message(context, saved.errorMessage!, saved, showRetry: true);
          }
          if (saved.hasLoaded) {
            return _message(context, AppMessages.noSavedNews, saved);
          }
          return const Center(child: AppLoader());
        },
      ),
    );
  }

  Widget _list(SavedNewsProvider saved) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => saved.loadSaved(refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: saved.articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => NewsCard(article: saved.articles[index]),
      ),
    );
  }

  Widget _message(
      BuildContext context,
      String text,
      SavedNewsProvider saved, {
        bool showRetry = false,
      }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!showRetry)
            const Icon(
              Icons.bookmark_border_rounded,
              size: 48,
              color: AppTheme.textSecondaryColor,
            ),
          const SizedBox(height: 12),
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
              isLoading: saved.isLoading,
              onPressed: () => saved.loadSaved(refresh: true),
            ),
          ],
        ],
      ),
    );
  }
}