import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
// import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:built_union/built_union.dart' as annotations show BuiltUnion;

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

/*

abstract class _$SimpleUnion {
  final _$SimpleUnionType _type;
  final List<Object> _values;

  _$SimpleUnion.empty(): _type = _$SimpleUnionType.empty, _values = [];
  _$SimpleUnion.integer(int integer): _type = _$SimpleUnionType.integer, _values = [integer];
  _$SimpleUnion.tuple(int tupleInteger, String tupleString): _type = _$SimpleUnionType.tuple, _values = [tupleInteger, tupleString];
  _$SimpleUnion.string(String string): _type = _$SimpleUnionType.string, _values = [string];
  _$SimpleUnion.fooInt(Foo<int> fooInt): _type = _$SimpleUnionType.fooInt, _values = [fooInt];
  _$SimpleUnion.fooString(Foo<String> fooString): _type = _$SimpleUnionType.fooString, _values = [fooString];

  T match<T>({
    @required T Function() empty,
    @required T Function(int) integer,
    @required T Function(int, String) tuple,
    @required T Function(String) string,
    @required T Function(Foo<int>) fooInt,
    @required T Function(Foo<String>) fooString,
  }) {
    switch (_type) {
      case _$SimpleUnionType.empty:
        return empty();
      case _$SimpleUnionType.integer:
        return integer(_values[0]);
      case _$SimpleUnionType.tuple:
        return tuple(_values[0], _values[1]);
      case _$SimpleUnionType.string:
        return string(_values[0]);
      case _$SimpleUnionType.fooInt:
        return fooInt(_values[0]);
      case _$SimpleUnionType.fooString:
        return fooString(_values[0]);
      default:
        // TODO: Better exception to throw here?
        throw Exception('unknown type');
    }
  }

  bool get isEmpty => _type == _$SimpleUnionType.empty;
  bool get isInteger => _type == _$SimpleUnionType.integer;
  bool get isTuple => _type == _$SimpleUnionType.tuple;
  bool get isString => _type == _$SimpleUnionType.string;
  bool get isfooInt => _type == _$SimpleUnionType.fooInt;
  bool get isFooString => _type == _$SimpleUnionType.fooString;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is _$SimpleUnion) {
      if (_type != other._type) {
        return false;
      }
      if (_values.length != other._values.length) {
        return false;
      }
      for (var i=0; i < _values.length; ++i) {
        if (_values[i] != other._values[i]) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    var curVal = $jc(0, _type.hashCode);
    for (final value in _values) {
      curVal = $jc(curVal, value.hashCode);
    }

    return $jf(curVal);
  }

  @override
  String toString() => (newBuiltValueToStringHelper('SimpleUnion')
        ..add('value', _values)
        ..add('type', _type))
      .toString();
}
*/

String calcEnumName(UnionSpec unionSpec) {
  return '_\$${unionSpec.unionName}Type';
}

String calcClassName(UnionSpec unionSpec) {
  return '_\$${unionSpec.unionName}';
}

/// Generate union type enum code
/// Example:
///
/// ```
/// enum _$SimpleUnionType {
///   empty,
///   integer,
///   tuple,
///   string,
///   fooInt,
///   fooString,
/// }
/// ```
String generateEnumType(UnionSpec unionSpec) {
  List<String> res = [];
  res.add('enum ${calcEnumName(unionSpec)} {');
  for (final variant in unionSpec.variants) {
    res.add('\t${variant.variantName},');
  }
  res.add('}');
  return res.join('\n');
}

/// Generate a class constructor.
/// Example:
/// ```
/// _$SimpleUnion.integer(int integer): _type = _$SimpleUnionType.integer, _values = [integer];
/// ```
String generateClassConstructor(
    String className, String enumName, VariantSpec variant) {
  List<String> res = [];

  // Constructor name:
  res.add('$className.${variant.variantName}(');

  // Add List of arguments:
  List<String> args = [];
  for (final argSpec in variant.variantArgs) {
    args.add('${argSpec.argType.toString()} ${argSpec.argName}');
  }
  res.add(args.join(','));
  res.add('): ');

  // Set type:
  res.add('_type = $enumName.${variant.variantName}, ');

  // Set values:
  res.add('values = [');

  // Collect all values:
  List<String> values = [];
  for (final argSpec in variant.variantArgs) {
    values.add(argSpec.argName);
  }

  // Add values:
  res.add(values.join(','));

  // Close values:
  res.add('];');

  return res.join('');
}

/// Generate list of constructors for the base autogenerated class
/// Example:
/// ```
/// _$SimpleUnion.empty(): _type = _$SimpleUnionType.empty, _values = [];
/// _$SimpleUnion.integer(int integer): _type = _$SimpleUnionType.integer, _values = [integer];
/// _$SimpleUnion.tuple(int tupleInteger, String tupleString): _type = _$SimpleUnionType.tuple, _values = [tupleInteger, tupleString];
/// _$SimpleUnion.string(String string): _type = _$SimpleUnionType.string, _values = [string];
/// _$SimpleUnion.fooInt(Foo<int> fooInt): _type = _$SimpleUnionType.fooInt, _values = [fooInt];
/// _$SimpleUnion.fooString(Foo<String> fooString): _type = _$SimpleUnionType.fooString, _values = [fooString];
/// ```
String generateClassConstructors(UnionSpec unionSpec) {
  List<String> res = [];

  for (final variant in unionSpec.variants) {
    res.add(generateClassConstructor(
        calcClassName(unionSpec), calcEnumName(unionSpec), variant));
  }
  return res.join('\n');
}

/// Generate one match argument
/// Example:
/// ```
/// @required T Function(int, String) tuple,
/// ```
String generateMatchArg(VariantSpec variantSpec) {
  List<String> argTypes = [];
  for (final arg in variantSpec.variantArgs) {
    argTypes.add(arg.argType.toString());
  }
  return '@required T Function(${argTypes.join(',')}) ${variantSpec.variantName}';
}

/// Generate one match body switch case
/// Example:
/// ```
/// case _$SimpleUnionType.tuple:
///   return tuple(_values[0], _values[1]);
/// ```
String generateMatchCase(String enumName, VariantSpec variantSpec) {
  List<String> res = [];

  res.add('case $enumName.${variantSpec.variantName}:');

  List<String> values = [];
  for (var i = 0; i < variantSpec.variantArgs.length; ++i) {
    values.add('_values[$i]');
  }

  res.add('\treturn ${variantSpec.variantName}(${values.join(',')});');

  return res.join('\n');
}

/// Generate a match method
/// Example:
/// ```
/// T match<T>({
///   @required T Function() empty,
///   @required T Function(int) integer,
///   @required T Function(int, String) tuple,
///   @required T Function(String) string,
///   @required T Function(Foo<int>) fooInt,
///   @required T Function(Foo<String>) fooString,
/// }) {
///   switch (_type) {
///     case _$SimpleUnionType.empty:
///       return empty();
///     case _$SimpleUnionType.integer:
///       return integer(_values[0]);
///     case _$SimpleUnionType.tuple:
///       return tuple(_values[0], _values[1]);
///     case _$SimpleUnionType.string:
///       return string(_values[0]);
///     case _$SimpleUnionType.fooInt:
///       return fooInt(_values[0]);
///     case _$SimpleUnionType.fooString:
///       return fooString(_values[0]);
///     default:
///       // TODO: Better exception to throw here?
///       throw Exception('unknown type');
///   }
/// }
/// ```
String generateMatch(UnionSpec unionSpec) {
  List<String> res = [];

  // Begin match declaration:
  res.add('T match<T>({');

  // match arguments:
  List<String> matchArgs = [];
  for (final variant in unionSpec.variants) {
    matchArgs.add(generateMatchArg(variant));
  }
  res.add(matchArgs.join(',\n'));

  // End match declaration and begin body:
  res.add('}) {');

  // Begin switch statement:
  res.add('switch (_type) {');

  // Add cases:
  for (final variant in unionSpec.variants) {
    res.add(generateMatchCase(calcEnumName(unionSpec), variant));
  }

  // Default case:
  res.add('default:');

  // TODO: Possibly get a better exception here?
  res.add('''throw Exception('${unionSpec.unionName}: Unknown type');''');

  // End switch statement:
  res.add('}');

  // End match body:
  res.add('}');

  return res.join('\n');
}

/// Generate the equality operator for the autogenerated class.
/// Example:
/// ```
/// @override
/// bool operator ==(Object other) {
///   if (identical(other, this)) {
///     return true;
///   }
///   if (other is _$SimpleUnion) {
///     if (_type != other._type) {
///       return false;
///     }
///     if (_values.length != other._values.length) {
///       return false;
///     }
///     for (var i=0; i < _values.length; ++i) {
///       if (_values[i] != other._values[i]) {
///         return false;
///       }
///     }
///     return true;
///   } else {
///     return false;
///   }
/// }
/// ```
String generateEqualOperator(String className) {
  return '''
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is $className) {
      if (_type != other._type) {
        return false;
      }
      if (_values.length != other._values.length) {
        return false;
      }
      for (var i=0; i < _values.length; ++i) {
        if (_values[i] != other._values[i]) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }
  ''';

}

/// Generate union base class
/// Example:
/// ```
/// abstract class _$SimpleUnion {
///   final _$SimpleUnionType _type;
///   final List<Object> _values;
///
///   // ... Constructors ...
///
///   // ... Match method ...
///
///   bool get isEmpty => _type == _$SimpleUnionType.empty;
///   bool get isInteger => _type == _$SimpleUnionType.integer;
///   bool get isTuple => _type == _$SimpleUnionType.tuple;
///   bool get isString => _type == _$SimpleUnionType.string;
///   bool get isListInt => _type == _$SimpleUnionType.listInt;
///
///   // ... Equal (==) operator
///
///   @override
///   int get hashCode {
///     var curVal = $jc(0, _type.hashCode);
///     for (final value in _values) {
///       curVal = $jc(curVal, value.hashCode);
///     }
///
///     return $jf(curVal);
///   }
///
///   @override
///   String toString() => (newBuiltValueToStringHelper('SimpleUnion')
///         ..add('value', _values)
///         ..add('type', _type))
///       .toString();
/// }
/// ```
String generateClass(UnionSpec unionSpec) {
  List<String> res = [];

  // Class header:
  res.add('abstract class ${calcClassName(unionSpec)} {');

  // Class state: _type and _values:
  res.add('\tfinal ${calcClassName(unionSpec)} _type;');
  res.add('\tfinal List<object> _values;');

  res.add(generateClassConstructors(unionSpec));
  res.add(generateMatch(unionSpec));
  res.add(generateEqualOperator(calcClassName(unionSpec)));

  res.add('}');

  return res.join('\n');
}

String generateBuiltUnion(UnionSpec unionSpec) {
  List<String> res = [];
  res.add(generateEnumType(unionSpec));
  res.add(generateClass(unionSpec));

  return res.join('\n');
  // return 'Hello world';
}
