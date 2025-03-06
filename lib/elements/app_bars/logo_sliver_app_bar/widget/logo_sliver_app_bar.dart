import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/blocs/blocs.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';
import 'package:omdk_repo/omdk_repo.dart';

class OMDKLogoSliverAppBar extends StatelessWidget {
  /// Create [OMDKLogoSliverAppBar] instance
  const OMDKLogoSliverAppBar({
    this.withLeading = true,
    this.leadingCallback,
    super.key,
    this.leadingIcon,
    this.customLogoPath,
    this.collapsedSize = 68,
    this.expandedSize = 170,
  });

  final bool withLeading;
  final IconAsset? leadingIcon;
  final VoidCallback? leadingCallback;
  final double collapsedSize;
  final double expandedSize;
  final String? customLogoPath;

  @override
  Widget build(BuildContext context) {
    return OMDKAnimatedAppBar(
      leading: withLeading
          ? IconButton(
              padding: const EdgeInsets.only(left: 20),
              enableFeedback: false,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onPressed: leadingCallback,
              icon: Image.asset(
                leadingIcon?.iconAsset ?? IconAsset.menu.iconAsset,
                color: Theme.of(context).colorScheme.outline,
                fit: BoxFit.contain,
                width: 22,
                height: 22,
              ),
            )
          : null,
      builder: (context, open) => Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Material(
                color: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 3,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _appBarLogo(
                    context,
                    open,
                    customLogoPath: customLogoPath,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      collapsedSize: collapsedSize,
      expandedSize: expandedSize,
    );
  }

  Widget? _appBarLogo(
    BuildContext context,
    double open, {
    String? customLogoPath,
  }) {
    if (customLogoPath != null && File(customLogoPath).existsSync()) {
      return Image.file(
        File(customLogoPath),
        height: 40,
      );
    }
    return Center(
      child: Image.asset(
        CompanyAssets.operaLogo.iconAsset,
        height: 40,
      ),
    );
  }


}
