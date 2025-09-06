import 'package:flutter/material.dart';

// This is a reusable class for creating a fade transition between pages.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  FadePageRoute({required this.child})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              child,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(opacity: animation, child: child),
        );
}
