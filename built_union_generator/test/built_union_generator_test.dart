import 'dart:async';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:built_union_generator/built_union_generator.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/*
class BuiltUnionGeneratorTest extends Generator {
  @override
  Object generate(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    print('Was here!!!');
    // throw Exception('Hello!');
    return 'Hello world!';
    // return makeUnionSpec(element, annotation);
  }
  // generateBuiltUnion(makeBuiltUnionSpec(element, annotation));
}
*/

void main() {
  group('generator', () {
    test('Basic test', () async {
      expect(await generate('''library value;
import 'package:built_value/built_value.dart' show Built, Builder, BuiltUnion;
import 'package:built_collection/built_collection.dart' show BuiltList;

part 'value.g.dart';

@BuiltUnion()
class SimpleUnion extends _\$SimpleUnion {
  static Serializer<SimpleUnion> get serializer => _\$simpleUnionSerializer;

  SimpleUnion.empty(): super.empty();
  SimpleUnion.integer(int integer): super.integer(integer);
  SimpleUnion.tuple(int tupleInt, String tupleString): super.tuple(tupleInt, tupleString);
  SimpleUnion.string(String string): super.string(string);
  SimpleUnion.listInt(BuiltList<int> listInt): super.listInt(listInt);
}


'''), contains('_\$SimpleUnion'));
    });
  });
}

// Test setup.

final String pkgName = 'pkg';

final Builder builder = PartBuilder([BuiltUnionGenerator()], '.g.dart');

Future<String> generate(String source) async {
  var srcs = <String, String>{
    'built_value|lib/built_value.dart': builtValueSource,
    '$pkgName|lib/value.dart': source,
  };

  // Capture any error from generation; if there is one, return that instead of
  // the generated output.
  String error;
  void captureError(LogRecord logRecord) {
    if (logRecord.error != null) {
      print('Error:');
      print('-------');
      print(logRecord.error);
      print('\n');
      print('Stack trace:');
      print('-------------');
      print(logRecord.stackTrace);
    }
    if (logRecord.error is InvalidGenerationSourceError) {
      if (error != null) {
        throw StateError('Expected at most one error.');
      }
      error = logRecord.error.toString();
    }
  }

  var writer = InMemoryAssetWriter();
  await testBuilder(builder, srcs,
      rootPackage: pkgName,
      writer: writer,
      onLog: captureError,
      reader: await PackageAssetReader.currentIsolate());

// reader: await PackageAssetReader.currentIsolate());

  return error ??
      String.fromCharCodes(
          writer.assets[AssetId(pkgName, 'lib/value.g.dart')] ?? []);
}

// Fix due to:
// https://github.com/dart-lang/build/pull/2297/commits/05e1c4e013269040324bb68ad544073dbb6084d2
// https://github.com/dart-lang/build/issues/2292
// Not really sure how it works
const String builtValueSource = r'''
// library built_value;

export 'package:built_union/built_union.dart';
export 'package:built_collection/built_collection.dart';
// export 'package:built_value/built_value.dart';
// import 'package:meta/meta.dart';

/*
@immutable
class BuiltUnion {
  const BuiltUnion();
}

abstract class Built<V extends Built<V, B>, B extends Builder<V, B>> {
  V rebuild(updates(B builder));
  B toBuilder();
}

abstract class Builder<V extends Built<V, B>, B extends Builder<V, B>> {
  void replace(V value);
  void update(updates(B builder));
  V build();
}

class BuiltValue {
  final bool comparableBuilders;
  final bool instantiable;
  final bool nestedBuilders;
  final String wireName;

  const BuiltValue({
      this.comparableBuilders: false,
      this.instantiable: true,
      this.nestedBuilders: true,
      this.wireName});
}
*/
''';
