import 'dart:async';
import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/db_page_builder.dart';
import 'package:db_navigator/src/db_router_delegate.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:db_navigator/src/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'utils.dart';

void main() {
  group(
    'instantiation',
    () {
      test(
        'should have initial page inside pages list',
        () async {
          final DBPage initialPage = TestPageBuilder.initialPage;

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: initialPage,
          );

          expect(routerDelegate.pages, hasLength(1));
          expect(routerDelegate.pages, contains(initialPage));
        },
      );

      test(
        'should have page builder inside pageBuilders list',
        () {
          const TestPageBuilder pageBuilder = TestPageBuilder();

          final List<DBPageBuilder> pageBuilders = <DBPageBuilder>[pageBuilder];

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: pageBuilders,
            initialPage: TestPageBuilder.initialPage,
          );

          expect(routerDelegate.pageBuilders, hasLength(1));
          expect(routerDelegate.pageBuilders, contains(pageBuilder));
        },
      );

      test(
        'should throw assertion error if instantiated '
        'with an empty list of pageBuilder',
        () {
          expect(
            () => DBRouterDelegate(
              pageBuilders: <DBPageBuilder>[],
              initialPage: TestPageBuilder.initialPage,
            ),
            throwsAssertionError,
          );
        },
      );

      test(
        'should throw an assertion error if passed pageBuilders '
        "that can't build the initial page",
        () {
          expect(
            () => DBRouterDelegate(
              pageBuilders: <DBPageBuilder>[const RejectingPageBuilder()],
              initialPage: TestPageBuilder.initialPage,
            ),
            throwsAssertionError,
          );
        },
      );

      test(
        'navigatorKey getter should return exact same $GlobalKey '
        'if there was one assigned to navigatorKey parameter',
        () {
          final GlobalKey<NavigatorState> navigatorKey =
              GlobalKey<NavigatorState>();

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
            navigatorKey: navigatorKey,
          );

          expect(routerDelegate.navigatorKey, equals(navigatorKey));
        },
      );
    },
  );

  group(
    'setNewRoutePath',
    () {
      const Destination unknownDestination = Destination(path: unknownPath);

      test(
        'should not update page stack and popResultTracker '
        'if there is no pageBuilder that can build the new route',
        () async {
          final Map<String, Completer<Object>> popResultTracker =
              <String, Completer<Object>>{};

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
            popResultTracker: popResultTracker,
          );

          final int pageCount = routerDelegate.pages.length;

          final int resultTrackerCount = popResultTracker.length;

          await routerDelegate.setNewRoutePath(unknownDestination);

          expect(routerDelegate.pages.length, equals(pageCount));

          expect(popResultTracker.length, equals(resultTrackerCount));
        },
      );

      test(
        'should add a new result trackers to popResultTracker map '
        'if new route is supported by one of pageBuilders',
        () async {
          final Map<String, Completer<Object>> popResultTracker =
              <String, Completer<Object>>{};

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
            popResultTracker: popResultTracker,
          );

          expect(popResultTracker, isEmpty);

          const Destination page2Destination = Destination(path: Page2.path);

          await routerDelegate.setNewRoutePath(page2Destination);

          expect(popResultTracker, hasLength(1));
          expect(popResultTracker, contains(page2Destination.path));
        },
      );

      test(
        'should add a new page to the pages list '
        'if new route is supported by one of pageBuilders',
        () async {
          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
          );

          expect(routerDelegate.pages, hasLength(1));

          const Destination page2Destination = Destination(path: Page2.path);

          await routerDelegate.setNewRoutePath(page2Destination);

          expect(routerDelegate.pages, hasLength(2));
        },
      );
    },
  );

  group(
    'navigateTo',
    () {
      test(
        'should throw an assertion error '
        'if location parameter is empty',
        () {
          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
          );

          expect(
            () => routerDelegate.navigateTo(location: ''),
            throwsAssertionError,
          );

          expect(
            () => routerDelegate.navigateTo(location: '    '),
            throwsAssertionError,
          );
        },
      );

      test(
        'should throw PageNotFoundException '
        'if no pageBuilders were found a navigation location',
        () {
          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
          );

          expect(
            () => routerDelegate.navigateTo(location: unknownPath),
            throwsA(isInstanceOf<PageNotFoundException>()),
          );
        },
      );
    },
  );

  group(
    'close',
    () {
      test(
        'should remove page from pages list',
        () async {
          final Map<String, Completer<Object?>> trackers =
              <String, Completer<Object?>>{};

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
            popResultTracker: trackers,
          );

          // since navigate to is async and return a future that wait until
          // the page is closed, we need to add a timeout and force complete
          // the future without removing the page.
          await routerDelegate.navigateTo(location: Page2.path).timeout(
            const Duration(milliseconds: 250),
            onTimeout: () {
              trackers.values.forEach((Completer<Object?> tracker) {
                tracker.complete();
              });
            },
          );

          expect(routerDelegate.pages, hasLength(2));

          routerDelegate.close();

          expect(routerDelegate.pages, hasLength(1));
        },
      );
    },
  );

  group(
    'onPopPage',
    () {
      test(
        'should not matching page remove page if route didPop return false',
        () {
          final DBPage initialPage = TestPageBuilder.initialPage;

          const TestPageBuilder pageBuilder = TestPageBuilder();

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[pageBuilder],
            initialPage: initialPage,
          );

          final _MockRoute route = _MockRoute();

          final List<DBPage> pages = routerDelegate.pages;

          expect(pages, hasLength(1));

          when(() => route.didPop(any())).thenReturn(false);

          final bool result = routerDelegate.onPopPage(route);

          expect(pages, hasLength(1));

          expect(result, false);
        },
      );

      test(
        'should remove matching page if didPop return true',
        () {
          final DBPage initialPage = TestPageBuilder.initialPage;

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: initialPage,
          );

          final _MockRoute route = _MockRoute();

          final List<DBPage> pages = routerDelegate.pages;

          expect(pages, hasLength(1));

          when(() => route.didPop(any())).thenReturn(true);

          when(() => route.settings).thenReturn(initialPage);

          final bool result = routerDelegate.onPopPage(route);

          expect(result, true);
        },
      );
    },
  );

  group(
    'currentConfiguration',
    () {
      test(
        'should return null '
        'if reportPageUpdateToEngine is false',
        () {
          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
            reportPageUpdateToEngine:
                false, // ignore: avoid_redundant_argument_values
          );

          expect(routerDelegate.currentConfiguration, isNull);
        },
      );

      test(
        'should return null if pages list is empty',
        () {
          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
            reportPageUpdateToEngine: true,
          )..close();

          expect(routerDelegate.currentConfiguration, isNull);
        },
      );

      test(
        'should return current visible page if reportPageUpdateToEngine '
        'is true and pages list is not empty',
        () async {
          final Map<String, Completer<Object?>> trackers =
              <String, Completer<Object?>>{};

          final DBRouterDelegate routerDelegate = DBRouterDelegate(
            pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
            initialPage: TestPageBuilder.initialPage,
            reportPageUpdateToEngine: true,
            popResultTracker: trackers,
          );

          // since navigate to is async and return a future that wait until
          // the page is closed, we need to add a timeout and force complete
          // the future without removing the page.
          await routerDelegate.navigateTo(location: Page2.path).timeout(
            const Duration(milliseconds: 250),
            onTimeout: () {
              trackers.values.forEach((Completer<Object?> tracker) {
                tracker.complete();
              });
            },
          );

          expect(routerDelegate.pages, hasLength(2));

          final Destination? currentDestination =
              routerDelegate.currentConfiguration;

          expect(currentDestination?.path, equals(Page2.path));
        },
      );
    },
  );

  group('reset', () {
    test(
      'should change the navigator page builders to different pageBuilders '
      'and initial page',
      () async {
        final Map<String, Completer<Object?>> trackers =
            <String, Completer<Object?>>{};

        final DBRouterDelegate routerDelegate = DBRouterDelegate(
          pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
          initialPage: TestPageBuilder.initialPage,
          popResultTracker: trackers,
        );

        final List<DBPageBuilder> previousPageBuilders =
            routerDelegate.pageBuilders;

        final List<DBPage> previousPages = routerDelegate.pages;

        await routerDelegate.reset(
          WidgetPageBuilder.key.value,
          <DBPageBuilder>[const WidgetPageBuilder(child: Placeholder())],
        );

        expect(
          routerDelegate.pageBuilders,
          isNot(orderedEquals(previousPageBuilders)),
        );

        expect(routerDelegate.pages, isNot(orderedEquals(previousPages)));

        expect(trackers, isEmpty);
      },
    );

    test('should reset pages list adding initial page', () async {
      final DBRouterDelegate routerDelegate = DBRouterDelegate(
        pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
        initialPage: TestPageBuilder.initialPage,
      );

      expect(routerDelegate.pages, contains(TestPageBuilder.initialPage));

      await routerDelegate.reset(
        WidgetPageBuilder.key.value,
        <DBPageBuilder>[const WidgetPageBuilder(child: Placeholder())],
      );

      expect(routerDelegate.pages, hasLength(1));

      expect(
        routerDelegate.pages.first.name,
        equals(WidgetPageBuilder.key.value),
      );
    });
  });
}

class _MockRoute extends Mock implements Route<Object?> {}
