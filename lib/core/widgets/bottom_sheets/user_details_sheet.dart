import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loader/app_loader.dart';
import '../../../providers/user_provider.dart';

/// Opens the user details bottom sheet (used by the Settings tab).
void showUserDetailsSheet(BuildContext context) {
  // Load the latest profile, the sheet rebuilds when it arrives.
  context.read<UserProvider>().loadUser();

  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _UserDetailsSheet(),
  );
}

class _UserDetailsSheet extends StatelessWidget {
  const _UserDetailsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Small drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _content(context, userProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, UserProvider userProvider) {
    if (userProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: AppLoader(),
      );
    }

    final user = userProvider.user;

    if (user == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          userProvider.errorMessage ?? 'No user details found.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final String initial =
    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            initial,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.fullName.isEmpty ? 'User' : user.fullName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        _detailRow(context, Icons.email_outlined, 'Email', user.email),
        _detailRow(
          context,
          Icons.phone_outlined,
          'Mobile',
          user.mobile.isEmpty ? 'Not added' : user.mobile,
        ),
      ],
    );
  }

  Widget _detailRow(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}