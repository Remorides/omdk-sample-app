import 'package:flutter/cupertino.dart';
import 'package:omdk_sample_app/common/route/routes.dart';
import 'package:omdk_sample_app/pages/pages.dart';

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //final args = settings.arguments;
    switch (settings.name) {
      case splashRoute:
        return CupertinoPageRoute(
          settings: const RouteSettings(name: splashRoute),
          builder: (_) => const SplashPage(),
        );
      case loginRoute:
        return CupertinoPageRoute(
          settings: const RouteSettings(name: loginRoute),
          builder: (_) => const LoginPage(),
        );
      case homeRoute:
        return CupertinoPageRoute(
          settings: const RouteSettings(name: homeRoute),
          builder: (_) => const HomePage(),
        );
      case otpFailsRoute:
        return CupertinoPageRoute(
          settings: const RouteSettings(name: otpFailsRoute),
          builder: (_) => const OTPFailsPage(),
        );
      default:
        return CupertinoPageRoute(builder: (_) => const SplashPage());
    }
  }
}

