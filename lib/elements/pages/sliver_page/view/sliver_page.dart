import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/common/assets/assets.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';

/// Login form class provide all required field to login
class OMDKSliverPage extends StatelessWidget {
  /// Create [OMDKSliverPage] instance
  OMDKSliverPage({
    this.withAppBar = true,
    this.withBottomBar = true,
    this.withDrawer = true,
    this.withRightContainer = true,
    this.withBackgroundImage = false,
    this.withKeyboardShortcuts = false,
    this.focusNodeList = const [],
    this.pageItems = const [],
    super.key,
    this.leading,
    this.trailing,
    this.floatingActionButton,
    this.previousRoute,
    this.appBar,
    this.rightAnimatedContainer,
    this.bottomBar,
    this.withSliverItems = false,
    this.anchor = 0.0,
    this.onTapAddBTN,
    this.scrollController,
    this.sliverPadding,
    this.sliverSeparator,
    this.withRefresh = false,
    this.refreshWidget,
    this.onRefresh,
    this.isForm = false,
    this.formKey,
    this.canPop = true,
    this.onPopInvokedWithResult,
    this.onNotificationTap,
    this.rightContainerBadgetActive = false,
    this.rightContainerBadgeLabel,
  });

  final bool withKeyboardShortcuts;
  final bool withAppBar;
  final bool withBottomBar;
  final bool withDrawer;
  final bool withRightContainer;
  final bool withBackgroundImage;
  final List<FocusNode> focusNodeList;
  final Widget? leading;
  final Widget? trailing;
  final String? previousRoute;
  final List<Widget> pageItems;
  final Widget? appBar;
  final Widget? rightAnimatedContainer;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final bool withSliverItems;
  final double anchor;
  final VoidCallback? onTapAddBTN;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? sliverPadding;
  final Widget? sliverSeparator;
  final bool withRefresh;
  final bool isForm;
  final GlobalKey<FormState>? formKey;
  final Widget? refreshWidget;
  final Future<void> Function()? onRefresh;
  final bool canPop;
  final void Function(bool, dynamic)? onPopInvokedWithResult;
  final VoidCallback? onNotificationTap;
  final bool rightContainerBadgetActive;
  final String? rightContainerBadgeLabel;

  final OMDKSliverPageCubit _cubit = OMDKSliverPageCubit();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: onPopInvokedWithResult,
        child: BlocBuilder<OMDKSliverPageCubit, SliverPageState>(
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
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (details.delta.dx < 0) {
                        // Swiping in left direction.
                        if (state.isDrawerExpanded) {
                          _cubit.collapseDrawer();
                        }
                      }
                    },
                    child: const OMDKAnimatedDrawer(),
                  ),
                ),
              if (withRightContainer)
                AnimatedContainer(
                  transform: Matrix4.translationValues(
                    state.isRightExpanded
                        ? (MediaQuery.of(context).size.width -
                            state.xOffsetRight)
                        : MediaQuery.of(context).size.width,
                    0,
                    0,
                  ),
                  duration: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      // Swiping in right direction.
                      if (details.delta.dx > 0) {
                        if (state.isRightExpanded) {
                          _cubit.collapseRight();
                        }
                      }
                    },
                    child: rightAnimatedContainer,
                  ),
                ),
              AnimatedContainer(
                transform: Matrix4.translationValues(
                  state.isRightExpanded
                      ? (state.xOffsetDrawer - state.xOffsetRight)
                      : state.xOffsetDrawer,
                  0,
                  0,
                ),
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  image: withBackgroundImage
                      ? DecorationImage(
                          image: AssetImage(
                            CompanyAssets.operaBackground.iconAsset,
                          ),
                          alignment: Alignment.bottomRight,
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
                child: GestureDetector(
                  onTap: state.isDrawerExpanded
                      ? _cubit.collapseDrawer
                      : state.isRightExpanded
                          ? _cubit.collapseRight
                          : null,
                  onPanUpdate: (details) {
                    if (details.delta.dx > 0) {
                      // Swiping in right direction.
                      if (state.isRightExpanded) {
                        _cubit.collapseRight();
                      }
                    } else if (details.delta.dx < 0) {
                      // Swiping in left direction.
                      if (state.isDrawerExpanded) {
                        return _cubit.collapseDrawer();
                      }
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: state.isDrawerExpanded || state.isRightExpanded,
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

  Widget _buildScaffold(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: _keyboardShortcut(
          context,
          child: isForm
              ? Form(key: formKey, child: _buildPage(context))
              : _buildPage(context),
        ),
        extendBody: true,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        bottomNavigationBar: withBottomBar
            ? bottomBar ??
                OMDKBottomBar(
                  onTapAddBTN: onTapAddBTN,
                  buttons: _bottomButtons,
                )
            : null,
      );

  List<OMDKBottomBarButton> get _bottomButtons => [
        OMDKBottomBarButton(
          assetImage: IconAsset.qrcodeAsset,
        ),
        OMDKBottomBarButton(
          assetImage: IconAsset.nfcAsset,
        ),
        OMDKBottomBarButton(
          withBadget: rightContainerBadgetActive,
          labelText: rightContainerBadgeLabel,
          assetImage: IconAsset.notificationsAsset,
          onTap: withRightContainer
              ? _cubit.state.isRightExpanded
                  ? _cubit.collapseRight
                  : _cubit.expandRight
              : onNotificationTap,
        ),
      ];

  Widget _keyboardShortcut(
    BuildContext context, {
    required Widget child,
  }) =>
      (Platform.isAndroid || Platform.isIOS) && withKeyboardShortcuts
          ? CustomKeyboardActions(focusNodes: focusNodeList, child: child)
          : child;

  Widget _buildPage(BuildContext context) => SafeArea(
        top: false,
        bottom: false,
        child: OMDKSimpleSliverList(
          scrollController: scrollController,
          anchor: anchor,
          withSliverItems: withSliverItems,
          sliverPadding: sliverPadding,
          sliverSeparator: sliverSeparator,
          withRefresh: withRefresh,
          refreshWidget: refreshWidget,
          onRefresh: onRefresh,
          appBar: withAppBar
              ? appBar ??
                  OMDKLogoSliverAppBar(
                    withLeading: withDrawer,
                    leadingCallback: _cubit.expandDrawer,
                  )
              : null,
          children: pageItems,
        ),
      );
}
