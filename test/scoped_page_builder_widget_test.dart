import 'package:db_navigator/db_navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() {
    registerFallbackValue<Destination>(const Destination(path: '/'));
  });

  testWidgets(
    'should call onInitialDestinationEntered when initial page is pushed',
    (WidgetTester tester) async {
      final DBPage initialPage = DBPage(
        key: const ValueKey<String>('/'),
        destination: const Destination(path: '/'),
        child: const Placeholder(),
      );

      final _MockScopedPageBuilder mockPageBuilder = _MockScopedPageBuilder();

      when(() => mockPageBuilder.supportRoute(initialPage.destination))
          .thenReturn(true);

      when(() => mockPageBuilder.buildPage(initialPage.destination))
          .thenAnswer((_) => SynchronousFuture<DBPage>(initialPage));

      when(() => mockPageBuilder.initialDestination)
          .thenReturn(initialPage.destination);

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: DBRouterDelegate(
            initialPage: initialPage,
            pageBuilders: <DBPageBuilder>[mockPageBuilder],
          ),
          routeInformationParser: const DBRouteInformationParser(),
        ),
      );

      verify(mockPageBuilder.onInitialDestinationEntered).called(1);

      verifyNever(mockPageBuilder.onInitialDestinationExited);
    },
  );

  testWidgets(
    'should call onInitialDestinationExited when initial page is existed and '
    'feature completely closed',
    (WidgetTester tester) async {
      final _MockScopedPageBuilder mockPageBuilder = _MockScopedPageBuilder();

      final DBPage initialPage = DBPage(
        key: const ValueKey<String>('/second'),
        destination: const Destination(path: '/second'),
        child: const Placeholder(),
      );

      final _MatchDestination pathMatcher = _MatchDestination(
        (Destination destination) {
          return destination.path == initialPage.destination.path;
        },
      );

      when(
        () => mockPageBuilder.supportRoute(any(that: pathMatcher)),
      ).thenReturn(true);

      when(() => mockPageBuilder.buildPage(any(that: pathMatcher)))
          .thenAnswer((_) => SynchronousFuture<DBPage>(initialPage));

      when(() => mockPageBuilder.initialDestination)
          .thenReturn(initialPage.destination);

      when(() => mockPageBuilder.scopeName).thenReturn('test');

      when(
        () => mockPageBuilder.supportRoute(
          _AdditionalFeaturePageBuilder.initialPage.destination,
        ),
      ).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: DBRouterDelegate(
            initialPage: _AdditionalFeaturePageBuilder.initialPage,
            pageBuilders: <DBPageBuilder>[
              mockPageBuilder,
              const _AdditionalFeaturePageBuilder(),
            ],
          ),
          routeInformationParser: const DBRouteInformationParser(),
        ),
      );

      final Router<Object> router = tester.firstWidget(
        find.byWidgetPredicate((Widget widget) {
          return widget is Router && widget.routerDelegate is DBRouterDelegate;
        }),
      );

      final DBRouterDelegate delegate = router.routerDelegate
          as DBRouterDelegate
        ..navigateTo(location: initialPage.destination.path);

      await tester.pumpAndSettle();

      delegate.close();

      await tester.pumpAndSettle();

      verify(mockPageBuilder.onInitialDestinationEntered).called(1);
      verify(mockPageBuilder.onInitialDestinationExited).called(1);
    },
  );

  testWidgets(
    'should not call onInitialDestinationExited when page from the same '
    'feature are pushed and initial page is in background',
    (WidgetTester tester) async {
      final DBPage initialPage = DBPage(
        key: const ValueKey<String>('/'),
        destination: const Destination(path: '/'),
        child: const Placeholder(),
      );

      final _MockScopedPageBuilder mockPageBuilder = _MockScopedPageBuilder();

      when(() => mockPageBuilder.supportRoute(initialPage.destination))
          .thenReturn(true);

      when(() => mockPageBuilder.buildPage(initialPage.destination))
          .thenAnswer((_) => SynchronousFuture<DBPage>(initialPage));

      when(() => mockPageBuilder.initialDestination)
          .thenReturn(initialPage.destination);

      when(() => mockPageBuilder.scopeName).thenReturn('test');

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: DBRouterDelegate(
            initialPage: initialPage,
            pageBuilders: <DBPageBuilder>[mockPageBuilder],
          ),
          routeInformationParser: const DBRouteInformationParser(),
        ),
      );

      final DBPage secondPage = DBPage(
        key: const ValueKey<String>('/second'),
        destination: const Destination(path: '/second'),
        child: const Placeholder(),
      );

      final _MatchDestination pathMatcher = _MatchDestination(
        (Destination destination) {
          return destination.path == secondPage.destination.path;
        },
      );

      when(() => mockPageBuilder.supportRoute(any(that: pathMatcher)))
          .thenReturn(true);

      when(() => mockPageBuilder.buildPage(any(that: pathMatcher)))
          .thenAnswer((_) => SynchronousFuture<DBPage>(secondPage));

      final Router<Object> router = tester.firstWidget(
        find.byWidgetPredicate((Widget widget) {
          return widget is Router && widget.routerDelegate is DBRouterDelegate;
        }),
      );

      (router.routerDelegate as DBRouterDelegate)
          .navigateTo(location: secondPage.destination.path);

      verify(mockPageBuilder.onInitialDestinationEntered).called(1);

      verifyNever(mockPageBuilder.onInitialDestinationExited);
    },
  );

  testWidgets(
    'should not call onInitialDestinationExited when dialog or page from '
    'navigator 1 are pushed and initial page is in background',
    (WidgetTester tester) async {
      final DBPage initialPage = DBPage(
        key: const ValueKey<String>('/'),
        destination: const Destination(path: '/'),
        child: const Placeholder(),
      );

      final _MockScopedPageBuilder mockPageBuilder = _MockScopedPageBuilder();

      when(() => mockPageBuilder.supportRoute(initialPage.destination))
          .thenReturn(true);

      when(() => mockPageBuilder.buildPage(initialPage.destination))
          .thenAnswer((_) => SynchronousFuture<DBPage>(initialPage));

      when(() => mockPageBuilder.initialDestination)
          .thenReturn(initialPage.destination);

      when(() => mockPageBuilder.scopeName).thenReturn('test');

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: DBRouterDelegate(
            initialPage: initialPage,
            pageBuilders: <DBPageBuilder>[mockPageBuilder],
          ),
          routeInformationParser: const DBRouteInformationParser(),
        ),
      );

      await tester.pumpAndSettle();

      final Router<Object> router = tester.firstWidget(
        find.byWidgetPredicate((Widget widget) {
          return widget is Router && widget.routerDelegate is DBRouterDelegate;
        }),
      );

      final DBRouterDelegate delegate =
          router.routerDelegate as DBRouterDelegate;

      showDialog<void>(
        context: delegate.navigatorKey.currentContext!,
        builder: (BuildContext context) => const SizedBox(height: 100),
      );

      verify(mockPageBuilder.onInitialDestinationEntered).called(1);

      verifyNever(mockPageBuilder.onInitialDestinationExited);
    },
  );
}

class _MockScopedPageBuilder extends Mock implements ScopedPageBuilder {}

class _AdditionalFeaturePageBuilder extends ScopedPageBuilder {
  static final DBPage initialPage = DBPage(
    key: const ValueKey<String>('/'),
    destination: const Destination(path: '/'),
    child: const Placeholder(),
  );

  const _AdditionalFeaturePageBuilder();

  @override
  Destination get initialDestination => initialPage.destination;

  @override
  String get scopeName => 'additional_feature';

  @override
  Future<DBPage> buildPage(Destination destination) {
    return SynchronousFuture<DBPage>(initialPage);
  }

  @override
  void onInitialDestinationEntered() {
    debugPrintThrottled(
      '_AdditionalFeaturePageBuilder#onInitialDestinationEntered',
    );
  }

  @override
  void onInitialDestinationExited() {
    debugPrintThrottled(
      '_AdditionalFeaturePageBuilder#onInitialDestinationExited',
    );
  }

  @override
  bool supportRoute(Destination destination) {
    return destination.path == initialPage.destination.path;
  }
}

class _MatchDestination extends Matcher {
  final bool Function(Destination) matchDestination;

  _MatchDestination(this.matchDestination);

  @override
  Description describe(Description description) {
    return description.add('destination are different');
  }

  @override
  bool matches(Object? item, Map<Object?, Object?> matchState) {
    return item is Destination && matchDestination(item);
  }
}
