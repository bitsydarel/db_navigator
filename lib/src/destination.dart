import 'package:db_navigator/src/destination_argument_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'destination.g.dart';

/// Navigation destination.
@JsonSerializable(explicitToJson: true)
@immutable
class Destination {
  @JsonKey(disallowNullValue: true, required: true)

  /// The navigation destination path.
  final String path;

  /// The metadata of the destination.
  @JsonKey(disallowNullValue: true)
  final DestinationMetadata metadata;

  /// Create a navigation destination with a [path] and it's [metadata].
  const Destination({
    required this.path,
    this.metadata = const DestinationMetadata(),
  });

  /// Create a [Destination] from [RouteInformation].
  factory Destination.fromRouteInformation(RouteInformation routeInformation,) {
    final Object? argument = routeInformation.state;
    return Destination(
      path: routeInformation.location ?? '' /*TODO think how to handle null*/,
      metadata: argument is DestinationMetadata
          ? argument
          : DestinationMetadata(arguments: argument),
    );
  }

  /// Convert the current [Destination] to a [RouteInformation].
  RouteInformation toRouteInformation() {
    return RouteInformation(location: path, state: metadata);
  }

  /// Convert the current [Destination] to a [RouteSettings].
  RouteSettings toSettings() {
    return RouteSettings(
      name: path,
      arguments: metadata.arguments,
    );
  }

  /// Create a [Destination] from it's json representation.
  factory Destination.fromJson(Map<String, Object?> json) {
    return _$DestinationFromJson(json);
  }

  /// Convert [Destination] instance to a json representation
  Map<String, Object?> toJson() {
    return _$DestinationToJson(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Destination &&
              runtimeType == other.runtimeType &&
              path == other.path &&
              metadata == other.metadata;

  @override
  int get hashCode => path.hashCode ^ metadata.hashCode;

  @override
  String toString() {
    return 'Destination{path: $path, metadata: $metadata}';
  }
}

/// Navigation [Destination]'s metadata.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
@immutable
class DestinationMetadata {
  /// Navigation destination's arguments.
  @JsonKey(
    includeIfNull: false,
    disallowNullValue: true,
    fromJson: DestinationArgumentConverter.pojoFromJson,
    toJson: DestinationArgumentConverter.pojoToJson,
  )
  final Object? arguments;

  /// Navigation destination's history.
  ///
  /// Basically the destinations before the container of
  /// this [DestinationMetadata].
  @JsonKey(
    fromJson: _fromJson,
    toJson: _toJson,
    disallowNullValue: true,
  )
  final List<Destination>? history;

  /// Create a [DestinationMetadata] from [arguments] and [history].
  const DestinationMetadata({this.arguments, this.history});

  /// Create a [DestinationMetadata] from [json].
  factory DestinationMetadata.fromJson(Map<String, Object?> json) {
    return _$DestinationMetadataFromJson(json);
  }

  /// Convert the [DestinationMetadata] to json representation.
  Map<String, Object?> toJson() {
    return _$DestinationMetadataToJson(this);
  }

  static List<Destination>? _fromJson(final Object? jsonHistory) {
    if (jsonHistory is List<dynamic>) {
      final List<Destination> history = <Destination>[];
      for (final dynamic json in jsonHistory) {
        if (json is Map<String, Object?>) {
          history.add(Destination.fromJson(json));
        }
      }
      return history.isEmpty ? null : history;
    }
    return null;
  }

  static List<Map<String, Object?>>? _toJson(final List<Destination>? history) {
    return history
        ?.map((Destination destination) => destination.toJson())
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DestinationMetadata &&
              runtimeType == other.runtimeType &&
              arguments == other.arguments &&
              listEquals<Destination>(history, other.history);

  @override
  int get hashCode => arguments.hashCode ^ history.hashCode;

  @override
  String toString() {
    return 'DestinationMetadata{arguments: $arguments, history: $history}';
  }
}
