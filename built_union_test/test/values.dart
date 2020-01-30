library values;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_union/built_union.dart';
import 'package:meta/meta.dart';

part 'values.g.dart';

abstract class SimpleValue implements Built<SimpleValue, SimpleValueBuilder> {
  static Serializer<SimpleValue> get serializer => _$simpleValueSerializer;

  int get anInt;
  BuiltList<String> get list;

  factory SimpleValue([Function(SimpleValueBuilder) updates]) = _$SimpleValue;
  SimpleValue._();
}

@BuiltUnion()
class SimpleUnion extends _$SimpleUnion {
  static Serializer<SimpleUnion> get serializer => _$simpleUnionSerializer;

  SimpleUnion.empty(): super.empty();
  SimpleUnion.integer(int integer): super.integer(integer);
  SimpleUnion.tuple(int tupleInt, String tupleString): super.tuple(tupleInt, tupleString);
  SimpleUnion.string(String string): super.string(string);
  SimpleUnion.builtList(BuiltList<int> builtList): super.builtList(builtList);
}


abstract class CompoundValue
    implements Built<CompoundValue, CompoundValueBuilder> {
  static Serializer<CompoundValue> get serializer => _$compoundValueSerializer;

  SimpleValue get simpleValue;
  SimpleUnion get simpleUnion;

  factory CompoundValue([Function(CompoundValueBuilder) updates]) =
      _$CompoundValue;
  CompoundValue._();
}

Serializers serializers = (new Serializers().toBuilder()
      ..add(SimpleValue.serializer)
      ..add(SimpleUnion.serializer)
      ..add(CompoundValue.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>()))
    .build();
