import 'package:db_navigator/src/db_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// [DBMaterialPage] material page route.
///
/// This can be [DBMaterialPage]
class DBMaterialPageRoute extends DBPageRoute
    with MaterialRouteTransitionMixin<Object?> {
  /// Create a [DBMaterialPageRoute].
  DBMaterialPageRoute({required DBMaterialPage page}) : super(page);

  /// [DBMaterialPage] of this [DBMaterialPageRoute].
  DBMaterialPage get page => settings as DBMaterialPage;
}

/// [DBCupertinoPageRoute] page route.
class DBCupertinoPageRoute extends DBPageRoute
    with CupertinoRouteTransitionMixin<Object?> {
  /// Create a [DBCupertinoPageRoute].
  DBCupertinoPageRoute({required DBCupertinoPage page}) : super(page);

  /// [DBCupertinoPage] of this [DBCupertinoPageRoute].
  DBCupertinoPage get page => _page as DBCupertinoPage;

  @override
  String? get title => page.title;
}

/// A [PageRoute] implementation for [DBPage].
abstract class DBPageRoute extends PageRoute<Object?> {
  /// Create a [DBPageRoute].
  DBPageRoute(this._page)
      : super(settings: _page, fullscreenDialog: _page.fullscreenDialog);

  final DBPage _page;

  @override
  bool get maintainState => _page.maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.destination.path})';

  /// Builds the primary contents of the route.
  Widget buildContent(BuildContext context) => _page.child;
}
