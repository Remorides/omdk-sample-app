part of 'date_time_cupertino_bloc.dart';

sealed class DateTimeCupertinoEvent {
  const DateTimeCupertinoEvent();
}

final class SetError extends DateTimeCupertinoEvent {
  SetError(this.errorText);

  final String? errorText;
}

final class SetDate extends DateTimeCupertinoEvent {
  SetDate(this.date);

  final DateTime? date;
}

final class ClearDate extends DateTimeCupertinoEvent {
  ClearDate(this.date);

  final DateTime? date;
}

final class DisableField extends DateTimeCupertinoEvent {}

final class EnableField extends DateTimeCupertinoEvent {}
