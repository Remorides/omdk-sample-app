import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/common/assets/company/company.dart';
import 'package:omdk_sample_app/common/assets/icons/icons.dart';
import 'package:omdk_sample_app/elements/elements.dart';

/// Login form class provide all required field to login
class OMDKSimplePage extends StatelessWidget {
  /// Create [OMDKSimplePage] instance
  OMDKSimplePage({
    required this.bodyPage,
    this.withAppbar = true,
    this.withBottomBar = true,
    this.withDrawer = true,
    this.withBackgroundImage = false,
    this.withKeyboardShortcuts = false,
    this.appBarTitle,
    this.focusNodeList = const [],
    super.key,
    this.leading,
    this.trailing,
    this.previousRoute,
    this.onPopCallback,
    this.onTapAddBTN,
    this.bottomBar,
    this.floatingActionButton,
    this.isForm = false,
    this.formKey,
    this.canPop = true,
    this.fullScreen = false,
    this.onPopInvokedWithResult,
  });

  final bool withAppbar;
  final bool withBottomBar;
  final bool withDrawer;
  final bool withBackgroundImage;
  final VoidCallback? onPopCallback;
  final bool withKeyboardShortcuts;
  final Widget bodyPage;
  final List<FocusNode> focusNodeList;
  final Widget? appBarTitle;
  final Widget? leading;
  final Widget? trailing;
  final String? previousRoute;
  final VoidCallback? onTapAddBTN;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool isForm;
  final GlobalKey<FormState>? formKey;
  final bool canPop;
  final bool fullScreen;
  final void Function(bool, dynamic)? onPopInvokedWithResult;

  final OMDKSimplePageCubit _cubit = OMDKSimplePageCubit();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: onPopInvokedWithResult,
        child: BlocBuilder<OMDKSimplePageCubit, OMDKSimplePageState>(
          bloc: _cubit,
          builder: (context, state) => Stack(
            children: [
              if (withDrawer)
                AnimatedContainer(
                  width: 300,
                  transform: Matrix4.translationValues(
                    (state.isDrawerExpanded ? 0 : state.initialXOffsetDrawer),
                    0,
                    0,
                  ),
                  duration: const Duration(milliseconds: 150),
                  child: const OMDKAnimatedDrawer(),
                ),
              AnimatedContainer(
                transform: Matrix4.translationValues(state.xOffsetDrawer, 0, 0),
                duration: const Duration(milliseconds: 150),
                decoration: withBackgroundImage
                    ? BoxDecoration(
                        image: withBackgroundImage
                            ? DecorationImage(
                                image: AssetImage(
                                  CompanyAssets.operaBackground.iconAsset,
                                ),
                                alignment: Alignment.bottomRight,
                                fit: BoxFit.contain,
                              )
                            : null,
                      )
                    : null,
                child: GestureDetector(
                  onTap: withDrawer && state.isDrawerExpanded
                      ? _cubit.collapseDrawer
                      : null,
                  child: AbsorbPointer(
                    absorbing: state.isDrawerExpanded,
                    child: _buildScaffold(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Scaffold _buildScaffold(BuildContext context) => Scaffold(
        appBar: withAppbar
            ? CupertinoNavigationBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                leading: withDrawer && !Navigator.of(context).canPop()
                    ? GestureDetector(
                        onTap: _cubit.expandDrawer,
                        child: const Icon(
                          Icons.menu_outlined,
                          size: 20,
                        ),
                      )
                    : leading,
                middle: appBarTitle,
                trailing: trailing,
                previousPageTitle: previousRoute,
              )
            : null,
        backgroundColor: Colors.transparent,
        body: isForm
            ? Form(key: formKey, child: _buildPage(context))
            : _buildPage(context),
        extendBody: true,
        bottomNavigationBar: !fullScreen && withBottomBar
            ? bottomBar ??
                OMDKBottomBar(
                  onTapAddBTN: onTapAddBTN,
                  buttons: _bottomButtons,
                )
            : null,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      );

  List<OMDKBottomBarButton> get _bottomButtons => [
        OMDKBottomBarButton(
          assetImage: IconAsset.searchButton,
          onTap: () => (),
        ),
        OMDKBottomBarButton(
          assetImage: IconAsset.addVideoFromCameraAsset,
          onTap: () => (),
        ),
        OMDKBottomBarButton(
          assetImage: IconAsset.helpAsset,
          onTap: () => (),
        ),
      ];

  Widget _buildPage(BuildContext context) {
    if (fullScreen) return bodyPage;
    if (kIsWeb) {
      return SafeArea(child: bodyPage);
    }
    return (Platform.isAndroid || Platform.isIOS) && withKeyboardShortcuts
        ? CustomKeyboardActions(
            focusNodes: focusNodeList,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: bodyPage,
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: bodyPage,
          );
  }
}
