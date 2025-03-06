import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:omdk_sample_app/common/common.dart';

/// Custom keyboard actions class to extend classic behaviour
class CustomKeyboardActions extends StatelessWidget {
  /// Create [CustomKeyboardActions] instance
  const CustomKeyboardActions({
    required this.child,
    required this.focusNodes,
    this.disableScroll = false,
    this.autoScroll = false,
    this.keyboardBarColor,
    super.key,
  });

  /// Child widget
  final Widget child;

  /// List of focus node to autofocus next input field
  final List<FocusNode> focusNodes;

  /// Disable scroll widget when keyboard is visible
  final bool disableScroll;

  /// Allow widget to autoscroll widget on autofocus action
  final bool autoScroll;

  /// Add possibility to set custom color on keyboard bar
  final Color? keyboardBarColor;

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      autoScroll: autoScroll,
      disableScroll: disableScroll,
      config: KeyboardActionsConfig(
        keyboardBarColor:
            keyboardBarColor ?? Theme.of(context).colorScheme.surface,
        actions: <KeyboardActionsItem>[
          for (final FocusNode node in focusNodes)
            KeyboardActionsItem(
              focusNode: node,
              toolbarButtons: <Widget Function(FocusNode)>[
                (node) => GestureDetector(
                      onTap: () => node.unfocus(),
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(context.l.k_btn_done),
                      ),
                    ),
              ],
            ),
        ],
      ),
      child: child,
    );
  }
}
