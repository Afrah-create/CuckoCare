/// How wide a page's content should sit. Screens pick a preset, not a number.
enum PageLayout {
  /// Lists and dashboards.
  standard,

  /// Forms. Narrows on landscape and tablet.
  form,

  /// Reading text.
  reading,

  /// Maps, splash, and photo viewers. No max width.
  fullBleed,
}
