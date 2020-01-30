// import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';

import 'values.dart';

void main() {
  group('built_union', () {
    test('CompoundValue', () {
      final compoundValue1 = CompoundValue((b) => b
        ..simpleValue.anInt = 3
        ..simpleUnion = SimpleUnion.tuple(4, 'four'));

      final compoundValue2 = CompoundValue((b) => b
        ..simpleValue.anInt = 3
        ..simpleUnion = SimpleUnion.tuple(4, 'four'));

      expect(compoundValue1, compoundValue2);
    });
    test('SimpleUnion constructors', () {
      final simpleUnionEmpty0 = SimpleUnion.empty();
      final simpleUnionEmpty1 = SimpleUnion.empty();
      expect(simpleUnionEmpty0, simpleUnionEmpty1);

      final simpleUnionInteger0 = SimpleUnion.integer(3);
      final simpleUnionInteger1 = SimpleUnion.integer(3);
      expect(simpleUnionInteger0, simpleUnionInteger1);

      final simpleUnionTuple0 = SimpleUnion.tuple(4, 'four');
      final simpleUnionTuple1 = SimpleUnion.tuple(4, 'four');
      expect(simpleUnionTuple0, simpleUnionTuple1);

      final simpleUnionString0 = SimpleUnion.string('String');
      final simpleUnionString1 = SimpleUnion.string('String');
      expect(simpleUnionString0, simpleUnionString1);

      final simpleUnionBuiltList0 = SimpleUnion.builtList(BuiltList([1,2,3,4]));
      final simpleUnionBuiltList1 = SimpleUnion.builtList(BuiltList([1,2,3,4]));
      expect(simpleUnionBuiltList0, simpleUnionBuiltList1);
    });
    test('SimpleUnion match()', () {
      final simpleUnionEmpty = SimpleUnion.empty();
      final resEmpty = simpleUnionEmpty.match(empty: () => true,
          integer: (_) => false,
          tuple: (_1, _2) => false,
          string: (_) => false,
          builtList: (_) => false);
      expect(resEmpty, true);

      final simpleUnionInteger = SimpleUnion.integer(3);
      final resInteger = simpleUnionInteger.match(empty: () => false,
          integer: (_) => true,
          tuple: (_1, _2) => false,
          string: (_) => false,
          builtList: (_) => false);
      expect(resInteger, true);

      final simpleUnionTuple = SimpleUnion.tuple(4, 'four');
      final resTuple = simpleUnionTuple.match(empty: () => false,
          integer: (_) => false,
          tuple: (_1, _2) => true,
          string: (_) => false,
          builtList: (_) => false);
      expect(resTuple, true);

      final simpleUnionString = SimpleUnion.string('string');
      final resString = simpleUnionString.match(empty: () => false,
          integer: (_) => false,
          tuple: (_1, _2) => false,
          string: (_) => true,
          builtList: (_) => false);
      expect(resString, true);

      final simpleUnionBuiltList = SimpleUnion.builtList(BuiltList([1,2,3,4]));
      final resBuiltList = simpleUnionBuiltList.match(empty: () => false,
          integer: (_) => false,
          tuple: (_1, _2) => false,
          string: (_) => false,
          builtList: (_) => true);
      expect(resBuiltList, true);
    });
  });
}

