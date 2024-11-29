import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final double height;
  final Color color;
  final BorderRadiusGeometry borderRadius;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double width;

  const Box({
    super.key,
    required this.height,
    required this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    required this.child,
    this.padding = const EdgeInsets.all(0.0),
    this.margin = const EdgeInsets.all(0.0),
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.6,
          colors: [
            color.withOpacity(0.7),
            color.withOpacity(0.0),
          ],
        ),
        borderRadius: borderRadius,
        border: Border.all(
          color: color.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
