library db_navigator;

export 'package:db_navigator/src/exceptions.dart';
export 'package:db_navigator/src/destination.dart';
export 'package:db_navigator/src/db_page.dart';
export 'package:db_navigator/src/db_page_builder.dart';
export 'package:db_navigator/src/db_route_information_parser.dart';
export 'package:db_navigator/src/db_router_delegate.dart';
export 'package:db_navigator/src/json_pojo_converter.dart';

/// DB Navigator.
///
/// Provide api to navigate from one location to another.
abstract class DBNavigator {
  /// Navigate to the following [location].
  ///
  /// [location] to navigate to, must not be null.
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
}
