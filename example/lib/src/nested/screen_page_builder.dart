import 'package:db_navigator/db_navigator.dart';
import 'package:example/src/nested/screen.dart';
import 'package:flutter/foundation.dart';

/// Screen page builder.
class ScreenPageBuilder extends DBPageBuilder {
  ///
  static final DBPage initialPage = DBPage(
    key: const ValueKey<String>('screen'),
    destination: const Destination(path: '/screen'),
    child: const Screen(index: 0),
  );

  @override
  Future<DBPage> buildPage(Destination destination) {
    final Object? arguments = destination.metadata.arguments;

    return SynchronousFuture<DBPage>(
      DBPage(
        key: ValueKey<String>('screen${arguments ?? ''}'),
        destination: destination,
        child: Screen(index: arguments is int ? arguments : 0),
      ),
    );
  }

  @override
  bool supportRoute(Destination destination) => true;
}
