import 'package:db_navigator/db_navigator.dart';
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
          child: GridView.count(
            crossAxisCount: 2,
            children: const <Widget>[
              _GridDemoItem(demoName: 'Regular', destination: RegularDemo.path),
              _GridDemoItem(demoName: 'Nested', destination: '/nested'),
              _GridDemoItem(demoName: 'Scoped', destination: '/scoped'),
              _GridDemoItem(
                demoName: 'Result & Arguments',
                destination: '/result&arg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// diagnostic_describe_all_properties
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
  };

  @override
  Future<DBPage> buildPage(Destination destination) {
    final DestinationPageFactory? pageFactory = _stack[destination.path];

    if (pageFactory != null) {
      return pageFactory(destination);
    }

    return Future<DBPage>.error(PageNotFoundException(destination));
  }

  @override
  bool supportRoute(Destination destination) {
    return _stack.containsKey(destination.path);
  }
}
