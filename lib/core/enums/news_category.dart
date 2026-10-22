enum NewsCategory {
  general('general', 'General'),
  business('business', 'Business'),
  entertainment('entertainment', 'Entertainment'),
  health('health', 'Health'),
  science('science', 'Science'),
  sports('sports', 'Sports'),
  technology('technology', 'Technology');

  /// Value sent to the API (?category=...).
  final String apiValue;

  /// Text shown in the UI.
  final String label;

  const NewsCategory(this.apiValue, this.label);
}