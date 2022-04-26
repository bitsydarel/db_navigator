import 'dart:async';

import 'package:db_navigator/src/db_navigation_observer.dart';
import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/db_page_builder.dart';
import 'package:db_navigator/src/db_router_delegate.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:db_navigator/src/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      test('should throw assert error if pages list empty', () {
        const TestPageBuilder pageBuilder = TestPageBuilder();

        final Map<String, Completer<Object?>> trackers =
            <String, Completer<Object?>>{};

        final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
          <DBPage>[],
          <DBPageBuilder>[pageBuilder],
          GlobalKey<NavigatorState>(),
          trackers,
          DBNavigationObserver(),
          <NavigatorObserver>[],
          null,
        );

        expect(routerDelegate.pages, isEmpty);

        expect(routerDelegate.close, throwsAssertionError);
      });

      test('should throw assert error if pages list only have one page', () {
        const TestPageBuilder pageBuilder = TestPageBuilder();

        final Map<String, Completer<Object?>> trackers =
            <String, Completer<Object?>>{};

        final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
          <DBPage>[TestPageBuilder.initialPage],
          <DBPageBuilder>[pageBuilder],
          GlobalKey<NavigatorState>(),
          trackers,
          DBNavigationObserver(),
          <NavigatorObserver>[],
          null,
        );

        expect(routerDelegate.pages, hasLength(equals(1)));

        expect(routerDelegate.close, throwsAssertionError);
      });

      test(
        'should remove page from pages list',
        () async {
          const TestPageBuilder pageBuilder = TestPageBuilder();

          final DBPage page2 = await pageBuilder.buildPage(
            const Destination(path: Page2.path),
          );

          final Map<String, Completer<Object?>> trackers =
              <String, Completer<Object?>>{};

          final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
            <DBPage>[page2, TestPageBuilder.initialPage],
            <DBPageBuilder>[pageBuilder],
            GlobalKey<NavigatorState>(),
            trackers,
            DBNavigationObserver(),
            <NavigatorObserver>[],
            null,
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
          final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
            <DBPage>[],
            <DBPageBuilder>[const TestPageBuilder()],
            GlobalKey<NavigatorState>(),
            <String, Completer<Object?>>{},
            DBNavigationObserver(),
            <NavigatorObserver>[],
            null,
            reportPageUpdateToEngine: true,
          );

          expect(routerDelegate.currentConfiguration, isNull);
        },
      );

      test(
        'should return current visible page if reportPageUpdateToEngine '
        'is true and pages list is not empty',
        () async {
          const TestPageBuilder pageBuilder = TestPageBuilder();

          final DBPage page2 =
              await pageBuilder.buildPage(const Destination(path: Page2.path));

          final Map<String, Completer<Object?>> trackers =
              <String, Completer<Object?>>{};

          final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
            <DBPage>[TestPageBuilder.initialPage, page2],
            <DBPageBuilder>[const TestPageBuilder()],
            GlobalKey<NavigatorState>(),
            trackers,
            DBNavigationObserver(),
            <NavigatorObserver>[],
            null,
            reportPageUpdateToEngine: true,
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

    test(
      "should reset pages list to match the new initial page and it's history",
      () async {
        const DBPageBuilder initialPageBuilder =
            WidgetPageBuilder(child: Placeholder());

        final DBPage initialPage =
            await initialPageBuilder.buildPage(const Destination(path: '/'));

        final DBRouterDelegate routerDelegate = DBRouterDelegate(
          initialPage: initialPage,
          pageBuilders: <DBPageBuilder>[
            const WidgetPageBuilder(child: Placeholder()),
          ],
        );

        expect(routerDelegate.pages, contains(initialPage));

        await routerDelegate.reset(
          Page2.path,
          <DBPageBuilder>[const TestPageBuilder()],
          initialPageHistory: <Destination>[
            const Destination(path: Page1.path)
          ],
        );

        expect(routerDelegate.pages, hasLength(2));

        final List<DBPage> currentPages = routerDelegate.pages;

        expect(currentPages[1].destination.path, equals(Page2.path));
        expect(currentPages[0].destination.path, equals(Page1.path));
      },
    );
  });

  group(
    'closeUntil',
    () {
      test('should throw assert error if pages list is empty', () {
        final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
          <DBPage>[],
          <DBPageBuilder>[const TestPageBuilder()],
          GlobalKey<NavigatorState>(),
          <String, Completer<Object?>>{},
          DBNavigationObserver(),
          <NavigatorObserver>[],
          null,
        );

        expect(routerDelegate.pages, isEmpty);

        expect(
          () => routerDelegate.closeUntil(location: Page1.path),
          throwsA(isA<DBRouterDelegateCantClosePageException>()),
        );
      });

      test('show throw assert error if pages length is less than 2', () {
        final DBRouterDelegate routerDelegate = DBRouterDelegate(
          initialPage: TestPageBuilder.initialPage,
          pageBuilders: <DBPageBuilder>[const TestPageBuilder()],
        );

        expect(routerDelegate.pages, hasLength(equals(1)));

        expect(
              () => routerDelegate.closeUntil(location: Page2.path),
          throwsA(isA<DBRouterDelegateCantClosePageException>()),
        );
      });

      test(
        'show throw assert error if location is not in the pages list',
        () async {
          const TestPageBuilder pageBuilder = TestPageBuilder();

          final DBPage page2 =
              await pageBuilder.buildPage(const Destination(path: Page2.path));

          final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
            <DBPage>[TestPageBuilder.initialPage, page2],
            <DBPageBuilder>[pageBuilder],
            GlobalKey<NavigatorState>(),
            <String, Completer<Object?>>{},
            DBNavigationObserver(),
            <NavigatorObserver>[],
            null,
          );

          expect(routerDelegate.pages, hasLength(2));

          expect(
                () => routerDelegate.closeUntil(location: Page3.path),
            throwsA(isA<DBRouterDelegateCantClosePageException>()),
          );
        },
      );

      test(
        'should throw assert error if closeUntil used to close a single page',
        () async {
          const TestPageBuilder pageBuilder = TestPageBuilder();

          final DBPage page2 =
              await pageBuilder.buildPage(const Destination(path: Page2.path));

          final DBPage page3 =
              await pageBuilder.buildPage(const Destination(path: Page3.path));

          final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
            <DBPage>[TestPageBuilder.initialPage, page2, page3],
            <DBPageBuilder>[pageBuilder],
            GlobalKey<NavigatorState>(),
            <String, Completer<Object?>>{},
            DBNavigationObserver(),
            <NavigatorObserver>[],
            null,
          );

          expect(routerDelegate.pages, hasLength(equals(3)));

          expect(
            () => routerDelegate.closeUntil(location: page3.destination.path),
            throwsAssertionError,
          );
        },
      );

      test(
        'should remove pages until specified page is the current visible',
        () async {
          const TestPageBuilder pageBuilder = TestPageBuilder();

          final DBPage page2 =
              await pageBuilder.buildPage(const Destination(path: Page2.path));

          final DBPage page3 =
              await pageBuilder.buildPage(const Destination(path: Page3.path));

          final DBPage page4 =
              await pageBuilder.buildPage(const Destination(path: Page4.path));

          final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
            <DBPage>[TestPageBuilder.initialPage, page2, page3, page4],
            <DBPageBuilder>[pageBuilder],
            GlobalKey<NavigatorState>(),
            <String, Completer<Object?>>{},
            DBNavigationObserver(),
            <NavigatorObserver>[],
            null,
          );

          expect(routerDelegate.pages, hasLength(equals(4)));

          routerDelegate.closeUntil(location: Page2.path);

          expect(routerDelegate.pages, hasLength(equals(2)));

          expect(
            routerDelegate.pages,
            containsAllInOrder(<DBPage>[TestPageBuilder.initialPage, page2]),
          );
        },
      );
    },
  );

  group('closeUntilLast', () {
    test('should throw assert error if pages list is empty', () {
      final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
        <DBPage>[],
        <DBPageBuilder>[const TestPageBuilder()],
        GlobalKey<NavigatorState>(),
        <String, Completer<Object?>>{},
        DBNavigationObserver(),
        <NavigatorObserver>[],
        null,
      );

      expect(routerDelegate.pages, isEmpty);

      expect(
        routerDelegate.closeUntilLast,
        throwsAssertionError,
      );
    });

    test(
      'should remove no page if the current page is the only page in the stack',
      () async {
        const TestPageBuilder pageBuilder = TestPageBuilder();

        final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
          <DBPage>[TestPageBuilder.initialPage],
          <DBPageBuilder>[pageBuilder],
          GlobalKey<NavigatorState>(),
          <String, Completer<Object?>>{},
          DBNavigationObserver(),
          <NavigatorObserver>[],
          null,
        );

        expect(routerDelegate.pages, hasLength(equals(1)));

        routerDelegate.closeUntilLast();

        expect(routerDelegate.pages, hasLength(equals(1)));

        expect(
          routerDelegate.pages,
          containsAllInOrder(<DBPage>[TestPageBuilder.initialPage]),
        );
      },
    );

    test(
      'should remove pages until the last page is visible',
      () async {
        const TestPageBuilder pageBuilder = TestPageBuilder();

        final DBPage page2 =
            await pageBuilder.buildPage(const Destination(path: Page2.path));

        final DBPage page3 =
            await pageBuilder.buildPage(const Destination(path: Page3.path));

        final DBPage page4 =
            await pageBuilder.buildPage(const Destination(path: Page4.path));

        final DBRouterDelegate routerDelegate = DBRouterDelegate.private(
          <DBPage>[TestPageBuilder.initialPage, page2, page3, page4],
          <DBPageBuilder>[pageBuilder],
          GlobalKey<NavigatorState>(),
          <String, Completer<Object?>>{},
          DBNavigationObserver(),
          <NavigatorObserver>[],
          null,
        );

        expect(routerDelegate.pages, hasLength(equals(4)));

        routerDelegate.closeUntilLast();

        expect(routerDelegate.pages, hasLength(equals(1)));

        expect(
          routerDelegate.pages,
          containsAllInOrder(<DBPage>[TestPageBuilder.initialPage]),
        );
      },
    );
  });
}

class _MockRoute extends Mock implements Route<Object?> {}
