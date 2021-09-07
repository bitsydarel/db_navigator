import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/scoped_page_builder.dart';
import 'package:flutter/widgets.dart';

/// Navigator observer that the navigation changes of it's [Navigator].
class DBNavigationObserver extends NavigatorObserver {
  /// List of [ScopedPageBuilder]
  final List<ScopedPageBuilder> pageBuilders;

  /// Create a [DBNavigationObserver] with the list of
  DBNavigationObserver({required this.pageBuilders});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final RouteSettings configuration = route.settings;

    if (configuration is DBPage) {
      pageBuilders.where(
        (ScopedPageBuilder pageBuilder) {
          return configuration.destination.path ==
              pageBuilder.initialDestination.path;
        },
      ).forEach((ScopedPageBuilder pageBuilder) {
        pageBuilder.onInitialDestinationEntered();
      });
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final RouteSettings configuration = route.settings;

    if (configuration is DBPage) {
      pageBuilders.where(
        (ScopedPageBuilder pageBuilder) {
          return configuration.destination.path ==
              pageBuilder.initialDestination.path;
        },
      ).forEach((ScopedPageBuilder pageBuilder) {
        pageBuilder.onInitialDestinationExited();
      });
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final RouteSettings configuration = route.settings;

    if (configuration is DBPage) {
      pageBuilders.where(
        (ScopedPageBuilder pageBuilder) {
          return configuration.destination.path ==
              pageBuilder.initialDestination.path;
        },
      ).forEach((ScopedPageBuilder pageBuilder) {
        pageBuilder.onInitialDestinationExited();
      });
    }
  }
}
