import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';
import 'package:omdk_repo/omdk_repo.dart';

import 'package:omdk_sample_app/pages/user/cubit/user_cubit.dart';
import 'package:omdk_sample_app/common/enums/loading_status.dart';

part 'user_card.dart';

/// Helper class to show user Card
class UserDialogHelper {
  /// Shows a dialog with the user profile
  void showUserProfileDialog({
    required BuildContext context,
    required String guid,
    required OperaUserRepo operaUserRepo,
  }) {
    final userCubit = UserCubit(
      userRepo: operaUserRepo,
      omdkLocalData: context.read<OMDKLocalData>(),
      attachmentRepo: context.read<OperaAttachmentRepo>(),
      operaUtils: context.read<OperaUtils>(),
    );

    final dialogFuture = showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: userCubit,
          child: AlertDialog(
            title: const Text('Details'),
            content: const SizedBox(
              width: double.maxFinite,
              child: _UserProfileCard(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );

    userCubit.loadItem(guid);

    dialogFuture.then((_) {
      userCubit.close();
    });
  }
}
