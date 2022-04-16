import 'dart:convert';

import 'package:db_navigator/src/destination.dart';
import 'package:db_navigator/src/destination_argument_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'destination_json_serialization',
    () {
      const JsonEncoder encoder = JsonEncoder();
      const JsonDecoder decoder = JsonDecoder();

      test(
        'encode destination without metadata and decode it',
        () {
          const Destination destination = Destination(path: '/');

          final String rawJson = encoder.convert(destination);

          expect(rawJson, isNotEmpty);

          final dynamic json = decoder.convert(rawJson);

          final Destination recoveredDestination = Destination.fromJson(
            json is Map<String, Object?>
                ? json
                : throw ArgumentError.value(json),
          );

          expect(recoveredDestination, equals(destination));
        },
      );

      test(
        'encode destination with metadata but without history and decode it',
        () {
          const Destination destination = Destination(
            path: '/',
            metadata: DestinationMetadata(arguments: 2),
          );

          final String rawJson = encoder.convert(destination);

          expect(rawJson, isNotEmpty);

          final dynamic json = decoder.convert(rawJson);

          final Destination recoveredDestination = Destination.fromJson(
            json is Map<String, Object?>
                ? json
                : throw ArgumentError.value(json),
          );

          expect(recoveredDestination, equals(destination));
        },
      );

      test(
        'encode destination with history without sub history and decode it',
        () {
          const Destination destination = Destination(
            path: '/home',
            metadata: DestinationMetadata(
              arguments: 'HOMEPAGE',
              history: <Destination>[Destination(path: '/')],
            ),
          );

          final String rawJson = encoder.convert(destination);

          expect(rawJson, isNotEmpty);

          final dynamic json = decoder.convert(rawJson);

          final Destination recoveredDestination = Destination.fromJson(
            json is Map<String, Object?>
                ? json
                : throw ArgumentError.value(json),
          );

          expect(recoveredDestination, equals(destination));
        },
      );

      test(
        'encode destination with history without sub history and decode it',
        () {
          const Destination destination = Destination(
            path: '/profile',
            metadata: DestinationMetadata(
              arguments: 'User 1',
              history: <Destination>[
                Destination(path: '/'),
                Destination(
                  path: '/home',
                  metadata: DestinationMetadata(
                    history: <Destination>[Destination(path: '/')],
                  ),
                ),
              ],
            ),
          );

          final String rawJson = encoder.convert(destination);

          expect(rawJson, isNotEmpty);

          final dynamic json = decoder.convert(rawJson);

          final Destination recoveredDestination = Destination.fromJson(
            json is Map<String, Object?>
                ? json
                : throw ArgumentError.value(json),
          );

          expect(recoveredDestination, equals(destination));
        },
      );

      test(
        'encode destination custom metadata argument and decode it',
        () {
          DestinationArgumentConverter()
              .addHelper('_Feature', _Feature.fromJson);

          const Destination destination = Destination(
            path: '/',
            metadata: DestinationMetadata(arguments: _testFeature),
          );

          final String rawJson = encoder.convert(destination);

          expect(rawJson, isNotEmpty);

          final dynamic json = decoder.convert(rawJson);

          final Destination recoveredDestination = Destination.fromJson(
            json is Map<String, Object?>
                ? json
                : throw ArgumentError.value(json),
          );

          expect(recoveredDestination, equals(destination));
        },
      );
    },
  );
}

const _Feature _testFeature = _Feature(
  name: 'Navigation',
  progress: _Progress.completed,
  infoBullets: <String>[
    // ignore: lines_longer_than_80_chars
    'Navigate across, into, and back out from the different pieces of content within your app',
    'Passing data between destinations',
    'Supports nested routes',
    'Uses latest Navigator 2.0 API',
    'Covered with unit tests'
  ],
);

@immutable
class _Feature implements HasToJson<Map<String, Object?>> {
  const _Feature({
    required this.name,
    required this.progress,
    required this.infoBullets,
  });

  final String name;

  final _Progress progress;

  final List<String> infoBullets;

  static Object fromJson(Object? json) {
    if (json is Map<String, Object?>) {
      final Object? rawName = json['name'];
      final Object? rawProgress = json['progress'];
      final Object? rawInfoBullets = json['infoBullets'];

      return _Feature(
        name: rawName is String ? rawName : throw ArgumentError.value(rawName),
        progress: rawProgress is int
            ? _Progress.values[rawProgress]
            : throw ArgumentError.value(rawProgress),
        infoBullets: rawInfoBullets is List
            ? rawInfoBullets.map((dynamic e) => e.toString()).toList()
            : throw ArgumentError.value(rawInfoBullets),
      );
    } else {
      throw ArgumentError.value(json);
    }
  }

  /// Convert the [DestinationMetadata] to json representation.
  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'progress': progress.index,
      'infoBullets': infoBullets
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Feature &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          progress == other.progress &&
          listEquals<String>(infoBullets, other.infoBullets);

  @override
  int get hashCode => name.hashCode ^ progress.hashCode ^ infoBullets.hashCode;

  @override
  String toString() {
    return '_Feature{name: $name, progress: $progress,'
        ' infoBullets: $infoBullets}';
  }
}

enum _Progress {
  planned,
  investigation,
  completed,
}
