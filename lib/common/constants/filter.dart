const templateSyncFilter =
    '[{"property":"Template.Periodicity.Type","operation":"Equal","value":["None"]}]';
const schemaSyncFilter =
    '[{"property":"Enabled","operation":"Equal","value":["True"]}]';

String getScheduledTimedFilter(double monthPast, double monthFuture) {
  final greaterThanOrEqual = DateTime.now()
      .subtract(Duration(days: monthPast.round() * 30))
      .toUtc()
      .toIso8601String();

  final lessThanOrEqual = DateTime.now()
      .add(Duration(days: monthFuture.round() * 30))
      .toUtc()
      .toIso8601String();

  return '[{"property":"Dates.Scheduled.TimeStamp","operation":"GreaterThanOrEqual","value":["$greaterThanOrEqual"]},{"property":"Dates.Scheduled.TimeStamp","operation":"LessThanOrEqual","value":["$lessThanOrEqual"]}]';
}
