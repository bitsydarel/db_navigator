import 'package:db_navigator/src/db_route_information_parser.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('restoreRouteInformation', () {
    test(
        'should return RouteInformation object '
        'with location being the destination path', () async {
      const DBRouteInformationParser parser = DBRouteInformationParser();
      final RouteInformation routeInfo = parser.restoreRouteInformation(
        const Destination(path: Page2.path),
      );

      expect(routeInfo.location, equals(Page2.path));
    });
  });
}
