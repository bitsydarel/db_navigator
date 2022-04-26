import 'package:db_navigator/db_navigator.dart';
import 'package:flutter/material.dart';

/// A mixing that provide functionality required to handle content switches.
mixin DBContentSwitcherMixin {
  final Map<int, BackButtonDispatcher> _backButtonDispatchers =
      <int, BackButtonDispatcher>{};

  /// Build the content for the content at the specified [contentIndex] with
  /// the specified [routerDelegate].
  Widget buildContent(
    BuildContext context,
    int contentIndex,
    DBRouterDelegate routerDelegate,
  ) {
    BackButtonDispatcher? routerBackButtonDispatcher =
        _backButtonDispatchers[contentIndex];

    if (routerBackButtonDispatcher == null) {
      final BackButtonDispatcher? parentBackButtonDispatcher =
          Router.of(context).backButtonDispatcher;

      assert(
        parentBackButtonDispatcher != null,
        "It's seems like this the screen is added "
        'on a parent without a $BackButtonDispatcher',
      );

      routerBackButtonDispatcher =
          parentBackButtonDispatcher?.createChildBackButtonDispatcher();
    }

    return Router<Destination>(
      routerDelegate: routerDelegate,
      routeInformationParser: const DBRouteInformationParser(),
      restorationScopeId: routerDelegate.restorationScopeId,
      backButtonDispatcher: routerBackButtonDispatcher,
    );
  }
}
