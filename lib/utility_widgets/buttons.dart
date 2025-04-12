import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final Function()? onTap;
  final String label;
  final Color color;
  final Color labelColor;
  final double Borderradius;

  const Buttons(
      {super.key,
      required this.onTap,
      required this.label,
      required this.color,
      required this.labelColor,
      required this.Borderradius});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Bounce(
          onTap: onTap,
          tapDelay: const Duration(milliseconds: 150),
          longPressDuration: const Duration(microseconds: 0),
          child: Container(
            width: MediaQuery.of(context).size.width - 90,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(Borderradius)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                    color: labelColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8),
                softWrap: false,
              ),
            ),
          )),
    );
  }
}
