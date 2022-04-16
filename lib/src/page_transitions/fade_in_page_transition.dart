import 'package:db_navigator/db_navigator.dart';
import 'package:db_navigator/src/db_page_route.dart';
import 'package:flutter/material.dart';

/// A implementation of [DBMaterialPageRoute].
///
/// That animate a page entering from transparency to light
/// and exiting from light to transparency.
class FadeInMaterialPageTransitionRoute extends DBMaterialPageRoute {
  /// Create [FadeInMaterialPageTransitionRoute].
  FadeInMaterialPageTransitionRoute({
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
/// That animate a page entering from transparency to light
/// and exiting from light to transparency.
class FadeInCupertinoPageTransitionRoute extends DBCupertinoPageRoute {
  /// Create [FadeInCupertinoPageTransitionRoute].
  FadeInCupertinoPageTransitionRoute({
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

  return FadeTransition(
    opacity: Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: curve))
        .animate(animation),
    child: FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0)
          .chain(CurveTween(curve: curve))
          .animate(secondaryAnimation),
      child: child,
    ),
  );
}
