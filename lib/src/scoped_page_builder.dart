import 'package:db_navigator/src/db_page_builder.dart';
import 'package:db_navigator/src/destination.dart';

/// A [DBPageBuilder] that provide api to be triggered when
/// the [initialDestination] is entered and existed.
abstract class ScopedPageBuilder extends DBPageBuilder {
  /// The name of the scope of this [ScopedPageBuilder].
  String get scopeName;

  /// The initial destination or entry point of this [DBPageBuilder].
  Destination get initialDestination;

  /// Create a new instance of [ScopedPageBuilder] in const expression.
  const ScopedPageBuilder();

  /// Called when the navigator navigated to the [initialDestination].
  void onInitialDestinationEntered();

  /// Called when the navigator navigated out of the [initialDestination].
  void onInitialDestinationExited();
}
