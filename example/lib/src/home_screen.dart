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
