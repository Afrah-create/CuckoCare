import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/batch_facts.dart';
import '../domain/calendar_date.dart';
import '../domain/loss_record.dart';

String formatCount(int n) => NumberFormat.decimalPattern().format(n);

/// Neutral wording only: a number, no judgement.
String formatPct(double pct) {
  if (pct == 0) {
    return '0%';
  }
  return '${pct.toStringAsFixed(pct < 10 ? 1 : 0)}%';
}

String formatDay(CalendarDate day) =>
    DateFormat.yMMMd().format(DateTime(day.year, day.month, day.day));

String formatDayShort(CalendarDate day) =>
    DateFormat.MMMd().format(DateTime(day.year, day.month, day.day));

String birdsLabel(int n) => n == 1 ? '1 bird' : '${formatCount(n)} birds';

String lossKindLabel(LossKind kind) => switch (kind) {
  LossKind.died => 'Died',
  LossKind.culled => 'Culled',
  LossKind.missing => 'Missing',
  LossKind.other => 'Other',
};

IconData lossKindIcon(LossKind kind) => switch (kind) {
  LossKind.died => Icons.heart_broken_outlined,
  LossKind.culled => Icons.content_cut,
  LossKind.missing => Icons.search_off,
  LossKind.other => Icons.more_horiz,
};

String causeLabel(SuspectedCause cause) => switch (cause) {
  SuspectedCause.unknown => 'Not sure',
  SuspectedCause.diseaseSigns => 'Signs of illness',
  SuspectedCause.injury => 'Injury',
  SuspectedCause.heatOrCold => 'Heat or cold',
  SuspectedCause.predator => 'Predator',
  SuspectedCause.other => 'Other',
};

String closeReasonLabel(CloseReason reason) => switch (reason) {
  CloseReason.sold => 'Sold',
  CloseReason.cycleComplete => 'Cycle complete',
  CloseReason.flockLost => 'All birds lost',
  CloseReason.other => 'Other',
};
