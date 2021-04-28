import 'union_spec.dart';
import 'utils.dart';

/// Change first letter of a string to be lower case
String decapitalize(String inputStr) {
  if (inputStr.isEmpty) {
    return inputStr;
  } else {
    return inputStr[0].toLowerCase() + inputStr.substring(1);
  }
}

/// Generate one match arm code for the serialize method.
/// Examples:
///
/// 1) Empty variant:
/// ```
/// empty: () => <Object?>['empty'],
/// ```
///
/// 2) Single value variant:
/// ```
/// integer: (value0) => <Object?>[
///     'integer',
///     serializers.serialize(value0, specifiedType: const FullType(int))
/// ],
/// ```
///
/// 3) Multiple values variant:
/// ```
/// tuple: (value0, value1) => <Object?>[
///     'tuple',
///     <Object?>[serializers.serialize(value0, specifiedType: const FullType(int)),
///     serializers.serialize(value1,
///     specifiedType: const FullType(String))]
/// ],
/// ```
String generateSerializeMatchArm(VariantSpec variantSpec) {
  if (variantSpec.variantArgs.isEmpty) {
    // Empty variant
    return '''${variantSpec.variantName}: () => <Object?>['${variantSpec.variantName}'],''';
  }

  if (variantSpec.variantArgs.length == 1) {
    /// This variant contains exactly one argument
    final argSpec = variantSpec.variantArgs[0];
    return '''${variantSpec.variantName}: (${argSpec.argName}) => <Object?>['${variantSpec.variantName}',\n''' +
        'serializers.serialize(${argSpec.argName}, specifiedType: ${generateFullType(argSpec.argType.toString())})\n' +
        '],';
  }

  /// Variant contains at least two arguments
  List<String> res = [];
  res.add('${variantSpec.variantName}: (');
  res.add(variantSpec.variantArgs.map((argSpec) => argSpec.argName).join(','));
  res.add(') => <Object?>[');
  res.add(''''${variantSpec.variantName}',''');
  res.add('<Object?>[');
  res.add(variantSpec.variantArgs
      .map((argSpec) =>
          'serializers.serialize(${argSpec.argName}, specifiedType: ${generateFullType(argSpec.argType.toString())}) as ${argSpec.argType.toString()}')
      .join(','));
  res.add(']');
  res.add('],');
  return res.join('\n');
}

/// Generate serialize method code
/// Example:
/// ```
/// @override
/// Iterable<Object> serialize(Serializers serializers, SimpleUnion object,
///     {FullType specifiedType = FullType.unspecified}) {
///   return object.match(
///
///       // ... match arms ...
///
///   );
/// }
/// ```
String generateSerializeMethod(UnionSpec unionSpec) {
  List<String> res = [];
  // Begin method scope:
  res.add('@override');
  res.add(
      'Iterable<Object?> serialize(Serializers serializers, ${unionSpec.unionName} object,');
  res.add('{FullType specifiedType = FullType.unspecified}) {');

  // Begin match:
  res.add('return object.match(');

  // Generate match arms:
  for (final variant in unionSpec.variants) {
    res.add(generateSerializeMatchArm(variant));
  }

  // Close match:
  res.add(');');

  // Close method scope:
  res.add('}');

  return res.join('\n');
}

/// Generate one deserialize switch case for a certain variant
/// Examples:
///
/// 1) Empty variant:
/// ```
/// case 'empty':
///   result = SimpleUnion.empty();
///   break;
/// ```
///
/// 2) Single value variant:
/// ```
/// case 'integer':
///   iterator.moveNext();
///   final dynamic value = iterator.current;
///   result = SimpleUnion.integer(serializers.deserialize(value,
///       specifiedType: const FullType(int)) as int);
///   break;
/// ```
///
/// 3) Multiple values variant:
/// ```
/// case 'tuple':
///   final innerIterator = (iterator.current as Iterable<Object>).iterator;
///   innerIterator.moveNext();
///   final dynamic value0 = innerIterator.current;
///   innerIterator.moveNext();
///   final dynamic value1 = innerIterator.current;
///
///   result = SimpleUnion.tuple(
///       serializers.deserialize(value0, specifiedType: const FullType(int)) as int,
///       serializers.deserialize(value1,
///           specifiedType: const FullType(String)) as String);
///   break;
/// ```
String generateDeserializeSwitchCase(
    String userClassName, VariantSpec variantSpec) {
  if (variantSpec.variantArgs.isEmpty) {
    // Empty variant
    return '''case '${variantSpec.variantName}':\n''' +
        'result = $userClassName.${variantSpec.variantName}();\n' +
        'break;';
  }

  if (variantSpec.variantArgs.length == 1) {
    // Variant with a single value
    final argSpec = variantSpec.variantArgs[0];
    return '''case '${variantSpec.variantName}':\n''' +
        'iterator.moveNext();\n' +
        'result = $userClassName.${variantSpec.variantName}(' +
        'serializers.deserialize(iterator.current, ' +
        'specifiedType: ${generateFullType(argSpec.argType.toString())}) as ${argSpec.argType.toString()});\n' +
        'break;';
  }

  // A variant with multiple values
  List<String> res = [];
  res.add('''case '${variantSpec.variantName}':''');
  res.add('iterator.moveNext();');
  res.add('final innerIterator = (iterator.current as Iterable).iterator;');

  // Obtain all values:
  res.add(variantSpec.variantArgs
      .map((argSpec) =>
          'innerIterator.moveNext();\n' +
          'final Object ${argSpec.argName} = innerIterator.current;')
      .join('\n'));

  // Instantiate variant:
  res.add('result = $userClassName.${variantSpec.variantName}(');
  res.add(variantSpec.variantArgs
      .map((argSpec) =>
          'serializers.deserialize(${argSpec.argName},' +
          'specifiedType: ${generateFullType(argSpec.argType.toString())}) as ${argSpec.argType.toString()},')
      .join('\n'));
  res.add(');');
  res.add('break;');

  return res.join('\n');
}

/// Generate deserialize method code
/// Example:
/// ```
/// @override
/// SimpleUnion deserialize(Serializers serializers, Iterable<Object?> serialized,
///     {FullType specifiedType = FullType.unspecified}) {
///
///   final iterator = serialized.iterator;
///   iterator.moveNext();
///   final key = iterator.current as String;
///   iterator.moveNext();
///   var result;
///   switch (key) {
///
///     // ... cases ...
///
///     default:
///       throw StateError('Unknown variant $key');
///   }
///
///   return result;
/// }
/// ```
String generateDeserializeMethod(UnionSpec unionSpec) {
  List<String> res = [];

  // Method declaration:
  res.add('@override');
  res.add(
      '${unionSpec.unionName} deserialize(Serializers serializers, Iterable<Object?> serialized, ');
  res.add('{FullType specifiedType = FullType.unspecified}) {');

  // Some variables:
  res.add('final iterator = serialized.iterator;');
  res.add('iterator.moveNext();');
  res.add('final key = iterator.current as String;');
  res.add('var result;');

  res.add('switch (key) {');
  for (final variant in unionSpec.variants) {
    res.add(generateDeserializeSwitchCase(unionSpec.unionName, variant));
  }

  // Default case:
  res.add('default:');
  // TODO: Possibly throw a different kind of exception?
  res.add('''throw StateError('Unknown variant \$key');''');

  // TOOD: Add default case
  res.add('}');

  // Final return statement:
  res.add('return result;');

  // Close method:
  res.add('}');

  return res.join('\n');
}

/// Generate serializer code for the union
/// Example:
/// ```
/// Serializer<SimpleUnion> _$simpleUnionSerializer = new _$SimpleUnionSerializer();
///
/// class _$SimpleUnionSerializer implements StructuredSerializer<SimpleUnion> {
///   @override
///   final Iterable<Type> types = const [SimpleUnion, _$SimpleUnion];
///   @override
///   final String wireName = 'SimpleUnion';
///
///   // ... serialize method ...
///
///   // ... deserialize method ...
///
/// }
/// ```
String generateSerializerClass(UnionSpec unionSpec) {
  List<String> res = [];

  final serializerClassName = '_\$${unionSpec.unionName}Serializer';
  final serializerName = '_\$${decapitalize(unionSpec.unionName)}Serializer';
  res.add('Serializer<${unionSpec.unionName}> $serializerName = ' +
      'new $serializerClassName();');

  // Class declaration:
  res.add(
      'class $serializerClassName implements StructuredSerializer<${unionSpec.unionName}> {');
  // types:
  res.add('@override');
  res.add(
      'final Iterable<Type> types = const [${unionSpec.unionName}, ${calcClassName(unionSpec)}];');
  // wireName:
  res.add('@override');
  res.add('''final String wireName = '${unionSpec.unionName}';''');

  // serialize method:
  res.add(generateSerializeMethod(unionSpec));

  // deserialize method:
  res.add(generateDeserializeMethod(unionSpec));

  // Close class scope:
  res.add('}');

  return res.join('\n');
}
