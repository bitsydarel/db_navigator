library db_navigator;

export 'package:db_navigator/src/db_page.dart';
export 'package:db_navigator/src/db_page_builder.dart';
export 'package:db_navigator/src/db_route_information_parser.dart';
export 'package:db_navigator/src/db_router_delegate.dart';
export 'package:db_navigator/src/destination.dart';
export 'package:db_navigator/src/destination_argument_converter.dart';
export 'package:db_navigator/src/exceptions.dart';
export 'package:db_navigator/src/scoped_page_builder.dart';

/// DB Navigator.
///
/// Provide api to navigate from one location to another.
abstract class DBNavigator {
  /// Navigate to the following [location].
  ///
  /// [location] to navigate to. Must be unique in the current navigation stack.
  ///
  /// [arguments] to pass at the location.
  Future<T?> navigateTo<T extends Object?>({
    required final String location,
    final Object? arguments,
  });

  /// Can close the current location.
  ///
  /// Should return true if the current location is not the initial.
  bool canClose();

  /// Close the current top most location.
  ///
  /// [result] to return when the location is closed.
  ///
  /// [result] is the value by which [navigateTo] future complete.
  void close<T extends Object?>([final T result]);

  /// Close the current top most location and every location after it until
  /// the last location is visible.
  ///
  /// [resultMap] of [String] location path to [Object] as result for screen.
  void closeUntilLast({final Map<String, Object?>? resultMap});

  /// Close the current top most location and
  /// every location after it until [location] is visible.
  ///
  /// [resultMap] of [String] location path to [Object] as result for screen.
  void closeUntil({
    required final String location,
    final Map<String, Object?>? resultMap,
  });
}
