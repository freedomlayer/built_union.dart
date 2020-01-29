import 'package:analyzer/dart/element/type.dart';

String getDartTypeName(DartType dartType) {
  if (dartType == null) {
    return null;
  } else if (dartType.isDynamic) {
    return 'dynamic';
  } else if (dartType is FunctionType) {
    return getDartTypeName(dartType.returnType) +
        ' Function(' +
        dartType.parameters.map((p) => getDartTypeName(p.type)).join(', ') +
        ')';
  } else if (dartType is InterfaceType) {
    var typeArguments = dartType.typeArguments;
    if (typeArguments.isEmpty || typeArguments.every((t) => t.isDynamic)) {
      return dartType.element.name;
    } else {
      final typeArgumentsStr = typeArguments.map(getDartTypeName).join(', ');
      return '${dartType.element.name}<$typeArgumentsStr>';
    }
  } else if (dartType is TypeParameterType) {
    return dartType.element.name;
  } else if (dartType.isVoid) {
    return 'void';
  } else {
    throw UnimplementedError('(${dartType.runtimeType}) $dartType');
  }
}
