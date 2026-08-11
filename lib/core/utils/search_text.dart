/// Normalises text so search behaves the way users expect in both languages.
///
/// Case folding alone is not enough for Arabic. Users type `احمد` for `أحمد`,
/// omit the hamza, write `ه` where the text has `ة`, and copy-paste strings that
/// carry tashkeel (diacritics) the keyboard never produces. Comparing raw
/// strings makes those searches silently return nothing.
String normalizeForSearch(String input) {
  final StringBuffer buffer = StringBuffer();

  for (final int rune in input.trim().toLowerCase().runes) {
    // Drop Arabic diacritics (tashkeel) and the tatweel elongation character.
    if (_isTashkeel(rune) || rune == _tatweel) continue;
    buffer.writeCharCode(_foldArabic(rune));
  }

  // Collapse runs of whitespace so "q1   summary" matches "q1 summary".
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// True when [haystack] contains [needle] under search normalisation.
bool matchesSearch(String haystack, String needle) {
  final String query = normalizeForSearch(needle);
  if (query.isEmpty) return true;
  return normalizeForSearch(haystack).contains(query);
}

const int _tatweel = 0x0640;

bool _isTashkeel(int rune) =>
    (rune >= 0x064B && rune <= 0x065F) || rune == 0x0670;

int _foldArabic(int rune) => switch (rune) {
      // Alef variants (أ إ آ ٱ) → bare alef.
      0x0623 || 0x0625 || 0x0622 || 0x0671 => 0x0627,
      // Teh marbuta → heh.
      0x0629 => 0x0647,
      // Alef maksura → yeh.
      0x0649 => 0x064A,
      _ => rune,
    };
