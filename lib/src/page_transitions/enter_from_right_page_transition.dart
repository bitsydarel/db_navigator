import 'package:db_navigator/db_navigator.dart';
import 'package:db_navigator/src/db_page_route.dart';
import 'package:flutter/widgets.dart';

/// A implementation of [DBMaterialPageRoute].
///
/// That animate a page entering from right but does not animate it's exiting.
class EnterFromRightMaterialPageTransition extends DBMaterialPageRoute {
  /// Create a [EnterFromRightMaterialPageTransition].
  EnterFromRightMaterialPageTransition({
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
/// That animate a page entering from right but does not animate it's exiting.
class EnterFromRightCupertinoPageTransition extends DBCupertinoPageRoute {
  /// Create a [EnterFromRightMaterialPageTransition].
  EnterFromRightCupertinoPageTransition({
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
      begin: const Offset(1, 0), // start hidden from the right.
      end: Offset.zero,
    ).chain(CurveTween(curve: curve)).animate(animation),
    child: child,
  );
}
