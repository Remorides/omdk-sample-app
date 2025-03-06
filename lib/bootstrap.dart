import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:omdk_repo/omdk_repo.dart';
import 'package:omdk_sample_app/blocs/blocs.dart';

/// Bootstrap class load custom BlocObserver and create repoLayer instance
Future<void> bootstrap() async {
  // retrieve config map from instanced flavor
  //final fConfig = FlavorConfig.instance.variables;

  /// Initialize api client with environment api endpoint
  final omdkApi = OMDKApi(
    baseUrl: 'https://www.test.remorides.cloud/OperaAPI_V6_0/api',
  );

  final omdkLocalData = OMDKLocalData();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await omdkLocalData.fileManager.getApplicationDocumentsDir).path,
          ),
  );

  FlutterError.onError = (details) {
    omdkLocalData.logManager.log(
      LogType.error,
      details.exceptionAsString(),
      stackTrace: details.stack,
    );
  };

  Bloc.observer = AppBlocObserver();

  final IAuthApi<AuthSession> authApi = OperaApiAuth(omdkApi.apiClient);
  final authRepo = AuthRepo(
    authApi: authApi,
    localData: omdkLocalData,
    omdkApi: omdkApi,
  );

  //omdkLocalData.coordinateProvider.resumeStreamPosition();
  // Retrieve default theme data
  final defaultTheme = await omdkLocalData.themeManager.getTheme(
    ThemeEnum.light,
  );

  runApp(
    App(
      authRepo: authRepo,
      omdkApi: omdkApi,
      omdkLocalData: omdkLocalData,
      defaultTheme: defaultTheme,
    ),
  );
}
