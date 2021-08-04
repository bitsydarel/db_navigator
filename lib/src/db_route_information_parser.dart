import 'package:db_navigator/src/db_router_delegate.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Transport Exchange Group Route Information parser.
///
/// Parse route information sent from the system to a [Destination], that's
/// suitable for [DBRouterDelegate].
class DBRouteInformationParser extends RouteInformationParser<Destination> {
  /// Const constructor. This constructor this class
  /// to be used in const expressions.
  const DBRouteInformationParser();

  @override
  Future<Destination> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    return SynchronousFuture<Destination>(
      Destination.fromRouteInformation(routeInformation),
    );
  }

  @override
  RouteInformation restoreRouteInformation(Destination configuration) {
    return RouteInformation(
      location: configuration.path,
      state: configuration.metadata,
    );
  }
}
