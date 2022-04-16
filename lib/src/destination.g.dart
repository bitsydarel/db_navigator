// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Destination _$DestinationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['path'],
    disallowNullValues: const ['path', 'metadata'],
  );
  return Destination(
    path: json['path'] as String,
    metadata: json['metadata'] == null
        ? const DestinationMetadata()
        : DestinationMetadata.fromJson(
            json['metadata'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$DestinationToJson(Destination instance) =>
    <String, dynamic>{
      'path': instance.path,
      'metadata': instance.metadata.toJson(),
    };

DestinationMetadata _$DestinationMetadataFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    disallowNullValues: const ['arguments', 'history'],
  );
  return DestinationMetadata(
    arguments: DestinationArgumentConverter.pojoFromJson(json['arguments']),
    history: DestinationMetadata._fromJson(json['history']),
  );
}

Map<String, dynamic> _$DestinationMetadataToJson(DestinationMetadata instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'arguments', DestinationArgumentConverter.pojoToJson(instance.arguments));
  writeNotNull('history', DestinationMetadata._toJson(instance.history));
  return val;
}
