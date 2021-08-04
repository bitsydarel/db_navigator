import 'dart:async';
import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/db_page_builder.dart';
import 'package:db_navigator/src/db_router_delegate.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:db_navigator/src/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

void main() {
  group(
    'instantiation',
    () {
      test(
        'should have initial page inside pages list after instantiating',
        () async {
          final DBRouterDelegate delegate = createDelegate();

          final DBPage result = delegate.pages.first;

          expect(initialPage, equals(result));
        },
      );

      test(
        'should have page builder instance inside '
        'pageBuilders list after instantiating',
        () {
          final DBRouterDelegate delegate = createDelegate();

          final DBPageBuilder result = delegate.pageBuilders.first;

          expect(pageBuilder, equals(result));
        },
      );

      test(
        'should throw assertion error if instantiated '
        'with an empty list of pageBuilder',
        () {
          expect(
            () => DBRouterDelegate(
              pageBuilders: <DBPageBuilder>[const RejectingPageBuilder()],
              initialPage: initialPage,
            ),
            throwsAssertionError,
          );
        },
      );

      test(
        "should throw assertion error if passed a pageBuilder list that can't "
        'build the initial page',
        () {
          expect(
            () => DBRouterDelegate(
              pageBuilders: <DBPageBuilder>[const RejectingPageBuilder()],
              initialPage: initialPage,
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

          final DBRouterDelegate delegate =
              createDelegate(navigatorKey: navigatorKey);

          expect(navigatorKey, equals(delegate.navigatorKey));
        },
      );
    },
  );

  group(
    'setNewRoutePath',
    () {
      const Destination unknownConfig = Destination(path: unknownPath);
      const Destination config = Destination(path: Page2.path);

      test(
        'should remain the same page stack and same popResultTracker entries '
        'if there is no pageBuilder found '
        'for incoming configuration',
        () async {
          final Map<String, Completer<Object>> popResultTracker =
              <String, Completer<Object>>{};

          final DBRouterDelegate delegate =
              createDelegate(popResultTracker: popResultTracker);

          final int pageCountBeforeSetNewRoutePath = delegate.pages.length;

          final int entriesCountBeforeSetNewRoutePath = popResultTracker.length;

          await delegate.setNewRoutePath(unknownConfig);

          expect(pageCountBeforeSetNewRoutePath, delegate.pages.length);

          expect(entriesCountBeforeSetNewRoutePath, popResultTracker.length);
        },
      );

      test(
        'should add a new entry to popResultTracker map '
        'if config is supported by one of pageBuilders',
        () async {
          const Destination config = Destination(path: Page2.path);

          final Map<String, Completer<Object>> popResultTracker =
              <String, Completer<Object>>{};

          final DBRouterDelegate delegate =
              createDelegate(popResultTracker: popResultTracker);

          await delegate.setNewRoutePath(config);

          expect(popResultTracker.length, 1);
        },
      );

      test(
        'should add a new page to the pages list '
        'if config is supported ',
        () async {
          final DBRouterDelegate delegate = createDelegate();

          await delegate.setNewRoutePath(config);

          expect(delegate.pages.length, 2);
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
          final DBRouterDelegate delegate = createDelegate();

          expect(() => delegate.navigateTo(location: ''), throwsAssertionError);

          expect(
            () => delegate.navigateTo(location: '    '),
            throwsAssertionError,
          );
        },
      );

      test(
        'should throw PageNotFoundException '
        'if no pageBuilders were found for location',
        () {
          final DBRouterDelegate delegate = createDelegate();

          expect(
            () => delegate.navigateTo(location: unknownPath),
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
        () {
          final DBRouterDelegate delegate = createDelegate()
            ..navigateTo(location: Page2.path);

          final int pageLengthBeforeClosing = delegate.pages.length;

          delegate.close();

          expect(delegate.pages.length, pageLengthBeforeClosing - 1);
        },
      );
    },
  );

  group(
    'onPopPage',
    () {
      test(
        'should return false if designated route didPop method '
        'returns false',
        () {
          final DBRouterDelegate delegate = createDelegate();

          final Route<dynamic> route = Route1();

          final bool result = delegate.onPopPage(route, null);

          expect(result, false);
        },
      );

      test(
        'should return true if designated route didPop method '
        'returns true',
        () {
          final DBRouterDelegate delegate = createDelegate();

          final Route<dynamic> route = Route2();

          final bool result = delegate.onPopPage(route, null);

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
          final DBRouterDelegate delegate = createDelegate();

          expect(delegate.currentConfiguration, isNull);
        },
      );

      test(
        'should return null if pages list is empty',
        () {
          final DBRouterDelegate delegate =
              createDelegate(reportsPageUpdateToEngine: true)..close();

          expect(delegate.currentConfiguration, isNull);
        },
      );
    },
  );

  group('reset', () {
    test(
        'should change the navigator page builders to different pageBuilder '
        'and initial page', () async {
      final DBRouterDelegate delegate = createDelegate();
      final DBPageBuilder previousPageBuilder = delegate.pageBuilders.first;
      final DBPage previousInitialPage = delegate.pages.first;
      final DBPageBuilder newPageBuilder = TestPageBuilder();

      await delegate.reset(Page2.path, <DBPageBuilder>[newPageBuilder]);

      expect(delegate.pageBuilders.first, isNot(previousPageBuilder));
      expect(delegate.pageBuilders.first, equals(newPageBuilder));

      expect(delegate.pages.first.name, equals(Page2.path));
      expect(delegate.pages.first.name,
          isNot(previousInitialPage.destination.path));
    });

    test('should reset pages list adding initial page', () async {
      final DBRouterDelegate delegate = createDelegate();
      final DBPageBuilder newPageBuilder = TestPageBuilder();

      expect(delegate.pages.first.name, equals(Page1.path));

      await delegate.reset(Page2.path, <DBPageBuilder>[newPageBuilder]);

      expect(delegate.pages.length, equals(1));
      expect(delegate.pages.first.name, equals(Page2.path));
    });
  });
}
