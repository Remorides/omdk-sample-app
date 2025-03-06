import 'dart:io';
import 'dart:typed_data';

import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:omdk_api/omdk_api.dart';
import 'package:omdk_sample_app/common/route/routes.dart';
//import 'package:omdk_sample_app/pages/activities/activities.dart';
import 'package:omdk_sample_app/pages/pages.dart';
//import 'package:omdk_sample_app/pages/spare_parts/view/spare_part_group_details_page.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      default:
        return CupertinoPageRoute(builder: (_) => const SplashPage());
    }
  }
}
