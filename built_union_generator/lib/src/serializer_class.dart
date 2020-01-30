import 'union_spec.dart';

/*
Serializer<SimpleUnion> _$simpleUnionSerializer = new _$SimpleUnionSerializer();

class _$SimpleUnionSerializer implements StructuredSerializer<SimpleUnion> {
  @override
  final Iterable<Type> types = const [SimpleUnion, _$SimpleUnion];
  @override
  final String wireName = 'SimpleUnion';

  @override
  Iterable<Object> serialize(Serializers serializers, SimpleUnion object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = object.match(
        empty: () => <Object>['empty'],
        integer: (value0) => <Object>[
              'integer',
              serializers.serialize(value0, specifiedType: const FullType(int))
            ],
        tuple: (value0, value1) => <Object>[
              'tuple',
              <Object>[serializers.serialize(value0, specifiedType: const FullType(int)),
              serializers.serialize(value1,
                  specifiedType: const FullType(String))]
            ],
        string: (value0) => <Object>[
              'string',
              serializers.serialize(value0,
                  specifiedType: const FullType(String))
            ],
        fooInt: (value0) {
          print('value0 = $value0');
          print(value0.data);
          return <Object>[
            'fooInt',
            serializers.serialize(value0, specifiedType: const FullType(Foo))
          ];
        },
        fooString: (value0) => <Object>[
              'fooString',
              serializers.serialize(value0, specifiedType: const FullType(Foo))
            ]);

    return result;
  }

  @override
  SimpleUnion deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {

    final iterator = serialized.iterator;
    iterator.moveNext();
    final key = iterator.current as String;
    iterator.moveNext();
    final Object value = iterator.current;
    var result;
    switch (key) {
      case 'empty':
        result = SimpleUnion.empty();
        break;
      case 'integer':
        iterator.moveNext();
        result = SimpleUnion.integer(serializers.deserialize(value,
            specifiedType: const FullType(int)));
        break;
      case 'tuple':
        final iterator = (value as Iterable<Object>).iterator;
        iterator.moveNext();
        final dynamic value0 = iterator.current;
        iterator.moveNext();
        final dynamic value1 = iterator.current;

        result = SimpleUnion.tuple(
            serializers.deserialize(value0, specifiedType: const FullType(int)),
            serializers.deserialize(value1,
                specifiedType: const FullType(String)));
        break;
      case 'string':
        result = SimpleUnion.integer(serializers.deserialize(value,
            specifiedType: const FullType(String)));
        break;
      case 'fooInt':
        result = SimpleUnion.fooInt(serializers.deserialize(value,
            specifiedType: const FullType(Foo)));
        break;
      case 'fooString':
        result = SimpleUnion.fooInt(serializers.deserialize(value,
            specifiedType: const FullType(Foo)));
        break;
    }

    return result;
  }
}
*/

/// Change first letter of a string to be lower case
String decapitalize(String inputStr) {
  if (inputStr.isEmpty) {
    return inputStr;
  } else {
    return inputStr[0].toLowerCase() + inputStr.substring(1);
  }
}

/// Strip type generics from type's name
/// Example: Input: `MyType<T,S>`, Ouptput: `MyType`
String stripGenerics(String typeName) {
  return typeName.split('<')[0];
}

/// Generate one match arm code for the serialize method.
/// Examples:
///
/// 1) Empty variant:
/// ```
/// empty: () => <Object>['empty'],
/// ```
///
/// 2) Single value variant:
/// ```
/// integer: (value0) => <Object>[
///     'integer',
///     serializers.serialize(value0, specifiedType: const FullType(int))
/// ],
/// ```
///
/// 3) Multiple values variant:
/// ```
/// tuple: (value0, value1) => <Object>[
///     'tuple',
///     <Object>[serializers.serialize(value0, specifiedType: const FullType(int)),
///     serializers.serialize(value1,
///     specifiedType: const FullType(String))]
/// ],
/// ```
String generateSerializeMatchArm(VariantSpec variantSpec) {
  if (variantSpec.variantArgs.isEmpty) {
    // Empty variant
    return '''${variantSpec.variantName}: () => <Object>['${variantSpec.variantName}'],''';
  }

  if (variantSpec.variantArgs.length == 1) {
    /// This variant contains exactly one argument
    final argSpec = variantSpec.variantArgs[0];
    return '''${variantSpec.variantName}: (${argSpec.argName}) => <Object>['${variantSpec.variantName}',\n''' +
        'serializers.serialize(value, specifiedType: const FullType(${stripGenerics(argSpec.argType.toString())}))\n' + 
        '],';
  }

  /// Variant contains at least two arguments
  List<String> res = [];
  res.add('${variantSpec.variantName}: (');
  res.add(variantSpec.variantArgs.map((argSpec) => argSpec.argName).join(','));
  res.add(') => <Object>[');
  res.add(''''${variantSpec.variantName}',''');
  res.add('<Object>[');
  res.add(variantSpec.variantArgs
      .map((argSpec) =>
          'serializers.serialize(${argSpec.argName}, specifiedType: const FullType(${stripGenerics(argSpec.argType.toString())}))')
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
///       empty: () => <Object>['empty'],
///       integer: (value0) => <Object>[
///             'integer',
///             serializers.serialize(value0, specifiedType: const FullType(int))
///           ],
///       tuple: (value0, value1) => <Object>[
///             'tuple',
///             <Object>[serializers.serialize(value0, specifiedType: const FullType(int)),
///             serializers.serialize(value1,
///                 specifiedType: const FullType(String))]
///           ],
///       string: (value0) => <Object>[
///             'string',
///             serializers.serialize(value0,
///                 specifiedType: const FullType(String))
///           ],
///       fooInt: (value0) {
///         return <Object>[
///           'fooInt',
///           serializers.serialize(value0, specifiedType: const FullType(Foo))
///         ];
///       },
///       fooString: (value0) => <Object>[
///             'fooString',
///             serializers.serialize(value0, specifiedType: const FullType(Foo))
///           ]);
/// }
/// ```
String generateSerializeMethod(UnionSpec unionSpec) {
  List<String> res = [];
  // Begin method scope:
  res.add('@override');
  res.add(
      'Iterable<Object> serialize(Serializers serializers, ${unionSpec.unionName} object,');
  res.add('{FullType specifiedType = FullType.unspecified}) {');

  // Begin match:
  res.add('return object.match(');

  for (final variant in unionSpec.variants) {
    res.add(generateSerializeMatchArm(variant));
  }

  // Close match:
  res.add(');');

  // Close method scope:
  res.add('}');

  return res.join('\n');
}

/// Generate deserialize method code
/// Example:
/// ```
/// @override
/// SimpleUnion deserialize(Serializers serializers, Iterable<Object> serialized,
///     {FullType specifiedType = FullType.unspecified}) {
///
///   final iterator = serialized.iterator;
///   iterator.moveNext();
///   final key = iterator.current as String;
///   iterator.moveNext();
///   final Object value = iterator.current;
///   var result;
///   switch (key) {
///     case 'empty':
///       result = SimpleUnion.empty();
///       break;
///     case 'integer':
///       iterator.moveNext();
///       result = SimpleUnion.integer(serializers.deserialize(value,
///           specifiedType: const FullType(int)));
///       break;
///     case 'tuple':
///       final iterator = (value as Iterable<Object>).iterator;
///       iterator.moveNext();
///       final dynamic value0 = iterator.current;
///       iterator.moveNext();
///       final dynamic value1 = iterator.current;
///
///       result = SimpleUnion.tuple(
///           serializers.deserialize(value0, specifiedType: const FullType(int)),
///           serializers.deserialize(value1,
///               specifiedType: const FullType(String)));
///       break;
///     case 'string':
///       result = SimpleUnion.integer(serializers.deserialize(value,
///           specifiedType: const FullType(String)));
///       break;
///     case 'fooInt':
///       result = SimpleUnion.fooInt(serializers.deserialize(value,
///           specifiedType: const FullType(Foo)));
///       break;
///     case 'fooString':
///       result = SimpleUnion.fooInt(serializers.deserialize(value,
///           specifiedType: const FullType(Foo)));
///       break;
///   }
///
///   return result;
/// }
/// ```
String generateDeserializeMethod(UnionSpec unionSpec) {
  // TODO:
  throw UnimplementedError;
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
  // res.add(generateDeserializeMethod(unionSpec));

  // Close class scope:
  res.add('}');

  return res.join('\n');
}
