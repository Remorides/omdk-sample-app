import 'package:bloc/bloc.dart';
import 'package:omdk_sample_app/common/common.dart';

part 'date_time_cupertino_event.dart';

part 'date_time_cupertino_state.dart';

class DateTimeCupertinoBloc
    extends Bloc<DateTimeCupertinoEvent, DateTimeCupertinoState> {
  DateTimeCupertinoBloc([DateTime? initialDate])
      : super(DateTimeCupertinoState(currentDate: initialDate)) {
    on<SetDate>(_onSetDate);
    on<SetError>(_onSetError);
    on<ClearDate>(_onClearDate);
    on<DisableField>(_onDisable);
    on<EnableField>(_onEnable);
  }

  Future<void> _onSetDate(
    SetDate event,
    Emitter<DateTimeCupertinoState> emit,
  ) async {
    if (event.date == null) return;
    return emit(state.copyWith(currentDate: event.date));
  }

  Future<void> _onSetError(
    SetError event,
    Emitter<DateTimeCupertinoState> emit,
  ) async {
    return emit(state.copyWith(errorText: event.errorText));
  }

  Future<void> _onClearDate(
    ClearDate event,
    Emitter<DateTimeCupertinoState> emit,
  ) async {
    return emit(state.copyWith());
  }

  Future<void> _onDisable(
    DisableField event,
    Emitter<DateTimeCupertinoState> emit,
  ) async {
    return emit(
      state.copyWith(
        isEnabled: false,
        currentDate: state.currentDate,
      ),
    );
  }

  Future<void> _onEnable(
    EnableField event,
    Emitter<DateTimeCupertinoState> emit,
  ) async {
    return emit(
      state.copyWith(
        isEnabled: true,
        currentDate: state.currentDate,
      ),
    );
  }
}
