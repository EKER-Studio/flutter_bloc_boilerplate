import 'package:intl/intl.dart';

/// Formats a [DateTime] as `yyyy-MM-dd HH:mm`.
String formatTodoDate(DateTime date) {
  return DateFormat('yyyy-MM-dd HH:mm').format(date);
}
