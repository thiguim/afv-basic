import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _percent = NumberFormat('#,##0.##', 'pt_BR');
final _date = DateFormat('dd/MM/yyyy', 'pt_BR');
final _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

String formatCurrency(double value) => _currency.format(value);
String formatPercent(double value) => '${_percent.format(value)}%';
String formatDate(DateTime dt) => _date.format(dt);
String formatDateTime(DateTime dt) => _dateTime.format(dt);
