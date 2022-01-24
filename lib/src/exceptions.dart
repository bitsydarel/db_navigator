import 'package:db_navigator/src/db_page_builder.dart';
import 'package:db_navigator/src/db_router_delegate.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:flutter/widgets.dart';

/// Exception to be thrown when a page is requested but there's
/// no [DBPageBuilder] was capable to provide it.
class PageNotFoundException implements Exception {
  /// The route that was requested and could not be provided.
  final Destination destination;

  /// Create a [PageNotFoundException] with the following [destination].
  const PageNotFoundException(this.destination);

  @override
  String toString() {
    return 'Request page was not found for destination: $destination';
  }
}

/// Exception to be thrown when [DBRouterDelegate.of] is call but no [Router]
/// with the [RouterDelegate] of type [DBRouterDelegate] was founded.
class DBRouterDelegateNotFoundException implements Exception {
  /// Create a [DBRouterDelegateNotFoundException].
  ///
  /// This constructor is here to allow this exception to be used in constant\
  /// expressions.
  const DBRouterDelegateNotFoundException();

  @override
  String toString() => '$DBRouterDelegate not found in the context';
}
