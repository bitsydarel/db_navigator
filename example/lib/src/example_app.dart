import 'package:db_navigator/db_navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Example application.
class ExampleApp extends StatefulWidget {
  /// The initial page of the application.
  final DBPage initialPage;

  /// The application [Page] builder.
  final List<DBPageBuilder> pageBuilders;

  /// Create an example application with [initialPage] and [pageBuilders].
  const ExampleApp({
    required this.initialPage,
    required this.pageBuilders,
    Key? key,
  }) : super(key: key);

  @override
  _ExampleAppState createState() => _ExampleAppState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<DBPageBuilder>('pageBuilders', pageBuilders))
      ..add(DiagnosticsProperty<DBPage>('initialPage', initialPage));
  }
}

class _ExampleAppState extends State<ExampleApp> {
  late DBRouterDelegate _routerDelegate;

  late RouteInformationProvider _routeInformationProvider;

  @override
  void initState() {
    super.initState();
    _routeInformationProvider = PlatformRouteInformationProvider(
      initialRouteInformation:
          widget.initialPage.destination.toRouteInformation(),
    );

    _routerDelegate = DBRouterDelegate(
      pageBuilders: widget.pageBuilders,
      initialPage: widget.initialPage,
      reportPageUpdateToEngine: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: const DBRouteInformationParser(),
      routerDelegate: _routerDelegate,
      routeInformationProvider: _routeInformationProvider,
    );
  }
}
