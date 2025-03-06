import 'package:flutter/material.dart';
import 'package:omdk_sample_app/common/assets/assets.dart';
import 'package:omdk_sample_app/elements/alerts/alerts.dart';

/// Example splash screen page
class SplashPage extends StatelessWidget {
  /// Create [SplashPage] instance
  const SplashPage({
    super.key,
    this.alert,
  });

  /// Custom alert message to show because error in loading methods
  final OMDKAlert? alert;

  @override
  Widget build(BuildContext context) {
    if (alert != null) {
      OMDKAlert.show(
        context,
        alert!,
      );
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              CompanyAssets.operaBackground.iconAsset,
            ),
            alignment: Alignment.bottomRight,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
