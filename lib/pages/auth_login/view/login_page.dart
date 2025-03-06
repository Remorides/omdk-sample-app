import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_repo/omdk_repo.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/alerts/alerts.dart';
import 'package:omdk_sample_app/elements/elements.dart';
import 'package:omdk_sample_app/pages/auth_login/cubit/login_cubit.dart';


part 'login_view.dart';

/// Login page builder
class LoginPage extends StatelessWidget {
  /// Create [LoginPage] instance
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return LoginCubit(
          authRepo: RepositoryProvider.of<AuthRepo>(context),
        );
      },
      child: const _LoginView(),
    );
  }
}
