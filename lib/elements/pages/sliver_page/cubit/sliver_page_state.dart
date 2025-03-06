part of 'sliver_page_cubit.dart';

final class SliverPageState extends Equatable {
  /// Create [SliverPageState] instance
  const SliverPageState({
    this.isDrawerExpanded = false,
    this.isRightExpanded = false,
    this.xOffsetDrawer = 0,
    this.initialXOffsetDrawer = -300,
    this.xOffsetRight = 0,
    this.initialXOffsetRightContainer = -300,
  });

  final bool isDrawerExpanded;
  final bool isRightExpanded;
  final double xOffsetDrawer;
  final double initialXOffsetDrawer;
  final double xOffsetRight;
  final double initialXOffsetRightContainer;

  SliverPageState copyWith({
    bool? isDrawerExpanded,
    bool? isRightExpanded,
    double? xOffsetDrawer,
    double? initialXOffsetDrawer,
    double? xOffsetRight,
    double? initialXOffsetRightContainer,
  }) {
    return SliverPageState(
      isDrawerExpanded: isDrawerExpanded ?? this.isDrawerExpanded,
      isRightExpanded: isRightExpanded ?? this.isRightExpanded,
      xOffsetDrawer: xOffsetDrawer ?? this.xOffsetDrawer,
      initialXOffsetDrawer: initialXOffsetDrawer ?? this.initialXOffsetDrawer,
      xOffsetRight: xOffsetRight ?? this.xOffsetRight,
      initialXOffsetRightContainer:
          initialXOffsetRightContainer ?? this.initialXOffsetRightContainer,
    );
  }

  @override
  List<Object> get props => [
        isDrawerExpanded,
        isRightExpanded,
        xOffsetDrawer,
        initialXOffsetDrawer,
        xOffsetRight,
        initialXOffsetRightContainer,
      ];
}
