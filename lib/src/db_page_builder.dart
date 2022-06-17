import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:flutter/widgets.dart';

/// Async function allowing to create [Widget] for the provided [Destination].
typedef AsyncDestinationWidgetFactory = Future<Widget> Function(Destination);

/// Async function allowing to create [DBPage] for the provided [Destination].
typedef AsyncDestinationPageFactory = Future<DBPage> Function(Destination);

/// Function allowing to create [Widget] for the provided [Destination].
typedef DestinationWidgetFactory = Widget Function(Destination);

/// Function allowing to create [DBPage] for the provided [Destination].
typedef DestinationPageFactory = DBPage Function(Destination);

/// DB Page Builder build a [DBPage] from a [Destination].
abstract class DBPageBuilder {
  /// Const constructor. allow this class
  /// to be used in const expressions.
  const DBPageBuilder();

  /// Build [DBPage] from the [destination].
  ///
  /// Call [supportRoute] to check if the [DBPageBuilder]
  /// can build the page requested by the [destination].
  Future<DBPage> buildPage(Destination destination);

  /// Check if the [DBPageBuilder] support the [Destination] requested.
  ///
  /// Return [bool] true if the [DBPageBuilder] can build the page requested
  /// by the [destination].
  bool supportRoute(Destination destination);
}
