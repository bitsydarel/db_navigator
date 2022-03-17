import 'package:db_navigator/db_navigator.dart';
import 'package:db_navigator/src/db_page_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A [DBPage] implementation for material.
class DBMaterialPage extends MaterialPage<Object?> with DBPage {
  /// Create a [DBMaterialPage] with [key] identifying the page, [destination]
  /// of the page and [child] to put at that destination.
  ///
  /// Note: [key] should be non-existent in the current navigation stack.
  DBMaterialPage({
    required LocalKey key,
    required this.destination,
    required Widget child,
    String? restorationId,
    this.customPageRouteFactory,
  }) : super(
          key: key,
          name: destination.path,
          arguments: destination.metadata,
          child: child,
          maintainState: true,
          fullscreenDialog: false,
          restorationId: restorationId,
        );

  /// The [Destination] for which this page was created.
  @override
  final Destination destination;

  /// Function that create a [DBPageRoute].
  ///
  /// Note: To implement [DBPageRoute] you can just extend a [DBMaterialPage]
  /// and override the property or function that you want.
  final DBPageRoute Function(DBMaterialPage page)? customPageRouteFactory;

  @override
  Route<Object?> createRoute(BuildContext context) {
    return customPageRouteFactory?.call(this) ??
        DBMaterialPageRoute(page: this);
  }
}

/// A [DBPage] implementation for Cupertino.
class DBCupertinoPage extends CupertinoPage<Object?> with DBPage {
  /// Create a [DBCupertinoPage] with [key] identifying the page, [destination]
  /// of the page and [child] to put at that destination.
  ///
  /// Note: [key] should be non-existent in the current navigation stack.
  DBCupertinoPage({
    required LocalKey key,
    required this.destination,
    required Widget child,
    String? restorationId,
    this.customPageRouteFactory,
  }) : super(
          key: key,
          name: destination.path,
          arguments: destination.metadata,
          child: child,
          maintainState: true,
          fullscreenDialog: false,
          restorationId: restorationId,
        );

  /// The [Destination] for which this page was created.
  @override
  final Destination destination;

  /// Function that create a [DBPageRoute].
  ///
  /// Note: To implement [DBPageRoute] you can just extend a [DBCupertinoPage]
  /// and override the property or function that you want.
  final DBPageRoute Function(DBCupertinoPage page)? customPageRouteFactory;

  @override
  Route<Object?> createRoute(BuildContext context) {
    return customPageRouteFactory?.call(this) ??
        DBCupertinoPageRoute(page: this);
  }
}

/// [DBRouterDelegate]'s pages.
mixin DBPage on Page<Object?> {
  /// The [Destination] of the page.
  abstract final Destination destination;

  /// Whether the route should remain in memory when it is inactive.
  abstract final bool maintainState;

  /// Whether the route should remain in memory when it is inactive.
  abstract final bool fullscreenDialog;

  /// Primary content of the page.
  abstract final Widget child;
}
