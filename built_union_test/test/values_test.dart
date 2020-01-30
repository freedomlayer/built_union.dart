// import 'package:built_value/built_value.dart';
import 'package:test/test.dart';

import 'values.dart';

void main() {
  group('built_union', () {
    test('CompoundValue', () {
      final compoundValue1 = CompoundValue((b) => b
        ..simpleValue.anInt = 3
        ..simpleUnion = SimpleUnion.tuple(4, "four"));

      final compoundValue2 = CompoundValue((b) => b
        ..simpleValue.anInt = 3
        ..simpleUnion = SimpleUnion.tuple(4, "four"));

      expect(compoundValue1, compoundValue2);
    });
  });
}

