import 'package:flutter/material.dart';

class PageRouteTransition<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  PageRouteTransition({
    this.child,
    this.duration = const Duration(milliseconds: 300),
  })  : assert(true, ""),
        super(
          transitionDuration: duration,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secAnimation,
            child,
          ) {
            animation = CurvedAnimation(
              parent: animation,
              curve: Curves.linear,
            );
            return Container(
                child: FadeTransition(opacity: animation, child: child));
          },
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secAnimation,
          ) {
            return child;
          },
        );
}
