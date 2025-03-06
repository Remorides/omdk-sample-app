import 'package:flutter/material.dart';
import 'package:omdk_sample_app/common/common.dart';

class OMDKBottomBarButton extends StatelessWidget {
  const OMDKBottomBarButton({
    required this.assetImage,
    this.onTap,
    this.labelText,
    this.withBadget = false,
  });

  final VoidCallback? onTap;
  final IconAsset assetImage;
  final bool withBadget;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    return Badge(
      backgroundColor: withBadget
          ? Theme.of(context).bottomNavigationBarTheme.unselectedItemColor
          : Theme.of(context).colorScheme.primaryContainer,
      label: withBadget
          ? Text(
              '$labelText',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : null,
      child: Material(
        type: MaterialType.transparency,
        shape: CircleBorder(
          side: BorderSide(
            color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor ??
                Colors.white,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(300),
          child: SizedBox.square(
            dimension: 40,
            child: Center(
              child: Image.asset(
                assetImage.iconAsset,
                color: Theme.of(context)
                        .bottomNavigationBarTheme
                        .unselectedItemColor ??
                    Colors.white,
                width: 17,
                height: 17,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
