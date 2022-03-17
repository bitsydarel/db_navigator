import 'package:db_navigator/db_navigator.dart';
import 'package:flutter/widgets.dart';

/// [DBRouterDelegate] extensions for [BuildContext]
extension DBRouterDelegateBuildContextExtensions on BuildContext {
  /// Close the current opened page.
  ///
  /// [useRootDelegate] to close a page on the root [DBRouterDelegate].
  ///
  /// [result] provide a result for the closing page.
  void closePage<T>({bool useRootDelegate = false, T? result}) {
    return DBRouterDelegate.of(this, root: useRootDelegate).close<T>(result);
  }

  /// Navigate to the following [location].
  ///
  /// [location] to navigate to. Must be unique in the current navigation stack.
  ///
  /// [arguments] to pass at the location.
  Future<T?> navigateTo<T>({
    required String location,
    Object? arguments,
    bool useRootDelegate = false,
  }) {
    return DBRouterDelegate.of(this, root: useRootDelegate)
        .navigateTo<T>(location: location, arguments: arguments);
  }
}
