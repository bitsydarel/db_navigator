import 'package:flutter/cupertino.dart';

/// Function that define a function that convert json to instance of an pojo.
typedef PojoFromJson = Object Function(Object? json);

/// Marker interface that define that a pojo can be converted to json.
///
/// https://en.wikipedia.org/wiki/Marker_interface_pattern
abstract class JsonToPojo<T extends Object> {
  /// Create a constant [JsonToPojo] instance.
  const JsonToPojo();

  /// Convert the pojo to a valid json representation.
  ///
  /// It must be a valid JSON type such as [String], [int],
  /// or [Map<String, Object?>].
  T toJson();
}

/// Class that help convert pojo to json representation and json to pojo.
///
/// Contains a registry of pojo type to [PojoFromJson].
class JsonPojoConverter {
  /// Map of pojo type in string to mapping function.
  @visibleForTesting
  final Map<String, PojoFromJson> helpers;

  /// The singleton instance of the [JsonPojoConverter].
  @visibleForTesting
  static JsonPojoConverter? instance;

  /// Get an instance of [JsonPojoConverter].
  ///
  /// Note: this constructor will always return the same instance per isolate.
  factory JsonPojoConverter() {
    return instance ??= JsonPojoConverter.private(<String, PojoFromJson>{});
  }

  /// Create a instance of [JsonPojoConverter] with this list of [helpers].
  @visibleForTesting
  JsonPojoConverter.private(this.helpers);

  /// Add the specified pojo from json [mapper] for the specified [type]
  /// to the mapper registry.
  void addHelper(String type, PojoFromJson mapper) {
    helpers[type] = mapper;
  }

  /// Get the current [PojoFromJson] registry.
  Map<String, PojoFromJson> getHelperRegistry() {
    return Map<String, PojoFromJson>.unmodifiable(helpers);
  }

  /// Clear the helper registry.
  void clearHelper() {
    helpers.clear();
  }

  /// Convert pojo from [json].
  static Object? pojoFromJson(Object? json) {
    if (json is Map<String, Object?> && json.isNotEmpty) {
      final MapEntry<String, Object?> entry = json.entries.first;

      return JsonPojoConverter().helpers[entry.key]?.call(entry.value) ?? json;
    }

    return json;
  }

  /// Convert [pojo] to json.
  static Object? pojoToJson(Object? pojo) {
    return pojo is JsonToPojo
        ? <String, Object>{pojo.runtimeType.toString(): pojo.toJson()}
        : pojo;
  }
}
