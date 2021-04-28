import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/serializer.dart';

/// A json serializer plugin. Works exactly the same as the StandardJsonPlugin,
/// except for a minor modification that allows to serialize empty union variants correctly.
class CustomJsonPlugin extends StandardJsonPlugin {
  @override
  Object? afterSerialize(Object? object, FullType specifiedType) {
    if (object is List &&
        specifiedType.root != BuiltList &&
        specifiedType.root != BuiltSet &&
        specifiedType.root != JsonObject) {
      if (specifiedType.isUnspecified) {
        return super.afterSerialize(object, specifiedType);
      } else {
        // A case used for an empty Union variant:
        if (object.length == 1 && object[0] != 'list') {
          return object[0];
        }
        return super.afterSerialize(object, specifiedType);
      }
    } else {
      return object;
    }
  }

  @override
  Object? beforeDeserialize(Object? object, FullType specifiedType) {
    if (object is Map && specifiedType.root != JsonObject) {
      if (specifiedType.isUnspecified) {
        return super.beforeDeserialize(object, specifiedType);
      } else {
        return super.beforeDeserialize(object, specifiedType);
      }
    } else {
      // A case used for an empty Union variant
      if (specifiedType.root != String && object is String) {
        return <Object>[object];
      }
      return object;
    }
  }
}
