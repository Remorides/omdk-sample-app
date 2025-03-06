part of 'date_time_cupertino_bloc.dart';

final class DateTimeCupertinoState {
  const DateTimeCupertinoState({
    this.loadingStatus = LoadingStatus.initial,
    this.isEnabled = true,
    this.currentDate,
    this.errorText,
  });

  final LoadingStatus loadingStatus;
  final DateTime? currentDate;
  final String? errorText;
  final bool isEnabled;

  DateTimeCupertinoState copyWith({
    LoadingStatus? loadingStatus,
    DateTime? currentDate,
    String? errorText,
    bool? isEnabled,
  }) {
    return DateTimeCupertinoState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      isEnabled: isEnabled ?? this.isEnabled,
      currentDate: currentDate,
      errorText: errorText,
    );
  }
}
