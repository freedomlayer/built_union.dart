import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
// import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:built_union/built_union.dart' as annotations show BuiltUnion;

Builder BuiltUnionBuilder(BuilderOptions options) =>
    SharedPartBuilder([BuiltUnionGenerator()], 'built_union');

class BuiltUnionGenerator
    extends GeneratorForAnnotation<annotations.BuiltUnion> {
  @override
  Object generateForAnnotatedElement(
          Element element, ConstantReader annotation, BuildStep buildStep) =>
      null;
  // generateBuiltUnion(makeBuiltUnionSpec(element, annotation));
}
