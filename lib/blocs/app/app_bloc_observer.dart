import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

/// custom observer to listen all blocs changes
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if ((FlavorConfig.instance.variables['blocObserverEvent'] as bool?) ??
        false) {
      log('${bloc.runtimeType} $event');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if ((FlavorConfig.instance.variables['blocObserverError'] as bool?) ??
        false) {
      log('${bloc.runtimeType} $error $stackTrace');
    }
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if ((FlavorConfig.instance.variables['blocObserverChange'] as bool?) ??
        false) {
      log('${bloc.runtimeType} $change');
    }
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if ((FlavorConfig.instance.variables['blocObserverTransition'] as bool?) ??
        false) {
      log('${bloc.runtimeType} $transition');
    }
  }
}
