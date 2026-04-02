/// Formats minutes into human-readable time:
/// - If less than 60 minutes, show in minutes (e.g., "45m")
/// - If 60 or more, show in hours with decimal (e.g., "2.5h")
String formatTime(dynamic rawMinutes) {
  final minutes = (rawMinutes is num)
      ? rawMinutes.toDouble()
      : double.tryParse(rawMinutes.toString()) ?? 0;

  if (minutes < 60) {
    return '${minutes.toInt()}m';
  }
  final hours = minutes / 60;
  if (hours == hours.roundToDouble()) {
    return '${hours.toInt()}h';
  }
  return '${hours.toStringAsFixed(1)}h';
}
