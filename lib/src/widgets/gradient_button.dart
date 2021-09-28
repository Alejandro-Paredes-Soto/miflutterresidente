import 'package:flutter/material.dart';

import 'elevated_container.dart';

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
    return ElevatedContainer(
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onPressed,
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
                gradient: onPressed != null ? gradient : disabledGradient,
                borderRadius: borderRadius),
            child: child,
          ),
        ),
      ),
    );
  }
}
