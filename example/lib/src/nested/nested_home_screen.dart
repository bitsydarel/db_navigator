import 'package:db_navigator/db_navigator.dart';
import 'package:example/src/nested/screen_page_builder.dart';
import 'package:flutter/material.dart';

/// Application Shell.
class NestedHomeScreen extends StatefulWidget {
  /// Nested home screen.
  static const String path = '/nested';

  /// Application Shell.
  const NestedHomeScreen({Key? key}) : super(key: key);

  @override
  _NestedHomeScreenState createState() => _NestedHomeScreenState();
}

class _NestedHomeScreenState extends State<NestedHomeScreen> {
  int _selectedTabIndex = 0;

  late DBRouterDelegate _tab1Delegate;
  late DBRouterDelegate _tab2Delegate;

  @override
  void initState() {
    super.initState();
    final ScreenPageBuilder pageBuilder1 = ScreenPageBuilder();

    _tab1Delegate = DBRouterDelegate(
      initialPage: ScreenPageBuilder.initialPage,
      pageBuilders: <DBPageBuilder>[pageBuilder1],
    );

    final ScreenPageBuilder pageBuilder2 = ScreenPageBuilder();

    _tab2Delegate = DBRouterDelegate(
      initialPage: ScreenPageBuilder.initialPage,
      pageBuilders: <DBPageBuilder>[pageBuilder2],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Router<Destination>(
        routerDelegate: _selectedTabIndex == 0 ? _tab1Delegate : _tab2Delegate,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (int index) {
          setState(() => _selectedTabIndex = index);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Feature 1',
            icon: Icon(Icons.arrow_left),
          ),
          BottomNavigationBarItem(
            label: 'Feature 2',
            icon: Icon(Icons.arrow_right),
          ),
        ],
      ),
    );
  }
}
