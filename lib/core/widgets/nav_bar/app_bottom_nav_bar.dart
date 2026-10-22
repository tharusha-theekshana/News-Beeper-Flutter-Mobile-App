import 'package:flutter/material.dart';

import '../../enums/home_tab.dart';
import '../../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final HomeTab currentTab;
  final ValueChanged<HomeTab> onTabSelected;

  const AppBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.textPrimaryColor.withAlpha(25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppTheme.borderColor, width: 0.5),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15)
                ),
              ),
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _buildStandardItem(context, HomeTab.home, Icons.home_rounded, 'Home'),
                    const Expanded(child: SizedBox()), // Spacer for center button
                    _buildStandardItem(context, HomeTab.categories, Icons.grid_view_rounded, 'Categories'),
                  ],
                ),
              ),
            ),

            // Floating Elevated Settings Button
            Positioned(
              top: -18,
              child: _buildFloatingCenterItem(context, HomeTab.settings, Icons.settings_rounded, 'Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardItem(
      BuildContext context,
      HomeTab tab,
      IconData icon,
      String label,
      ) {
    final bool selected = currentTab == tab;
    final Color color = selected ? AppTheme.primaryColor : AppTheme.textSecondaryColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(tab),
        splashColor: AppTheme.primaryColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCenterItem(
      BuildContext context,
      HomeTab tab,
      IconData icon,
      String label,
      ) {
    final bool selected = currentTab == tab;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onTabSelected(tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.backgroundColor,
              border: Border.all(
                color: AppTheme.secondaryColor.withAlpha(120),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? AppTheme.primaryColor.withAlpha(150)
                      : AppTheme.textPrimaryColor.withAlpha(30),
                  blurRadius: selected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppTheme.secondaryColor.withAlpha(200),
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}