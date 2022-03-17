import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/scoped_page_builder.dart';
import 'package:flutter/widgets.dart';

/// Navigator observer that the navigation changes of it's [Navigator].
class DBNavigationObserver extends NavigatorObserver {
  /// List of [ScopedPageBuilder] to track entering and exiting events.
  final List<ScopedPageBuilder> _currentPageBuilders;
  final List<ScopedPageBuilder> _releasablePageBuilders;

  /// Create a [DBNavigationObserver] with the list of
  DBNavigationObserver({
    List<ScopedPageBuilder>? initialPageBuilders,
    List<ScopedPageBuilder>? releasablePageBuilders,
  })  : _currentPageBuilders = <ScopedPageBuilder>[
          if (initialPageBuilders != null) ...initialPageBuilders,
        ],
        _releasablePageBuilders = <ScopedPageBuilder>[
          if (releasablePageBuilders != null) ...releasablePageBuilders,
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
        _releasablePageBuilders.add(pageBuilder);
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
    for (final ScopedPageBuilder newPageBuilder in newPageBuilders) {
      final bool pageBuilderExist = _currentPageBuilders.any(
        (ScopedPageBuilder newPageBuilder) {
          return newPageBuilder.scopeName == newPageBuilder.scopeName;
        },
      );

      // if the page builder does not exist in the new list of page builders.
      // it's means that it's page builder is no longer necessary.
      if (!pageBuilderExist) {
        _currentPageBuilders.add(newPageBuilder);
      }
    }
  }

  /// Dispose the [DBNavigationObserver].
  ///
  /// Will stop tracking scope of all [ScopedPageBuilder], registered.
  void reset() {
    _currentPageBuilders
      ..forEach(
        (ScopedPageBuilder pageBuilder) {
          if (_releasablePageBuilders.contains(pageBuilder)) {
            pageBuilder.onInitialDestinationExited();
          }
        },
      )
      ..clear();

    _releasablePageBuilders.clear();
  }

  /// Exit the [ScopedPageBuilder] with initial destination matching the [page].
  @visibleForTesting
  void exitPageBuilderScope(DBPage page) {
    _currentPageBuilders.removeWhere(
      (ScopedPageBuilder pageBuilder) {
        return page.destination.path == pageBuilder.initialDestination.path;
      },
    );

    final List<ScopedPageBuilder> releasable = _releasablePageBuilders.where(
      (ScopedPageBuilder pageBuilder) {
        return page.destination.path == pageBuilder.initialDestination.path;
      },
    ).toList();

    for (final ScopedPageBuilder pageBuilder in releasable) {
      pageBuilder.onInitialDestinationExited();
      _releasablePageBuilders.remove(pageBuilder);
    }

    // final int builderIndex = _currentPageBuilders.lastIndexWhere(
    //   (ScopedPageBuilder pageBuilder) {
    //     return page.destination.path == pageBuilder.initialDestination.path;
    //   },
    // );
    //
    // final int startIndex = _currentPageBuilders.length - 1;
    //
    // for (int index = startIndex; index >= builderIndex; index--) {
    //   final ScopedPageBuilder pageBuilder = _currentPageBuilders[index]
    //     ..onInitialDestinationExited();
    //
    //   if (_releasablePageBuilders.contains(pageBuilder)) {
    //     _currentPageBuilders.remove(pageBuilder);
    //     _releasablePageBuilders.remove(pageBuilder);
    //   }
    // }
  }
}
