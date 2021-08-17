import 'dart:async';
import 'package:db_navigator/db_navigator.dart';
import 'package:db_navigator/src/db_navigation_observer.dart';
import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/db_page_builder.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:db_navigator/src/exceptions.dart';
import 'package:db_navigator/src/scoped_page_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Transport group exchange Flutter Application Router delegate.
/// Manage the navigation stack/history of a [Router].
class DBRouterDelegate extends RouterDelegate<Destination>
    with
        PopNavigatorRouterDelegateMixin<Destination>,
// Ignored because we can't extend the delegate with ChangeNotifier.
// Because dart only allow one parent and we can't ChangeNotifier to be
// a mixin.
// ignore: prefer_mixin
        ChangeNotifier
    implements
        DBNavigator {
  final GlobalKey<NavigatorState> _navigatorKey;
  final List<DBPage> _pages;
  final List<DBPageBuilder> _pageBuilders;
  final Map<String, Completer<Object?>> _popResultTracker;

  /// Report page update to the flutter engine when the top most page changes.
  ///
  /// The messages are used by the web engine to update the browser URL bar.
  ///
  /// If there are multiple [DBRouterDelegate] in the widget tree, at most one
  /// of them can set this property to true (typically, the top-most one
  /// created from the [WidgetsApp]). Otherwise, the web engine may
  /// receive multiple route update messages from different navigators and fail
  /// to update the URL bar.
  final bool reportPageUpdateToEngine;

  /// Get the nearest [DBRouterDelegate] from the provided [context].
  static DBRouterDelegate of(final BuildContext context, {bool root = false}) {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: root);

    final RouterDelegate<dynamic> delegate =
        Router.of(navigator.context).routerDelegate;

    if (delegate is DBRouterDelegate) {
      return delegate;
    } else {
      throw const DBRouterDelegateNotFoundException();
    }
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Destination? get currentConfiguration {
    // Note: Returning not null, make the Router widget
    // require a RouteInformationProvider.
    // because this getter is called mostly on web to update the url.
    // Basically this RouteSettings is sent to the RouteInformationParser and
    // transformed to a RouteInformation which basically update the url.
    return reportPageUpdateToEngine && _pages.isNotEmpty
        ? _pages.last.destination
        : null;
  }

  /// Current navigation stack of this [DBRouterDelegate].
  List<DBPage> get pages => List<DBPage>.unmodifiable(_pages);

  /// [List] of [DBPageBuilder] that build the [Page]
  /// that compose the navigation stack.
  List<DBPageBuilder> get pageBuilders =>
      List<DBPageBuilder>.unmodifiable(_pageBuilders);

  /// Create a [DBRouterDelegate] with the provided [pageBuilders]
  /// and [initialPage].
  ///
  /// [pageBuilders] the list [DBPageBuilder] that will be used to build route
  /// requested by client of this [DBRouterDelegate].
  ///
  /// If none of the [pageBuilders] in this list can't create the page
  /// requested a [PageNotFoundException] will be thrown.
  ///
  /// [initialPage] that will be displayed by the [DBRouterDelegate].
  ///
  /// [navigatorKey] Key for the [Navigator]'s state, allowing to have the
  /// same state on different [build] and that can be used to
  /// access the navigator created by this delegate.
  ///
  /// [popResultTracker] A [Map] that track pop result of page pushed
  /// into the stack.
  factory DBRouterDelegate({
    required DBPage initialPage,
    required List<DBPageBuilder> pageBuilders,
    GlobalKey<NavigatorState>? navigatorKey,
    @visibleForTesting Map<String, Completer<Object?>>? popResultTracker,
    bool reportPageUpdateToEngine = false,
  }) {
    assert(pageBuilders.isNotEmpty, 'Page builder list is empty');
    assert(
      pageBuilders.any(
        (DBPageBuilder builder) {
          return builder.supportRoute(initialPage.destination);
        },
      ),
      'no page builder in [pageBuilders] list can build initialPage',
    );

    return DBRouterDelegate.private(
      <DBPage>[initialPage],
      List<DBPageBuilder>.of(pageBuilders),
      navigatorKey ?? GlobalKey<NavigatorState>(),
      popResultTracker ?? <String, Completer<Object?>>{},
      reportPageUpdateToEngine: reportPageUpdateToEngine,
    );
  }

  /// Create a [DBRouterDelegate] from scratch.
  @visibleForTesting
  DBRouterDelegate.private(
    this._pages,
    this._pageBuilders,
    this._navigatorKey,
    this._popResultTracker, {
    this.reportPageUpdateToEngine = false,
  });

  @override
  Future<void> setInitialRoutePath(Destination configuration) async {
    final DBPage? newPage = await pageBuilders.getPage(configuration);

    // This is called mostly for deep linking or web navigation
    // if the path is unknown and can't be handle we just ignore it
    // or we could return the user to a 404 page.
    if (newPage != null) {
      // Setting a initial route we need clear up the the stack
      // and reset the history to start with the requested route.
      _pages.clear();

      final List<Destination>? newStack = configuration.metadata.history;

      // If the new destination has a history then we need to recreate that
      // stack before add the new page.
      if (newStack != null) {
        final List<DBPage> newPages = await _pageBuilders.createPages(newStack);

        _pages.addAll(newPages);
      }
      _pages.add(newPage);
    }
  }

  @override
  Future<void> setNewRoutePath(Destination configuration) async {
    final DBPage? newPage = await pageBuilders.getPage(configuration);

    // Since this is called mostly for deep linking or web navigation
    // if the path is unknown and can't be handle we just ignore it
    // or we could return the user to a 404 page.
    if (newPage != null) {
      // map the current list of page to it's destination representation.
      final Iterable<Destination> currentHistory = _pages.map(
        (DBPage page) => page.destination,
      );

      // If the new page has a history than we need to check that it's not
      // the same as the current one.
      final List<Destination>? newPageHistory = configuration.metadata.history;

      final Iterable<Destination> newPageFullHistory = <Destination>[
        if (newPageHistory != null) ...newPageHistory,
        configuration, // add the new destination requested.
      ];

      // If the stack are equals then there's no point on updating the pages
      // Because we might loose state of each screen and in a tabbed navigation
      // this might be called when switching tabs.
      if (!areNavigationStackEquals(currentHistory, newPageFullHistory)) {
        // If the new stack is null or empty than we just add the new page.
        if (newPageHistory == null || newPageHistory.isEmpty) {
          _pages.add(newPage);
        } else {
          final List<DBPage> newPages =
              await _pageBuilders.createPages(newPageHistory);

          _pages
            ..addAll(newPages)
            ..add(newPage);
        }
        final Completer<Object> popTracker = Completer<Object>();
        _popResultTracker[configuration.path] = popTracker;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ScopedPageBuilder> scopedPageBuilder =
        pageBuilders.whereType<ScopedPageBuilder>().toList();

    return Navigator(
      key: _navigatorKey,
      onPopPage: onPopPage,
      pages: pages,
      reportsRouteUpdateToEngine: reportPageUpdateToEngine,
      observers: <NavigatorObserver>[
        if (scopedPageBuilder.isNotEmpty)
          DBNavigationObserver(pageBuilders: scopedPageBuilder),
      ],
    );
  }

  /// Update the list of page builder composing this delegate.
  /// [initialPath] to use for this delegate.
  Future<void> reset(
    final String initialPath,
    final List<DBPageBuilder> newPageBuilders, {
    Object? arguments,
    List<Destination>? initialPageHistory,
  }) async {
    assert(newPageBuilders.isNotEmpty, "List of page builders can't be empty");

    _pageBuilders
      ..clear()
      ..addAll(newPageBuilders);

    final Destination destination = Destination(
      path: initialPath,
      metadata: DestinationMetadata(
        arguments: arguments,
        history: initialPageHistory,
      ),
    );

    final DBPage? initialPage = await _pageBuilders.getPage(destination);

    if (initialPage == null) {
      throw PageNotFoundException(destination);
    }

    if (initialPageHistory != null && initialPageHistory.isNotEmpty) {
      final List<DBPage> prevPages = await _pageBuilders.createPages(
        initialPageHistory,
      );

      _pages
        ..clear()
        ..addAll(prevPages)
        ..add(initialPage);
    } else {
      _pages
        ..clear()
        ..add(initialPage);
    }

    for (final Completer<Object?> tracker in _popResultTracker.values) {
      tracker.complete();
    }

    notifyListeners();
  }

  @override
  Future<T?> navigateTo<T extends Object?>({
    required final String location,
    final Object? arguments,
  }) async {
    assert(location.trim().isNotEmpty, 'destination location is empty');

    final Destination destination = Destination(
      path: location,
      metadata: DestinationMetadata(
        arguments: arguments,
        history: _pages.map((DBPage page) => page.destination).toList(),
      ),
    );

    final DBPage? newPage = await _pageBuilders.getPage(destination);

    if (newPage == null) {
      throw PageNotFoundException(destination);
    }

    _pages.add(newPage);

    final Completer<T?> popTracker = Completer<T?>();
    _popResultTracker[destination.path] = popTracker;

    notifyListeners();

    final T? result = await popTracker.future;

    return result;
  }

  @override
  bool canClose() => _pages.length > 1;

  @override
  void close<T extends Object?>([final T? result]) {
    assert(_pages.isNotEmpty, "there's no page in the stack to close");
    assert(_pages.length > 1, "You can't remove the only page in the stack");
    final DBPage topPage = _pages.removeAt(_pages.length - 1);

    final Completer<Object?>? tracker = _popResultTracker.remove(
      topPage.destination.path,
    );

    if (tracker != null && !tracker.isCompleted) {
      tracker.complete(result);
    }

    notifyListeners();
  }

  @override
  void closeUntil({required String location, Map<String, Object?>? resultMap}) {
    assert(_pages.isNotEmpty, "there's no page in the stack to close");
    assert(_pages.length > 1, "You can't remove the only page in the stack");

    final int locationIndex = _pages.indexWhere((DBPage page) {
      return page.destination.path == location;
    });

    assert(
      locationIndex > 0,
      '$location is the last page or not found in the list of available '
      'pages:\n${_pages.reversed.map((DBPage page) => page.destination.path)}',
    );

    assert(
      (locationIndex + 1) < _pages.length,
      "$location is the top most, so it's make no sense to use closeUntil, "
      'use close method to close a single location',
    );

    final List<DBPage> pagesToClose = _pages.sublist(locationIndex + 1);
    _pages.removeRange(locationIndex + 1, _pages.length);

    // Run throughout the list of pages, from the top most page first and on.
    for (final DBPage page in pagesToClose.reversed) {
      final Completer<Object?>? tracker = _popResultTracker.remove(
        page.destination.path,
      );

      final Object? result = resultMap?[page.destination.path];

      if (tracker != null && !tracker.isCompleted) {
        tracker.complete(result);
      }
    }
  }

  /// Callback to handle imperative pop or operating system pop event.
  ///
  /// [route] request to be be pop/removed.
  /// [result] provided with the request to pop the [route].
  @visibleForTesting
  bool onPopPage(Route<Object?> route, [Object? result]) {
    final bool popSucceeded = route.didPop(result);
    // In the imperative pop, the route can decline to be pop so we
    // need to only update the page if the route has agreed to be pop.
    if (popSucceeded) {
      // the navigator pop always remove the top most page but for safety
      // i prefer to look for the page before popping it.
      DBPage? foundPage;

      for (final DBPage page in _pages) {
        if (page.name == route.settings.name) {
          foundPage = page;
          break;
        }
      }

      _pages.remove(foundPage);

      notifyListeners();
      // if someone is waiting for the result, we remove it and signal
      // the completion.
      final Completer<Object?>? tracker =
          _popResultTracker.remove(foundPage?.name);

      if (tracker?.isCompleted == false) {
        tracker?.complete(result);
      }
    }

    return popSucceeded;
  }

  /// Check the equality between two list of destination.
  ///
  /// [leftStack] to be verified.
  /// [rightStack] to be verified.
  ///
  /// return true if both stack are equals.
  ///
  /// Note: equals only in path not arguments or histories.
  @visibleForTesting
  bool areNavigationStackEquals(
    final Iterable<Destination> leftStack,
    final Iterable<Destination> rightStack,
  ) {
    // if the stack don't have the same length they are definitely not equal.
    if (leftStack.length != rightStack.length) {
      return false;
    }

    final List<String> leftStackPaths =
        leftStack.map((Destination destination) => destination.path).toList();

    final List<String> rightStackPaths =
        rightStack.map((Destination destination) => destination.path).toList();

    for (int index = 0; index < leftStackPaths.length; index++) {
      final String leftPath = leftStackPaths[index];
      final String rightPath = rightStackPaths[index];

      if (leftPath != rightPath) {
        return false;
      }
    }

    return true;
  }
}

/// Convenient extension to manipulate a collection of [DBPageBuilder]
extension ListOfPageBuilderExtension on Iterable<DBPageBuilder> {
  /// The method creates a list of db pages based on a list of destinations.
  /// Note the resulting list of pages only contains the pages
  /// with destination supported by the list of page builders.
  @visibleForTesting
  Future<List<DBPage>> createPages(final List<Destination> history) async {
    final List<Destination> filteredHistory = filterHistory(history);

    return buildStack(filteredHistory);
  }

  /// Filters the list of destinations to only contain the destination supported
  /// by the collection of page builders.
  @visibleForTesting
  List<Destination> filterHistory(final List<Destination> destinations) {
    final List<Destination> filteredHistory = <Destination>[];

    for (final Destination destination in destinations) {
      final bool supportedDestination = any(
        (DBPageBuilder pageBuilder) => pageBuilder.supportRoute(destination),
      );

      if (kDebugMode) {
        debugPrintThrottled(
          'Did not found a page builder that can build ${destination.path}',
        );
      }

      if (supportedDestination) {
        filteredHistory.add(destination);
      }
    }

    return filteredHistory;
  }

  /// Builds navigation stack of pages from list of [Destination]
  @visibleForTesting
  Future<List<DBPage>> buildStack(
    final List<Destination> destinations,
  ) async {
    final List<DBPage> stack = <DBPage>[];

    for (final Destination destination in destinations) {
      final DBPage? newPage = await getPage(destination);

      if (newPage != null) {
        stack.add(newPage);
      }
    }

    return stack;
  }

  /// Gets a page from destination,
  /// returns null if any of [DBPageBuilder] does not support the destination.
  @visibleForTesting
  Future<DBPage?> getPage(final Destination destination) async {
    for (final DBPageBuilder pageBuilder in this) {
      if (pageBuilder.supportRoute(destination)) {
        return pageBuilder.buildPage(destination);
      }
    }
    return null;
  }
}
