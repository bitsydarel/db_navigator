import 'package:db_navigator/db_navigator.dart';
import 'package:db_navigator/src/db_page_route.dart';
import 'package:flutter/widgets.dart';

/// A implementation of [DBMaterialPageRoute].
///
/// That animate a page entering from left to exiting to left.
class EnterFromLeftExitToLeftMaterialPageTransitionRoute
    extends DBMaterialPageRoute {
  /// Create a [EnterFromLeftExitToLeftMaterialPageTransitionRoute].
  EnterFromLeftExitToLeftMaterialPageTransitionRoute({
    required DBMaterialPage page,
  }) : super(page: page);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _buildTransitions(context, animation, secondaryAnimation, child);
  }
}

/// A implementation of [DBCupertinoPageRoute].
///
/// That animate a page entering from left to exiting to left.
class EnterFromLeftExitToLeftCupertinoPageTransitionRoute
    extends DBCupertinoPageRoute {
  /// Create a [EnterFromLeftExitToLeftCupertinoPageTransitionRoute].
  EnterFromLeftExitToLeftCupertinoPageTransitionRoute({
    required DBCupertinoPage page,
  }) : super(page: page);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _buildTransitions(context, animation, secondaryAnimation, child);
  }
}

Widget _buildTransitions(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const Curve curve = Curves.easeIn;

  // context: The context in which the route is being built.
  //
  // animation: is executed when the page is first presented.
  //
  // secondaryAnimation: is executed when the there is a page that replace
  // this page as top most.
  //
  // child, the page contents, as returned by buildPage.
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(-1, 0), // start hidden from the left.
      end: Offset.zero,
    ).chain(CurveTween(curve: curve)).animate(animation),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1, 0), // end hidden to the left.
      ).chain(CurveTween(curve: curve)).animate(secondaryAnimation),
      child: child,
    ),
  );
}
