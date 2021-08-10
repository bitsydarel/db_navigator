import 'package:flutter/cupertino.dart';

/// Function that define a function that convert json to
/// instance of an destination argument.
typedef DestinationArgumentFromJson = Object Function(Object? json);

/// Marker interface that define that a pojo can be converted to json.
///
/// https://en.wikipedia.org/wiki/Marker_interface_pattern
abstract class HasToJson<T extends Object> {
  /// Const constructor to allow child to define their const constructor
  /// and be used in const expressions.
  const HasToJson();

  /// Convert the pojo to a valid json representation.
  ///
  /// It must be a valid JSON type such as [String], [int],
  /// or [Map<String, Object?>].
  T toJson();
}

/// Class that help convert pojo to json representation and json to pojo.
///
/// Contains a registry of pojo type to [DestinationArgumentFromJson].
class DestinationArgumentConverter {
  /// Map of pojo type in string to mapping function.
  @visibleForTesting
  final Map<String, DestinationArgumentFromJson> helpers;

  /// The singleton instance of the [DestinationArgumentConverter].
  @visibleForTesting
  static DestinationArgumentConverter? instance;

  /// Get an instance of [DestinationArgumentConverter].
  ///
  /// Note: this constructor will always return the same instance per isolate.
  factory DestinationArgumentConverter() {
    return instance ??= DestinationArgumentConverter.private(
      <String, DestinationArgumentFromJson>{},
    );
  }

  /// Create a instance of [DestinationArgumentConverter]
  /// with this list of [helpers].
  @visibleForTesting
  DestinationArgumentConverter.private(this.helpers);

  /// Add the specified pojo from json [mapper] for the specified [type]
  /// to the mapper registry.
  void addHelper(String type, DestinationArgumentFromJson mapper) {
    helpers[type] = mapper;
  }

  /// Get the current [DestinationArgumentFromJson] registry.
  Map<String, DestinationArgumentFromJson> getHelperRegistry() {
    return Map<String, DestinationArgumentFromJson>.unmodifiable(helpers);
  }

  /// Clear the helper registry.
  void clearHelper() {
    helpers.clear();
  }

  /// Convert pojo from [json].
  static Object? pojoFromJson(Object? json) {
    if (json is Map<String, Object?> && json.isNotEmpty) {
      final MapEntry<String, Object?> entry = json.entries.first;

      final DestinationArgumentFromJson? helper =
          DestinationArgumentConverter().helpers[entry.key];

      return helper?.call(entry.value) ?? json;
    }

    return json;
  }

  /// Convert [pojo] to json.
  static Object? pojoToJson(Object? pojo) {
    return pojo is HasToJson
        ? <String, Object>{pojo.runtimeType.toString(): pojo.toJson()}
        : pojo;
  }
}
