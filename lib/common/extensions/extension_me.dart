import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';
import 'package:omdk_sample_app/blocs/auth/auth.dart';
import 'package:opera_api_auth/src/models/authenticated_user.dart';

extension MeHelper on BuildContext {

  AuthenticatedUser get me => read<AuthBloc>().state.user;

  String? get myGuid => read<AuthBloc>().loggedUserGUID;

  String? get myFullName => read<AuthBloc>().state.user.fullName;

  String? get myRole => read<AuthBloc>().state.user.userProfile;

  Uint8List? get myPhoto {
    final myEntity =
        read<OperaUserRepo>().readLocalItemSync(itemID: myGuid!);
    return myEntity.fold(
      (entity) => entity.entity.thumbnailImage,
      (failure) => null,
    );
  }
}

extension FindMeHelper on List<JUserParticipation>? {
  JUserParticipation? findMe(String? guid) =>
      this?.firstWhereOrNull((u) => u.user?.guid == guid);

  int? indexMe(String? guid) => this?.indexWhere((u) => u.user?.guid == guid);
}
