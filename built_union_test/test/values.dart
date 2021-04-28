library values;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_union/built_union.dart';

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

  SimpleUnion.empty() : super.empty();
  SimpleUnion.integer(int integer) : super.integer(integer);
  SimpleUnion.tuple(int tupleInt, String tupleString)
      : super.tuple(tupleInt, tupleString);
  SimpleUnion.string(String string) : super.string(string);
  SimpleUnion.builtList(BuiltList<int> builtList) : super.builtList(builtList);
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

/*
// TODO: Generics
// A generic union will probably look like this:
@BuiltUnion()
class GenericUnion<T,W> extends _$GenericUnion<T,W> {
  static Serializer<GenericUnion> get serializer => _$genericUnionSerializer;

  GenericUnion.empty() : super.empty();
  GenericUnion.variantT(T t) : super.variantT(t);
  GenericUnion.variantW(W w) : super.variantW(w);
  GenericUnion.variantTW(T t, W w) : super.variantTW(t,w);
  GenericUnion.string(String string) : super.string(string);
}
*/

@BuiltValue(instantiable: false)
abstract class ContentBitsModel {
  ContentBitsModel rebuild(void Function(ContentBitsModelBuilder) updates);

  ContentBitsModelBuilder toBuilder();
}

abstract class SkillContentBitsModel
    implements
        ContentBitsModel,
        Built<SkillContentBitsModel, SkillContentBitsModelBuilder> {
  SkillContentBitsModel._();

  factory SkillContentBitsModel(
          [void Function(SkillContentBitsModelBuilder) updates]) =
      _$SkillContentBitsModel;

  static Serializer<SkillContentBitsModel> get serializer =>
      _$skillContentBitsModelSerializer;

  static SkillContentBitsModel fromJson(String jsonString) {
    return serializers.deserializeWith(
        SkillContentBitsModel.serializer, json.decode(jsonString))!;
  }
}

abstract class StoryContentBitsModel
    implements
        ContentBitsModel,
        Built<StoryContentBitsModel, StoryContentBitsModelBuilder> {
  StoryContentBitsModel._();

  factory StoryContentBitsModel(
          [void Function(StoryContentBitsModelBuilder) updates]) =
      _$StoryContentBitsModel;

  static Serializer<StoryContentBitsModel> get serializer =>
      _$storyContentBitsModelSerializer;

  static StoryContentBitsModel fromJson(String jsonString) {
    return serializers.deserializeWith(
        StoryContentBitsModel.serializer, json.decode(jsonString))!;
  }
}

@BuiltUnion()
class ContentBitsUnion extends _$ContentBitsUnion {
  static Serializer<ContentBitsUnion> get serializer =>
      _$contentBitsUnionSerializer;

  ContentBitsUnion.unknown() : super.unknown();

  ContentBitsUnion.skill(SkillContentBitsModel model) : super.skill(model);

  ContentBitsUnion.story(StoryContentBitsModel model) : super.story(model);
}

Serializers serializers = (new Serializers().toBuilder()
      ..add(SimpleValue.serializer)
      ..add(SimpleUnion.serializer)
      ..add(CompoundValue.serializer)
      ..add(SkillContentBitsModel.serializer)
      ..add(ContentBitsUnion.serializer)
      ..add(StoryContentBitsModel.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>()))
    .build();
