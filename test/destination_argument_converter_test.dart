import 'package:db_navigator/src/destination_argument_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('JsonPojoConverter initializes once and then returns the same instance',
      () {
    final DestinationArgumentConverter pojoConverter =
        DestinationArgumentConverter();

    expect(
      identical(DestinationArgumentConverter.instance, pojoConverter),
      isTrue,
    );
  });

  group(
    'addHelper',
    () {
      test(
        'should add entry to helpers map',
        () {
          final DestinationArgumentConverter converter =
              DestinationArgumentConverter();

          expect(converter.helpers.isEmpty, isTrue);

          converter.addHelper('PersonHelper', _Person.fromJson);

          expect(converter.helpers.containsKey('PersonHelper'), isTrue);
        },
      );
    },
  );

  group(
    'getHelperRegistry',
    () {
      test(
        'should return a map of existent helpers',
        () {
          final DestinationArgumentConverter converter =
              DestinationArgumentConverter()
                ..addHelper('PersonHelper', _Person.fromJson);

          final Map<String, DestinationArgumentFromJson> helpers =
              converter.getHelperRegistry();

          expect(helpers, equals(converter.helpers));
        },
      );
    },
  );

  group(
    'clearHelper',
    () {
      test(
        'should clear all helpers',
        () {
          final DestinationArgumentConverter converter =
              DestinationArgumentConverter();

          for (int i = 0; i < 5; i++) {
            converter.addHelper('helper #$i', _Person.fromJson);
          }

          expect(converter.helpers, isNotEmpty);

          converter.clearHelper();

          expect(converter.helpers.isEmpty, isTrue);
        },
      );
    },
  );

  group(
    'pojoFromJson',
    () {
      test(
        'should convert json to pojo',
        () {
          final DestinationArgumentConverter _ = DestinationArgumentConverter()
            ..addHelper('PersonHelper', _Person.fromJson);

          final _Person somePerson = _Person(fullName: 'Arden Rose', age: 28);

          final Map<String, Object?> json = <String, Object?>{
            'PersonHelper': <String, Object?>{
              'fullName': somePerson.fullName,
              'age': somePerson.age
            }
          };

          final Object? personFromPojo =
              DestinationArgumentConverter.pojoFromJson(json);

          expect(personFromPojo, isA<_Person>());
        },
      );
    },
  );

  group(
    'pojoToJson',
    () {
      test(
        'should convert pojo to json',
        () {
          final _Person person = _Person(fullName: 'Arden Rose', age: 28);

          final Object? json = DestinationArgumentConverter.pojoToJson(person);

          expect(json, isA<Map<String, Object?>>());

          if (json is Map<String, Object?>) {
            final Map<String, Object?> jsonFromPojo = json;

            expect(jsonFromPojo.containsKey('_Person'), isTrue);

            final Object? _personJson = json['_Person'];

            if (_personJson is Map<String, Object?>) {
              final Map<String, Object?> personJson = _personJson;

              expect(personJson.containsKey('fullName'), isTrue);
              expect(personJson.containsKey('age'), isTrue);
            }
          }
        },
      );
    },
  );
}

class _Person implements HasToJson<Map<String, Object?>> {
  final String fullName;

  final int age;

  _Person({required this.fullName, required this.age});

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{'fullName': fullName, 'age': age};
  }

  static Object fromJson(Object? json) {
    if (json is Map<String, Object?>) {
      final Object? rawName = json['fullName'];
      final Object? rawAge = json['age'];

      return _Person(
        fullName:
            rawName is String ? rawName : throw ArgumentError.value(rawName),
        age: rawAge is int ? rawAge : throw ArgumentError.value(rawAge),
      );
    } else {
      throw ArgumentError.value(json);
    }
  }
}
