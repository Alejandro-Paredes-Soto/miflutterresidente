import 'package:flutter/material.dart';

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final Gradient disabledGradient;

  final Function onPressed;
  final BorderRadius borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.disabledGradient,
    this.onPressed,
    this.borderRadius,
    this.elevation = 2.0,
    this.padding = const EdgeInsets.all(0.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: onPressed,
      child: Ink(
        padding: padding,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.18),
                  blurRadius: 20,
                  offset: Offset(3, 3))
            ],
            gradient: onPressed != null ? gradient : disabledGradient,
            borderRadius: borderRadius),
        child: child,
      ),
    );
  }
}
