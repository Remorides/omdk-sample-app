import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/elements/elements.dart';

part 'home_menu.dart';


/// Example home page
class HomePage extends StatelessWidget {
  /// Create [HomePage] instance
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeMenu();
  }
}
