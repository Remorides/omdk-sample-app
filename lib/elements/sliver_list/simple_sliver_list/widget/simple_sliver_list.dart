import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';
import 'package:omdk_repo/omdk_repo.dart';

class OMDKSimpleSliverList extends StatelessWidget {
  /// Create [OMDKSimpleSliverList] instance
  const OMDKSimpleSliverList({
    required this.children,
    required this.withSliverItems,
    this.appBar,
    super.key,
    this.anchor = 0,
    this.scrollController,
    this.sliverPadding = const EdgeInsets.all(18),
    this.sliverSeparator = const Space.vertical(8),
    this.withRefresh = false,
    this.refreshWidget,
    this.onRefresh,
  });

  final double anchor;
  final Widget? appBar;
  final List<Widget> children;
  final bool withSliverItems;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? sliverPadding;
  final Widget? sliverSeparator;
  final bool withRefresh;
  final Widget? refreshWidget;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CustomScrollView(
        anchor: anchor,
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (appBar != null) appBar!,
          if (withRefresh)
            CupertinoSliverRefreshControl(
              refreshIndicatorExtent: 180,
              refreshTriggerPullDistance: 180,
              builder: (context, mode, d1, d2, d3) => refreshWidget!,
              onRefresh:  onRefresh,
            ),
          if (withSliverItems)
            ...children
          else
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: sliverPadding ?? const EdgeInsets.all(18),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) => children[index],
                  itemCount: children.length,
                  separatorBuilder: (context, index) =>
                      sliverSeparator ?? const Space.vertical(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
