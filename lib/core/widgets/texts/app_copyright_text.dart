import 'package:flutter/material.dart';

class AppCopyrightText extends StatelessWidget {
  final String companyName;
  final int? year;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const AppCopyrightText({
    super.key,
    this.companyName = 'CoderUX Solutions',
    this.year,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final displayYear = year ?? DateTime.now().year;

    return Padding(
      padding: padding,
      child: Center(
        child: Text(
          '© $displayYear $companyName. All rights reserved.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}