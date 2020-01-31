import 'dart:convert';
import 'package:built_value/serializer.dart';
import 'package:built_union/custom_json_plugin.dart';
import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';

import 'values.dart';

void main() {
  final serializersWithPlugin = (serializers.toBuilder()..addPlugin(CustomJsonPlugin())).build();

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

    test('SimpleUnion serialization', () {
      final simpleUnions = [
        SimpleUnion.empty(),
        SimpleUnion.integer(3),
        SimpleUnion.tuple(4, 'four'),
        SimpleUnion.string('string'),
        SimpleUnion.builtList(BuiltList([1,2,3,4])),
      ];

      for (final simpleUnion in simpleUnions) {
        final serialized = serializers.serialize(simpleUnion, specifiedType: FullType(SimpleUnion));
        final simpleUnion2 = serializers.deserialize(serialized, specifiedType: FullType(SimpleUnion));
        expect(simpleUnion, simpleUnion2);
      }
    });
    test('CompoundValue serialization', () {
      final compoundValue = CompoundValue((b) => b
        ..simpleValue.anInt = 3
        ..simpleUnion = SimpleUnion.tuple(4, 'four'));

      final serialized = serializers.serialize(compoundValue, specifiedType: FullType(CompoundValue));
      final compoundValue2 = serializers.deserialize(serialized, specifiedType: FullType(CompoundValue));
      expect(compoundValue, compoundValue2);
    });
    test('SimpleUnion json serialization', () {
      final simpleUnions = [
        SimpleUnion.empty(),
        SimpleUnion.integer(3),
        SimpleUnion.tuple(4, 'four'),
        SimpleUnion.string('string'),
        SimpleUnion.builtList(BuiltList([1,2,3,4])),
      ];


      for (final simpleUnion in simpleUnions) {
        final serialized = serializersWithPlugin.serialize(simpleUnion, specifiedType: FullType(SimpleUnion));

        // Make sure that json encoding runs without crashing:
        JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        encoder.convert(serialized);

        final simpleUnion2 = serializersWithPlugin.deserialize(serialized, specifiedType: FullType(SimpleUnion));
        expect(simpleUnion, simpleUnion2);
      }

    });
    test('SimpleUnion empty variant json serialization', () {
      final simpleUnion = SimpleUnion.empty();
      final serialized = serializersWithPlugin.serialize(simpleUnion, specifiedType: FullType(SimpleUnion));

      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(serialized);
      // Empty variant is expected to be represented as a single string:
      expect(jsonString, '"empty"');
    });
  });
}

