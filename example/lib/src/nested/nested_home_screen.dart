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

  late final List<DBRouterDelegate> _tabDelegates;

  @override
  void initState() {
    super.initState();
    _tabDelegates = <DBRouterDelegate>[
      DBRouterDelegate(
        initialPage: ScreenPageBuilder.initialPage,
        pageBuilders: <DBPageBuilder>[ScreenPageBuilder()],
      ),
      DBRouterDelegate(
        initialPage: ScreenPageBuilder.initialPage,
        pageBuilders: <DBPageBuilder>[ScreenPageBuilder()],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DBNestedNavigationIndexedStack(
        delegates: _tabDelegates,
        currentViewIndex: _selectedTabIndex,
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
