import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/scoped_page_builder.dart';
import 'package:flutter/widgets.dart';

/// Navigator observer that the navigation changes of it's [Navigator].
class DBNavigationObserver extends NavigatorObserver {
  /// List of [ScopedPageBuilder] to track entering and exiting events.
  final List<ScopedPageBuilder> _currentPageBuilders;
  final List<ScopedPageBuilder> _pushedPageBuilders;

  /// Create a [DBNavigationObserver] with the list of
  DBNavigationObserver({
    List<ScopedPageBuilder>? initialPageBuilders,
    List<ScopedPageBuilder>? pushedPageBuilders,
  })  : _currentPageBuilders = <ScopedPageBuilder>[
          if (initialPageBuilders != null) ...initialPageBuilders,
        ],
        _pushedPageBuilders = <ScopedPageBuilder>[
          if (pushedPageBuilders != null) ...pushedPageBuilders,
        ];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final RouteSettings configuration = route.settings;

    if (configuration is DBPage) {
      _currentPageBuilders.where(
        (ScopedPageBuilder pageBuilder) {
          return configuration.destination.path ==
              pageBuilder.initialDestination.path;
        },
      ).forEach((ScopedPageBuilder pageBuilder) {
        pageBuilder.onInitialDestinationEntered();
        // Since the page builder initial destination has been push.
        // This page builder can be released when needed.
        _pushedPageBuilders.add(pageBuilder);
      });
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final RouteSettings configuration = route.settings;

    if (configuration is DBPage) {
      exitPageBuilderScope(configuration);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final RouteSettings configuration = route.settings;

    if (configuration is DBPage) {
      exitPageBuilderScope(configuration);
    }
  }

  /// Add [newPageBuilders] to the list of tracked page builders.
  void addAll(List<ScopedPageBuilder> newPageBuilders) {
    _currentPageBuilders
      ..clear()
      ..addAll(newPageBuilders);
  }

  /// Dispose the [DBNavigationObserver].
  ///
  /// Will stop tracking scope of all [ScopedPageBuilder], registered.
  void reset() {
    _currentPageBuilders.clear();

    _pushedPageBuilders
      ..forEach(
        (ScopedPageBuilder pageBuilder) {
          pageBuilder.onInitialDestinationExited();
        },
      )
      ..clear();
  }

  /// Exit the [ScopedPageBuilder] with initial destination matching the [page].
  @visibleForTesting
  void exitPageBuilderScope(DBPage page) {
    _currentPageBuilders.removeWhere(
      (ScopedPageBuilder pageBuilder) {
        return page.destination.path == pageBuilder.initialDestination.path;
      },
    );

    final List<ScopedPageBuilder> releasable = _pushedPageBuilders.where(
      (ScopedPageBuilder pageBuilder) {
        return page.destination.path == pageBuilder.initialDestination.path;
      },
    ).toList();

    for (final ScopedPageBuilder pageBuilder in releasable) {
      pageBuilder.onInitialDestinationExited();
      _pushedPageBuilders.remove(pageBuilder);
    }
  }
}
