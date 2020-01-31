## Built Union (Sum type) values for Dart

`built_union.dart` introduces Union values, also known as: 
- Tagged unions (C)
- Enums (Rust)
- Sum types (Haskell)


A Union value is type that has a few different variants. 
At any given time, the Union value has a value of a certain **single** variant.

You will want to use Built Union if you want to represent a type that means:
"Either this or that, but not both at the same time".

**Fully compatible with** [BuiltValue](https://github.com/google/built_value.dart).

Created as part of the [Offst project](https://www.offst.org).

## How to use?

Add to your `pubspec.yaml` file:

```yaml
dependencies:
    meta: ^1.1.0
    built_union: ^0.1.0
    # built_value: ^7.0.6

dev_dependencies:
    built_union_generator: ^0.1.0
    # built_value_generator: ^7.0.8 
    build_runner: ^1.0.0
```

Note that versions might differ from this example, so make sure to use the
correct versions by checking at [pub.dev](https://pub.dev/).

You will most likely need `built_value` and `built_value_generator` for the
creation of `BuiltValue`s and serialization. If you don't, you can omit those
dependencies.


## Examples

Quick links:
- [Definitions example](built_union_test/test/values.dart)
- [Usage example](built_union_test/test/values_test.dart)

Consider the following `SimpleUnion` definition:

```dart
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
```

The definition above means that `SimpleUnion` always must be in one of a few states:
- empty
- integer
- tuple
- string
- builtList


Some examples for instantiating `SimpleUnion`:

```dart
final simpleUnionEmpty = SimpleUnion.empty();
final simpleUnionInteger = SimpleUnion.integer(3);
final simpleUnionTuple = SimpleUnion.tuple(4, 'four');
final simpleUnionString = SimpleUnion.string('String');
final simpleUnionBuiltList = SimpleUnion.builtList(BuiltList([1,2,3,4]));
```

## Serialization

Built Union supports json serialization.
Example:

```dart
final simpleUnions = [
  SimpleUnion.empty(),
  SimpleUnion.integer(3),
  SimpleUnion.tuple(4, 'four'),
  SimpleUnion.string('string'),
  SimpleUnion.builtList(BuiltList([1,2,3,4])),
];

for (final simpleUnion in simpleUnions) {
  final serialized = serializersWithPlugin.serialize(simpleUnion, specifiedType: FullType(SimpleUnion));

  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  print(encoder.convert(serialized));

  final simpleUnion2 = serializersWithPlugin.deserialize(serialized, specifiedType: FullType(SimpleUnion));
  expect(simpleUnion, simpleUnion2);
}
```

Resulting json:

```
"empty"

{
  "integer": 3
}

{
  "tuple": [
    4,
    "four"
  ]
}

{
  "string": "string"
}

{
  "builtList": [
    1,
    2,
    3,
    4
  ]
}
```

## Unimplemented features

- Generics


## Hacking guide

1. Clone the repository
2. Add dependency overrides
    - built_union_generator/pubspec.yaml: 
        ```yaml
        dependency_overrides:
            built_union:
                path: ../built_union
        ```
    - built_union_test/pubspec.yaml:
        ```yaml
        dependency_overrides:
            built_union:
                path: ../built_union
            built_union_generator:
                path: ../built_union_generator
        ```
3. Run `tool/presubmit` to format, build, analyze and test all packages.

## Thanks

Special thanks to [David Morgan](https://github.com/davidmorgan) for the
guidance during the development of this package. 

See the [original issue](https://github.com/google/built_value.dart/issues/395)
that led to the creation of this package.
