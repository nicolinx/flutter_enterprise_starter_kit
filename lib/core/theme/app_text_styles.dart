import 'package:flutter/material.dart';

/// Named text styles built on top of the ambient [TextTheme], so feature
/// widgets style text via `AppTextStyles.title(context)` instead of
/// constructing `TextStyle`s inline.
abstract class AppTextStyles {
  static TextStyle title(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.w700,
      );

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static TextStyle caption(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodySmall!.copyWith(color: Theme.of(context).hintColor);
}
