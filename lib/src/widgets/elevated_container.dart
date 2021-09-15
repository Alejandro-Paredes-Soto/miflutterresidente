import 'package:flutter/material.dart';

class ElevatedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const ElevatedContainer({
    this.child,
    this.padding = const EdgeInsets.all(0),
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.18),
              blurRadius: 20,
              offset: Offset(3, 3))
        ],
      ),
      child: child,
    );
  }
}
