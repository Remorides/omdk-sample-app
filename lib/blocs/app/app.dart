import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';
import 'package:omdk_repo/omdk_repo.dart';
import 'package:omdk_sample_app/blocs/blocs.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

/// Create base [App] to instance repo layer
class App extends StatefulWidget {
  /// Build [App] instance
  const App({
    required this.defaultTheme,
    required this.authRepo,
    required this.omdkApi,
    required this.omdkLocalData,
    super.key,
  });

  /// [AuthRepo] instance
  final AuthRepo authRepo;

  /// [OMDKApi] instance
  final OMDKApi omdkApi;

  /// [OMDKLocalData] instance
  final OMDKLocalData omdkLocalData;

  final ThemeData defaultTheme;

  @override
  State<App> createState() => _AppState();
}

/// AppState builder
class _AppState extends State<App> {
  late final OperaAttachmentRepo _attachmentRepo;
  late final ConnectivityProvider _connectivityProvider;

  @override
  void dispose() {
    widget.authRepo.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _connectivityProvider = ConnectivityProvider();
    _attachmentRepo = OperaAttachmentRepo(
      OperaApiAttachment(widget.omdkApi.apiClient),
      entityIsarSchema: !kIsWeb ? AttachmentSchema : null,
      connectivityProvider: _connectivityProvider,
    );
  }

  //Get params from url
  final paramOTP = Uri.base.queryParameters['otp'];

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepo),
        RepositoryProvider.value(value: _attachmentRepo),
        RepositoryProvider.value(value: widget.omdkLocalData),
        RepositoryProvider<OperaUtils>(
          create: (_) => OperaUtils(
            localData: widget.omdkLocalData,
            authRepo: widget.authRepo,
          ),
        ),
        RepositoryProvider<OperaUserRepo>(
          create: (_) => OperaUserRepo(
            OperaApiUser(widget.omdkApi.apiClient),
            entityIsarSchema: !kIsWeb ? UserSchema : null,
            connectivityProvider: _connectivityProvider,
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          RouteObserverProvider(),
          ChangeNotifierProvider.value(value: _connectivityProvider),
          BlocProvider(
            create: (_) => AuthBloc(
              authRepo: widget.authRepo,
              localData: widget.omdkLocalData,
            )..add(
                paramOTP != null
                    ? ValidateOTP(otp: paramOTP!)
                    : RestoreSession(),
              ),
          ),
        ],
        child: AppView(theme: widget.defaultTheme),
      ),
    );
  }

  Locale getLocaleFromCode(String? inputLanguage) {
    final language = inputLanguage ?? Platform.localeName;
    if (language.length == 5) {
      return Locale(language.substring(0, 2).toLowerCase());
    } else if (language.length == 2) {
      return Locale(language.toLowerCase());
    } else {
      return const Locale('en');
    }
  }
}

///
class AppView extends StatefulWidget {
  /// create [AppView] instance
  const AppView({required this.theme, super.key});

  final ThemeData theme;

  @override
  State<AppView> createState() => _AppViewState();
}

/// App widget redirect user to login or home page due auth
class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return FlavorBanner(
      child: MaterialApp(
        onGenerateRoute: RouteManager.generateRoute,
        initialRoute: splashRoute,
        navigatorObservers: [RouteObserverProvider.of(context)],
        theme: widget.theme,
        navigatorKey: _navigatorKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('it'),
          Locale('es'),
          Locale('fr'),
        ],
        builder: (context, child) => BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            switch (state.status) {
              case AuthStatus.tokenExpired:

                /// Do nothing
                break;
              case AuthStatus.authenticated:
                await _navigator.pushNamedAndRemoveUntil(
                  homeRoute,
                  (route) => false,
                );
              case AuthStatus.unauthenticated:
                await _navigator.pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              case AuthStatus.unknown:

                /// Initial and default status of AuthStatus
                /// Wait for changes
                break;
              case AuthStatus.otpFailed:
                await _navigator.pushNamedAndRemoveUntil(
                  otpFailsRoute,
                  (route) => false,
                );
              case AuthStatus.conflicted:
                await _navigator.pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
            }
          },
          child: child,
        ),
      ),
    );
  }
}
