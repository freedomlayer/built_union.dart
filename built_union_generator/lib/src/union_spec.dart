import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

/*
// Example union:

@BuiltUnion()
class SimpleUnion extends _$SimpleUnion {
  static Serializer<SimpleUnion> get serializer => _$simpleUnionSerializer;

  SimpleUnion.empty(): super.empty();
  SimpleUnion.integer(int integer): super.integer(integer);
  SimpleUnion.tuple(int tupleInt, String tupleString): super.tuple(tupleInt, tupleString);
  SimpleUnion.string(String string): super.string(string);
  SimpleUnion.listInt(BuiltList<int> listInt): super.listInt(listInt);
}
*/

/// Information about one argument for one variant of a union
/// Example: 
/// `Foo<int> fooInt`
@immutable
class ArgSpec {
  const ArgSpec({
    @required this.argName,
    @required this.argType,
  });

  final String argName;
  final DartType argType;
}

/// Information saved about one variant of a union
/// Example: 
/// `SimpleUnion.fooInt(Foo<int> fooInt): super.fooInt(fooInt);`
@immutable
class VariantSpec {
  const VariantSpec({
    @required this.variantName,
    @required this.variantArgs,
  });

  /// Name of the variant. Derived from the name of a constructor
  final String variantName;
  /// Arguments for a given variant constructor.
  final List<ArgSpec> variantArgs;
}

/// Information saved about a union
@immutable
class UnionSpec {
  const UnionSpec({
    @required this.unionName,
    @required this.variants,
  });

  /// Name of the union as specified in the class declaration
  final String unionName;
  /// All possible variants, read from the declared constructors
  final List<VariantSpec> variants;
}

VariantSpec __makeVariantSpec(ConstructorElement ctor) {
  print(ctor);
  final variantArgs = ctor.parameters.map((param) => ArgSpec(argName: param.name, argType: param.type));
  return VariantSpec(
      variantName: ctor.name,
      variantArgs: List.from(variantArgs),
  );
}


UnionSpec makeUnionSpec(Element element, ConstantReader annotation) {
  if (element is ClassElement && !element.isMixin && !element.isEnum) {
    final unionName = element.name;

    final variants = element.constructors
        .where((ctor) => ctor.name?.isNotEmpty == true && !ctor.isFactory)
        .map(__makeVariantSpec);

    return UnionSpec(
      unionName: unionName,
      variants: List.from(variants));
  }
  throw Exception("A BuiltValueUnion declaration must be a class");
}

