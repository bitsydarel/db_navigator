import 'package:collection/collection.dart';
import 'package:db_navigator/db_navigator.dart';
import 'package:example/src/args_demo_screen.dart';
import 'package:example/src/nested/nested_home_screen.dart';
import 'package:example/src/regular_demo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Home screen of the example app.
class HomeScreen extends StatelessWidget {
  /// Path to this home screen.
  static const String path = '/';

  /// Create a [HomeScreen] from a const expression.
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 56, left: 8, right: 8),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              children: const <Widget>[
                _GridDemoItem(
                  demoName: 'Regular',
                  destination: RegularDemo.path,
                ),
                _GridDemoItem(demoName: 'Nested', destination: '/nested'),
                _GridDemoItem(
                  demoName: 'Result & Arguments',
                  destination: ArgsDemoScreen.path,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridDemoItem extends StatelessWidget {
  final String demoName;

  final String destination;

  const _GridDemoItem({
    required this.demoName,
    required this.destination,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        DBRouterDelegate.of(context).navigateTo(location: destination);
      },
      child: Card(elevation: 2, child: Center(child: Text(demoName))),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('destination', destination))
      ..add(StringProperty('demoName', demoName));
  }
}

/// Home page builder.
class HomePageBuilder extends DBPageBuilder {
  /// Initial page.
  static final DBPage initialPage = DBPage(
    key: const ValueKey<String>(HomeScreen.path),
    destination: const Destination(path: HomeScreen.path),
    child: const HomeScreen(),
  );

  static final Map<String, DestinationPageFactory> _stack =
  <String, DestinationPageFactory>{
    HomeScreen.path: (Destination destination) {
      return SynchronousFuture<DBPage>(initialPage);
    },
    RegularDemo.path: (Destination destination) {
      return SynchronousFuture<DBPage>(
        DBPage(
          key: const ValueKey<String>(RegularDemo.path),
          destination: destination,
          child: const RegularDemo(),
        ),
      );
    },
    NestedHomeScreen.path: (Destination destination) {
      return SynchronousFuture<DBPage>(
        DBPage(
          key: ValueKey<String>(destination.path),
          destination: destination,
          child: const NestedHomeScreen(),
        ),
      );
    },
    ArgsDemoScreen.path: (Destination destination) {
      return SynchronousFuture<DBPage>(
        DBPage(
          key: ValueKey<String>(destination.path),
          destination: destination,
          child: ArgsDemoScreen(
            argument: destination.metadata.arguments?.toString(),
          ),
        ),
      );
    }
  };

  @override
  Future<DBPage> buildPage(Destination destination) {
    debugPrintThrottled(destination.path);

    final DestinationPageFactory? pageFactory = _stack[destination.path] ??
        _stack[_stack.keys.firstWhereOrNull(
          (String knownPath) => destination.path.startsWith(knownPath),
        )];

    if (pageFactory != null) {
      return pageFactory(destination);
    }

    return Future<DBPage>.error(PageNotFoundException(destination));
  }

  @override
  bool supportRoute(Destination destination) {
    return _stack.containsKey(destination.path) ||
        _stack.keys.any(
          (String knownPath) => destination.path.startsWith(knownPath),
        );
  }
}
