import 'package:db_navigator/db_navigator.dart';
import 'package:example/src/args_demo_screen.dart';
import 'package:example/src/home_screen.dart';
import 'package:example/src/nested/nested_home_screen.dart';
import 'package:example/src/regular_demo.dart';
import 'package:flutter/foundation.dart';

/// Home page builder.
class HomePageBuilder extends DBPageBuilder {
  /// Initial page.
  static final DBMaterialPage initialPage = DBMaterialPage(
    key: const ValueKey<String>(HomeScreen.path),
    destination: const Destination(path: HomeScreen.path),
    child: const HomeScreen(),
  );

  static final Map<String, AsyncDestinationPageFactory> _stack =
      <String, AsyncDestinationPageFactory>{
    HomeScreen.path: (Destination destination) {
      return SynchronousFuture<DBMaterialPage>(initialPage);
    },
    RegularDemo.path: (Destination destination) {
      return SynchronousFuture<DBMaterialPage>(
        DBMaterialPage(
          key: const ValueKey<String>(RegularDemo.path),
          destination: destination,
          child: const RegularDemo(),
        ),
      );
    },
    NestedHomeScreen.path: (Destination destination) {
      return SynchronousFuture<DBMaterialPage>(
        DBMaterialPage(
          key: ValueKey<String>(destination.path),
          destination: destination,
          child: const NestedHomeScreen(),
        ),
      );
    },
    ArgsDemoScreen.path: (Destination destination) {
      final String? argument = destination.metadata.arguments?.toString();

      return SynchronousFuture<DBMaterialPage>(
        DBMaterialPage(
          key: ValueKey<String>(destination.path),
          destination: destination,
          child: ArgsDemoScreen(argument: argument),
        ),
      );
    }
  };

  @override
  Future<DBPage> buildPage(Destination destination) {
    debugPrintThrottled(destination.path);

    final AsyncDestinationPageFactory? pageFactory = _stack[destination.path] ??
        (destination.path.startsWith(ArgsDemoScreen.path)
            ? _stack[ArgsDemoScreen.path]
            : null);

    if (pageFactory != null) {
      return pageFactory(destination);
    }

    return Future<DBMaterialPage>.error(PageNotFoundException(destination));
  }

  @override
  bool supportRoute(Destination destination) {
    return _stack.containsKey(destination.path) ||
        destination.path.startsWith(ArgsDemoScreen.path);
  }
}
