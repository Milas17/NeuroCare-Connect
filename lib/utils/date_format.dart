import 'package:intl/intl.dart';

class DateFormatter {
  String dateConverter(String dateString, DateFormat format) {
    try {
      DateTime date = DateTime.tryParse(dateString) ?? DateTime.now();

      final formattedDate = format.format(date);

      return formattedDate;
    } catch (e) {
      final formattedDate = format.format(DateTime.now());

      return formattedDate;
    }
  }

  
}
