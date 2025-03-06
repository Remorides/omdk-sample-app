import 'dart:async';

import 'package:firebase_core/firebase_core.dart'
    show Firebase, FirebaseOptions;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:omdk_repo/omdk_repo.dart';
import 'package:omdk_sample_app/blocs/blocs.dart';

/// Bootstrap class load custom BlocObserver and create repoLayer instance
Future<void> bootstrap() async {
  // retrieve config map from instanced flavor
  final fConfig = FlavorConfig.instance.variables;

  /// Initialize api client with environment api endpoint
  final omdkApi = OMDKApi(
    connectTimeout: fConfig['connectTimeout'] as Duration?,
    receiveTimeout: fConfig['receiveTimeout'] as Duration?,
    sendTimeout: fConfig['sendTimeout'] as Duration?,
    logEnabled: fConfig['logEnabled'] as bool?,
    logRequest: fConfig['logRequest'] as bool?,
    logRequestHeader: fConfig['logRequestHeader'] as bool?,
    logRequestBody: fConfig['logRequestBody'] as bool?,
    logResponseHeader: fConfig['logResponseHeader'] as bool?,
    logResponseBody: fConfig['logResponseBody'] as bool?,
  );

  final omdkLocalData = OMDKLocalData(
    analyticsEnabled: fConfig['analyticsEnabled'] as bool?,
    crashlyticsEnabled: fConfig['crashlyticsEnabled'] as bool?,
  );

  if ((fConfig['analyticsEnabled'] as bool? ?? false) ||
      (fConfig['crashlyticsEnabled'] as bool? ?? false)) {
    await Firebase.initializeApp(
      options: fConfig['firebaseOptions'] as FirebaseOptions?,
    );
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await omdkLocalData.fileManager.getApplicationDocumentsDir).path,
          ),
  );

  FlutterError.onError = (details) {
    if (fConfig['crashlyticsEnabled'] as bool? ?? false) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
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
    crashlyticsEnabled: fConfig['crashlyticsEnabled'] as bool? ?? false,
    analyticsEnabled: fConfig['analyticsEnabled'] as bool? ?? false,
  );

  //omdkLocalData.coordinateProvider.resumeStreamPosition();
  // Retrieve default theme data
  final defaultTheme = await omdkLocalData.themeManager.getTheme(
    ThemeEnum.light,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    App(
      authRepo: authRepo,
      omdkApi: omdkApi,
      omdkLocalData: omdkLocalData,
      defaultTheme: defaultTheme,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
