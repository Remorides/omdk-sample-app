import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OMDKSimpleActionButton extends StatelessWidget {
  OMDKSimpleActionButton({
    this.onTapAddBTN,
    this.iconData = CupertinoIcons.plus,
  });

  final VoidCallback? onTapAddBTN;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTapAddBTN,
      shape: const CircleBorder(),
      child: Icon(iconData, size: 26),
    );
  }
}
