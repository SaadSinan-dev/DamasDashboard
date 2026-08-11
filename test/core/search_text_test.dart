import 'package:damas_dashboard/core/utils/search_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeForSearch', () {
    test('trims, lowercases and collapses whitespace', () {
      expect(normalizeForSearch('  Q1   Financial  '), 'q1 financial');
    });

    test('folds Arabic alef variants to bare alef', () {
      // A user typing on a phone keyboard rarely produces the hamza forms.
      expect(normalizeForSearch('أحمد'), normalizeForSearch('احمد'));
      expect(normalizeForSearch('إدارة'), normalizeForSearch('ادارة'));
      expect(normalizeForSearch('آمن'), normalizeForSearch('امن'));
    });

    test('folds teh marbuta to heh and alef maksura to yeh', () {
      expect(normalizeForSearch('مراجعة'), normalizeForSearch('مراجعه'));
      expect(normalizeForSearch('على'), normalizeForSearch('علي'));
    });

    test('strips tashkeel and tatweel', () {
      expect(normalizeForSearch('مَالِيّ'), normalizeForSearch('مالي'));
      expect(normalizeForSearch('مـــالي'), normalizeForSearch('مالي'));
    });
  });

  group('matchesSearch', () {
    test('an empty query matches everything', () {
      expect(matchesSearch('anything', ''), isTrue);
      expect(matchesSearch('anything', '   '), isTrue);
    });

    test('matches case-insensitively on a substring', () {
      expect(matchesSearch('Quarterly financial summary', 'FINANCIAL'), isTrue);
      expect(matchesSearch('Quarterly financial summary', 'audit'), isFalse);
    });

    test('matches Arabic text typed without hamza or diacritics', () {
      expect(matchesSearch('الملخّص المالي الربعي', 'المالي'), isTrue);
      expect(matchesSearch('التدقيق السنوي للخوادم', 'التدقيق'), isTrue);
      expect(matchesSearch('التدقيق السنوي للخوادم', 'الإيرادات'), isFalse);
    });
  });
}
