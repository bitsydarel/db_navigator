import 'package:flutter/material.dart';
import 'package:db_navigator/src/destination.dart';

/// Transport Group Exchange representation of a [DBPage]
class DBPage extends MaterialPage<Object?> {
  /// The [Destination] from which this page was created.
  final Destination destination;

  /// Create a [DBPage] with [key] identifying the page, [destination] of the
  /// page and [child] to put at that destination.
  DBPage({
    required LocalKey key,
    required this.destination,
    required Widget child,
    String? restorationId,
  }) : super(
          key: key,
          name: destination.path,
          arguments: destination.metadata,
          child: child,
          maintainState: true,
          fullscreenDialog: false,
          restorationId: restorationId,
        );
}
