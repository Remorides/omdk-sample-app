import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';
import 'package:omdk_sample_app/elements/elements.dart';
import 'package:omdk_sample_app/pages/home/cubit/home_cubit.dart';
import 'package:omdk_sample_app/common/enums/loading_status.dart';

part 'home_menu.dart';

/// Example home page
class HomePage extends StatelessWidget {
  /// Create [HomePage] instance
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeCubit(context.read<OperaUserRepo>())..loadItems(),
      child: const _HomeMenu(),
    );
  }
}
