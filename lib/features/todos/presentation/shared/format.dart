/// Formats a [DateTime] as `yyyy-MM-dd HH:mm`.
String formatTodoDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final mo = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  final h = date.hour.toString().padLeft(2, '0');
  final mi = date.minute.toString().padLeft(2, '0');
  return '$y-$mo-$d $h:$mi';
}
