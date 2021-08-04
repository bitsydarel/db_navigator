import 'dart:async' show Completer;

import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/db_page_builder.dart';
import 'package:db_navigator/src/db_router_delegate.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final DBPageBuilder pageBuilder = TestPageBuilder();
final DBPage initialPage = TestPageBuilder.initialPage;
const String unknownPath = '/unknown';

DBRouterDelegate createDelegate({
  Map<String, Completer<Object?>>? popResultTracker,
  GlobalKey<NavigatorState>? navigatorKey,
  bool reportsPageUpdateToEngine = false,
}) {
  return DBRouterDelegate(
    pageBuilders: <DBPageBuilder>[pageBuilder],
    initialPage: initialPage,
    popResultTracker: popResultTracker,
    navigatorKey: navigatorKey,
    reportPageUpdateToEngine: reportsPageUpdateToEngine,
  );
}

/// A [DBPageBuilder] that does not support building a [DBPage].
///
/// [supportRoute] return false always.
///
/// [buildPage] throw an [UnsupportedError].
class RejectingPageBuilder extends DBPageBuilder {
  const RejectingPageBuilder();

  @override
  Future<DBPage> buildPage(Destination destination) {
    throw UnsupportedError("Oops can't build this page");
  }

  @override
  bool supportRoute(Destination destination) => false;
}

class TestPageBuilder implements DBPageBuilder {
  static final DBPage initialPage = DBPage(
    key: const ValueKey<String>(Page1.path),
    destination: const Destination(path: Page1.path),
    child: const Page1(),
  );

  @override
  Future<DBPage> buildPage(Destination destination) {
    return SynchronousFuture<DBPage>(
      DBPage(
        key: ValueKey<String>(destination.path),
        destination: destination,
        child: destination.path == Page1.path ? const Page1() : const Page2(),
      ),
    );
  }

  @override
  bool supportRoute(Destination destination) {
    return destination.path == Page1.path || destination.path == Page2.path;
  }
}

class Page1 extends StatelessWidget {
  static const String path = '/page1';

  const Page1([Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

class Page2 extends StatelessWidget {
  static const String path = '/page2';

  const Page2([Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

class Route1 extends Route<dynamic> {
  @override
  bool didPop(dynamic result) {
    super.didPop(result);
    return false;
  }
}

class Route2 extends Route<dynamic> {
  @override
  RouteSettings get settings => const RouteSettings(name: Page2.path);

  @override
  bool didPop(dynamic result) {
    super.didPop(result);
    return true;
  }
}

class SearchObjectPageBuilder extends DBPageBuilder {
  static const String key = 'pageToLookForObject';

  final Widget widgetToLookForObject;

  SearchObjectPageBuilder({required this.widgetToLookForObject});

  @override
  Future<DBPage> buildPage(Destination destination) {
    return SynchronousFuture<DBPage>(_createPage(destination));
  }

  @override
  bool supportRoute(Destination destination) => true;

  DBPage _createPage([Destination? destination]) {
    const ValueKey<String> valueKey = ValueKey<String>(key);

    return DBPage(
      key: valueKey,
      destination: destination ?? const Destination(path: '/'),
      child: widgetToLookForObject,
    );
  }
}
