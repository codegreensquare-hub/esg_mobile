import 'package:intl/intl.dart';

String formatKRW(num price) {
  return '${NumberFormat('#,###').format(price)}원';
}
