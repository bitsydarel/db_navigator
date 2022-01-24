import 'package:db_navigator/src/db_page.dart';
import 'package:db_navigator/src/db_page_builder.dart';
import 'package:db_navigator/src/db_route_information_parser.dart';
import 'package:db_navigator/src/db_router_delegate.dart';
import 'package:db_navigator/src/destination.dart';
import 'package:db_navigator/src/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  testWidgets(
    'should return an instance '
    'of DBRouterDelegate if there is one in context',
    (WidgetTester tester) async {
      const ValueKey<String> key = ValueKey<String>(
        '_DBRouterDelegateLookUpWidget',
      );

      final WidgetPageBuilder pageBuilder = WidgetPageBuilder(
        child: _DBRouterDelegateLookUpWidget(key),
      );

      final DBPage initialPage = await pageBuilder.buildPage(
        const Destination(path: '/'),
      );

      final DBRouterDelegate delegate = DBRouterDelegate(
        pageBuilders: <DBPageBuilder>[pageBuilder],
        initialPage: initialPage,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: delegate,
          routeInformationParser: const DBRouteInformationParser(),
          routeInformationProvider: PlatformRouteInformationProvider(
            initialRouteInformation: const RouteInformation(location: ''),
          ),
        ),
      );

      final _DBRouterDelegateLookUpWidget result = tester.firstWidget(
        find.byKey(key),
      );

      expect(delegate, result.delegate);
    },
  );

  testWidgets(
    'should throw $DBRouterDelegateNotFoundException '
    'if there is no DBRouteDelegate in context',
    (WidgetTester tester) async {
      const ValueKey<String> key = ValueKey<String>('throwableKey');
      final _TestRouterDelegate delegate = _TestRouterDelegate(key);

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: const DBRouteInformationParser(),
          routerDelegate: delegate,
        ),
      );

      final _ThrowableWidget widget = tester.firstWidget(find.byKey(key));

      expect(
        widget.getDelegate,
        throwsA(
          isInstanceOf<DBRouterDelegateNotFoundException>(),
        ),
      );
    },
  );
}

//must_be_immutable ignored just for Testing
// ignore: must_be_immutable
class _DBRouterDelegateLookUpWidget extends StatelessWidget {
  late DBRouterDelegate delegate;

  _DBRouterDelegateLookUpWidget(Key key) : super(key: key);

  @override
  Widget build(BuildContext context) {
    delegate = DBRouterDelegate.of(context);
    return const SizedBox(height: 100, width: 100);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DBRouterDelegate>('delegate', delegate));
  }
}

class _TestRouterDelegate extends RouterDelegate<Destination>
    with
        // ignore: prefer_mixin
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<Destination> {
  final ValueKey<String> key;

  _TestRouterDelegate(this.key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (Route<dynamic> settings, dynamic result) => true,
      pages: <Page<Object>>[MaterialPage<Object>(child: _ThrowableWidget(key))],
    );
  }

  @override
  Future<void> setNewRoutePath(Destination configuration) {
    return SynchronousFuture<void>(null);
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();
}

//must_be_immutable ignored just for Testing
// ignore: must_be_immutable
class _ThrowableWidget extends StatelessWidget {
  _ThrowableWidget(Key key) : super(key: key);

  late BuildContext _buildContext;

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    return const SizedBox(height: 100, width: 100);
  }

  DBRouterDelegate getDelegate() {
    return DBRouterDelegate.of(_buildContext);
  }
}
