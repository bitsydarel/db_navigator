import 'package:db_navigator/db_navigator.dart';
import 'package:example/src/nested/screen.dart';
import 'package:flutter/foundation.dart';

/// Screen page builder.
class ScreenPageBuilder extends DBPageBuilder {
  /// Initial page.
  static final DBMaterialPage initialPage = DBMaterialPage(
    key: const ValueKey<String>('screen'),
    destination: const Destination(path: '/screen'),
    child: const Screen(index: 0),
    customPageRouteFactory: (DBMaterialPage page) {
      return EnterFromRightExitToLeftMaterialPageTransition(page: page);
    },
  );

  @override
  Future<DBPage> buildPage(Destination destination) {
    final Object? arguments = destination.metadata.arguments;

    return SynchronousFuture<DBPage>(
      DBMaterialPage(
          key: ValueKey<String>('screen${arguments ?? ''}'),
          destination: destination,
          child: Screen(index: arguments is int ? arguments : 0),
          customPageRouteFactory: (DBMaterialPage page) {
            return EnterFromRightExitToLeftMaterialPageTransition(page: page);
          }),
    );
  }

  @override
  bool supportRoute(Destination destination) => true;
}
