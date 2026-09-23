/// Скорость в КБ/с так, как её пишет прототип: до тысячи — килобайты,
/// дальше — мегабайты с [digits] знаками после точки. Ноль — байты:
/// «0 КБ/с» читалось бы как «немного», а приёма нет совсем.
String formatRate(int kilobytesPerSecond, {int digits = 2}) =>
    kilobytesPerSecond == 0
    ? '0 Б/с'
    : kilobytesPerSecond < 1000
    ? '$kilobytesPerSecond КБ/с'
    : '${(kilobytesPerSecond / 1000).toStringAsFixed(digits)} МБ/с';

/// Доля 0…1 целыми процентами.
int percent(double fraction) => (fraction * 100).round();

/// Сыгранное время: «24 ч 10 мин», «6 ч», «40 мин».
String formatPlayed(Duration played) {
  final hours = played.inHours, minutes = played.inMinutes % 60;
  if (hours == 0) return '$minutes мин';
  return minutes == 0 ? '$hours ч' : '$hours ч $minutes мин';
}
