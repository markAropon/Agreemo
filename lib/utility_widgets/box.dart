import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Color color;
  final double height;
  final double width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? BorderColor;
  final BorderRadiusGeometry borderRadius;
  final Widget child;

  const Box({
    super.key,
    required this.height,
    required this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    required this.child,
    this.padding = const EdgeInsets.all(0.0),
    this.margin = const EdgeInsets.all(0.0),
    required this.width,
    this.BorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: BorderColor != null
            ? Border.all(
                color: BorderColor!,
                width: 1,
              )
            : null,
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
