import 'package:collection/collection.dart';
import 'package:db_navigator/db_navigator.dart';
import 'package:db_navigator/src/ui/db_content_switcher_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// [DBNestedNavigationIndexedStack] allow to setup nested navigation for
/// the underlying [IndexedStack].
///
/// Every [delegates] in the list are the representation of every index entry.
class DBNestedNavigationIndexedStack extends StatefulWidget {
  /// Create [DBNestedNavigationIndexedStack].
  const DBNestedNavigationIndexedStack({
    required this.delegates,
    required this.currentViewIndex,
    this.handleDelegateDispose = true,
    Key? key,
  }) : super(key: key);

  /// List of [DBRouterDelegate] that will manage the navigation state of each
  /// index stack entry.
  final List<DBRouterDelegate> delegates;

  /// The current view index to show.
  final int currentViewIndex;

  /// [bool] enable or disable dispose for [delegates] when
  /// [DBNestedNavigationIndexedStack] is removed from the tree.
  final bool handleDelegateDispose;

  @override
  State<DBNestedNavigationIndexedStack> createState() {
    return _DBNestedNavigationIndexedStackState();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<DBRouterDelegate>('delegates', delegates))
      ..add(IntProperty('currentViewIndex', currentViewIndex))
      ..add(
        DiagnosticsProperty<bool>(
          'handleDelegateDispose',
          handleDelegateDispose,
        ),
      );
  }
}

class _DBNestedNavigationIndexedStackState
    extends State<DBNestedNavigationIndexedStack> with DBContentSwitcherMixin {
  @override
  void dispose() {
    if (widget.handleDelegateDispose) {
      // dispose all nested router delegate.
      widget.delegates.forEach((DBRouterDelegate routerDelegate) {
        routerDelegate.dispose();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.currentViewIndex,
      children: widget.delegates.mapIndexed((
        int index,
        DBRouterDelegate routerDelegate,
      ) {
        return buildContent(context, index, routerDelegate);
      }).toList(),
    );
  }
}
