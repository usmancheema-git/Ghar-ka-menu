/// Date formatting helpers. Hand-rolled rather than pulling in `intl`, which
/// is not a project dependency (AGENT.md §1).
const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// `9 July 2026` — no leading zero on the day, as in the S7 prototype.
String formatDayMonthYear(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
