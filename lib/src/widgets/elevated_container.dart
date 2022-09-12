import 'package:flutter/material.dart';

class ElevatedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final double blurRadius;
  final double offsetX;
  final double offsetY;
  const ElevatedContainer({
    required this.child,
    this.padding = const EdgeInsets.all(0),
    this.opacity = 0.18,
    this.blurRadius = 20.0,
    this.offsetX = 3.0,
    this.offsetY = 3.0,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, opacity),
              blurRadius: blurRadius,
              offset: Offset(offsetX, offsetY))
        ],
      ),
      child: child,
    );
  }
}
