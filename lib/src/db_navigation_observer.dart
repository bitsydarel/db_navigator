import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/scoped_page_builder.dart';
import 'package:flutter/widgets.dart';

/// Navigator observer that the navigation changes of it's [Navigator].
class DBNavigationObserver extends NavigatorObserver {
  /// List of [ScopedPageBuilder] to track entering and exiting events.
  final Set<ScopedPageBuilder> _currentPageBuilders;
  final Set<ScopedPageBuilder> _releasablePageBuilders;

  /// Create a [DBNavigationObserver] with the list of
  DBNavigationObserver({
    List<ScopedPageBuilder>? initialPageBuilders,
    List<ScopedPageBuilder>? releasablePageBuilders,
  })  : _currentPageBuilders = <ScopedPageBuilder>{
          if (initialPageBuilders != null) ...initialPageBuilders,
        },
        _releasablePageBuilders = <ScopedPageBuilder>{
          if (releasablePageBuilders != null) ...releasablePageBuilders,
        };

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
  void addAll(final List<ScopedPageBuilder> newPageBuilders) {
    for (final ScopedPageBuilder currentPageBuilder in _currentPageBuilders) {
      final bool pageBuilderExist = newPageBuilders.any(
        (ScopedPageBuilder newPageBuilder) {
          return newPageBuilder.scopeName == currentPageBuilder.scopeName;
        },
      );

      // if the page builder does not exist in the new list of page builders.
      // it's means that it's page builder is no longer necessary.
      if (!pageBuilderExist) {
        _releasablePageBuilders.add(currentPageBuilder);
      }
    }

    _currentPageBuilders.addAll(newPageBuilders);
  }

  /// Dispose the [DBNavigationObserver].
  ///
  /// Will stop tracking scope of all [ScopedPageBuilder], registered.
  void reset() {
    _currentPageBuilders
      ..forEach(
        (ScopedPageBuilder pageBuilder) {
          pageBuilder.onInitialDestinationExited();
        },
      )
      ..clear();

    _releasablePageBuilders.clear();
  }

  /// Exit the [ScopedPageBuilder] with initial destination matching the [page].
  @visibleForTesting
  void exitPageBuilderScope(DBPage page) {
    _currentPageBuilders
        .where(
          (ScopedPageBuilder pageBuilder) {
            return page.destination.path == pageBuilder.initialDestination.path;
          },
        )
        .toList()
        .forEach(
          (ScopedPageBuilder pageBuilder) {
            // notify the pageBuilder that it's initial destination is exited.
            pageBuilder.onInitialDestinationExited();

            if (_releasablePageBuilders.contains(pageBuilder)) {
              _currentPageBuilders.removeWhere(
                (ScopedPageBuilder obsoletePageBuilder) {
                  return obsoletePageBuilder.scopeName == pageBuilder.scopeName;
                },
              );

              _releasablePageBuilders.removeWhere(
                (ScopedPageBuilder obsoletePageBuilder) {
                  return obsoletePageBuilder.scopeName == pageBuilder.scopeName;
                },
              );
            }
          },
        );
  }
}
