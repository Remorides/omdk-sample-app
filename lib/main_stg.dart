import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:omdk_sample_app/bootstrap.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig(
    name: 'DEV',
    color: Colors.green,
    variables: {
      'connectTimeout': const Duration(seconds: 30),
      'receiveTimeout': const Duration(seconds: 30),
      'sendTimeout': const Duration(seconds: 30),
      'logEnabled': true,
      'logRequest': true,
      'logRequestHeader': true,
      'logRequestBody': true,
      'logResponseHeader': true,
      'logResponseBody': true,
      'analyticsEnabled': false,
      'crashlyticsEnabled': false,
      //'firebaseOptions': DefaultFirebaseOptions.currentPlatform,
      'blocObserverEvent': false,
      'blocObserverError': false,
      'blocObserverChange': false,
      'blocObserverTransition': false,
    },
  );

  /// Setting SystemUIMode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  /// Set image cache
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 << 20;

  await bootstrap();
}
