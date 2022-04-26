import 'package:collection/collection.dart';
import 'package:db_navigator/src/db_router_delegate.dart';
import 'package:db_navigator/src/ui/db_content_switcher_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// [DBNestedNavigationForTabBarView] allow to setup nested navigation for
/// the underlying [TabBarView].
///
/// Every [delegates] in the list are the representation of every tab entry.
class DBNestedNavigationForTabBarView extends StatefulWidget {
  /// Create [DBNestedNavigationForTabBarView].
  const DBNestedNavigationForTabBarView({
    required this.delegates,
    this.handleRouterDelegateDispose = true,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
    Key? key,
  }) : super(key: key);

  /// List of [DBRouterDelegate] that will manage the navigation state of each
  /// tabs.
  final List<DBRouterDelegate> delegates;

  /// [bool] enable or disable dispose for [delegates] when
  /// [DBNestedNavigationForTabBarView] is removed from the tree.
  final bool handleRouterDelegateDispose;

  /// [TabController] to pass to the underlying [TabBarView].
  final TabController? controller;

  /// {@macro flutter.material.scrollable.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  State<DBNestedNavigationForTabBarView> createState() {
    return _DBNestedNavigationForTabBarViewState();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<DBRouterDelegate>('delegates', delegates))
      ..add(
        DiagnosticsProperty<bool>(
          'handleDelegateDispose',
          handleRouterDelegateDispose,
        ),
      )
      ..add(DiagnosticsProperty<TabController?>('controller', controller))
      ..add(
        EnumProperty<DragStartBehavior>('dragStartBehavior', dragStartBehavior),
      )
      ..add(DiagnosticsProperty<ScrollPhysics?>('physics', physics));
  }
}

class _DBNestedNavigationForTabBarViewState
    extends State<DBNestedNavigationForTabBarView> with DBContentSwitcherMixin {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.controller,
      children: widget.delegates.mapIndexed(
        (int index, DBRouterDelegate routerDelegate) {
          return buildContent(context, index, routerDelegate);
        },
      ).toList(),
    );
  }
}
