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
    return RaisedButton(
      color: Colors.transparent,
      padding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Ink(
        padding: padding,
        decoration: BoxDecoration(
            gradient: onPressed != null ? gradient : disabledGradient,
            borderRadius: borderRadius),
        child: child,
      ),
      onPressed: onPressed,
    );
  }
}
