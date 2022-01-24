import 'package:db_navigator/db_navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String unknownPath = '/unknown';

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
  const TestPageBuilder();

  static final DBPage initialPage = DBPage(
    key: const ValueKey<String>(Page1.path),
    destination: const Destination(path: Page1.path),
    child: const Page1(),
  );

  @override
  Future<DBPage> buildPage(Destination destination) async {
    final Widget child;

    switch (destination.path) {
      case Page1.path:
        child = const Page1();
        break;
      case Page2.path:
        child = const Page2();
        break;
      case Page3.path:
        child = const Page3();
        break;
      case Page4.path:
        child = const Page4();
        break;
      default:
        throw PageNotFoundException(destination);
    }

    return DBPage(
      key: ValueKey<String>(destination.path),
      destination: destination,
      child: child,
    );
  }

  @override
  bool supportRoute(Destination destination) {
    switch (destination.path) {
      case Page1.path:
        return true;
      case Page2.path:
        return true;
      case Page3.path:
        return true;
      case Page4.path:
        return true;
      default:
        return false;
    }
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

class Page3 extends StatelessWidget {
  static const String path = '/page3';

  const Page3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

class Page4 extends StatelessWidget {
  static const String path = '/page4';

  const Page4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

/// Widget page builder.
///
/// A [DBPageBuilder] that create a page with the [child] field
/// for any destination requested.
class WidgetPageBuilder extends DBPageBuilder {
  static const ValueKey<String> key = ValueKey<String>('widget-page');

  final Widget child;

  const WidgetPageBuilder({required this.child});

  @override
  Future<DBPage> buildPage(Destination destination) {
    return SynchronousFuture<DBPage>(
      DBPage(
        key: key,
        destination: destination,
        child: child,
      ),
    );
  }

  @override
  bool supportRoute(Destination destination) => true;
}
