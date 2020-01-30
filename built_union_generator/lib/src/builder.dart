import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
// import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:built_union/built_union.dart' as annotations show BuiltUnion;

import 'union_class.dart';
import 'serializer_class.dart';
import 'union_spec.dart';

Builder BuiltUnionBuilder(BuilderOptions options) =>
    SharedPartBuilder([BuiltUnionGenerator()], 'built_union');

class BuiltUnionGenerator
    extends GeneratorForAnnotation<annotations.BuiltUnion> {
  @override
  Object generateForAnnotatedElement(
          Element element, ConstantReader annotation, BuildStep buildStep) =>
      generateBuiltUnion(makeUnionSpec(element, annotation));
}

String generateBuiltUnion(UnionSpec unionSpec) {
  List<String> res = [];
  res.add(generateEnumType(unionSpec));
  res.add(generateUnionClass(unionSpec));
  res.add(generateSerializerClass(unionSpec));

  return res.join('\n');
}
