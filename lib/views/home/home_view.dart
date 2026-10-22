import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/home_tab.dart';
import '../../core/enums/news_category.dart';
import '../../core/widgets/bottom_sheets/user_details_sheet.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/lists/news_list.dart';
import '../../core/widgets/nav_bar/app_bottom_nav_bar.dart';
import '../../core/widgets/scaffold/app_scaffold.dart';
import '../../providers/auth_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeTab _currentTab = HomeTab.home;

  // Category chosen in the Categories tab.
  NewsCategory _selectedCategory = NewsCategory.general;

  // Change view according to tab
  void _onTabSelected(HomeTab tab) {
    if (tab == HomeTab.settings) {
      showUserDetailsSheet(context);
      return;
    }
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: _currentTab == HomeTab.categories ? _categoriesBody() : _homeBody(),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: _currentTab,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  // Home tab: top headlines
  Widget _homeBody() {
    final name = context.read<AuthProvider>().displayName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (name.isNotEmpty)
          Text('Hello, $name', style: Theme.of(context).textTheme.bodySmall),
        Text('Top Headlines', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Expanded(child: NewsList()),
      ],
    );
  }

  // Categories tab: chips + news of the selected category
  Widget _categoriesBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        CategoryChips(
          selected: _selectedCategory,
          onSelected: (category) =>
              setState(() => _selectedCategory = category),
        ),
        const SizedBox(height: 12),
        Expanded(
          // The key makes the list reload when the category changes.
          child: NewsList(
            key: ValueKey(_selectedCategory),
            category: _selectedCategory,
          ),
        ),
      ],
    );
  }
}