import 'package:flutter/material.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'toRouteInformation',
    () {
      test(
        'should contain exact same path and state '
        'as destination path and metadata',
        () {
          const Destination homeDestination = Destination(path: '/home');
          const List<Destination> history = <Destination>[homeDestination];
          const Destination destination = Destination(
            path: '/',
            metadata: DestinationMetadata(arguments: 0, history: history),
          );

          final RouteInformation routeInformation =
              destination.toRouteInformation();

          expect(routeInformation.location, equals(destination.path));

          expect(routeInformation.state, isA<DestinationMetadata>());

          expect(
            identical(routeInformation.state, destination.metadata),
            isTrue,
          );
        },
      );
    },
  );

  group(
    'toSettings',
    () {
      test(
        'should contain exact same name and arguments '
        'as destination path and metadata arguments',
        () {
          const Destination destination = Destination(
            path: '/',
            metadata: DestinationMetadata(arguments: 0),
          );

          final RouteSettings settings = destination.toSettings();

          expect(settings.name, equals(destination.path));
          expect(settings.arguments, equals(destination.metadata.arguments));
        },
      );
    },
  );
}
