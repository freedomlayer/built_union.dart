import 'package:built_collection/built_collection.dart';

String _getBareType(String name) {
  var genericsStart = name.indexOf('<');
  return genericsStart == -1 ? name : name.substring(0, genericsStart);
}

String _getGenerics(String name) {
  var genericsStart = name.indexOf('<');
  return genericsStart == -1
      ? ''
      : name
          .substring(genericsStart + 1)
          .substring(0, name.length - genericsStart - 2);
}

/// Splits a generic parameter string on top level commas; that means
/// commas nested inside '<' and '>' are ignored.
BuiltList<String> _splitOnTopLevelCommas(String string) {
  var result = ListBuilder<String>();
  var accumulator = StringBuffer();
  var depth = 0;
  for (var i = 0; i != string.length; ++i) {
    if (string[i] == '<') ++depth;
    if (string[i] == '>') --depth;

    if (string[i] == ',' && depth == 0) {
      result.add(accumulator.toString().trim());
      accumulator.clear();
    } else {
      accumulator.write(string[i]);
    }
  }
  if (accumulator.isNotEmpty) {
    result.add(accumulator.toString().trim());
  }
  return result.build();
}

String _generateFullType(String typeName) {
  var bareType = _getBareType(typeName);
  var generics = _getGenerics(typeName);
  var genericItems = _splitOnTopLevelCommas(generics);

  if (generics.isEmpty) {
    return 'const FullType($bareType)';
  } else {
    final parameterFullTypes =
        genericItems.map((item) => _generateFullType(item)).join(', ');
    final canUseConst = parameterFullTypes.startsWith('const ');
    final constOrNew = canUseConst ? 'const' : 'new';
    final constOrEmpty = canUseConst ? 'const' : '';
    return '$constOrNew FullType($bareType, $constOrEmpty [$parameterFullTypes])';
  }
}

String generateFullType(String typeName) {
  return _generateFullType(typeName);
}
